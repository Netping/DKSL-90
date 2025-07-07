#!/bin/bash

chmod 755 /etc/np_scripts/default.btn_monitor.py
      
systemctl daemon-reload
systemctl enable default.btn_monitor.service
systemctl start default.btn_monitor.service
