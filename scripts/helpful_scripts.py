from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork","mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development","ganache-localMe"]

#we are changing the decimal price from 18 to 8 here since our FundMe contract will add 10 decimal places by multiplying by 10 ** 10 when fetching the eth usd price.
DECIMALS = 8
STARTING_PRICE = 200000000000 
#2000 + 8 zeros


def get_account():
    #when we are working with local blockchain network or with a mainnet fork we want brownie to make us an account from the accounts array
    #this doesnt mean that we will deploy mocks for a forked mainnet network as it provides us with an aggregatorv3interface like the testnet/mainnet
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS or 
        network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print(f"Deploying Mocks ...")
    if len(MockV3Aggregator) <= 0: 
        mock_aggregator = MockV3Aggregator.deploy(
            DECIMALS,STARTING_PRICE,{"from":get_account()}
        )
    print("Mocks deployed!") 
    
