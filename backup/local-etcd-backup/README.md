# Local ETCD Backkup
This backup method will automate the etcd backup on the master nodes.

THis method should only be used if other methods are not available.

It is reccomended to store these backups outside the cluser, OR backups the cluser nodes.

## 1. Configure the Backup Job

### 1.1 Create the namespace
```
oc new-project ocp-etcd-backup --description "Openshift Backup Automation Tool" --display-name "Backup ETCD Automation"
```

### 1.2 Create a service account
```
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: openshift-backup
  namespace: ocp-etcd-backup
  labels:
    app: openshift-backup
---
$ oc apply -f sa-etcd-bkp.yml
```

### 1.3 Create cluster role
```
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-etcd-backup
rules:
- apiGroups: [""]
  resources:
     - "nodes"
  verbs: ["get", "list"]
- apiGroups: [""]
  resources:
     - "pods"
     - "pods/log"
  verbs: ["get", "list", "create", "delete", "watch"]
---
$ oc apply -f cluster-role-etcd-bkp.yml
```

### 1.4 Create role binding
```
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: openshift-backup
  labels:
    app: openshift-backup
subjects:
  - kind: ServiceAccount
    name: openshift-backup
    namespace: ocp-etcd-backup
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-etcd-backup
---
$ oc apply -f cluster-role-binding-etcd-bkp.yml
```

### 1.5 Grant the SA Privileged access
```
oc adm policy add-scc-to-user privileged -z openshift-backup
```

### 1.6 Create backup cronjob

   - Update schedule to desired backup schedule

```
---
kind: CronJob
apiVersion: batch/v1beta1
metadata:
  name: openshift-backup
  namespace: ocp-etcd-backup
  labels:
    app: openshift-backup
spec:
  schedule: "@daily"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  jobTemplate:
    metadata:
      labels:
        app: openshift-backup
    spec:
      backoffLimit: 0
      template:
        metadata:
          labels:
            app: openshift-backup
        spec:
          containers:
            - name: backup
              image: "registry.redhat.io/openshift4/ose-cli"
              command:
                - "/bin/bash"
                - "-c"
                - oc get no -l node-role.kubernetes.io/master --no-headers -o name | xargs -I {} --  oc debug {} -- bash -c 'chroot /host sudo -E /usr/local/bin/cluster-backup.sh /home/core/backup/ && chroot /host sudo -E find /home/core/backup/ -type f -mmin +"1" -delete'
          restartPolicy: "Never"
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: "ClusterFirst"
          serviceAccountName: "openshift-backup"
          serviceAccount: "openshift-backup"
---

$ oc apply -f cronjob-etcd-bkp.yml
```

## 2. Test a Backup
### 2.1 Trigger a Manual backup job
```
oc create job --from=cronjob/openshift-backup manual-backup-(date +"%Y%m%d-%H%M")
```

### 2.2 Check backup status
```
oc logs -n ocp-etcd-backup manual-backup-<DATE FROM ABOVE>
```

