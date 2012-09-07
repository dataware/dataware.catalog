from __future__ import division
import json
import urllib
import OpenIDManager
from CatalogDB import *   
import logging
import AuthorizationModule
from framework import bottle
from framework.bottle import *
from google.appengine.ext.webapp.util import run_wsgi_app
from os.path import join, dirname

log = logging.getLogger( "console_log" )

@route( "/", method = "GET" )
@route( "/home", method = "GET" )
def user_home( ):
    try:
        user = _user_check_login()
    except RegisterException, e:
        redirect( "/register" )
    except LoginException, e:
        return user_error( e.msg )
    except Exception, e:
        return user_error( e )
   
    
    return template( "home_page_template", REALM=REALM, user=user);

#///////////////////////////////////////////////


@route( "/login", method = "GET" )
def user_openid_login():

    try:
        params = "resource_id=%s&redirect_uri=%s&state=%s" % \
            ( request.GET[ "resource_id" ],
              request.GET[ "redirect_uri" ], 
              request.GET[ "state" ], )
    except:
        params = ""
    
    try: 
        username = request.GET[ "username" ]    
    except: 
        username = None
     
    try:      
        provider = request.GET[ "provider" ]
    except: 
        return template( 
            "login_page_template", 
            REALM=REALM, user=None, params=params )    
    try:
        url = OpenIDManager.process(
            realm=REALM,
            return_to=REALM + "/checkauth?" + urllib.quote( params ),
            provider=provider,
            username=username,
            web_proxy=WEB_PROXY
        )
    except Exception, e:
        log.error( e )
        return user_error( e )
    
    #Here we do a javascript redirect. A 302 redirect won't work
    #if the calling page is within a frame (due to the requirements
    #of some openid providers who forbid frame embedding), and the 
    #template engine does some odd url encoding that causes problems.
    return "<script>self.parent.location = '%s'</script>" % (url,)
    

#///////////////////////////////////////////////

@route( "/logout" )
def user_openid_logout():
    
    _delete_authentication_cookie()
    redirect( ROOT_PAGE )

#///////////////////////////////////////////////    
    
@route( "/register", method = "GET" )
def user_register():
    
    #TODO: first check the user is logged in!
    try:
        user_id = _user_extract_id()
    except LoginException, e:
        return user_error( e.msg )
    except Exception, e:
        return user_error( e )
    
    errors = {}
    
    #if the user has submitted registration info, parse it
    try: 
        request.GET[ "submission" ]
        submission = True;
    except:
        submission = False
        
    if ( submission ): 
        #validate the user_name supplied by the user
        try:
            user_name = request.GET[ "user_name" ]
            email = request.GET[ "email" ]
            
            if ( not _valid_name( user_name ) ):
                errors[ 'user_name' ] = "Must be 3-64 legal characters"
            else: 
                log.info("name is valid...")
                match = db.user_fetch_by_name( user_name ) 
                if ( not match is None ):
                    errors[ 'user_name' ] = "That name has already been taken"                    
        except:
            errors[ 'user_name' ] = "You must supply a valid user name"
    
        #validate the email address supplied by the user
        try:
            email = request.GET[ "email" ]

            if ( not _valid_email( email ) ):
                errors[ 'email' ] = "The supplied email address is invalid"
            else: 
                match = db.user_fetch_by_email( email ) 
                if ( not match is None ):
                    errors[ 'email' ] = "That email has already been taken"
        except:
            errors[ 'email' ] = "You must supply a valid email"


        #if everything is okay so far, add the data to the database    
        if ( len( errors ) == 0 ):
            try:
                match = db.user_register( user_id, user_name, email) 
            except Exception, e:
                return user_error( e )

            #update the cookie with the new details
            _set_authentication_cookie( user_id, user_name )
            
            #return the user to the user_home page
            redirect( ROOT_PAGE )
    
    else:
        email = ""
        user_name = ""
        
    #if this is the first visit to the page, or there are errors

    return template( 
        "register_page_template",
        REALM=REALM,  
        user=None, 
        email=email,
        user_name=user_name,
        errors=errors ) 
    

    
@route( "/static/:filename" )
def user_get_static_file( filename ):
    return static_file( filename, root=os.path.join(appPath, 'static'))
    
#//////////////////////////////////////////////////////////
# OPENID SPECIFIC WEB-API CALLS
#//////////////////////////////////////////////////////////


class LoginException ( Exception ):
    
    def __init__(self, msg):
        self.msg = msg


#///////////////////////////////////////////////


class RegisterException ( Exception ):
    """Base class for RegisterException in this module."""
    
    pass

    
#///////////////////////////////////////////////

#///////////////////////////////////////////////


@route( "/error", method = "GET" )
def user_error( e ):
    
    return "A user_error has occurred: %s" % ( e )


#///////////////////////////////////////////////
    
#///////////////////////////////////////////////

    
def _user_check_login():

    #first try and extract the user_id from the cookie.
    #n.b. this can generate LoginExceptions
    user_id = _user_extract_id()

    if ( user_id ) :
        
        #we should have a record of this id, from when it was authenticated
        user = db.user_fetch_by_id( user_id )
        
        if ( not user ):
            _delete_authentication_cookie()
            raise LoginException( "We have no record of the id supplied. Resetting." )
        
        #and finally lets check to see if the user has registered their details
        if ( user.user_name is None):
            raise RegisterException()
        
        return user
        
    #if the user has made it this far, their page can be processed accordingly
    else:
        return None

def _user_extract_id():
    
    cookie = request.get_cookie( EXTENSION_COOKIE )
        
    #is the user logged in? First check we have a cookie...
    if cookie:
        #and that it contains suitably formatted data
        try:
            data = json.loads( cookie )
        except:
            _delete_authentication_cookie()
            raise LoginException( "Your login data is corrupted. Resetting." )
        
        #and then that it contains a valid user_id
        try:
            user_id =  data[ "user_id" ]
            return user_id
        except:
            _delete_authentication_cookie()
            raise LoginException( "You are logged in but have no user_id. Resetting." )
    else:
        return None
        
#///////////////////////////////////////////////
 
         
def _delete_authentication_cookie():
    
    response.delete_cookie( 
        key=EXTENSION_COOKIE,
    )
            
            
#///////////////////////////////////////////////


def _set_authentication_cookie( user_id, user_name = None ):
    
    #if the user has no "user_name" it means that they
    #haven't registered an account yet    
    if ( not user_name ):
        json = '{"user_id":"%s","user_name":null}' \
            % ( user_id, )
        
    else:
        json = '{"user_id":"%s","user_name":"%s"}' \
            % ( user_id, user_name )
         
    response.set_cookie( EXTENSION_COOKIE, json )
    
    
#//////////////////////////////////////////////////////////

@route( "/checkauth", method = "GET" )
def user_openid_authenticate():
    
    o = OpenIDManager.Response( request.GET )
    
    #check to see if the user logged in succesfully
    if ( o.is_success() ):
        
        user_id = o.get_user_id()
         
        #if so check we received a viable claimed_id
        if user_id:
            try:
                user = db.user_fetch_by_id( user_id )
                 
                #if this is a new user add them
                if ( not user ):
                    db.user_insert( o.get_user_id() )
                    user_name = None
                else :
                    user_name = user.user_name
                
                _set_authentication_cookie( user_id, user_name  )
                
            except Exception, e:
                return user_error( e )
            
            
        #if they don't something has gone horribly wrong, so mop up
        else:
            _delete_authentication_cookie()

    #else make sure the user is still logged out
    else:
        _delete_authentication_cookie()
        
    try:
        redirect_uri = "resource_request?resource_id=%s&redirect_uri=%s&state=%s" % \
            ( request.GET[ "resource_id" ], 
              request.GET[ "redirect_uri" ], 
              request.GET[ "state" ] )
    except:
        redirect_uri = REALM + ROOT_PAGE
    
    return "<script>self.parent.location = '%s'</script>" % ( redirect_uri, )
       
                
#///////////////////////////////////////////////


def _valid_name( str ):
    
    return re.search( "^[A-Za-z0-9 ']{3,64}$", str )

#///////////////////////////////////////////////


def _valid_email( str ):
    
    return re.search( "^[A-Za-z0-9%._+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$", str )


#///////////////////////////////////////////////
      
db = CatalogDB()
WEB_PROXY=""
ROOT_PAGE = "/"
REALM = "http://127.0.0.1:8080"
EXTENSION_COOKIE = "catalog_logged_in"
appPath = dirname(__file__)
app = bottle.default_app()

