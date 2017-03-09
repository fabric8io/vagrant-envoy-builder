#!/bin/sh
set -x 

yum -y update 
yum -y groupinstall 'Development Tools'

rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh https://centos7.iuscommunity.org/ius-release.rpm

yum -y update 

yum -y remove  git
# disable base repo for installation as it has older git version
yum -y --disablerepo=base,updates --enablerepo=ius install git

# make sure i dont miss any thing 
yum install -y wget cmake gmp-devel mpfr-devel libmpc-devel golang clang c-ares-devel

# Directory that will have envoy tools
mkdir -p /opt/envoy_env
chown -R vagrant:vagrant /opt/envoy_env