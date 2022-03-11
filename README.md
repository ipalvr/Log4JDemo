<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Log4JDemo](#log4jdemo)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Log4JDemo
Code to create an EKS cluster and deploy vulnerable containers for Prisma Cloud Compute Demostrations

# Prerequisites
AWS account with and IAM account with Admin Access and an Access Key and Secret Key.  Configure the AWS CLI with your Access Key and Secret Key.

Terraform

# Create EKS Cluster

Clone repo to a working directory and cd to the eks-cluster directory
```
terraform init
```
If initialzation is successful, run
```
terraform plan out="filename"
```
Build cluster
```
terraform apply "filename"
```
Once the build is complete, update kubeconfig
```
aws eks --region "region" update-kubeconfig --name "cluster_name"
```
# Install Prisma Cloud Defender

Create twistlock namespace
```
kubectl create ns twistlock
```
Change your namespace context
```
kubectl config set-context $(kubectl config current-context) --namespace=twistlock
```
Download YAML directly from the Prisma Cloud Compute console and instal the Defender as a daemonset
```
kubectl apply -f daemonset.yaml
```
Confirm twistlock containers are runnning
```
kubectl get pods
```
# Create Collections, Policies, and WAAS Rules

Get token and add as a variable
```
curl -k -H "Content-Type: application/json" -X POST -d '{"username":"admin","password":"password"}' https://api.prismacloud.io/api/v22.01/authenticate
```
CSPM  
```
curl --request POST --url https://api.prismacloud.io/login --header 'content-type: application/json; charset=UTF-8' --data '{"customerName":"string","password":"string","prismaId":"string","username":"string"}'
```

# Add Collections

No error and no collection
```
curl -k -v POST -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"name":"Weib Log4Shell Demo - vul-app-1","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "https://api.prismacloud.io/api/v22.01/collections"
```
```
curl https://api.prismacloud.io/api/v22.01/collections -k -v POST -u "09c82544-0a30-4eb1-bdf9-d59e66fec44f"::"UkEEGT7peXhJzsPuTtAgFDes+HQ=" -H 'Content-Type: application/json' -d '{"name":"weib-collection","images":["ubuntu:18.04"]}'
```
```
curl -k -X POST -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app-2","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-2"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "https://192.168.1.43:8083//api/v21.08/collections"
```
Worked...
```
curl 'https://us-east1.cloud.twistlock.com/us-1-111573457/api/v1/collections?project=Central+Console' \
  -k \
  -X POST \
  -H 'Authorization: Bearer $TOKEN' \
  -H 'Content-Type: application/json' \
  -d \
'{"name":"Weib Test 5","containers":["*"],"hosts":["*"],"images":["amazon/amazon-ecs-agent:latest"],"labels":["*"],"appIDs":["*"],"functions":["*"],"namespaces":["*"],"accountIDs":["*"],"codeRepos":["*"],"clusters":["*"],"system":false,"color":"#7CC592"}'
```

# Add Runtime Rules
NEW_RULES='[{"name":"vul-app-2","previousName":"","collections":[{"name":"Log4Shell demo - vul-app-2"}],"advancedProtection":true,"processes":{"effect":"prevent","blacklist":[],"whitelist":[],"checkCryptoMiners":true,"checkLateralMovement":true,"checkParentChild":true,"checkSuidBinaries":true},"network":{"effect":"alert","blacklistIPs":[],"blacklistListeningPorts":[],"whitelistListeningPorts":[],"blacklistOutboundPorts":[],"whitelistOutboundPorts":[],"whitelistIPs":[],"skipModifiedProc":false,"detectPortScan":true,"skipRawSockets":false},"dns":{"effect":"prevent","blacklist":[],"whitelist":[]},"filesystem":{"effect":"prevent","blacklist":[],"whitelist":[],"checkNewFiles":true,"backdoorFiles":true,"skipEncryptedBinaries":false,"suspiciousELFHeaders":true},"kubernetesEnforcement":true,"cloudMetadataEnforcement":true,"wildFireAnalysis":"alert"},{"name":"vul-app-1","previousName":"","collections":[{"name":"Log4Shell demo - vul-app-1"}],"advancedProtection":true,"processes":{"effect":"alert","blacklist":[],"whitelist":[],"checkCryptoMiners":true,"checkLateralMovement":true,"checkParentChild":true,"checkSuidBinaries":true},"network":{"effect":"alert","blacklistIPs":[],"blacklistListeningPorts":[],"whitelistListeningPorts":[],"blacklistOutboundPorts":[],"whitelistOutboundPorts":[],"whitelistIPs":[],"skipModifiedProc":false,"detectPortScan":true,"skipRawSockets":false},"dns":{"effect":"alert","blacklist":[],"whitelist":[]},"filesystem":{"effect":"alert","blacklist":[],"whitelist":[],"checkNewFiles":true,"backdoorFiles":true,"skipEncryptedBinaries":false,"suspiciousELFHeaders":true},"kubernetesEnforcement":true,"cloudMetadataEnforcement":true,"wildFireAnalysis":"alert"}]'
ALL_RULES=$(curl -k -X GET -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/runtime/container" | jq --argjson nr "$NEW_RULES" ' .rules = $nr + .rules ')
curl -k -X PUT -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/runtime/container" -d "$ALL_RULES"

# Add WAAS Rule
NEW_RULES='[{"name":"vul-app-2","collections":[{"name":"Log4Shell demo - vul-app-2"}],"applicationsSpec":[{"appID":"app-0001","sessionCookieSameSite":"Lax","customBlockResponse":{},"banDurationMinutes":5,"certificate":{"encrypted":""},"tlsConfig":{"minTLSVersion":"1.2","metadata":{"notAfter":"0001-01-01T00:00:00Z","issuerName":"","subjectName":""},"HSTSConfig":{"enabled":false,"maxAgeSeconds":31536000,"includeSubdomains":false,"preload":false}},"dosConfig":{"enabled":false,"alert":{},"ban":{}},"apiSpec":{"endpoints":[{"host":"*","basePath":"*","exposedPort":0,"internalPort":8080,"tls":false,"http2":false}],"effect":"disable","fallbackEffect":"disable","skipLearning":false},"botProtectionSpec":{"userDefinedBots":[],"knownBotProtectionsSpec":{"searchEngineCrawlers":"disable","businessAnalytics":"disable","educational":"disable","news":"disable","financial":"disable","contentFeedClients":"disable","archiving":"disable","careerSearch":"disable","mediaSearch":"disable"},"unknownBotProtectionSpec":{"generic":"disable","webAutomationTools":"disable","webScrapers":"disable","apiLibraries":"disable","httpLibraries":"disable","botImpersonation":"disable","browserImpersonation":"disable","requestAnomalies":{"threshold":9,"effect":"disable"}},"sessionValidation":"disable","interstitialPage":false,"jsInjectionSpec":{"enabled":false,"timeoutEffect":"disable"},"reCAPTCHASpec":{"enabled":false,"siteKey":"","secretKey":{"encrypted":""},"type":"checkbox","allSessions":true,"successExpirationHours":24}},"networkControls":{"advancedProtectionEffect":"alert","subnets":{"enabled":false,"allowMode":true,"fallbackEffect":"alert"},"countries":{"enabled":false,"allowMode":true,"fallbackEffect":"alert"}},"body":{"inspectionSizeBytes":131072},"intelGathering":{"infoLeakageEffect":"alert","removeFingerprintsEnabled":true},"maliciousUpload":{"effect":"disable","allowedFileTypes":[],"allowedExtensions":[]},"csrfEnabled":true,"clickjackingEnabled":true,"sqli":{"effect":"alert","exceptionFields":[]},"xss":{"effect":"alert","exceptionFields":[]},"attackTools":{"effect":"alert","exceptionFields":[]},"shellshock":{"effect":"alert","exceptionFields":[]},"malformedReq":{"effect":"alert","exceptionFields":[]},"cmdi":{"effect":"alert","exceptionFields":[]},"lfi":{"effect":"alert","exceptionFields":[]},"codeInjection":{"effect":"alert","exceptionFields":[]},"remoteHostForwarding":{},"customRules":[{"_id":37,"action":"audit","effect":"prevent"},{"_id":36,"action":"audit","effect":"prevent"}]}]}]'
ALL_RULES=$(curl -k -X GET -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/firewall/app/container" | jq --argjson nr "$NEW_RULES" ' .rules = $nr + .rules ')
curl -k -X PUT -H "authorization: Bearer $TOKEN" -H 'Content-Type: application/json' "${var.pcc_url}/api/v21.08/policies/firewall/app/container" -d "$ALL_RULES"