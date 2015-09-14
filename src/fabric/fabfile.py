from __future__ import with_statement
from fabric.api import local, settings, abort, run, sudo
from fabric.contrib.console import confirm
from fabric.contrib.files import exists

# create /opt/webapp/<appname>/

def deploy(app_name):
  root_path = '/opt/webapp/%s' % app_name
  if not exists(root_path):
    print 'Creating %s...' % root_path
    sudo('mkdir -p %s' % root_path)
  print 'Deploying %s' % app_name
  run('touch /tmp/test')



