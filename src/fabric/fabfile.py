from fabric.api import local, abort, run, sudo, put
from fabric.contrib.files import exists

from StringIO import StringIO
from time import gmtime, strftime

# Local Filesystem
from os.path import basename
from os.path import isfile

#
# Deployment Entry Point
#

def deploy(local_app_path):
  app_name = basename(local_app_path)
  if not app_name or app_name.isspace():
    abort('app_name inferred from %s is empty, enter full path without trailing slash, e.g. /home/deployer/targets/myapplication')

  print 'Using app_name=%s' % app_name

  # Check local application
  local_app = '%s/app.jar' % local_app_path
  local_props = '%s/app.properties' % local_app_path
  local_healthcheck = '%s/healthcheck.sh' % local_app_path
  local_files = [local_app, local_props, local_healthcheck]
  for f in local_files:
    if not isfile(f):
      abort('%s does not exist in local filesystem' % f)
  print 'Layout of %s looks good.' % local_app_path

  # Get hashes
  local_app_hash = local('cat %s | shasum' % local_app, capture=True)
  print 'shasum(%s) = %s' % (local_app, local_app_hash)

  # Create directory structure
  root_path = '/opt/webapp/%s' % app_name
  if not exists(root_path):
    print 'Creating %s...' % root_path
    sudo('mkdir -p %s' % root_path)

  var_path = '%s/var' % root_path
  if not exists(var_path):
    sudo('mkdir %s' % var_path)

  log_path = '%s/log' % var_path
  if not exists(log_path):
    print 'Creating log path %s' % log_path
    sudo('mkdir %s' % log_path)
  else:
    print 'No need to create log path %s' % log_path

  props_path = '%s/app.properties' % var_path

  bin_path = '%s/bin' % root_path
  if not exists(bin_path):
    sudo('mkdir %s' % bin_path)

  app_path = '%s/app.jar' % bin_path

  # Copy files
  put('./server.sh', '%s/server.sh' % bin_path, use_sudo=True)
  put(local_healthcheck, '%s/healthcheck.sh' % bin_path, use_sudo=True)
  put(local_props, props_path, use_sudo=True)

  app_copy_required=True
  if exists(app_path):
    app_hash = sudo('cat %s | shasum' % app_path)
    print 'shasum(%s) = %s' % (app_path, app_hash)
    if app_hash == local_app_hash:
      print 'Local and remote app.jar hashes match each other, skipping copying'
      app_copy_required=False
  
  if app_copy_required:
    put(local_app, app_path, use_sudo=True)

  # Create deployment.txt which will contain deployment information
  put(StringIO('''Deployment of %s from %s completed successfully.
Local deployment time=%s
''' % (app_name, local_app_path, strftime("%Y-%m-%d %H:%M:%SZ", gmtime()))), '%s/deployment.txt' % root_path, use_sudo=True)

  # Run the server
  sudo('export SERVICE_NAME=%s && export BASE_DIR=%s && export SERVER_START_ACTION=restart && bash %s/server.sh' % (app_name, root_path, bin_path))

  # Copy artifacts
  print 'Deployment of %s succeeded!' % app_name



