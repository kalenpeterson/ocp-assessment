
Create HTPasswd File
```
htpasswd -c -B -b ./htpasswd <user_name> <password>
```

Create Secret
```
oc create secret generic htpass-secret --from-file=htpasswd=./htpasswd -n openshift-config 
```

Edit the OAuth Config
```
oc edit oauth cluster
```

Add the HTPasswd auth option
**NOTE**: Ensure that you don't remove other authentication options, Like LDAP
```
---
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd_provider 
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
```

Test Login
```
oc login -u user
```

Create Groups and Rolebinding
```
oc adm groups new local-admins
oc adm groups add-users local-admins <local user>
oc adm policy add-cluster-role-to-group cluster-admin local-admins
```

Remove kubeadmin
```
oc delete secrets kubeadmin -n kube-system
```
