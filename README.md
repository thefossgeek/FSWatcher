# FSWatcher
File System events monitoring on Linux through the inotify Linux kernel subsystem. Pyinotify Python library for monitoring filesystem events on Linux through the inotify Linux kernel subsystem. It can monitor when a file is created, accessed, deleted, modified, etc.

Installation:

$ cd /opt

$ git clone https://github.com/thefossgeek/FSWatcher.git

$ cd FSWatcher

$ mv bin/fswatcherd /etc/init.d/

$ mkdir -p /var/log/FSWatcher

$ sudo service fswatcherd start

$ cat notifier.cron >> /etc/crontab

$ sudo service crond restart

further enhancement and documentation in progress.
