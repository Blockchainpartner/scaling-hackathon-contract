// cairo.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract IFactRegistry {
    function isValid(bytes32 fact) external view virtual returns(bool);
}

contract CairoProver {
    uint256         CAIRO_PROGRAM_HASH;
    IFactRegistry   CAIRO_VERIFIER;
    
    event Prove(uint256[], bytes32);
    
    constructor(uint256 cairoProgramHash, address cairoVerifier) {
        CAIRO_PROGRAM_HASH = cairoProgramHash;
        CAIRO_VERIFIER = IFactRegistry(cairoVerifier);
    }

    function updateState(uint256[] memory programOutput) public returns (bytes32) {
        bytes32 outputHash = keccak256(abi.encodePacked(programOutput));
        bytes32 fact = keccak256(abi.encodePacked(CAIRO_PROGRAM_HASH, outputHash));
        require(CAIRO_VERIFIER.isValid(fact), "INVALID_PROOF");

        emit Prove(programOutput, fact);
        return (fact);
    }
}