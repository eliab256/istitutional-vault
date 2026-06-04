// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;
import {Proposal, Signer} from "./Types.sol";
import {Roles as R} from "./Roles.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract InstitutionalMultiSig is EIP712, AccessControl {
    error InstitutionalMultiSig__ProposalAlreadyExecuted(uint256 proposalNonce);
    error InstitutionalMultiSig__NotAuthorized(address signer);
    error InstitutionalMultiSig__QuorumNotReached(uint256 proposalNonce);
    error InstitutionalMultiSig__ProposalExecutionFailed(uint256 proposalNonce);

    event ProposalCreated(uint256 indexed proposalNonce, address indexed target, bytes data, uint256 value);
    event ProposalExecuted(uint256 indexed proposalNonce, address indexed target, bytes data, uint256 value);
    event NotAuthorizedSigner(address indexed signer);
    event SignerAlreadyVoted(address indexed signer, uint256 indexed proposalNonce);
    event SignerVoted(address indexed signer, uint256 indexed proposalNonce, uint256 weight);
    event InvalidSignature(bytes signature, uint256 indexed proposalNonce);

    /// @dev signer address => Signer details
    mapping (address => Signer) public s_signers;

    /// @dev proposalNonce => Proposal details
    mapping (uint256 => Proposal) public s_proposalFromNonce;

    /// @dev proposalNonce => executed
    mapping (uint256 => bool) public s_executedProposals;

    /// @dev proposalNonce => voter => voting Power
    mapping (uint256 => mapping (address => uint256)) public s_votesOnProposal;
    uint256 public s_proposalNonce;

    uint256 public immutable i_quorum;

    bytes32 private constant PROPOSAL_TYPEHASH = keccak256("Proposal(address target,bytes data,uint256 value,uint256 nonce)");

    modifier notExecuted(uint256 _proposalId) {
        _notExecuted(_proposalId);
        _;
    }

    constructor(uint256 quorum) EIP712("InstitutionalMultiSig", "1") {
        i_quorum = quorum;
    }

    function addSigner(address signer, R.Role role, uint8 weight) external {
        s_signers[signer] = Signer({
            role: role,
            weight: weight
        });
    }

    function removeSigner(address signer) external {
        delete s_signers[signer];
    }
    
    // @audit-issue capire come implementare access control
    function propose(address _target, bytes memory _data, uint256 _value) external  {
        uint256 proposalNonce = s_proposalNonce++;

        s_proposalFromNonce[proposalNonce] = Proposal({
            target: _target,
            data: _data,
            value: _value,
            nonce: proposalNonce
        });

        emit ProposalCreated(proposalNonce, _target, _data, _value);
    }

    function executeProposal(uint256 _proposalNonce, bytes[] memory _signatures) external notExecuted(_proposalNonce) {
        // Retieve digest from proposal details
        Proposal memory proposal = s_proposalFromNonce[_proposalNonce];
        bytes32 structHash = keccak256(abi.encode(PROPOSAL_TYPEHASH, proposal.target, keccak256(proposal.data), proposal.value, proposal.nonce));   
        bytes32 digest = _hashTypedDataV4(structHash);

        // Verify signatures and count votes
        uint256 totalVotes;
        for(uint256 i = 0; i < _signatures.length; i++){
            address signer = ECDSA.recover(digest, _signatures[i]);
            
            // Check valid signature
            if(signer == address(0)){
                emit InvalidSignature(_signatures[i], _proposalNonce);
                continue;
            }

            // If the signer has already voted on this proposal, emit event but continue counting votes
            if(s_votesOnProposal[_proposalNonce][signer] > 0) {
                emit SignerAlreadyVoted(signer, _proposalNonce);
                continue;
            }
            uint256 signerWeight = s_signers[signer].weight;
            // If not authorized signer, emit event but continue counting votes
            if(signerWeight == 0) {
                emit NotAuthorizedSigner(signer);
            } else {
                // If valid signature from authorized signer, count votes and emit event
                totalVotes += signerWeight;
                s_votesOnProposal[_proposalNonce][signer] = signerWeight;

                emit SignerVoted(signer, _proposalNonce, signerWeight);
            }
        }
        
        // If quorum is reached execute proposal, otherwise revert
        if(!_hasQuorum(totalVotes)) {
            revert InstitutionalMultiSig__QuorumNotReached(_proposalNonce);
        } else {

            // Execute proposal
            address target = s_proposalFromNonce[_proposalNonce].target;
            bytes memory data = s_proposalFromNonce[_proposalNonce].data;
            uint256 value = s_proposalFromNonce[_proposalNonce].value;
            (bool success, ) = target.call{value: value}(data);

            // If call failed, revert with details about the proposal that failed
            if (!success) {
                revert InstitutionalMultiSig__ProposalExecutionFailed(_proposalNonce);
            }
            
            // Mark proposal as executed
            s_executedProposals[_proposalNonce] = true;

            emit ProposalExecuted(_proposalNonce, target, data, value);
        }
    }

    function _notExecuted(uint256 _proposalNonce) internal view {
        if (s_executedProposals[_proposalNonce]) {
            revert InstitutionalMultiSig__ProposalAlreadyExecuted(_proposalNonce);
        }
    }

    function _hasQuorum(uint256 totalVotes) internal view returns (bool) {
        return totalVotes >= i_quorum;
    }
}
