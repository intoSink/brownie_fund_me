from brownie import FundMe,MockV3Aggregator, network, config
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENTS
from web3 import Web3

def deploy_fund_me():
    account = get_account()
    
    #pass the priceFeed address to our fund me contract
    #if we are on a persistent network like rinkeby, use the associated address 
    #otherwise deploy mocks

    #if its development use mockv3aggregator and if its test network use AggregatorV3Interface address saved in the config file
    #if its mainnet fork we will get our price feed from the config instead of the mockV3Aggregator as we should
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()]["eth_usd_price_feed"]
    else:
       deploy_mocks()
       price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from":account}, 
        publish_source=config["networks"][network.show_active()].get("verify")
    )
    #in the end we can add ["verify"] instead of .get("verify") but if we havent added a value for verify in our config file
    #we will run into an error and .get("verify") helps us get around that error. A pre-emptive measure
    print(f"Contract deployed to {fund_me.address}")
    return fund_me

def main():
    deploy_fund_me()
