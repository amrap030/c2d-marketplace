[![Build](https://github.com/amrap030/wol-wake-on-lan/actions/workflows/ci.yml/badge.svg)](https://github.com/amrap030/wol-wake-on-lan/actions/workflows/ci.yml)
[![Commitizen friendly](https://img.shields.io/badge/commitizen-friendly-brightgreen.svg)](http://commitizen.github.io/cz-cli/)

# C2D - Compute-to-Data Marketplace

This is a repository for my master thesis about enhancing blockchain-based data marketplaces with compute-to-data through verifiable off-chain computations. It uses [ZoKrates](https://github.com/Zokrates/ZoKrates) to build zero-knowledge proofs, in particular zkSNARKS, to prove to a buyer the correct computation of statistics on private datasets. The protocol additionally includes [FairSwap](https://eprint.iacr.org/2018/740) as a fair data exchange protocol to guarantee a buyer receives tamper-free computation results when the seller receives the money. For more information have a look under `./thesis` to access the paper.

## 💡 Get Started

Luckily, it's incredibly easy to get your development started:

```bash
# Start local hardhat blockchain node
cd src/contracts
yarn hh-node

# Deploy necessary contracts
yarn deploy

# Start all docker containers
docker compose build # in case local images are not build
docker compose up -d

# Create & deploy the subgraph indexer
cd src/subgraph
yarn create:local
yarn deploy:local

# Start the compute node & queue worker
cd src/compute-node
yarn dev
yarn worker

# Start the frontend
cd src/marketplace
yarn dev
```

## 🧪 Testing

For testing the smart contracts run the following commands:

```bash
cd src/contracts
yarn test
```

> If you want to see the gas consumption for each smart contract function, set the `gasReporter` under `hardhat.config.ts` to `enabled: true` and rerun the test.

## 📈 Changelog

Please see our [releases](https://github.com/amrap030/wol-wake-on-lan/releases) page for more information on what has changed recently.

## 💪🏼 Contributing

> Only allowed when master thesis is finished!

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for details.

## 🏝 Community

For help, discussion about best practices, or any other conversation that would benefit from being searchable:

- TODO

## 📄 License

The MIT License (MIT). Please see [LICENSE](LICENSE.md) for more information.

Made with ❤️

<!-- Badges -->

[npm-version-src]: https://img.shields.io/npm/v/@ow3/dummy-ts-pkg?style=flat-square
[npm-version-href]: https://npmjs.com/package/@ow3/dummy-ts-pkg
[npm-downloads-src]: https://img.shields.io/npm/dm/@ow3/dummy-ts-pkg?style=flat-square
[npm-downloads-href]: https://npmjs.com/package/@ow3/dummy-ts-pkg
[github-actions-src]: https://img.shields.io/github/workflow/status/openwebstacks/ts-starter/CI/main?style=flat-square
[github-actions-href]: https://github.com/openwebstacks/ts-starter/actions?query=workflow%3Aci

<!-- [codecov-src]: https://img.shields.io/codecov/c/gh/openwebstacks/ts-starter/main?style=flat-square
[codecov-href]: https://codecov.io/gh/openwebstacks/ts-starter -->
