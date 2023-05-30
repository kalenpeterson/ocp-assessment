# Simple ETCD Backkup
This backup method will automate the etcd backup on the master nodes with a few destinations.

## Destinations
### Local
The local method will backup etcd to a directory on the master node's root volume.

### NFS
This NFS method will backup etcd to an NFS export from a master node.

NOTE: If etcd is encrypted, these backup methods will also export the keys required to decrypt.

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

## 2. Create backup cronjobs
This section has variations of the same cronjob that will backup in different ways or to different destinations.
Choose the method that is most suited to your use-case.

### 2.1 Local Master Node backup cronjob
This will create a backup of etcd to the root filesystem of ALL master nodes in the cluster. A recovery can be made from any master node.

   - Update schedule to desired backup schedule
   - Update the "mtime" parameter in the bash command to change the backup retention
     - Default is 14 days

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
                - oc get no -l node-role.kubernetes.io/master --no-headers -o name | xargs -I {} --  oc debug {} -- bash -c 'chroot /host sudo -E /usr/local/bin/cluster-backup.sh /home/core/backup/ && chroot /host sudo -E find /home/core/backup/ -type f -mtime +"14" -delete'
          restartPolicy: "Never"
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: "ClusterFirst"
          serviceAccountName: "openshift-backup"
          serviceAccount: "openshift-backup"
---

$ oc apply -f cronjob-etcd-bkp.yml
```

### 2.1 NFS backup cronjob
This will backup from one of the available master nodes to an NFS export.

   - Update the NFS Export in the script
   - Update schedule to desired backup schedule
   - Update the "mtime" parameter in the bash command to change the backup retention
     - Default is 14 days

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
                - oc get no -l node-role.kubernetes.io/master --no-headers -o name | head -n 1 |xargs -I {} -- oc debug {}  --to-namespace=ocp-etcd-backup -- bash -c 'chroot /host rm -rf /home/core/backup && chroot /host  mkdir /home/core/backup && chroot /host  sudo -E  mount -t nfs <nfs-server-IP>:<shared-path>    /home/core/backup && chroot /host sudo -E /usr/local/bin/cluster-backup.sh /home/core/backup && chroot /host sudo -E find /home/core/backup/ -type f -mtime +"14" -delete'
          restartPolicy: "Never"
          terminationGracePeriodSeconds: 30
          activeDeadlineSeconds: 500
          dnsPolicy: "ClusterFirst"
          serviceAccountName: "openshift-backup"
          serviceAccount: "openshift-backup"
---

$ oc apply -f cronjob-etcd-bkp.yml
```

## 3. Test a Backup
### 3.1 Trigger a Manual backup job
```
oc create job --from=cronjob/openshift-backup manual-backup-(date +"%Y%m%d-%H%M")
```

### 3.2 Check backup status
```
oc logs -n ocp-etcd-backup manual-backup-<DATE FROM ABOVE>
```

