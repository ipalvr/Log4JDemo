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

`terraform init`

If initialzation is successful, run

`terraform plan out="filename"`

Build cluster

`terraform apply "filename"`

Once the build is complete, update kubeconfig

`aws eks --region "region" update-kubeconfig --name "cluster_name"`

