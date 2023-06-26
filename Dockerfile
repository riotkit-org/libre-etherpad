# For DependaBot usage only: DependaBot bumps this version number, then ./get-version.sh will point to a new version
# and in effect the Makefile will build a new versinon of Etherpad without human interaction
FROM etherpad/etherpad:1.9.0 as versionProvider
