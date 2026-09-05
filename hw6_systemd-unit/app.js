// Node JS app will be added as  systemd unit service

const fs = require('fs');

setInterval(() => {
  const log = `${new Date().toISOString()} | PID=${process.pid}\n`;
  try {
    fs.appendFileSync('/var/log/js-app/app.log', log);
  } catch (err) {
    console.error('log write failed:', err.message);
  }
}, 5000);
