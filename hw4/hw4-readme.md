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

 ## vm20 as NTP server for all other vms

```textmate
Internet NTP
      ↓
vm20 (NTP server)
      ↓
jumphost
vm10
vm11
```

```shell

aleksei@vm20:~$ systemctl status chrony
● chrony.service - chrony, an NTP client/server
     Loaded: loaded (/lib/systemd/system/chrony.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2026-03-12 17:37:17 UTC; 4h 1min ago
       Docs: man:chronyd(8)
             man:chronyc(1)
             man:chrony.conf(5)
   Main PID: 847 (chronyd)
      Tasks: 2 (limit: 4558)
     Memory: 2.2M
        CPU: 540ms
     CGroup: /system.slice/chrony.service
             ├─847 /usr/sbin/chronyd -F 1
             └─848 /usr/sbin/chronyd -F 1

Mar 12 17:37:23 vm20 chronyd[847]: Selected source 185.125.190.56 (ntp.ubuntu.com)
Mar 12 17:37:23 vm20 chronyd[847]: System clock wrong by 2.358672 seconds
Mar 12 17:37:26 vm20 chronyd[847]: System clock was stepped by 2.358672 seconds
Mar 12 17:37:26 vm20 chronyd[847]: System clock TAI offset set to 37 seconds
Mar 12 17:37:27 vm20 chronyd[847]: Selected source 185.125.190.57 (ntp.ubuntu.com)
Mar 12 17:37:28 vm20 chronyd[847]: Source 185.125.190.58 replaced with 2620:2d:4000:1::3f (ntp.ubuntu.com)
Mar 12 18:00:09 vm20 chronyd[847]: Selected source 185.125.190.56 (ntp.ubuntu.com)
Mar 12 18:08:45 vm20 chronyd[847]: Source 2620:2d:4000:1::3f replaced with 2620:2d:4000:1::41 (ntp.ubuntu.com)
Mar 12 19:05:59 vm20 chronyd[847]: Selected source 185.125.190.57 (ntp.ubuntu.com)
Mar 12 20:01:16 vm20 chronyd[847]: Source 2620:2d:4000:1::41 replaced with 2620:2d:4000:1::40 (ntp.ubuntu.com)
aleksei@vm20:~$

```

```shell

aleksei@vm20:~$ sudo chronyc clients
Hostname                      NTP   Drop Int IntL Last     Cmd   Drop Int  Last
===============================================================================
10.10.0.11                    234      0   6   -    29       0      0   -     -
10.10.0.100                   232      0   6   -    36       0      0   -     -
10.10.0.10                    232      0   6   -    37       0      0   -     -
localhost                       0      0   -   -     -       7      0  11   23m



```




```ecmascript 6

aleksei@vm20:~$ chronyc sources -v

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| /             'x' = may be in error, '~' = too variable, '?' = unusable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^+ alphyn.canonical.com          2  10   377   607    -15ms[  -15ms] +/-  166ms
^* prod-ntp-4.ntp1.ps5.cano>     2  10   377   702  -3436us[-1796us] +/-   68ms
^? prod-ntp-4.ntp4.ps5.cano>     0  10     0     -     +0ns[   +0ns] +/-    0ns
^+ prod-ntp-3.ntp1.ps5.cano>     2  10   377   698    +16ms[  +16ms] +/-   94ms

```

### check from jupmhost - vm20 is NTP server


```ecmascript 6

aleksei@jumphost:~$ chronyc sources -v

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| /             'x' = may be in error, '~' = too variable, '?' = unusable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 10.10.0.20                    3   6   377    32    +39us[  +44us] +/-   81ms


```

```shell
aleksei@jumphost:~$ timedatectl
               Local time: Thu 2026-03-12 21:32:02 UTC
           Universal time: Thu 2026-03-12 21:32:02 UTC
                 RTC time: Thu 2026-03-12 21:32:02
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```


```shell

aleksei@jumphost:~$ chronyc tracking
Reference ID    : 0A0A0014 (10.10.0.20)
Stratum         : 4
Ref time (UTC)  : Thu Mar 12 21:35:39 2026
System time     : 0.000016279 seconds fast of NTP time
Last offset     : +0.000011523 seconds
RMS offset      : 0.000171340 seconds
Frequency       : 1399.575 ppm slow
Residual freq   : +0.005 ppm
Skew            : 0.366 ppm
Root delay      : 0.137276188 seconds
Root dispersion : 0.013541230 seconds
Update interval : 64.5 seconds
Leap status     : Normal


```