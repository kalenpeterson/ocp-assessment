# Configure ETCD Encryption

## References
  - https://docs.openshift.com/container-platform/4.11/security/encrypting-etcd.html

## 1. Enabling Encryption
```
oc patch apiserver -p '{"spec":{"encryption":{"type":"aescbc"}}}'
```

## 2. Check Encruption status
This can take up-to 20minutes to complete.

The result should show: "EncryptionCompleted"
```
oc get openshiftapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="Encrypted")]}{.reason}{"\n"}{.message}{"\n"}'
```

## 3. Disabling Encruption
To disable/decrypt etcd after encruption has been enabled.
```
oc patch apiserver -p '{"spec":{"encryption":{"type":"identity"}}}'
```

You can check the encryption status again after decrupting it. It should show "DecryptionCompleted"

