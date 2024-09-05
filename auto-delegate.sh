#!/bin/bash
######################################################
## Auto delegate Nym to a mixnode
######################################################
Help()
{
        echo "=============================="
        echo "Auto delegate Nym to a mixnode"
        echo "=============================="
        echo
        echo "Syntax: auto-delegate-nym.sh [-h]"
        echo
        echo "options:"
        echo "-h        Print this Help"
        echo "-m        Mnemonic of your Nym wallet"
        echo "-p        Path to the Nym-cli"
        echo "-t        Target Mixnode Id"
        echo "-a        Account Id"
        echo "-d        Minumum delegtion amount"
}

# Set defaults
nym_cli_path='./'
nym_wallet_mnemonic=""
nym_account="n14epla9mvgwl8456l4emvvchyj6reqg8agvpw7n"
target_mixnode_id="292"
minimum_delegation_amount="500"
gas_allowance="1"

# Set values from environment varaiables
if [[ "$MNEMONIC" != "" ]]; then
        nym_wallet_mnemonic=$MNEMONIC
fi
if [[ "$MIXNODE_ID" != "" ]]; then
        target_mixnode_id=$MIXNODE_ID
fi
if [[ "$ACCOUNT_ID" != "" ]]; then
        nym_account=$ACCOUNT_ID
fi
if [[ "$MINIMUM_DELEGATION_AMOUNT" != "" ]]; then
        minimum_delegation_amount=$MINIMUM_DELEGATION_AMOUNT
fi

# Get the options
while getopts :hm:t:a:d: option; do
        case ${option} in
                h) Help
                   exit;;
                m) nym_wallet_mnemonic=${OPTARG};;
                p) nym_cli_path=${OPTARG}};;
                t) target_mixnode_id=${OPTARG};;
                a) nym_account=${OPTARG};;
                d) minimum_delegation_amount=${OPTARG};;
                \?) # Invalid option
                   echo "Error: Invalid option"
                   exit;;
        esac
done

#echo "Mnemonic: $nym_wallet_mnemonic"
echo "Mnemonic: ******"
echo "Nym cli path: $nym_cli_path"
echo "target mixnode id: $target_mixnode_id"
echo "Nym account: $nym_account"
echo "Minimum delegation amount: $minimum_delegation_amount"
echo "Gas allowance: $gas_allowance"
echo

#################################################
# Main Processing
#################################################
## Existing balance
# Get the balance using the cli call then return only the number
account_balance=$($nym_cli_path/nym-cli account balance --denom unym $nym_account | grep -Eo '[0-9]+[.]' | grep -Eo '[0-9]*' | tr -d '"')

account_balance_is_high_enough_to_delegate=false
if (( $account_balance > $minimum_delegation_amount )); then
        account_balance_is_high_enough_to_delegate=true
fi

if [[ "$account_balance_is_high_enough_to_delegate" == "false" ]]; then
        echo "The account balance of $account_balance is too low to delegate.  Exiting"
        exit 0
fi

## Pending delegations
# Check to see if we are have pending delegations (look for the Pending delegations and the next 4 lines - check to see if the target mix node id is in that output)
output=$($nym_cli_path/nym-cli mixnet delegators list --mnemonic "$nym_wallet_mnemonic" | grep -A4 'Pending delegations' | grep $target_mixnode_id )

pending_delegations_exist=true
if [[ "$output" == "" ]]; then
        pending_delegations_exist=false
fi

echo "Pending delegations exist: $pending_delegations_exist"

## Delegate
# ensure that there is enough Nym left in the account to cover the gas
amount_to_delegate=$(echo "$account_balance-$gas_allowance" | bc)
echo "Amount to delegate: $amount_to_delegate"

# convert nym to unym
delegation_amount_as_unym=$(echo "$amount_to_delegate*1000000" | bc)
echo "Amount of unym to delegate: $delegation_amount_as_unym"

$($nym_cli_path/nym-cli mixnet delegators delegate --mix-id $target_mixnode_id --mnemonic "$nym_wallet_mnemonic" --amount $delegation_amount_as_unym)

echo "Finished"