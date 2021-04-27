%builtins output pedersen

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.alloc import alloc

struct PassengerInfo:
    member name: felt
end

func processPassenger{pedersen_ptr : HashBuiltin*}(passengersPtr: PassengerInfo*, expected: felt) -> (success: felt, outputHash: felt):
    alloc_locals
    local secret
    assert_not_zero(passengersPtr.name)

    %{ ids.secret = program_input['secret'] %}

    let output = 0
    let (res) = hash2{hash_ptr=pedersen_ptr}(passengersPtr.name, secret)
    
    if res == expected:
        let (outputHash) = hash2{hash_ptr=pedersen_ptr}(res, secret)
        return (1, outputHash)
    end
    return (0, 0)
end

############################################################################### 
#  processPassengers: for each passager, check if it's me, MARIO
############################################################################### 
func processPassengers{pedersen_ptr: HashBuiltin*}(passengers: PassengerInfo*, nPassengers: felt, expected: felt) -> (success: felt, outputHash: felt):
    if nPassengers == 0:
        return (0, 0)
    end

    let (result, outputHash) = processPassenger(passengersPtr=passengers, expected=expected)
    if result == 1:
        return (1, outputHash)
    end

    let (result, outputHash) = processPassengers(passengers=passengers + PassengerInfo.SIZE, nPassengers=nPassengers - 1, expected=expected)
    return (result, outputHash)
end

############################################################################### 
#  getPassengerNames: Retrieve the list of all the passengers
############################################################################### 
func getPassengerNames() -> (passengerList: PassengerInfo*, n: felt):
    alloc_locals
    local n
    let (passengers: PassengerInfo*) = alloc()
    %{
        index = 0
        ids.n = len(program_input['passengers'])
        for key in program_input['passengers']:
            base_addr = ids.passengers.address_ + ids.PassengerInfo.SIZE * index
            memory[base_addr + ids.PassengerInfo.name] = key
            # memory[base_addr + ids.PassengerInfo.name] = int(key, 16) //ONLY IF HEX STRING
            index += 1
    %}
    return (passengerList=passengers, n=n)
end

############################################################################### 
#  Entry point, main function, wich will returns the Output struct
############################################################################### 
func main{output_ptr: felt*, pedersen_ptr : HashBuiltin*} ():
    alloc_locals
    let output = cast(output_ptr, Output*)
    let output_ptr = output_ptr + Output.SIZE

    local   expected
    %{
        registry = program_input['registry']
        for address, account in registry.items():
            if address == program_input['missa']:
                ids.expected = int(account['name'], 16)
                break
    %}

    assert_not_zero(expected)

    let (passengers, n) = getPassengerNames()
    let (success, outputHash) = processPassengers(passengers, n, expected)

    assert_not_zero(outputHash)
    assert output.success = success
    assert output.hash = outputHash
    return ()
end

############################################################################### 
#  STRUCTS
############################################################################### 
struct Output:
    member hash: felt
    member success: felt
end