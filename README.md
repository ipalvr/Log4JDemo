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
Get url and token
-----------------

Go to System -> Utilities -> Path to Console to get the url (SaaS Version)
Go to System -> Utilities -> API Token to copy the Token details and replace <TOKEN> with a valid token.

Deply containers
----------------
Create dirty-net namespace
```
kubectl create namespace dirty-net2 
```
Apply Deployment
```
kubectl apply -f log4shell_deploy.yaml
```

Change Container State to "Active" state and Create Collections
---------------------------------------------------------------

Add your console url and token in cwp_cfg.sh and run;
```
bash cwp_cfg.sh
```

Add Runtime Rules ans WAAS Rules
--------------------------------

You can add the Runtime Rules either by importing the JSON files in the Console or using the API.

Import Runtime and WAAS Rules in the Console

Use vul_app1.json and vul_app2.json  Defend -> Runtime -> Container Policy -> Import
Use waas_rules.json   Defend -> WAAS -> Container -> Import

Import Runtime Rules using the API
----------------------------------

```
curl -k \
  -H 'authorization: Bearer <TOKEN>' \
  -X POST \
  -H "Content-Type:application/json" \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/runtime/container \
  --data-binary "@vul_app1.json"
```
```
curl -k \
  -H 'authorization: Bearer <TOKEN>' \
  -X POST \
  -H "Content-Type:application/json" \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/runtime/container \
  --data-binary "@vul_app2.json"
  ```


Import WAAS Rules using the API - (Not Working, import)
----------------------------------

```
curl -k -v \
  -H 'authorization: Bearer <TOKEN>' \
  -X POST \
  -H "Content-Type:application/json" \
  https://console-master-demo.mweibeler.demo.twistlock.com/api/v1/policies/firewall/app/container \
  --data-binary "@waas_rules_2.json"
```