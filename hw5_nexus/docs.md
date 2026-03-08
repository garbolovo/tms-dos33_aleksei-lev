```
aleksei@vm20:~$ docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED       STATUS          PORTS                                         NAMES
f142f5357993   sonatype/nexus3:3.89.0   "/opt/sonatype/nexus…"   2 weeks ago   Up 13 minutes   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp   nexus
aleksei@vm20:~$ docker compose ls
NAME                STATUS              CONFIG FILES
nexus               running(1)          /opt/nexus/docker-compose.yml

```

## Доступ к Nexus
ssh -L 8081:10.10.0.20:8081 jump (на хотсe)
http://localhost:8081

