# Запуск Node.js-приложения как службы systemd

Этот пример предназначен для Linux-дистрибутивов с `systemd`, например Ubuntu или Debian.
Приложение запускается в фоне, автоматически стартует вместе с системой и каждые 5 секунд
записывает время и PID процесса в `/var/log/js-app/app.log`.

## Что понадобится

- Linux с `systemd`;
- пользователь с правами `sudo`;
- файлы `app.js` и `js-app.service` из этого каталога.

Проверьте, что используется `systemd`:

```bash
ps --no-headers -o comm 1
```

Команда должна вывести `systemd`.

## 1. Установка Node.js

Для Ubuntu или Debian:

```bash
sudo apt update
sudo apt install -y nodejs
```

Проверьте установку и расположение программы:

```bash
node --version
which node
```

Unit-файл ожидает, что Node.js находится по пути `/usr/bin/node`. Если `which node`
показывает другой путь, укажите его в параметре `ExecStart` файла `js-app.service`.

## 2. Создание пользователя службы

Приложение будет работать от отдельного системного пользователя без домашнего каталога:

```bash
sudo useradd --system --no-create-home nodeuser
```

Если пользователь уже существует, переходите к следующему шагу.

## 3. Установка приложения

Выполняйте команды из каталога, в котором находятся `app.js` и `js-app.service`:

```bash
sudo mkdir -p /opt/js-app
sudo cp app.js /opt/js-app/app.js
sudo chown -R nodeuser:nodeuser /opt/js-app
```

Создайте каталог для логов и разрешите приложению записывать в него:

```bash
sudo mkdir -p /var/log/js-app
sudo chown nodeuser:nodeuser /var/log/js-app
```

## 4. Установка и запуск службы

Скопируйте unit-файл в каталог `systemd`:

```bash
sudo cp js-app.service /etc/systemd/system/js-app.service
```

Перечитайте конфигурацию, включите автозапуск и сразу запустите службу:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now js-app
```

## 5. Проверка работы

Проверьте состояние службы:

```bash
systemctl status js-app --no-pager
```

В исправном состоянии будет указано `Active: active (running)`.

Посмотрите записи приложения:

```bash
sudo tail -f /var/log/js-app/app.log
```

Для выхода из режима просмотра нажмите `Ctrl+C`.

Посмотрите последние системные сообщения службы:

```bash
journalctl -u js-app -n 50 --no-pager
```

## Управление службой

```bash
# Остановить
sudo systemctl stop js-app

# Запустить
sudo systemctl start js-app

# Перезапустить
sudo systemctl restart js-app

# Отключить автозапуск
sudo systemctl disable js-app
```

После изменения `js-app.service` снова выполните:

```bash
sudo systemctl daemon-reload
sudo systemctl restart js-app
```

После изменения только `app.js` скопируйте его заново и перезапустите службу:

```bash
sudo cp app.js /opt/js-app/app.js
sudo chown nodeuser:nodeuser /opt/js-app/app.js
sudo systemctl restart js-app
```

## Если служба не запускается

Проверьте подробный статус и журнал:

```bash
systemctl status js-app --no-pager
journalctl -u js-app -n 100 --no-pager
```

Частые причины:

- Node.js установлен не по пути `/usr/bin/node`;
- пользователь `nodeuser` не создан;
- файл `/opt/js-app/app.js` отсутствует;
- у `nodeuser` нет права записи в `/var/log/js-app`.

## Удаление службы

```bash
sudo systemctl disable --now js-app
sudo rm /etc/systemd/system/js-app.service
sudo systemctl daemon-reload
sudo rm -r /opt/js-app
sudo rm -r /var/log/js-app
sudo userdel nodeuser
```

Команды удаления безвозвратно удаляют приложение и его логи, поэтому выполняйте их только
тогда, когда служба больше не нужна.
