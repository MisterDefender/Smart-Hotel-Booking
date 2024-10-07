# 🏨 Hotel Booking Smart Contract
---

## 📝 Overview
This smart contract manages hotel bookings using ERC20 token payments on the Camino blockchain. It allows guests to create bookings, make payments, and request refunds. The contract also includes dispute resolution functionality.

## ✨ Features
- 🛎️ Create bookings with specified check-in dates and durations
- 💰 Make payments using an ERC20 token
- 🔄 Process refunds for eligible bookings
- ⚖️ Raise and resolve disputes
- 💸 Withdraw accumulated funds (owner only)

## 🔧 Smart Contract Details
- 📄 Solidity Version: 0.8.24
- 🪙 ERC20 Token: Configurable (set during deployment)
- 💹 Service Fee: 5.00% per booking
- ⏳ Refund Period: 7 days after check-out
- ⚖️ Dispute Period: 1 day after check-out

## 🔑 Key Functions
- `createBooking`: 🆕 Create a new booking
- `payForBooking`: 💳 Pay for an existing booking
- `refundBooking`: 🔙 Request a refund for an eligible booking
- `raiseDispute`: 🚩 Raise a dispute for a booking
- `resolveDispute`: ✅ Resolve a raised dispute (owner only)
- `markBookingForRefund`: ✔️ Mark a booking as eligible for refund (owner only)

## 🚀 Deployment
1. Deploy an ERC20 token or use an existing one on the Camino network
2. Deploy the HotelBooking contract, providing the ERC20 token address and owner address

## 🔐 Security
- 🛡️ Uses OpenZeppelin's SafeERC20 for secure token transfers
- 🔒 Implements Ownable2Step for secure ownership management
- 🕵️ Includes checks to prevent common vulnerabilities
