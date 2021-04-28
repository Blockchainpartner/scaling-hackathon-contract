pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract IFactRegistry {
    function isValid(bytes32 fact) external view virtual returns(bool);
}

contract CairoProver is Ownable {
    mapping(uint256 => uint256) public    registriesHash;
    uint256                   public    registriesProgramHash;
    uint256                   public    identitiesProgramHash;
    IFactRegistry             public    CAIRO_VERIFIER;
    
    event Prove(uint256, bytes32);
    event UpdateRegistry(uint256, uint256, uint256);
    
    constructor(uint256 _registriesProgramHash, uint256 _identitiesProgramHash, address cairoVerifier) {
        identitiesProgramHash = _identitiesProgramHash;
        registriesProgramHash = _registriesProgramHash;
        CAIRO_VERIFIER = IFactRegistry(cairoVerifier);
    }

    function updateRegistry(uint256 registryKey, uint256 oldRegistryHash, uint256 newRegistryHash) onlyOwner public returns (bytes32) {
        bytes32 outputHash = keccak256(abi.encodePacked(oldRegistryHash, newRegistryHash));
        bytes32 fact = keccak256(abi.encodePacked(registriesProgramHash, outputHash));
        require(CAIRO_VERIFIER.isValid(fact), "INVALID_PROOF");
        require(registriesHash[registryKey] == oldRegistryHash);

        registriesHash[registryKey] = newRegistryHash;
        emit UpdateRegistry(registryKey, oldRegistryHash, newRegistryHash);
        return (fact);
    }

    function proveIdentity(uint256 registryKey, uint256 hash, uint256 registryHash) public view returns (bool) {
        bytes32 outputHash = keccak256(abi.encodePacked(hash, registryHash));
        bytes32 fact = keccak256(abi.encodePacked(identitiesProgramHash, outputHash));
        return registriesHash[registryKey] == registryHash && CAIRO_VERIFIER.isValid(fact);
    }
}