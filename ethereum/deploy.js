const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledFactory = require('./build/ElectionFactory.json');
const config = require('./config');

const provider = new HDWalletProvider(
    config.mnemonic,
    config.provider
);

const web3 = new Web3(provider);

// Have to have a function in order to use async
const deploy = async () => {
    const accounts = await web3.eth.getAccounts(); // Get a list of all accounts
    console.log('All accounts with mnemonic: ', accounts);
    console.log('Attempting to deploy from account', accounts[0]);

    const result = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
        .deploy({ data: '0x' + compiledFactory.bytecode })
        .send({ from: accounts[0] });

    console.log('Deployed contract to address ', result.options.address);
};
deploy();