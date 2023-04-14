# Configure Splunk Log Forwarding

Reference
  - https://cloud.redhat.com/blog/forwarding-logs-to-splunk-using-the-openshift-log-forwarding-api

## Prerequisites
Before running these steps, the Splunk administrator must do the following:

  * Create an index in splunk named "openshift". If they name it something else, you will need to change it in the values.yaml below.
  * Create a rule to send messages with sourcetype of "openshift" to the index. If they user another name, change it in the values.yaml.
  * Generate an HEC Token with write permissions to this index
  * Provide you with the following Splunk Endpoint details
    * URI/Port
    * CA file if the endpoint is not already trusted by the installed ca trust bundle

## 1. Install Logging Operator
Install the RedHat OpenShift Logging Operator in the Console

Ensure it is installed to the "openshift-logging" Project/Namespace

## 2. Generate Splunk Certs
  - This must be placed in this exact location
  - You can generate your own
  - The CN must match this exactly
  - You should set a passphrase

NOTE: We are using a self-signed cert with a duration of 10years.
This certificate is only used to secure the logging traffic between the fluentd collector on each node,
and the splunk forwarder instances in the cluster. These certs will never be presented to anything else.
You may also get a signed certificate from your CA, but it may be a pain to renew later.

Create the Passphrase
```
openssl rand -hex 16
```

Create the Cert (And set the passphrase)
```
openssl req -x509 -newkey rsa:4096 \
	-keyout ./openshift-logforwarding-splunk/charts/openshift-logforwarding-splunk/files/custom-openshift-logging-fluentd.key \
	-out ./openshift-logforwarding-splunk/charts/openshift-logforwarding-splunk/files/custom-openshift-logging-fluentd.crt \
	-sha256 -days 3650 -subj '/CN=openshift-logforwarding-splunk.openshift-logging.svc'
```

## 3. Fill out values file
Fill out the (non-secret) values for yoru splunk endpoint in the values.yaml file. Like so
```
  splunk:
    # Specify Splunk Index and endpoint details
    index: openshift
    protocol: https
    hostname: company.mysplunkcloud.com
    port: 443
    insecure: false
    sourcetype: openshift
    source: openshift
```

## 4. Deploy Splunk Helm Chart
  - This will deploy the splunk forwarder and configure logforwarding
  - If anything is changed, run this again

Generate a Shared Key
```
openssl rand -hex 16
```

Deploy the Helm Chart (Insert secrets)
```
helm upgrade -i \
  --namespace=openshift-logging \
  openshift-logforwarding-splunk \
  openshift-logforwarding-splunk/charts/openshift-logforwarding-splunk/ \
  --values ./values.yml \
  --set forwarding.fluentd.sharedkey=<SET_SHARED_KEY>,forwarding.fluentd.passphrase=<SET_SSL_KEY_PASSPHRASE>,forwarding.splunk.token=<SPLUNK_TOKEN>,forwarding.splunk.source=<CLUSTER_NAME>
```

## 5. Deploy the Log Collectors
  - This will deploy the fluentd log collectors on each node and start sending logs to the splunk forwarder
```
oc create -f ./cluster-logging.yml
```

## 6. Validate
Within a few minutes, openshift logs should start appearing in Splunk in this index.