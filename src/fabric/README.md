
# Deployment Example

AWS:

```
fab deploy:$HOME/opt/deploy/brikar-demo-website -i ~/Path/to/your.pem -H ubuntu@sample-ip-address.us-west-2.compute.amazonaws.com
```

Vagrant:

```
fab deploy:$HOME/opt/deploy/brikar-demo-website -i $HOME/vagrant/test-deploy-box/.vagrant/machines/default/virtualbox/private_key -H vagrant@127.0.0.1:2222
```

# Other commands

Stop:

```
fab stop:brikar-demo-website -i /path-to/private_key -H vagrant@127.0.0.1:2222
```

Restart:

```
fab restart:brikar-demo-website -i /path-to/private_key -H vagrant@127.0.0.1:2222
```

Undeploy:

```
fab undeploy:brikar-demo-website -i /path-to/private_key -H vagrant@127.0.0.1:2222
```


