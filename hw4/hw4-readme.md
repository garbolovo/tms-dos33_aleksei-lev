### Create default user (auto UID/GID, with sudo)

```shell
./50-users.sh devops
```

### Create user with fixed UID/GID (recommended for multi-VM / Docker / K8s)
```bach
./50-users.sh devops -u 2000 -g 2000
```


### Create user with custom primary group
```
./50-users.sh devops developers
```


### Create service user (no sudo)
```
./50-users.sh devops --no-sudo
```

