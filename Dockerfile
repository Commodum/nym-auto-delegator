FROM ubuntu:latest
WORKDIR /nym
## Install Nym-cli (note ca-certificates is also required for this to run)
RUN apt-get update && apt-get install -y ca-certificates
ADD https://github.com/nymtech/nym/releases/download/nym-binaries-v2024.9-topdeck/nym-cli nym-cli
RUN chmod +x nym-cli

## Copy our custom auto delegation script over
COPY auto-delegate.sh auto-delegate.sh 
RUN chmod +x auto-delegate.sh

## Define environment variable
ENV MNEMONIC=""

## Define the entry point
ENTRYPOINT /nym/auto-delegate.sh -m "$MNEMONIC"
#CMD ["/bin/sh"]

## Usefull commands
#docker build -t nym-auto-delegate:latest .
#docker run --rm -it -e "MNEMONIC=$mnemonic" nym-auto-delegate:latest
