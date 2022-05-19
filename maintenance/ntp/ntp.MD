# Configure NTP on UPI INstalls

References
 - https://docs.openshift.com/container-platform/4.9/installing/install_config/installing-customizing.html


## Download/Install Butane on Bastion host

With curl, place in bin
```
curl https://mirror.openshift.com/pub/openshift-v4/clients/butane/latest/butane-aarch64 --output butane
```

## Create Manifests

Edit .bu files to use appropriate NTP servers

Create Manifests from them
```
butane 99-worker-ntp.bu -o ./99-worker-ntp.yaml
butane 99-master-ntp.bu -o ./99-master-ntp.yaml
```

Apply the Manifests
```
oc create -f ./99-worker-ntp.yaml
oc create -f ./99-master-ntp.yaml
```

## Monitor updates
```
oc get machineconfigpool
oc get machineconfigs
oc describe mcp worker
```