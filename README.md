Decentralized Voting Smart Contract

A Clarity-based decentralized voting system built on the **Stacks blockchain** that enables transparent proposal creation, voting, and result tracking for community-driven governance.

---

Overview

The **Voting Smart Contract** allows users to:
- Create proposals with titles, descriptions, voting options, and deadlines.  
- Cast votes securely on-chain (one vote per user per proposal).  
- Retrieve proposal details and live voting results.  
- Close proposals once their voting period has expired.  

This smart contract serves as a foundation for **DAO voting**, **community governance**, and **on-chain decision-making systems**.

---

Core Features

**Proposal Creation** – Users can initiate proposals with configurable options and voting periods.  
**Voting Functionality** – Participants can vote once per proposal before the deadline.  
**Result Tracking** – Results are stored and publicly accessible for transparency.  
**Proposal Closure** – Only proposal creators can close the voting process.  
**Read-Only Queries** – Anyone can fetch proposal details and results.

---

Smart Contract Functions

| Function | Type | Description |
|-----------|------|-------------|
| `create-proposal(title, description, options, duration)` | Public | Creates a new proposal with metadata and voting duration. |
| `vote(proposal-id, choice)` | Public | Allows a participant to cast a vote for a specific option. |
| `close-proposal(proposal-id)` | Public | Enables the proposal creator to close voting after the deadline. |
| `get-proposal(proposal-id)` | Read-Only | Retrieves full proposal details. |
| `get-results(proposal-id)` | Read-Only | Returns vote counts per option. |

---

Data Structures

- **Proposals Map:** Stores metadata and state of each proposal.  
- **Votes Map:** Records each participant’s vote to prevent duplicates.  
- **Results Map:** Tracks total votes per option.  
- **Proposal Counter:** Increments with each new proposal for unique IDs.

---

Deployment (Testnet)

1. Install [**Clarinet**](https://docs.hiro.so/clarinet/getting-started) – the Clarity development framework.  
2. Clone this repository:
   ```bash
   git clone https://github.com/<your-username>/voting-smart-contract.git
   cd voting-smart-contract
