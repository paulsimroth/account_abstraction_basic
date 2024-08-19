# Account Abstraction

## About
1. Create a basic Account Abstraction Account on Ethereum
2. Create a basic Account Abstraction Account on zkSync
3. Deploy and send a transaction

## Used Ressources

libs:
- [eth-infinitism/account-abstraction](https://github.com/eth-infinitism/account-abstraction)
- [openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

### zkSync

To use the zkSync related contract you neeed to use [foundry-zksync](https://github.com/matter-labs/foundry-zksync) instead of regular foundry

## Foundry
Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
