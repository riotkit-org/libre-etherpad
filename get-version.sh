#!/bin/bash
cat ./Dockerfile | grep "as versionProvider" | grep -v "RUN cat" | awk '{print $2}' | cut -d ":" -f 2
