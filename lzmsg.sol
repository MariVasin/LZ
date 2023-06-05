// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "https://github.com/LayerZero-Labs/solidity-examples/blob/36580de4a0f8089960c7c3d44ca614d460b8c5fc/contracts/lzApp/LzApp.sol";

import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/util/BitLib.sol";

import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/util/ExcessivelySafeCall.sol";
import "https://github.com/LayerZero-Labs/solidity-examples/blob/main/contracts/libraries/LzLib.sol";
/*
    LayerZero BNB
      lzChainId:102 lzEndpoint:0x3c2269811836af69497E5F486A85D7316753cf62
      contract: 0x29efEFF5d90De5eDcE45e7fF8dAE6288405610bA
    LayerZero MoonRiver
      lzChainId:167 lzEndpoint:0x7004396C99D5690da76A7C59057C5f3A53e01704
      contract: 0x2F9fEe4174F65deDa594f541DCCB2F7FB9E3dEf4
*/

contract LayerZeroTest is NonblockingLzApp {
    string public data = "Nothing received yet";
    uint16 destChainId;
    using BytesLib for bytes;
    uint constant public DEFAULT_PAYLOAD_SIZE_LIMIT = 10000;
    ILayerZeroEndpoint public immutable lzEndpoint;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(uint16 => mapping(uint16 => uint)) public minDstGasLookup;
    mapping(uint16 => uint) public payloadSizeLimitLookup;
    address public precrime;
    event SetPrecrime(address precrime);
    event SetTrustedRemote(uint16 _remoteChainId, bytes _path);
    event SetTrustedRemoteAddress(uint16 _remoteChainId, bytes _remoteAddress);
    event SetMinDstGas(uint16 _dstChainId, uint16 _type, uint _minDstGas);
  
   constructor(address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        if (_lzEndpoint == 0x3c2269811836af69497E5F486A85D7316753cf62) destChainId = 167;
        if (_lzEndpoint == 0x7004396C99D5690da76A7C59057C5f3A53e01704) destChainId = 102;
    }

    function _nonblockingLzReceive(uint16, bytes memory, uint64, bytes memory _payload) internal override {
       data = abi.decode(_payload, (string));
    }

    function send(string memory _message) public payable {
        bytes memory payload = abi.encode(_message);
        _lzSend(destChainId, payload, payable(msg.sender), address(0x0), bytes(""), msg.value);
    }

    function trustAddress(address _otherContract) public onlyOwner {
        trustedRemoteLookup[destChainId] = abi.encodePacked(_otherContract, address(this));
    }
  // _path = abi.encodePacked(remoteAddress, localAddress)
    // this function set the trusted path for the cross-chain communication
    function setTrustedRemote(uint16 _remoteChainId, bytes calldata _path) external onlyOwner {
        trustedRemoteLookup[_remoteChainId] = _path;
        emit SetTrustedRemote(_remoteChainId, _path);
    } 
     function setTrustedRemoteAddress(uint16 _remoteChainId, bytes calldata _remoteAddress) external onlyOwner {
        trustedRemoteLookup[_remoteChainId] = abi.encodePacked(_remoteAddress, address(this));
        emit SetTrustedRemoteAddress(_remoteChainId, _remoteAddress);
    }

    function getTrustedRemoteAddress(uint16 _remoteChainId) external view returns (bytes memory) {
        bytes memory path = trustedRemoteLookup[_remoteChainId];
        require(path.length != 0, "LzApp: no trusted path record");
        return path.slice(0, path.length - 20); // the last 20 bytes should be address(this)
    }    
   
}
