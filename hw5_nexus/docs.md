```
aleksei@vm20:~$ docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED       STATUS          PORTS                                         NAMES
f142f5357993   sonatype/nexus3:3.89.0   "/opt/sonatype/nexus…"   2 weeks ago   Up 13 minutes   0.0.0.0:8081->8081/tcp, [::]:8081->8081/tcp   nexus
aleksei@vm20:~$ docker compose ls
NAME                STATUS              CONFIG FILES
nexus               running(1)          /opt/nexus/docker-compose.yml

```

## Доступ к Nexus
```
ssh -L 8081:10.10.0.20:8081 jump (на хотсe)
http://localhost:8081


```

Download packege from Nexus (vm20)

```
aleksei@vm10:~$ python3 -m pip install --user httpx -v
Using pip 22.0.2 from /usr/lib/python3/dist-packages/pip (python 3.10)
Looking in indexes: http://10.10.0.20:8081/repository/pypi-proxy/simple
Collecting httpx
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/httpx/0.28.1/httpx-0.28.1-py3-none-any.whl (73 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 73.5/73.5 KB 11.7 MB/s eta 0:00:00
Collecting anyio
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/anyio/4.12.1/anyio-4.12.1-py3-none-any.whl (113 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 113.6/113.6 KB 27.3 MB/s eta 0:00:00
Requirement already satisfied: certifi in /usr/lib/python3/dist-packages (from httpx) (2020.6.20)
Requirement already satisfied: idna in /usr/lib/python3/dist-packages (from httpx) (3.3)
Collecting httpcore==1.*
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/httpcore/1.0.9/httpcore-1.0.9-py3-none-any.whl (78 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 78.8/78.8 KB 14.8 MB/s eta 0:00:00
Collecting h11>=0.16
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/h11/0.16.0/h11-0.16.0-py3-none-any.whl (37 kB)
Collecting typing_extensions>=4.5
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/typing-extensions/4.15.0/typing_extensions-4.15.0-py3-none-any.whl (44 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 44.6/44.6 KB 8.5 MB/s eta 0:00:00
Collecting exceptiongroup>=1.0.2
  Downloading http://10.10.0.20:8081/repository/pypi-proxy/packages/exceptiongroup/1.3.1/exceptiongroup-1.3.1-py3-none-any.whl (16 kB)
Installing collected packages: typing_extensions, h11, httpcore, exceptiongroup, anyio, httpx
  Creating /home/aleksei/.local/bin
  changing mode of /home/aleksei/.local/bin/httpx to 775
  WARNING: The script httpx is installed in '/home/aleksei/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
Successfully installed anyio-4.12.1 exceptiongroup-1.3.1 h11-0.16.0 httpcore-1.0.9 httpx-0.28.1 typing_extensions-4.15.0
aleksei@vm10:~$

```

