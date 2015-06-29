#!/bin/bash
 
# Invoke the Forever module (to START our Node.js server).
PORT=3456 \
ENV=staging \
./node_modules/forever/bin/forever \
start \
--minUptime 1 \
-l forever.log \
-a \
-o out.log \
-e err.log \
app.js \