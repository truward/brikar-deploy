
# Deployment Example

AWS:

```
fab deploy -i ~/Path/to/your.pem -H ubuntu@sample-ip-address.us-west-2.compute.amazonaws.com
```

Vagrant:

```
fab deploy:$HOME/opt/deploy/brikar-demo-website -i $HOME/vagrant/test-deploy-box/.vagrant/machines/default/virtualbox/private_key -H vagrant@127.0.0.1:2222
```

