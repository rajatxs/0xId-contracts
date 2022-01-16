
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "5777",
    },
  },
  contracts_directory: "./src",
  migrations_directory: "./migrations",
  contracts_build_directory: "./abis",
  compilers: {
    solc: { version: "0.8.5" },
  },
};
