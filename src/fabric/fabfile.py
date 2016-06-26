# Deployment script for brikar web applications
# Alexander Shabanov, 2015-2016

from fabric.api import local, abort, run, put
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
  webapp_path = '/opt/webapp'
  if not exists(webapp_path):
    run('mkdir -p %s' % webapp_path)
    run('chown -R %s %s' % (run('whoami'), webapp_path))

  root_path = '/opt/webapp/%s' % app_name
  if not exists(root_path):
    print 'Creating %s...' % root_path
    run('mkdir -p %s' % root_path)

  var_path = '%s/var' % root_path
  if not exists(var_path):
    run('mkdir %s' % var_path)

  log_path = '%s/log' % var_path
  if not exists(log_path):
    run('mkdir %s' % log_path)

  props_path = '%s/app.properties' % var_path

  bin_path = '%s/bin' % root_path
  if not exists(bin_path):
    run('mkdir %s' % bin_path)

  app_path = '%s/app.jar' % bin_path

  # Copy files
  put('./server.sh', '%s/server.sh' % bin_path)
  put(local_healthcheck, '%s/healthcheck.sh' % bin_path)
  put(local_props, props_path)

  app_copy_required=True
  if exists(app_path):
    app_hash = run('cat %s | shasum' % app_path)
    print 'shasum(%s) = %s' % (app_path, app_hash)
    if app_hash == local_app_hash:
      print 'Local and remote app.jar hashes match each other, skipping copying'
      app_copy_required=False
  
  if app_copy_required:
    put(local_app, app_path)

  # Create deployment.txt which will contain deployment information
  put(StringIO('''Deployment of %s from %s completed successfully.
Local deployment time=%s
''' % (app_name, local_app_path, strftime("%Y-%m-%d %H:%M:%SZ", gmtime()))), '%s/deployment.txt' % root_path)

  # Create oom.sh - file which will be used by JVM on OOM condition
  put(StringIO('''# !/bin/sh
kill -9 `%s/process-pid`
''' % var_path), '%s/oom.sh' % bin_path)
  run('chmod +x %s/oom.sh' % bin_path)

  # Run the server
  run('export SERVICE_NAME=%s && export BASE_DIR=%s && export SERVER_START_ACTION=restart && bash %s/server.sh' % (app_name, root_path, bin_path))

  # Copy artifacts
  print 'Deployment of %s succeeded!' % app_name


#
# Stop entry point (finds remotely running application and tries to stop it)
#

def stop(app_name):
  print 'Trying to stop %s' % app_name
  root_path = '/opt/webapp/%s' % app_name
  run('export SERVICE_NAME=%s && export BASE_DIR=%s && export SERVER_START_ACTION=stop && bash %s/bin/server.sh' % (app_name, root_path, root_path))
  print 'Stop %s succeeded!' % app_name

#
# Restart entry point
#

def restart(app_name):
  print 'Trying to restart %s' % app_name
  root_path = '/opt/webapp/%s' % app_name
  run('export SERVICE_NAME=%s && export BASE_DIR=%s && export SERVER_START_ACTION=restart && bash %s/bin/server.sh' % (app_name, root_path, root_path))
  print 'Restart %s succeeded!' % app_name

#
# Undeploy entry point
#

def undeploy(app_name):
  print 'Trying to undeploy %s' % app_name
  stop(app_name)
  run('rm -rf /opt/webapp/%s' % app_name)
  print 'Undeploy %s succeeded' % app_name



