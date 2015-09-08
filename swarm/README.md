# Swarm Shell Scripts

Utility scripts for deploying a swarm locally or out on various cloud providers.  Cloud provider usage assumes various environmental variables are defined; these are (or should be) documented in the help documentation.  Run `[script name] -h` for full help documents.

> These scripts are under development and are USE AT YOUR OWN RISK.  They are all self-documenting and do discuss gotchas and warnings.  

## Scripts

* `create_swarm.sh` - Script for creating/expanding a swarm.
* `cleanup_swarm.sh` - Used to deallocate a swarm.  IT USES STRING MATCHING AND WILL MODIFY/DELETE ENGINES WITH CONTAINING THE WORD "SWARM". YHBW!