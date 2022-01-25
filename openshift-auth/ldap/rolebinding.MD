
Create IDP in UI
Notes:
  * Need to include search string
  * Test login after this
  * Check Pods after update
```
Option	Value
Name	Active Directory
URL	ldaps://domaincontroller/DC=demo,DC=openshift,DC=pub?sAMAccountName?sub
Bind DN	service-account
Bind Password	*********
Attributes:
ID	sAMAccountName
Preferred Username	sAMAccountName
Name	cn
Email	mail
```

Setup LDAP Sync
Notes:
  * Need project created first

```
oc new-project ldap-sync

oc create secret generic ldap-sync \
    --from-file=ldap-sync.yaml=ldap-sync.yaml \
    --from-file=whitelist.txt=whitelist.txt \
    --from-file=ca.crt=ca.crt

oc create clusterrole ldap-group-sync \
    --verb=create,update,patch,delete,get,list \
    --resource=groups.user.openshift.io

oc create sa ldap-sync
oc adm policy add-cluster-role-to-user ldap-group-sync \
    -z ldap-sync \
    -n ldap-sync

oc create -f ./cron-ldap-sync.yaml
```

Test LDAP Sync
```
kubectl create job --from=cronjob/<name of cronjob> <name of job>
```

Cluster Admins
```
oc adm policy add-cluster-role-to-group cluster-admin <groupname>
```

