// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint balance);

    function ownerOf(uint tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    function approve(address to, uint tokenId) external;

    function getApproved(uint tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721 {
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint => address) internal _ownerOf;

    // Mapping owner address to token count
    mapping(address => uint) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function ownerOf(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "does not exist");
        address owner = _ownerOf[id];
        return owner;
    }

    function balanceOf(address owner) external view returns (uint) {
        require(owner != address(0), "not owner");
        return _balanceOf[owner];
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = true;
        
        emit ApprovalForAll(msg.sender, operator, true);
    }

    function getApproved(uint id) external view returns (address) {
        require(_ownerOf[id] != address(0), "fail");
        
        return _approvals[id];
    }

    function approve(address to, uint id) external {
        address owner = _ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "fail");
        
        _approvals[id] = to;
        
        emit Approval(owner, to, id);
    }
    
    function _isApprovedOrOwner(address owner, address spender, uint id) internal view returns(bool){
        return (spender == owner || isApprovedForAll[owner][spender] || spender == _approvals[id]);
    }

    function transferFrom(address from, address to, uint id) public {
        require(from == _ownerOf[id], "fail");
        require(to != address(0), "fail");
        
        require(_isApprovedOrOwner(from, msg.sender, id), "fail");
        
        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;
        
        delete _approvals[id];
        
        emit Transfer(from, to, id);
        
    }
    
    function isContract(address to) public view returns(bool){
        return to.code.length > 0;
    }

    function safeTransferFrom(address from, address to, uint id) external {
        transferFrom(from, to, id);
        
        require(
        to.code.length == 0 ||
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, "") ==
            IERC721Receiver.onERC721Received.selector,
        "unsafe recipient"
    );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint id,
        bytes calldata data
    ) external {
         transferFrom(from, to, id);

    require(
        to.code.length == 0 ||
            IERC721Receiver(to).onERC721Received(msg.sender, from, id, data) ==
            IERC721Receiver.onERC721Received.selector,
        "unsafe recipient"
    );
    }

    function mint(address to, uint id) external {
        require(to != address(0), "Cant mint");
        require(_ownerOf[id] == address(0), "Already minted");
        
        _balanceOf[to]++;
        _ownerOf[id] = to;
        
        emit Transfer(address(0), to , id);
        
        
    }

    function burn(uint id) external {
        require(msg.sender == _ownerOf[id], "fail");
        
        _balanceOf[msg.sender] -= 1;
        
        delete _ownerOf[id];
        delete _approvals[id];
        
        emit Transfer(msg.sender, address(0), id);
        
    }
}
