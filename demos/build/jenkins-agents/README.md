# Jenkins Build

## x86

Create Namespace
```
oc new-project jenkins
```

Create Credential

Create Build
```
oc create -f ./build-jenkins-agent-x86.yml
```


