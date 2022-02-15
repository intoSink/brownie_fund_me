#Now that we have deployed the contract by adding our own ganache-localMe network to the network list of brownie
#making the necessary changes in helpful_scripts and deploy i.e. if the network is development or local then use MockV3Aggregator
#and if it is test, such as rinkeby or kovan, use the AggregatorV3Interface for which an API key is provided by the network on etherscan
#the API key is saved as Etherscan Token in config file which brownie goes over when deploying the smart contract(s)

from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    fund_me = FundMe[-1]
    print(fund_me)
    account = get_account()
    print(account)
    entrance_fee = fund_me.getEntranceFee()
    print(entrance_fee)
    print(f"The current entry fee is {entrance_fee}")
    fund_me.fund({"from": account, "value":entrance_fee})
    #any transaction data we wish to send with our transactions and function calls will be placed in ({}) like above 
     
def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from":account})

def main():
    fund()
    withdraw()
