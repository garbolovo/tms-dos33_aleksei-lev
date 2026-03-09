
## how to start service

```
sudo systemctl daemon-reload
sudo systemctl enable js-app
sudo systemctl start js-app
```
## how do i know the path to the programm
needed  for ExecStart in init file


```

which python3
which node
which docker
```

Ex:
```
aleksei@vm20:/etc/systemd/system$ which node
/usr/bin/node
aleksei@vm20:/etc/systemd/system$ node -v
v12.22.9

```

## Running

```


aleksei@vm20:/opt/js-app$ systemctl status js-app
● js-app.service - JS DevOps App
     Loaded: loaded (/etc/systemd/system/js-app.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2026-03-09 21:39:36 UTC; 3s ago
   Main PID: 7724 (node)
      Tasks: 7 (limit: 4558)
     Memory: 7.9M
        CPU: 71ms
     CGroup: /system.slice/js-app.service
             └─7724 /usr/bin/node /opt/js-app/app.js

Mar 09 21:39:36 vm20 systemd[1]: Stopped JS DevOps App.
Mar 09 21:39:36 vm20 systemd[1]: Started JS DevOps App.

```
