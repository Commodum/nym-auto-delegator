# nym-auto-delegator
Automatically deligate Nym to a mixnode

# Parameters
The following parameters can be set as environment variable when calling the docker container
| Environment Variable Name | Purpose | Defaults |
| :--- | :--- | :--- |
| MNEMONIC | The mnemonic of the Nym account which is being used to delegate the funds from | |
| MIXNODE_ID | The ID of the mix node that is being delegated to. | 292 |
| Account_ID | The Account ID of the Nym account which is being used to delegate the funds from | |
| MINIMUM_DELEGATION_AMOUNT | Only delegate the funds if the account has more than this amcount | 500 |

## Build locally
```
docker build -t nym-auto-delegate:latest .
```

## Run locally
This will run locally in interactive mode.
Set local variable ```mnemonic```.
```
docker run --rm -it -e "MNEMONIC=$mnemonic" nym-auto-delegate:latest
```

# Production build process
Tagging a commit with v* will trigger a build.  Builds are published to ```ghcr.io/commodum/nym-auto-delegator```

# Install
1) Pull the latest buld 
```
docker pull ghcr.io/commodum/nym-auto-delegator:latest
```
2) create a run directory eg ```/user/nym/nym-auto-delegator```. Be strict with security - only allow access to the account running the cron job.
3) upload ```run_nym-auto-delegate.sh``` into the run directory
4) create a ```nym-auto-delegator.mnemonic``` file in the run directory containing only the mnemonic for the account containing the nym to be delegated.
5) create a crontab entry
```
# Nym - auto delegate - run every 2 hours at 15 minutes past the hour.  Ensure the logs are included in journalctl with the nym-auto-delegator tag
15 */2 * * *    (cd ~/commodum/nym-auto-delegator/ && ./run_nym-auto-delegate.sh) 2>&1 | logger -t nym-auto-delegator
```
