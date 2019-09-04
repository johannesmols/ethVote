const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath); // delete build folder

// Election.sol

let electionPath = path.resolve(__dirname, 'contracts', 'Election.sol');
let source = fs.readFileSync(electionPath, 'utf8');
let output = solc.compile(source, 1).contracts;

fs.ensureDirSync(buildPath); // make sure that directory exists, creates it if it doesn't

for (let contract in output) {
    fs.outputJSONSync(
        path.resolve(buildPath, contract.replace(':', '') + '.json'), // path to output file
        output[contract] // output content
    );
}