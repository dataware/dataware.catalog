#!/bin/sh
apt-get -y remove --purge dataware-catalog
rm -rf /usr/share/pyshared/dataware-catalog
apt-get -y --purge autoremove
ucf --purge /etc/dbconfig-common/dataware-catalog.conf
ucf --purge /etc/dataware/catalog_config.cfg
