# Scaling the INgress Router pods

 - References
    https://access.redhat.com/solutions/5393521
    
Run the followig to scale the ingress routers to the desired number. Usually the number of workers.
```
oc patch -n openshift-ingress-operator ingresscontroller/default --patch '{"spec":{"replicas": 3}}' --type=merge
ingresscontroller.operator.openshift.io/default patched
```

Check the status
```
oc get -o yaml deployment/router-default -n openshift-ingress | grep replicas
```

