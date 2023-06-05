// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;
/*
    LayerZero BNB
      lzChainId:102 lzEndpoint:0x3c2269811836af69497E5F486A85D7316753cf62
      contract: 0x29efEFF5d90De5eDcE45e7fF8dAE6288405610bA
    LayerZero MoonRiver
      lzChainId:167 lzEndpoint:0x7004396C99D5690da76A7C59057C5f3A53e01704
      contract: 0x2F9fEe4174F65deDa594f541DCCB2F7FB9E3dEf4
*/


contract LayerZero is NonblockingLzApp {
    string public data = "Nothing received yet";
    uint16 destChainId;
    
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
    function setTrustedRemote(uint16 _remoteChainId, bytes calldata _path) public onlyOwner {
         trustedRemoteLookup[_remoteChainId] = _path;   
    }    
}
