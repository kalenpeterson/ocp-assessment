# Guide for OCP Metric Setup

## Notes

  * This is tested with 4.9+

## Configure Cluster Metrics

Check existing Cluster metrics
```
oc -n openshift-monitoring get configmap cluster-monitoring-config
```

Create the config map
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
```

```
oc apply -f cluster-monitoring-config.yaml
```

## Configure User Metrics
Check existing User metrics
```
oc -n openshift-user-workload-monitoring get configmap user-workload-monitoring-config
```

Create the config map
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-workload-monitoring-config
  namespace: openshift-user-workload-monitoring
data:
  config.yaml: |
```

```
oc apply -f user-workload-monitoring-config.yaml
```

## Metric Forwarding

  * https://access.redhat.com/solutions/6490491
  * https://docs.openshift.com/container-platform/4.9/monitoring/configuring-the-monitoring-stack.html#configuring_remote_write_storage_configuring-the-monitoring-stack


