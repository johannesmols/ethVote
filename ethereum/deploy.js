const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledFactory = require('./build/ElectionFactory.json');
const compiledRegistrationAuthority = require('./build/RegistrationAuthority.json');
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

    // First deploy the registration authority contract because the address of that is needed in order to deploy the election factory contract
    const deployResultRA = await new web3.eth.Contract(JSON.parse(compiledRegistrationAuthority.interface))
        .deploy({ data: '0x' + compiledRegistrationAuthority.bytecode })
        .send({ from: accounts[0] });

    const deployResultEF = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
        .deploy({ data: '0x' + compiledFactory.bytecode, arguments: [deployResultRA.options.address] }) // argument is the address of the registration authority contract
        .send({ from: accounts[0] });

    console.log('Deployed Registration Authority contract to address ', deployResultRA.options.address);
    console.log('Deployed Election Factory contract to address ', deployResultEF.options.address);
};
deploy();