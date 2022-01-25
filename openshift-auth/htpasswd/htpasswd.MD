
Create HTPasswd File
```
htpasswd -c -B -b ./htpasswd <user_name> <password>
```

Create Secret
```
oc create secret generic htpass-secret --from-file=htpasswd=./htpasswd -n openshift-config 
```

Create CR
```
oc apply -f </path/to/CR>
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
