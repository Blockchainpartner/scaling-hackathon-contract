# Scaling Hackathon by Blockchain Partner

⚠️  
⚠️ Outdated. Please use [this repo](https://github.com/Blockchainpartner/scaling-hackathon-backend) to check the Cairo program and the Solidity contract ! ⚠️  
⚠️  

## Stack
- Solidity
- Cairo
- JS/TS

## How to
- Install Cairo with [this documentation](https://www.cairo-lang.org/docs/quickstart.html)
- Clone this repository

## Hash, fact & other
By running `cairo-hash-program --program cairo.json`, you will get an hash, `0x7ea4678b414e06a2537e5e79f730e3986c25d96e62037204525420072e4b9f2` which is the Cairo program hash. The `Hints` are not used to compute this hash, and this hash is deployed with the SmartContract.

By running `cairo-run --program=cairo.json --print_output --layout=small --program_input=input.json`, you will try to prove, thanks to your data in `input.json` that you are in the registry. The program will fail on error, or produce an output on success. For this example, the output should be :
```
Program output:
  -307539572955118350718880860395119943660313796352848841712661292173759557171
  1
```

By running `cairo-sharp submit --program cairo.json --program_input input.json` you will submit your program and your inputs to the cairo prover. The prover will compute the proof and register it on it's smartcontract by providing a `fact` which is `hash(programHash, programOutputsHash)`.
```
Running...
Submitting to SHARP...
Job sent.
Job key: 4f24f94e-cf01-46d9-b609-5f44f7f2a757
Fact: 0xa24f828158a77fa3f7e6775bf9efd6ab426b16c0cfe8da7677d588f57ad44897
```

By running `cairo-sharp status 4f24f94e-cf01-46d9-b609-5f44f7f2a757` we can ask to the cairo prover is the proof has been `PROCESSED`.


## The input file
The input file contains 4 informations. Theses informations are used to run the program, but are not sent to the smartcontract, and not public :
- `secret` which is a secret (`string` -> `hex` -> `bigInt`) used to encrypt your informations in the registry. You are the only one to know your secret.
- `missa` which is basically an index. You are trying to prove that you are in a registry, you have to provide us where to look in int.
- `registry` which contains a list of `addresses` with, for each one, an encrypted name corresponding to `hash(name, secret)` where name is a `bigInt` (`string` -> `hex` -> `bigInt`, ex: `Thomas` === `85081027341669`, and the above secret.
- `passenger` which is a list of data we want to prove we belong to.
