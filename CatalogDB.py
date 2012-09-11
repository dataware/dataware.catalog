import ConfigParser
import hashlib
import logging
import time
from google.appengine.ext import db

log = logging.getLogger( "console_log" )


class CatalogUser(db.Model):
    """Models a user of the dataware Catalog."""
    user_id = db.StringProperty()
    content = db.StringProperty()            
    user_name = db.StringProperty()
    email   =   db.StringProperty()        
    registered = db.FloatProperty()
    
class CatalogClient(db.Model):
    """Models a third party client registered with the dataware Catalog."""
    client_id = db.StringProperty()
    client_name = db.StringProperty()
    client_uri = db.StringProperty()
    description = db.StringProperty(multiline=True)
    logo_uri = db.StringProperty()
    web_uri = db.StringProperty()
    namespace = db.StringProperty()
    registered = db.FloatProperty()

class CatalogResource(db.Model):
    """Models the resources managed by this catalog."""
    resource_id = db.StringProperty()
    resource_name = db.StringProperty()
    resource_uri = db.StringProperty()
    description = db.StringProperty()
    logo_uri = db.StringProperty()
    web_uri = db.StringProperty()
    namespace  = db.StringProperty()
    registered = db.FloatProperty()

class CatalogInstall(db.Model):
    user_id = db.StringProperty()
    #resource_id = db.StringProperty() 
    resource = db.ReferenceProperty(CatalogResource)
    state = db.StringProperty()
    install_token = db.StringProperty()
    auth_code = db.StringProperty()
    created = db.FloatProperty()
    ctime = db.FloatProperty()

class CatalogProcessor(db.Model):
    user_id = db.StringProperty()
    client = db.ReferenceProperty(CatalogClient)
    state = db.StringProperty()
    resource = db.ReferenceProperty(CatalogResource)
    expiry_time = db.FloatProperty()
    query = db.TextProperty()
    checksum  = db.StringProperty()
    request_status = db.StringProperty()
    access_token = db.StringProperty()
    auth_code = db.StringProperty()
    created = db.FloatProperty()
    ctime = db.FloatProperty()   
   
class CatalogDB():
        
    def __init__(self):
        self.name = "CatalogDB"
        
    #////////////////////////////////////////////////////////////////////////////////////////////
    # CATALOG SPECIFIC CALLS
    #////////////////////////////////////////////////////////////////////////////////////////////
    
    def user_insert( self, user_id ):
        
        if user_id:
            
            log.info( 
                "%s %s: Adding user '%s' into database" 
                % ( self.name, "user_insert", user_id ) 
            );
            
            user = CatalogUser(user_id=user_id)
            user.put()
            return True;
        
        else:
            log.warning( 
                "%s %s: Was asked to add 'null' user to database" 
                % (  self.name, "user_insert", ) 
            );
            return False;

 
    #///////////////////////////////////////
    
                    
    def user_register( self, user_id, user_name, email ):
            
        if ( user_id and user_name and email ):
            
            log.info( 
                "%s %s: Updating user '%s' registration in database" 
                % ( self.name, "user_register", user_id ) 
            );
            
            q = db.Query(CatalogUser)
            q.filter('user_id =', user_id)
            user = q.get()
            user.user_name = user_name
            user.email = email
            user.registered = time.time()
            user.put()
            return True;
        
        else:
            log.warning( 
                "%s %s: Registration requested with incomplete details" 
                % (  self.name, "user_register", ) 
            );
            return False;     
        
                  
    #///////////////////////////////////////
              
    def user_fetch_by_id( self, user_id ) :

        if user_id :
           
            q = db.Query(CatalogUser)
            q.filter('user_id =', user_id)
            row = q.get()
    
            if not row is None:
                return row
            else :
                return None
        else :
            return None     
            
       
        
    #///////////////////////////////////////
    
    def user_fetch_by_name( self, user_name ) :
        if user_name :
            q = db.Query(CatalogUser)
            q.filter('user_name =', user_name)
            row = q.get()

            if not row is None:
                return row
            else :
                return None
        else :
            return None     
            
            
    #///////////////////////////////////////
              
    def user_fetch_by_email( self, email ) :

        if email :
            q = db.Query(CatalogUser)
            q.filter('email =', email)
            row = q.get()

            if not row is None:
                return row
            else :
                return None
        else :
            return None    
        

    #///////////////////////////////////////////////////////////////////////////////////////////
    
           
    def client_insert( self, client_id, client_name,
        client_uri, description, logo_uri, web_uri, namespace):
       
        client = CatalogClient(client_id=client_id, client_name=client_name,
        client_uri=client_uri, description=description, logo_uri=logo_uri, web_uri=web_uri, namespace=namespace, registered=time.time())
        
        client.put()
                
        
    #///////////////////////////////////////
    
    def client_fetch_by_id( self, client_id ) :
        if not client_id: return None
        
        q = db.Query(CatalogClient)
        q.filter('client_id =', client_id)
        
        return q.get()
        
    #///////////////////////////////////////
               
    def client_fetch_by_name( self, client_name ) :
        
        if not client_name: return None
        
        q = db.Query(CatalogUser)
        q.filter('client_name =', client_name)
        
        return q.get()
        
                      
    #////////////////////////////////////////////////////////////////////////////////////////////
    
    def resource_insert( self, resource_id, resource_name,
        resource_uri, description, logo_uri, web_uri, namespace):  
        resource = CatalogResource(resource_id=resource_id, resource_name=resource_name,
        resource_uri=resource_uri, description=description, logo_uri=logo_uri, web_uri=web_uri, namespace=namespace, registered=time.time())
        resource.put()
        
    #///////////////////////////////////////

              
    def resource_fetch_by_id( self, resource_id ) :
        
        if not resource_id: return None
        
        q = db.Query(CatalogResource)
        q.filter('resource_id =', resource_id)
        
        return q.get()
        
    
    #///////////////////////////////////////
              
    def resource_fetch_by_name( self, resource_name ) :
        
        if not resource_name: return None
        
        q = db.Query(CatalogResource)
        q.filter('resource_name =', resource_name)
        
        return q.get()

    
    #////////////////////////////////////////////////////////////////////////////////////////////
    def install_insert( self, user_id, resource,
        state, install_token, auth_code ):
        
        install = CatalogInstall( user_id=user_id, resource=resource,
        state=state, install_token=install_token, auth_code=auth_code, created=time.time(), ctime=time.time() )
        
        install.put()
        
        
    def install_fetch_by_id( self, user_id, resource_id ) :
        
        if not resource_id: return None
        q = db.Query(CatalogInstall)
        q.filter('user_id =', user_id) #.filter('resource.resource_id =', resource_id)
        installs = q.fetch(limit=1000)
       
        for install in installs:
            if (install.resource.resource_id == resource_id):
                return install
        
        return None   
    
    
    #///////////////////////////////////////
               
    def install_fetch_by_name( self, user_id, resource_name ) :

        if not resource_name: return None
       
        ciq = db.Query(CatalogInstall)
        ciq.filter('user_id =', user_id)
        row = ciq.get()
    
        return row
        
    #///////////////////////////////////////
              
    def install_fetch_by_auth_code( self, auth_code ) :
        
        if auth_code :
            q = db.Query(CatalogInstall)
            q.filter('auth_code =', auth_code)
            row = q.get()
            
            if not row is None:
                return row
            else :
                return None
        else :
            return None
        
        
    #////////////////////////////////////////////////////////////////////////////////////////////

    def processor_insert( self, 
        user_id, client, state, resource, 
        expiry_time, query_code, request_status ):
     
        #create a SHA checksum for the file
        checksum = hashlib.sha1( query_code ).hexdigest()
        
        processor = CatalogProcessor(user_id=user_id, client=client, state=state,resource=resource, expiry_time=float(expiry_time), query=query_code, request_status=request_status, created=time.time())
        
        processor.put()
        
    #///////////////////////////////////////

               
    def processor_fetch_by_id( self, processor_id ) :

        if processor_id :
           return CatalogProcessor().get_by_id(int(processor_id))
        else: 
           return None

    #///////////////////////////////////////

               
    def processor_fetch_by_auth_code( self, auth_code ) :

        if auth_code :
            q = db.Query(CatalogProcessor)
            q.filter('auth_code =', auth_code)
            row = q.get()
        
            if not row is None:
                return row
            else :
                return None
        else :
            return None              

    
    #///////////////////////////////////////
               
    def processor_update( self, processor_id, request_status, access_token, auth_code ) :

        if processor_id and access_token : 
        
            processor = CatalogProcessor().get_by_id(int(processor_id))
     
            if not processor is None:
                processor.request_status = request_status
                processor.access_token = access_token
                processor.auth_code = auth_code
                processor.put()
                return True
        else :
            log.warning( 
                "%s: attempting to update access request with insufficient parameters" 
                % self.name 
            )
            return False
      
        
    #///////////////////////////////////////
    
    def processor_delete( self, processor_id ) :

        if processor_id :
            processor = CatalogProcessor().get_by_id(int(processor_id))
            
            if not processor is None:
                processor.delete()
                log.debug( "%s: Access request %s deleted" % ( self.name, processor_id ) )
                return True
            else:
                log.warning( "%s: trying to delete unknown request %s" % (self.name, processor_id ) )
                return False
        else :
            log.warning( 
                "%s: attempting to delete an access request with insufficient parameters" 
                % self.name 
            )
            return False        
        

    #///////////////////////////////////////
          
    def processors_fetch( self, user_id = None ):
      
        if user_id:
            q = db.Query(CatalogProcessor)
            q.filter('user_id =', user_id)
            return q.fetch(limit=100)
        else:
            return None