"use strict"

const path = require('path');
const fs = require('fs');

function getABI(filename) {
    try {
        if (fs.existsSync(path(__dirname,`assets/abi/build/${filename}.abi`))) {
            return fs.readFileSync(path(__dirname,`assets/abi/build/${filename}.abi`));
        } else {
            return JSON.stringify({});
        }
    } catch(error) {
        return JSON.stringify({});
    }
}

function getBIN(filename) {
    try {
        if (fs.existsSync(path(__dirname,`assets/abi/build/${filename}.bin`))) {
            return fs.readFileSync(path(__dirname,`assets/abi/build/${filename}.bin`));
        } else {
            return "";
        }
    } catch(error) {
        return "";
    }
}

function getTruffleBuild(filename) {
    try {
        if (fs.existsSync(path(__dirname,`build/contracts/${filename}`))) {
            return fs.readFileSync(path(__dirname,`build/contracts/${filename}`));
        } else {
            return JSON.stringify({});
        }
    } catch(error) {
        return JSON.stringify({});
    }
}

module.exports = {
    getABI,
    getBIN,
    getTruffleBuild
}