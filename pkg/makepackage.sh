#!/bin/sh
ROOT_DIR=~/dataware.catalog
PKG_DIR=$ROOT_DIR/pkg/package_files
cd $ROOT_DIR/src
rm -rf deb_dist
python setup.py --command-packages=stdeb.command sdist_dsc
cd deb_dist/dataware-catalog-0.1/debian
cp $PKG_DIR/control ./
cp $PKG_DIR/config ./
cp $PKG_DIR/postinst ./
cp $PKG_DIR/rules ./
cp $PKG_DIR/dirs ./
cd ..
#cp $PKG_DIR/mysql.sql ./
dpkg-buildpackage -rfakeroot -uc -us
cd debian/dataware-catalog
mkdir -p var/dataware-catalog
mkdir -p etc/dataware
mkdir -p var/log/dataware
chmod -R 777 var/log/dataware
mv ../../dataware-catalog/static ./var/dataware-catalog
mv ../../dataware-catalog/views  ./var/dataware-catalog
cp ../../dataware-catalog/__init__.py ./usr/share/pyshared/dataware-catalog
cp ../../dataware-catalog/catalog.cfg ./usr/share/pyshared/dataware-catalog
cp -R ../../dataware-catalog/framework ./usr/share/pyshared/dataware-catalog
cp -R ../../dataware-catalog/sqlparse ./usr/share/pyshared/dataware-catalog
cd ..
dpkg --build dataware-catalog dataware-catalog.deb
cp dataware-catalog.deb $ROOT_DIR 
