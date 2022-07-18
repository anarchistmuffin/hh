pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

import "./entities/Resource.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ResourceRepository {

    address public resourceRepositoryOwner;

    mapping(string => bool) private _rExists;
    mapping(bytes32 => bool) private _ids;
    mapping(bytes32 => string) private _idToString;
    mapping(string => bytes32) private _resourceIDs;
    mapping(bytes32 => address) private _resourceAddresses;
    mapping(bytes32 => Resource.ResourceTypes) private _resourceTypes;
    mapping(bytes32 => mapping(Resource.ResourceTypes => bool)) private _isResourceType;
    mapping(bytes32 => Resource.ResourceRecord) private _resourceRecords;
    
    using Counters for Counters.Counter;
    Counters.Counter internal _index;

    Resource internal _res;



    constructor() {
        _res.initialize();
        resourceRepositoryOwner = msg.sender;

    }

    function _addResource(string memory name, Resource.ResourceTypes rType, address resAddr, address owner_) internal returns(bytes32) {
        bytes32 id = _calculateResourceID(name, rType);
        _rExists[name] = true;
        _ids[id] = true;
        _resourceIDs[name] = id;
        _resourceAddresses[id] = resAddr;
        _resourceTypes[id] = rType;
        _isResourceType[id][rType] = true;
        Resource.ResourceRecord memory rr = Resource.ResourceRecord({
            name: name,
            rType: rType,
            rAddress: resAddr,
            owner: owner_
        });
        _resourceRecords[id] = rr;
        return id;
    }

    function _calculateResourceID(string memory name, Resource.ResourceTypes  rType) internal  returns(bytes32) {
        uint256 nonce = _index.current();
        bytes memory toKeccak = abi.encode(name, rType, nonce);
        _index.increment();
        return keccak256(toKeccak);
    }

    function addResource(string memory name,Resource.ResourceTypes rType, address resAddr, address owner_) public onlyOwner returns (bytes32) {

       require(_rExists[name] != true, "resource already exists");
       return _addResource(name, rType, resAddr, owner_);

    }

    function removeResource(bytes32 id) public onlyOwner {
        require(_ids[id] == true, "resource does not exists");
         
        string memory name = _idToString[id];
        delete _resourceIDs[name];
        delete _resourceAddresses[id];
        Resource.ResourceTypes rtype = _resourceTypes[id];
        delete _isResourceType[id][rtype];
        delete _resourceTypes[id];
        delete _idToString[id];
        delete _rExists[name];
        delete _resourceRecords[id];
        delete _ids[id];
    }

    modifier onlyOwner() {
        require(msg.sender == resourceRepositoryOwner, "access denied");
        _;
    }

}