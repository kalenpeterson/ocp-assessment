# Setup Infra Nodes from an existing pool of workers

## Links

  * Infra Node Process
    * https://access.redhat.com/solutions/5034771
  * Custom MachineConfigPools
    * https://github.com/openshift/machine-config-operator/blob/master/docs/custom-pools.md



## Notes

  * No need to create seperate MachineConfigPools, this is a little more complicated.
  * MachineSets are ONLY for IPI, we cannot do this on Power



## Process

### 1. Label Nodes
Label all infra nodes
```
oc label node <NODE NAME> node-role.kubernetes.io/infra=
```

Label all app nodes
```
oc label node <NODE NAME> node-role.kubernetes.io/app=
```

Validate Labels
```
oc get nodes
```

### 2. Change Default Scheduler
Update the default node schedular to aply node selectors
```
oc get scheduler cluster -o yaml
oc patch scheduler cluster --type=merge -p '{"spec":{"defaultNodeSelector":"node-role.kubernetes.io/app="}}'
oc get scheduler cluster -o yaml
```

### 3. Deploy Custom MachineConfigPool
Note, this will be used in the case that we need cutom MachineConfigs. This guide does not yet do that.
```
oc apply -f ./infra-mcp.yaml
```

### 4. Move Resources to infra nodes
Use the following nodeSelector to move each resource to the infra nodes
```
spec:
  nodePlacement:
    nodeSelector:
      matchLabels:
        node-role.kubernetes.io/infra: ""
```

#### 4.1 Router
Patch the ingress Controllers
```
oc patch ingresscontroller/default -n  openshift-ingress-operator  --type=merge -p '{"spec":{"nodePlacement": {"nodeSelector": {"matchLabels": {"node-role.kubernetes.io/infra": ""}}}}}'
```

Scale ingress controllers to infra node count (3 in this case)
```
oc patch ingresscontroller/default -n openshift-ingress-operator --type=merge -p '{"spec":{"replicas": 3}}'
```

#### 4.1 Registry
```
oc patch configs.imageregistry.operator.openshift.io/cluster --type=merge -p '{"spec":{"nodeSelector": {"node-role.kubernetes.io/infra": ""}}}'
```

#### 4.2 Monitoring
Check the existing monitoring apps and apply this as needed
```
oc create -f cluster-monitoring-configmap.yaml
```

#### 4.3 Logging
This may require at least 6 infra nodes. See notes
  * https://access.redhat.com/solutions/5034771



