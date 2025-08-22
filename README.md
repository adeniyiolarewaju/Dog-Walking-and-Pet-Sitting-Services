# Dog Walking and Pet Sitting Services - Clarity Smart Contract System

A comprehensive blockchain-based platform for managing dog walking and pet sitting services built on the Stacks blockchain using Clarity smart contracts.

## System Overview

This system provides a decentralized platform for connecting pet owners with professional dog walkers and pet sitters. It manages the entire service lifecycle from booking to completion, ensuring transparency, security, and accountability for all parties involved.

## Core Features

### Pet Management
- **Pet Registration**: Owners can register their pets with detailed profiles including breed, age, medical conditions, and behavioral notes
- **Care Instructions**: Comprehensive care requirements, feeding schedules, and special needs documentation
- **Emergency Contacts**: Veterinary information and emergency contact details
- **Medical Records**: Vaccination status, medication requirements, and health conditions

### Walker Management
- **Walker Profiles**: Professional walker registration with experience, certifications, and service areas
- **Availability Scheduling**: Dynamic schedule management for walker availability
- **Service Pricing**: Transparent pricing structure for different service types
- **Rating System**: Performance tracking and customer feedback integration

### Booking System
- **Service Requests**: Pet owners can create detailed service requests with specific requirements
- **Walker Matching**: Automatic matching based on location, availability, and pet requirements
- **Booking Confirmation**: Secure booking process with deposit handling
- **Schedule Coordination**: Real-time schedule management and conflict resolution

### GPS Tracking & Documentation
- **Route Tracking**: GPS coordinate logging for walk routes and exercise areas
- **Duration Monitoring**: Accurate timing of service delivery
- **Photo Updates**: Real-time photo sharing during service completion
- **Exercise Metrics**: Distance walked, time spent, and activity levels recorded

### Payment & Transparency
- **Escrow System**: Secure payment holding until service completion
- **Transparent Pricing**: Clear fee structure with no hidden costs
- **Automatic Payments**: Smart contract-based payment release upon service verification
- **Dispute Resolution**: Built-in mechanisms for handling service disputes

## Smart Contract Architecture

### 1. Pet Registry Contract (`pet-registry.clar`)
Manages pet profiles, owner information, and care instructions.

### 2. Walker Management Contract (`walker-management.clar`)
Handles walker registration, availability, and service capabilities.

### 3. Booking System Contract (`booking-system.clar`)
Coordinates service requests, bookings, and schedule management.

### 4. GPS Tracking Contract (`gps-tracking.clar`)
Records location data, routes, and service completion verification.

### 5. Payment System Contract (`payment-system.clar`)
Manages escrow, payments, and financial transactions.

## Data Types

### Pet Profile
- Pet ID (unique identifier)
- Owner principal
- Pet name, breed, age
- Medical conditions and medications
- Behavioral notes and special requirements
- Emergency contact information
- Veterinary details

### Walker Profile
- Walker ID (unique identifier)
- Walker principal
- Service areas and availability
- Pricing structure
- Certifications and experience
- Rating and review history

### Service Booking
- Booking ID (unique identifier)
- Pet ID and Walker ID
- Service type and duration
- Scheduled date and time
- Special instructions
- Payment amount and status

### GPS Route Data
- Route ID (unique identifier)
- Booking ID reference
- GPS coordinates array
- Timestamps for each location
- Total distance and duration
- Service completion status

## Security Features

- **Principal-based Authentication**: All actions require proper wallet authentication
- **Data Validation**: Comprehensive input validation and error handling
- **Access Control**: Role-based permissions for different user types
- **Immutable Records**: Blockchain-based audit trail for all transactions
- **Emergency Protocols**: Built-in safety mechanisms for urgent situations

## Getting Started

### Prerequisites
- Stacks wallet for blockchain interaction
- Clarinet for local development and testing
- Node.js for running the test suite

### Installation
1. Clone the repository
2. Install dependencies: `npm install`
3. Run tests: `npm test`
4. Deploy contracts: `clarinet deploy`

### Usage
1. **Pet Owners**: Register pets, create service requests, track services
2. **Dog Walkers**: Register as service provider, manage availability, complete services
3. **System Monitoring**: Track all activities through blockchain transparency

## Testing

Comprehensive test suite covering:
- Contract deployment and initialization
- Pet and walker registration flows
- Booking creation and management
- GPS tracking and route verification
- Payment processing and escrow handling
- Error conditions and edge cases

## Contributing

This project follows standard Clarity development practices with emphasis on security, transparency, and user experience. All contributions should include comprehensive tests and documentation.

## License

MIT License - See LICENSE file for details.
