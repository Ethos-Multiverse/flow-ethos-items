import NonFungibleToken from  0xf8d6e0586b0a20c7;
// Implement the NonFungibleToken standard
pub contract EthosItems: NonFungibleToken {

  // Counter to keep track of number of NFTs
  pub var totalSupply: UInt64

  pub event ContractInitialized()

  pub event Withdraw(id: UInt64, from: Address?)

  pub event Deposit(id: UInt64, to: Address?)

  // NFT resource
  pub resource NFT: NonFungibleToken.INFT {
    pub let id: UInt64 

    // To associate an external image with NFT
    pub let ipfsHash: String

    // Mapping from string to string
    pub var metadata: {String: String}

    init(_ipfsHash: String, _metadata: {String: String}) {
      // Use totalSupply as NFT Ids
      self.id = EthosItems.totalSupply

      // Update total supply
      EthosItems.totalSupply = EthosItems.totalSupply + 1

      self.ipfsHash = _ipfsHash
      self.metadata = _metadata
    }
  }

  //
  pub resource interface CollectionPublic {
    pub fun borrowEntireNFT(id: UInt64): &EthosItems.NFT
  }

  // Collection
  pub resource Collection: NonFungibleToken.Receiver, NonFungibleToken.Provider, NonFungibleToken.CollectionPublic, CollectionPublic {
    // the id of the NFT --> the NFT with that id
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
    
    // Removes NFT from collection and deposits it to caller
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("This NFT does not exist ")

      // Invoke withdraw event
      emit Withdraw(id: token.id, from: self.owner?.address)

      return <- token
    }

    // Adds NFT to collections dictionary
    pub fun deposit(token: @NonFungibleToken.NFT) {
      // Check if NFT is native NFT
      let myToken <- token as! @EthosItems.NFT

      // Invoke deposit event
      emit Deposit(id: myToken.id, to: self.owner?.address)

      // If native, store id
      self.ownedNFTs[myToken.id] <-! myToken
    }


    // Returns list of all NFT ids in collection
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Returns a reference to an NFT in the collection based on id
    // Allows caller to read data and call its methods
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
    }

    pub fun borrowEntireNFT(id: UInt64): &EthosItems.NFT {
      let reference = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
      return reference as! &EthosItems.NFT
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // Allows caller to own native NFTs
  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  // 
  pub fun createToken(ipfsHash: String, metadata: {String: String}): @EthosItems.NFT {
    return <- create NFT(_ipfsHash: ipfsHash, _metadata: metadata)
  }

  init() {
    self.totalSupply = 0
  }
}
 