
## 1. Configure LDAP IDP
  * https://urldefense.com/v3/__https://docs.openshift.com/container-platform/4.9/authentication/identity_providers/configuring-ldap-identity-provider.html*configuring-ldap-identity-provider__;Iw!!HUqgN_M!taZrM2Qj97v5kUMc5WzNcSj1mDEkc9sI1oMbNyqiLG2T-vaU4CPNz3Roi2RXnZwBNvhkYyq_JqxxqsA2sAu5e4ymmwM$ 

### 1.1 Create ldap-secret
```
oc create secret generic ldap-secret --from-literal=bindPassword=<secret> -n openshift-config 
```

### 1.2 Create CA if needed
  * This is required if your are using LDAPs
  * You should already have a CA setup at this point
  * If you have a system-wide proxy setup to trust CAs, omit this
```
oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config
```

### 1.3 Configure the OAuth Provider
NOTE: Check to see if there are any other auth providers enabled. If there are, creating this will overwite them.
If there are other oauth providers, edit this CR instead and add this to the list of providers
Edit and Create the LDAP CR
```
oc apply -f ldap-oauth-cr.yaml
```

### 1.4 Test Login
  * Note, check for the auth operator to restart

Anyone should be able to login now, but not see/do anything.

You can check via console or with the oc command
```
oc login -u <username>
```

## 2. Setup LDAP Sync
LDAP sync is done with a cronjob. We'll need to setup a namespace and job for it.

### 2.1 Create a Project for Syncing

```
oc new-project ldap-sync
```

### 2.1 Edit and Create the LDAP Sync secret

NOTE: If you need nested groups. See here for the configuration
  * https://urldefense.com/v3/__https://docs.openshift.com/container-platform/4.9/authentication/ldap-syncing.html*ldap-syncing-nesting_ldap-syncing-groups__;Iw!!HUqgN_M!taZrM2Qj97v5kUMc5WzNcSj1mDEkc9sI1oMbNyqiLG2T-vaU4CPNz3Roi2RXnZwBNvhkYyq_JqxxqsA2sAu5QQFrtP8$ 

  
  * Duplicate this from the LDAP IDP configuration
  * Omit the CA if it was configured cluster-wide
  * Make sure each group desired is mapped
  * Also, ensure each group is in the whitelist

```
oc create secret generic ldap-sync \
    --from-file=ldap-sync.yaml=ldap-sync.yaml \
    --from-file=whitelist.txt=whitelist.txt \
    --from-file=ca.crt=ca.crt
```

### 2.2 Setup the Role, ServiceAccount, and RoleBinding
```
oc create clusterrole ldap-group-sync \
    --verb=create,update,patch,delete,get,list \
    --resource=groups.user.openshift.io

oc create sa ldap-sync
oc adm policy add-cluster-role-to-user ldap-group-sync \
    -z ldap-sync \
    -n ldap-sync
```

### 2.3 Edit and create the Sync cronjob

```
oc create -f ./cron-ldap-sync.yaml
```

### 2.4 Test LDAP Sync
```
kubectl create job --from=cronjob/<name of cronjob> <name of job>
```

### 2.5 Create RoleBindings for each group
Cluster Admins
```
oc adm policy add-cluster-role-to-group cluster-admin <groupname>
```

Cluster ReadOnly
```
oc adm policy add-cluster-role-to-group cluster-reader <groupname>
```
