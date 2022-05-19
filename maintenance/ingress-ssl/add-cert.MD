# Configurating default Ingress SSL Certificate

  - References
    https://docs.openshift.com/container-platform/4.9/security/certificates/replacing-default-ingress-certificate.html

## Import Custom CA
Follow the instruction to import/trust a custom PKI

## Create the Secret
```
oc create secret tls default-ingress-cert --cert=</path/to/cert.crt> --key=</path/to/cert.key> -n openshift-ingress
```

## Update the Ingress Controller
```
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "default-ingress-cert"}}}' -n openshift-ingress-operator
```