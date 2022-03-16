<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Log4JDemo](#log4jdemo)
  - [Prerequisites](#prerequisites)
  - [Create EKS Cluster](#create-eks-cluster)
  - [Install Prisma Cloud Defender](#install-prisma-cloud-defender)
  - [Create Collections, Policies, and WAAS Rules](#create-collections-policies-and-waas-rules)
  - [Add Collections](#add-collections)
  - [Add Runtime Rules](#add-runtime-rules)
  - [Add WAAS Rule](#add-waas-rule)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Log4JDemo
Code to create an EKS cluster and deploy vulnerable containers for Prisma Cloud Compute Demostrations

Prerequisites
-------------

AWS account with and IAM account with Admin Access and an Access Key and Secret Key.  Configure the AWS CLI with your Access Key and Secret Key.

Terraform

Create EKS Cluster
------------------

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
Install Prisma Cloud Defender
-----------------------------

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
Create Collections, Policies, and WAAS Rules
--------------------------------------------

Get token and add as a variable
```
curl -k -H "Content-Type: application/json" -X POST -d '{"username":"admin","password":"password"}' https://api.prismacloud.io/api/v22.01/authenticate
```
CSPM  
```
curl --request POST --url https://api.prismacloud.io/login --header 'content-type: application/json; charset=UTF-8' --data '{"customerName":"string","password":"string","prismaId":"string","username":"string"}'
```

Add Collections
---------------

Go to System -> Utilities -> Path to Console to get the url https://us-east1.cloud.twistlock.com/us-1-111573457
Go to System -> Utilities -> API Token to copy the Token details and replace <TOKEN> with a valid token.

```
curl -k -v POST -H 'authorization: Bearer <TOKEN>' -H 'Content-Type: application/json' -d '{"name":"Weib Log4Shell Demo - vul-app-3","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-3"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/collections?project=Central+Console"
```

```
curl -k -v POST -H 'authorization: Bearer <TOKEN>' -H 'Content-Type: application/json' -d '{"name":"Weib Log4Shell Demo - vul-app-1","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app-1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/collections?project=Central+Console"
```


Add Runtime Rules
-----------------

Add individual run method (-v is verbose curl logging)

curl -k -v \
  -H 'authorization: Bearer <TOKEN>' \
  -X POST \
  -H "Content-Type:application/json" \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/runtime/container \
  --data-binary "@vul_app_1.json"

Export / Import Method

First, export the existing rules.

```
 curl -k \
  -H 'authorization: Bearer <TOKEN>' \
  -H 'Content-Type: application/json' \
  -X GET \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/runtime/container \
  | jq '.' > model_rules.json
```  

Modify the saved JSON with the updates, including any new rule insertions.

```
curl -k -v \
  -H 'authorization: Bearer <TOKEN>' \
  -X PUT \
  -H "Content-Type:application/json" \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/runtime/container \
  --data-binary "@model_rules.json"
```

Add WAAS Rule
-------------
