#!/bin/bash

tar -xzf Start.tar.gz
chmod 755 *.sh *doitall* mfclo*
./doitall.swo
tar -czf End.tar.gz --exclude '*.tar.gz' *
