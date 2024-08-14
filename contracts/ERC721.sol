// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IERC165 Interface
/// @dev Interface for checking if a contract supports another interface.
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceID The interface identifier, as specified in ERC-165
     * @return True if the contract implements the interface specified by `interfaceID`
     */
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// @title IERC721 Interface
/// @dev Interface for an ERC-721 Non-Fungible Token Standard.
interface IERC721 is IERC165 {
    /**
     * @notice Count all tokens assigned to an owner
     * @param owner The address of the owner to query
     * @return The number of tokens owned by `owner`
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @notice Find the owner of an NFT
     * @param tokenId The identifier for an NFT
     * @return The address of the owner of the NFT
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @notice Transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param tokenId The identifier of the NFT to transfer
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @notice Transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param tokenId The identifier of the NFT to transfer
     * @param data Additional data with no specified format
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @notice Transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param tokenId The identifier of the NFT to transfer
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @notice Change or reaffirm the approved address for an NFT
     * @param to The new approved NFT controller
     * @param tokenId The identifier of the NFT to approve
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @notice Get the approved address for a single NFT
     * @param tokenId The identifier of the NFT
     * @return The address currently approved to control the NFT
     */
    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage all of `msg.sender`'s assets
     * @param operator Address to add to the set of authorized operators
     * @param _approved True if the operator is approved, false to revoke approval
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @notice Query if an address is an authorized operator for another address
     * @param owner The address that owns the NFTs
     * @param operator The address that acts on behalf of the owner
     * @return True if `operator` is an approved operator for `owner`, false otherwise
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

/// @title IERC721Receiver Interface
/// @dev Interface for contracts that want to support safeTransfers from ERC721 asset contracts.
interface IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return The selector for `onERC721Received` function
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

/// @title ERC721 Implementation
/// @dev Implementation of the ERC-721 Non-Fungible Token Standard.
contract ERC721 is IERC721 {
    /**
     * @notice Emitted when ownership of an NFT changes
     * @param from The previous owner of the token
     * @param to The new owner
     * @param id The identifier of the NFT that was transferred
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    /**
     * @notice Emitted when an NFT is approved to be transferred by a third party
     * @param owner The owner of the NFT
     * @param spender The address approved to transfer the NFT
     * @param id The identifier of the NFT that was approved
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );

    /**
     * @notice Emitted when an operator is enabled or disabled for an owner
     * @param owner The owner of the NFT
     * @param operator The operator being enabled or disabled
     * @param approved True if the operator is approved, false to revoke approval
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping from token ID to owner address
    mapping(uint256 => address) internal _ownerOf;

    // Mapping from owner address to token count
    mapping(address => uint256) internal _balanceOf;

    // Mapping from token ID to approved address
    mapping(uint256 => address) internal _approvals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return True if the contract implements the interface specified by `interfaceId`
     */
    function supportsInterface(
        bytes4 interfaceId
    ) external pure returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    /**
     * @notice Find the owner of an NFT
     * @param id The identifier for an NFT
     * @return owner The address of the owner of the NFT
     */
    function ownerOf(uint256 id) external view returns (address owner) {
        owner = _ownerOf[id];
        require(owner != address(0), "token doesn't exist");
    }

    /**
     * @notice Count all tokens assigned to an owner
     * @param owner The address of the owner to query
     * @return The number of tokens owned by `owner`
     */
    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "owner = zero address");
        return _balanceOf[owner];
    }

    /**
     * @notice Enable or disable approval for a third party ("operator") to manage all of `msg.sender`'s assets
     * @param operator Address to add to the set of authorized operators
     * @param approved True if the operator is approved, false to revoke approval
     */
    function setApprovalForAll(address operator, bool approved) external {
        require(operator != address(0), "operator = zero address");
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @notice Change or reaffirm the approved address for an NFT
     * @param spender The new approved NFT controller
     * @param id The identifier of the NFT to approve
     */
    function approve(address spender, uint256 id) external {
        address owner = _ownerOf[id];
        require(
            msg.sender == owner || isApprovedForAll[owner][msg.sender],
            "not authorized"
        );
        require(spender != address(0), "spender = zero address");

        _approvals[id] = spender;

        emit Approval(owner, spender, id);
    }

    /**
     * @notice Get the approved address for a single NFT
     * @param id The identifier of the NFT
     * @return The address currently approved to control the NFT
     */
    function getApproved(uint256 id) external view returns (address) {
        require(_ownerOf[id] != address(0), "token doesn't exist");
        return _approvals[id];
    }

    /**
     * @dev Checks if the spender is the owner or an approved operator
     * @param owner The owner of the NFT
     * @param spender The spender to check
     * @param id The identifier of the NFT
     * @return True if `spender` is the owner or an approved operator, false otherwise
     */
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint256 id
    ) internal view returns (bool) {
        return (spender == owner ||
            isApprovedForAll[owner][spender] ||
            spender == _approvals[id]);
    }

    /**
     * @notice Transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param id The identifier of the NFT to transfer
     */
    function transferFrom(address from, address to, uint256 id) public {
        require(from == _ownerOf[id], "from != owner");
        require(to != address(0), "transfer to zero address");

        require(_isApprovedOrOwner(from, msg.sender, id), "not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[id] = to;

        delete _approvals[id];

        emit Transfer(from, to, id);
    }

    /**
     * @notice Safely transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param id The identifier of the NFT to transfer
     */
    function safeTransferFrom(address from, address to, uint256 id) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    ""
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    /**
     * @notice Safely transfer ownership of an NFT
     * @param from The current owner of the NFT
     * @param to The new owner
     * @param id The identifier of the NFT to transfer
     * @param data Additional data with no specified format
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) external {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    id,
                    data
                ) ==
                IERC721Receiver.onERC721Received.selector,
            "unsafe recipient"
        );
    }

    /**
     * @notice Mint a new NFT
     * @dev Internal function to mint a new NFT
     * @param to The address that will own the minted NFT
     * @param id The identifier of the NFT to mint
     */
    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    /**
     * @notice Burn an NFT
     * @dev Internal function to burn an NFT
     * @param id The identifier of the NFT to burn
     */
    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

/// @title MyNFT Contract
/// @dev A simple ERC-721 contract for minting and burning NFTs
contract MyNFT is ERC721 {
    /**
     * @notice Mint a new NFT
     * @param to The address that will own the minted NFT
     * @param id The identifier of the NFT to mint
     */
    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    /// @notice Burn an NFT
    /// @param id The identifier of the NFT to burn
    function burn(uint256 id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}
