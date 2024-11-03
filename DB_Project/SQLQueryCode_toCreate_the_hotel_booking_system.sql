-- Database creation
CREATE DATABASE HotelBookingSystem
USE HotelBookingSystem

-- 1. Hotel Table
CREATE TABLE Hotel (
    HotelID INT IDENTITY PRIMARY KEY,
    Hotel_Name NVARCHAR(100) NOT NULL UNIQUE,
    ContactNumber NVARCHAR(20) NOT NULL,
    Rating FLOAT,
    CONSTRAINT CHK_Rating CHECK (Rating BETWEEN 1 AND 5)
)

-- 2. Hotel_Location Table
CREATE TABLE Hotel_Location (
    HotelID INT NOT NULL,
    Location NVARCHAR(100) NOT NULL,
    PRIMARY KEY (HotelID),
    CONSTRAINT FK_HotelLocation_Hotel FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE ON UPDATE CASCADE
)

-- 3. StaffMember Table
CREATE TABLE StaffMember (
    StaffID INT IDENTITY PRIMARY KEY,
    Staff_Name NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    ContactNumber NVARCHAR(20) NOT NULL,
    HotelID INT NOT NULL
)

-- 4. Guest Table
CREATE TABLE Guest (
    GuestID INT IDENTITY PRIMARY KEY,
    Guest_Name NVARCHAR(100) NOT NULL,
    IDProof_Type NVARCHAR(50) NOT NULL,
    IDProof_Number NVARCHAR(50) NOT NULL,
    Contact NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE
)

-- 5. Room Table
CREATE TABLE Room (
    RoomID INT IDENTITY PRIMARY KEY,
    RoomNumber NVARCHAR(10) NOT NULL UNIQUE,
    Type NVARCHAR(20) NOT NULL CHECK (Type IN ('Single', 'Double', 'Suite')),
    PricePerNight DECIMAL(10, 2) NOT NULL CHECK (PricePerNight > 0),
    AvailabilityStatus BIT NOT NULL DEFAULT 1,
    HotelID INT NOT NULL
)

-- 6. Booking Table
CREATE TABLE Booking (
    BookingID INT IDENTITY PRIMARY KEY,
    BookingDate DATE NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Canceled', 'Check-in', 'Check-out')),
    CheckOutDate DATE NOT NULL,
    CheckInDate DATE NOT NULL,
    PricePerNight DECIMAL(10, 2) NOT NULL CHECK (PricePerNight > 0), -- New column added for PricePerNight
    TotalCost AS (DATEDIFF(DAY, CheckInDate, CheckOutDate) * PricePerNight) PERSISTED, 
    GuestID INT NOT NULL,
    RoomID INT NOT NULL,
    CONSTRAINT CHK_CheckIn_CheckOut CHECK (CheckInDate <= CheckOutDate)
)

-- 7. Payment Table
CREATE TABLE Payment (
    PaymentID INT IDENTITY PRIMARY KEY,
    Date DATE NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    Method NVARCHAR(20) NOT NULL,
    BookingID INT NOT NULL
)

-- 8. Review Table
CREATE TABLE Review (
    ReviewID INT IDENTITY PRIMARY KEY,
    Comments NVARCHAR(255) NOT NULL DEFAULT 'No comments',
    Date DATE NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5)
)

-- 9. Hotel_Review Table
CREATE TABLE Hotel_Review (
    HotelID INT NOT NULL,
    ReviewID INT NOT NULL,
    PRIMARY KEY (HotelID, ReviewID)
)

-- 10. Guest_Review Table
CREATE TABLE Guest_Review (
    GuestID INT NOT NULL,
    ReviewID INT NOT NULL,
    PRIMARY KEY (GuestID, ReviewID)
)

-- Adding Foreign Keys with Cascade Rules
-- StaffMember to Hotel
ALTER TABLE StaffMember
ADD CONSTRAINT FK_StaffMember_Hotel FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE ON UPDATE CASCADE

-- Room to Hotel
ALTER TABLE Room
ADD CONSTRAINT FK_Room_Hotel FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE ON UPDATE CASCADE

-- Booking to Guest
ALTER TABLE Booking
ADD CONSTRAINT FK_Booking_Guest FOREIGN KEY (GuestID) REFERENCES Guest(GuestID) ON DELETE CASCADE ON UPDATE CASCADE

-- Booking to Room
ALTER TABLE Booking
ADD CONSTRAINT FK_Booking_Room FOREIGN KEY (RoomID) REFERENCES Room(RoomID) ON DELETE CASCADE ON UPDATE CASCADE

-- Payment to Booking
ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Booking FOREIGN KEY (BookingID) REFERENCES Booking(BookingID) ON DELETE CASCADE ON UPDATE CASCADE

-- Hotel_Review to Hotel
ALTER TABLE Hotel_Review
ADD CONSTRAINT FK_HotelReview_Hotel FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID) ON DELETE CASCADE ON UPDATE CASCADE

-- Hotel_Review to Review
ALTER TABLE Hotel_Review
ADD CONSTRAINT FK_HotelReview_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID) ON DELETE CASCADE ON UPDATE CASCADE

-- Guest_Review to Guest
ALTER TABLE Guest_Review
ADD CONSTRAINT FK_GuestReview_Guest FOREIGN KEY (GuestID) REFERENCES Guest(GuestID) ON DELETE CASCADE ON UPDATE CASCADE

-- Guest_Review to Review
ALTER TABLE Guest_Review
ADD CONSTRAINT FK_GuestReview_Review FOREIGN KEY (ReviewID) REFERENCES Review(ReviewID) ON DELETE CASCADE ON UPDATE CASCADE
