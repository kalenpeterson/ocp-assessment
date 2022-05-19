# Congigure a cluster-wide proxy

References
- https://docs.openshift.com/container-platform/4.9/networking/configuring-a-custom-pki.html

## Create Proxy with CA Cert

### Create ca-bundle
Add the X.509 encoded Certs to user-ca-bundle.yaml

Create the Secret
```
oc create -f user-ca-bundle.yaml
```

### Add the bundle to the cluster-wide proxy

Edic the openshift proxy config
```
oc edit proxy/cluster
```

Example
```
apiVersion: config.openshift.io/v1
kind: Proxy
metadata:
  name: cluster
spec:
  trustedCA:
    name: user-ca-bundle 
```