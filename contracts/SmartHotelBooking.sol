// SPDX-License-Identifier: MIT
pragma solidity = 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title Hotel Booking Smart Contract
/// @author [Your Name or Organization]
/// @notice This contract manages hotel bookings with ERC20 token payments
/// @dev Inherits from OpenZeppelin's Ownable2Step for secure ownership management
contract HotelBooking is Ownable2Step {
    using SafeERC20 for IERC20;

    /// @notice Structure to store booking details
    /// @dev isEligibleForRefund is set by the owner to allow refunds
    struct Booking {
        address guest;
        uint256 checkInTS;
        uint256 checkOutTS;
        uint256 roomPrice;
        bool isPaid;
        bool isRefunded;
        bool isDisputed;
        bool isEligibleForRefund;
    }

    mapping(uint256 => Booking) public bookings;
    uint256 public nextBookingId;

    uint256 public constant SERVICE_FEE_PERCENTAGE = 500; // 5.00%
    uint256 public constant REFUND_PERIOD = 7 days;
    uint256 public constant DISPUTE_PERIOD = 1 days;

    IERC20 public paymentToken;

    event BookingCreated(uint256 bookingId, address guest, uint256 checkInTS, uint256 checkOutTS, uint256 roomPrice);
    event PaymentReceived(uint256 bookingId, uint256 amount);
    event RefundIssued(uint256 bookingId, uint256 amount);
    event DisputeRaised(uint256 bookingId);
    event DisputeResolved(uint256 bookingId, bool inGuestFavor);

    /// @notice Contract constructor
    /// @param _paymentToken Address of the ERC20 token used for payments
    /// @param _owner Address of the contract owner
    constructor(address _paymentToken, address _owner) Ownable(_owner) {
        paymentToken = IERC20(_paymentToken);
    }

    /// @notice Creates a new booking
    /// @param _numOfDays Number of days for the booking
    /// @param _checkInTS Timestamp for check-in
    /// @param _roomPrice Price of the room per booking
    /// @dev Emits a BookingCreated event
    function createBooking(uint256 _numOfDays, uint256 _checkInTS, uint256 _roomPrice) external {
        require(_numOfDays > 0, "Booking days should be more than one day");
        uint256 bookingId = nextBookingId++;
        uint256 _checkOutTS = _checkInTS + _numOfDays;
        bookings[bookingId] = Booking({
            guest: msg.sender,
            checkInTS: _checkInTS,
            checkOutTS: _checkOutTS,
            roomPrice: _roomPrice,
            isPaid: false,
            isRefunded: false,
            isDisputed: false,
            isEligibleForRefund: false
        });
        emit BookingCreated(bookingId, msg.sender, _checkInTS, _checkOutTS, _roomPrice);
    }

    /// @notice Allows a guest to pay for their booking
    /// @param _bookingId ID of the booking to pay for
    /// @dev Transfers tokens from the guest to the contract
    function payForBooking(uint256 _bookingId) external {
        Booking memory booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Only the guest can pay");
        require(!booking.isPaid, "Booking already paid");
        require(block.timestamp < booking.checkInTS, "Payment should be made before Check-In");
        uint256 serviceFee = (booking.roomPrice * SERVICE_FEE_PERCENTAGE) / 10000;
        uint256 totalAmount = booking.roomPrice + serviceFee;

        paymentToken.safeTransferFrom(msg.sender, address(this), totalAmount);
        bookings[_bookingId].isPaid = true;
        emit PaymentReceived(_bookingId, totalAmount);
    }

    /// @notice Processes a refund for an eligible booking
    /// @param _bookingId ID of the booking to refund
    /// @dev Only callable by the guest after the refund period and if marked as eligible
    function refundBooking(uint256 _bookingId) external {
        Booking memory booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Only the guest can request a refund");
        require(booking.isPaid, "Booking not paid");
        require(!booking.isRefunded, "Booking already refunded");
        require(booking.isEligibleForRefund, "Not eligible for a refund");
        require(block.timestamp > booking.checkOutTS + REFUND_PERIOD, "Refund period has not passed");
        uint256 refundAmount = booking.roomPrice;
        bookings[_bookingId].isRefunded = true;
        paymentToken.safeTransfer(booking.guest, refundAmount);
        emit RefundIssued(_bookingId, refundAmount);
    }

    /// @notice Allows a guest to raise a dispute for a booking
    /// @param _bookingId ID of the booking to dispute
    /// @dev Must be called within the dispute period after check-out
    function raiseDispute(uint256 _bookingId) external {
        Booking memory booking = bookings[_bookingId];
        require(msg.sender == booking.guest, "Only the guest can raise a dispute");
        require(booking.isPaid, "Booking not paid");
        require(!booking.isDisputed, "Dispute already raised");
        require(block.timestamp <= booking.checkOutTS + DISPUTE_PERIOD, "Dispute period has passed");
        bookings[_bookingId].isDisputed = true;
        emit DisputeRaised(_bookingId);
    }

    /// @notice Resolves a dispute for a booking
    /// @param _bookingId ID of the disputed booking
    /// @param _inGuestFavor Whether the dispute is resolved in favor of the guest
    /// @dev Only callable by the contract owner
    function resolveDispute(uint256 _bookingId, bool _inGuestFavor) external onlyOwner {
        Booking memory booking = bookings[_bookingId];
        require(booking.isDisputed, "No dispute raised for this booking");
        if (_inGuestFavor) {
            uint256 refundAmount = booking.roomPrice;
            paymentToken.safeTransfer(booking.guest, refundAmount);
        }
        emit DisputeResolved(_bookingId, _inGuestFavor);
    }

    /// @notice Allows the owner to withdraw funds from the contract
    /// @param _amount Amount of tokens to withdraw
    /// @dev Only callable by the contract owner
    function withdrawFunds(uint256 _amount) external onlyOwner {
        paymentToken.safeTransfer(owner(), _amount);
    }

    /// @notice Marks a booking as eligible for refund
    /// @param _bookingId ID of the booking to mark for refund
    /// @dev Only callable by the contract owner within the refund period
    function markBookingForRefund(uint256 _bookingId) external onlyOwner {
        Booking memory booking = bookings[_bookingId];
        require(booking.guest != address(0), "No booking exists");
        require(block.timestamp <= booking.checkOutTS + REFUND_PERIOD, "Mark for refund period has passed");
        require(booking.isPaid, "Booking not paid");
        require(!booking.isRefunded, "Booking already refunded");
        bookings[_bookingId].isEligibleForRefund = true;
    }
}
