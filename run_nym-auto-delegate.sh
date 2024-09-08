#!/bin/bash
MNEMONIC=$(cat ./nym-auto-delegator.mnemonic)
docker run --rm -e "MNEMONIC=$MNEMONIC" ghcr.io/commodum/nym-auto-delegator:latest