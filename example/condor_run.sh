#!/bin/bash

export PATH=.:$PATH
tar -xzf Start.tar.gz
dos2unix *.sh *doitall*
chmod 755 *.sh *doitall* mfclo*
doitall.swo
tar -czf End.tar.gz --exclude '*.tar.gz' *
