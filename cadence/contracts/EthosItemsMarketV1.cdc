import NonFungibleToken from "./NonFungibleToken.cdc"
import EthosItems from "./EthosItems.cdc"
import FungibleToken from "./FungibleToken.cdc"
import FlowToken from "./FlowToken.cdc"

pub contract EthosItemsMarketV1 {

  // Expose functions to public
  pub resource interface SaleCollectionPublic {
    // Allow anyone to get IDs from collection
    pub fun getIDs(): [UInt64]

    // Allow anyone to get prices from collection
    pub fun getPrice(id: UInt64): UFix64

    // Allow anyone to purchase from collection
    pub fun purchase(id: UInt64, recipientCollection: &EthosItems.Collection{NonFungibleToken.CollectionPublic}, payment: @FlowToken.Vault)
  }

  pub resource SaleCollection: SaleCollectionPublic  {
    // maps the id of the NFT --> the price of that NFT
    pub var forSale: {UInt64: UFix64}

    // Provide reference to collection
    pub let EthosItemsCollection: Capability<&EthosItems.Collection>

    // On NFT purchase, store funds to vault
    pub let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

    // List NFT for sale
    pub fun listForSale(id: UInt64, price: UFix64) {
      pre {
        // Check if price is greater than   
        price >= 0.0: "Can't list for less than zero"
        // Only can list NFT for sale if they own NFT
        self.EthosItemsCollection.borrow()!.getIDs().contains(id): "This SaleCollection owner does not have this NFT"
      } 

      self.forSale[id] = price
    }

    // Remove NFT from sale list
    pub fun unlistFromSale(id: UInt64) {
      self.forSale.remove(key: id)
    }

    // Allow caller to purchase token
    pub fun purchase(id: UInt64, recipientCollection: &EthosItems.Collection{NonFungibleToken.CollectionPublic}, payment: @FlowToken.Vault) {
      // Check if payment is correct amount
      pre {
        payment.balance == self.forSale[id]: "The payment is not equal to price of NFT"
      }

      // Deposit NFT into callers collection
      recipientCollection.deposit(token: <- self.EthosItemsCollection.borrow()!.withdraw(withdrawID: id))
      self.FlowTokenVault.borrow()!.deposit(from: <- payment)
    }

    // Helper func, get token price
    pub fun getPrice(id: UInt64): UFix64{
      return self.forSale[id]!
    }

    // Helper func, get token id
    pub fun getIDs(): [UInt64] {
      return self.forSale.keys 
    }

    init(_EthosItemsCollection: Capability<&EthosItems.Collection>, _FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
      self.forSale = {}
      self.EthosItemsCollection = _EthosItemsCollection
      self.FlowTokenVault = _FlowTokenVault
    }
  }

  // Allow caller list native NFT to marketplace
  pub fun createSaleCollection(EthosItemsCollection: Capability<&EthosItems.Collection>, FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>): @SaleCollection {
    return <- create SaleCollection(_EthosItemsCollection: EthosItemsCollection, _FlowTokenVault: FlowTokenVault)
  }

  init() {
  
  }
}