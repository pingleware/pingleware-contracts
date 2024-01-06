module.exports = {
              compilers: {
                solc: {
                  version: '0.8.22',
                  settings: {
                    optimizer: {
                      enabled: false,
                      runs: 200,
                    },
                    evmVersion: null
                  }
                }
              }
            }