#!/bin/sh

# Use sendmail on host just to forward to postfix
cd /etc/mail && make
cd /etc/mail && sed '/^FEATURE.*dnl/d' `hostname`.submit.mc >> submit.mc.new
cd /etc/mail && echo 'FEATURE(`msp'"'"', `[10.0.0.10]'"'"')dnl' >> submit.mc.new
cd /etc/mail && mv `hostname`.submit.mc `hostname`.submit.mc.old
cd /etc/mail && mv submit.mc.new `hostname`.submit.mc
cd /etc/mail && make install
sysrc sendmail_enable=NO
sysrc sendmail_msp_queue_enable=YES
sysrc sendmail_outbound_enable=NO
sysrc submit_enable=YES
cd /etc/mail && make stop && make start
