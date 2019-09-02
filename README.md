# Commands

## Install dependencies

```bash
npm install --save ganache-cli mocha solc@0.4.26 fs-extra web3 truffle-hdwallet-provider
```

**Note:** ```solc@0.4.26``` is the last Solidity compiler version before the breaking ```0.5.0``` [update](https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html). Compile and deploy scripts broke because of this, and ```0.4.26``` is used in this project.

## Compile contracts

```bash
node .\ethereum\compile.js
```

## Deploy contracts using Infuria

```bash
node .\ethereum\deploy.js
```