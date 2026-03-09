// Node JS app will be added as  systemd unit service

const fs = require('fs');

setInterval(() => {
  const log = `${new Date().toISOString()} | PID=${process.pid}\n`;
  fs.appendFileSync('/var/log/js-app/app.log', log);
}, 5000);
