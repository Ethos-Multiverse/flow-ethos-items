// Config information for FCL

import { config } from "@onflow/fcl";

// Use environment variables for easy deployment across environments
config({
  "accessNode.api": "https://rest-testnet.onflow.org",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn",
  "0xEthosItems": "0xd8144e7c81e68eb9" // account address for testnet profile contract
})

