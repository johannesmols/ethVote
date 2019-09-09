const assert = require('assert');
const ganache = require('ganache-cli'); // local ethereum test network
const Web3 = require('web3'); // Web3 is a constructur, which is why it's capitalized. Instances of web3 are with lowercase
const web3 = new Web3(ganache.provider()); // instance of web3, with the provider being Ganache

const compiledRegistrationAuthority = require('../ethereum/build/RegistrationAuthority.json');
const compiledElectionFactory = require('../ethereum/build/ElectionFactory.json');
const compiledElection = require('../ethereum/build/Election.json');

let accounts, ra, ef;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();
    ra = await new web3.eth.Contract(JSON.parse(compiledRegistrationAuthority.interface))
        .deploy({ data: '0x' + compiledRegistrationAuthority.bytecode })
        .send({ from: accounts[0], gas: '3000000' });
    ef = await new web3.eth.Contract(JSON.parse(compiledElectionFactory.interface))
        .deploy({ data: '0x' + compiledElectionFactory.bytecode, arguments: [ra.options.address] })
        .send({ from: accounts[0], gas: '3000000' });
});

describe('Registration Authority', () => {
    it('deploys the RA contract to the blockchain', () => {
        assert.ok(ra.options.address);
    })

    it('the manager of the contract is also its creator', async () => {
        assert(await ra.methods.manager().call() == accounts[0]);
    });

    it('the number of registered voters is initialized with a zero', async () => {
        assert(await ra.methods.voterCount().call() == 0);
    });

    it('only the manager can access restricted functions', async () => {
        let e;
        try {
            assert(await ra.methods.registerVoter(accounts[0].send({ from: accounts[0]}))); // manager
            await ra.methods.registerVoter(accounts[1]).send({ from: accounts[1], gas: 3000000 }); // not the manager
        } catch (err) {
            e = err;
        }
        assert(e);
    });

    it('a voter can be registerd', async () => {
        await ra.methods.registerVoter(accounts[0]).send({ from: accounts[0], gas: 3000000 });
        assert(await ra.methods.voters(accounts[0]).call()); // returns true
        assert(await ra.methods.voterCount().call() == 1);
    });

    it('a voter can be unregisterd', async () => {
        await ra.methods.registerVoter(accounts[0]).send({ from: accounts[0], gas: 3000000 });
        assert(await ra.methods.voters(accounts[0]).call()); // returns true
        assert(await ra.methods.voterCount().call() == 1);

        await ra.methods.unregisterVoter(accounts[0]).send({ from: accounts[0], gas: 3000000 });
        assert(!await ra.methods.voters(accounts[0]).call()); // returns false
        assert(await ra.methods.voterCount().call() == 0);
    });

    it('multiple voters can be registered and unregisterd', async () => {
        await ra.methods.registerVoter(accounts[0]).send({ from: accounts[0], gas: 3000000 });
        await ra.methods.registerVoter(accounts[1]).send({ from: accounts[0], gas: 3000000 });
        await ra.methods.registerVoter(accounts[2]).send({ from: accounts[0], gas: 3000000 });
        await ra.methods.unregisterVoter(accounts[1]).send({ from: accounts[0], gas: 3000000 });
        assert(await ra.methods.voterCount().call() == 2);
    });
});

describe('Election Factory', () => {
    it('deploys the EF contract to the blockchain', () => {
        assert.ok(ef.options.address);
    });

    it('the manager of the contract is also its creator', async () => {
        assert(await ef.methods.factoryManager().call() == accounts[0]);
    });

    it('the contract has a valid address to the registstration authority', async () => {
        assert.ok(await ef.methods.registrationAuthority().call());
    });

    it('the contract has zero deployed elections initially', async () => {
        assert(await ef.methods.getDeployedElections().call().length == undefined);
    });

    it('only the factory manager can access restricted functions', async () => {
        let e;
        try {
            assert(await ef.methods.createElection('','',0,0).send({ from: accounts[0], gas: 3000000 })); // should work
            await ef.methods.createElection('','',0,0).send({ from: accounts[1], gas: 3000000 }); // should throw an error
        } catch (err) {
            e = err;
        }
        assert(e);
    });

    it('an election contract can be deployed', async () => {
        await ef.methods.createElection('', '', 0, 0).send({ from: accounts[0], gas: 3000000 });
        const deployedContracts = await ef.methods.getDeployedElections().call();
        assert(deployedContracts.length == 1);
        assert.ok(deployedContracts[0]);
    });

    it('multiple election contracts can be deployed', async () => {
        await ef.methods.createElection('a', 'a', 1, 2).send({ from: accounts[0], gas: 3000000 });
        await ef.methods.createElection('b', 'b', 3, 4).send({ from: accounts[0], gas: 3000000 });
        const deployedContracts = await ef.methods.getDeployedElections().call();
        assert(deployedContracts.length == 2);
        assert.ok(deployedContracts[0]);
        assert.ok(deployedContracts[1]);
    });
});