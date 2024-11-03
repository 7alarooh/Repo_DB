DROP TABLE IF EXISTS Hotel_Location

ALTER TABLE Hotel
ADD Location NVARCHAR(100) NOT NULL

-- Insert sample data into Hotels
INSERT INTO Hotel (Hotel_Name, Location, ContactNumber, Rating)
VALUES 
('Grand Plaza', 'New York', '123-456-7890', 4.5),
('Royal Inn', 'London', '234-567-8901', 4.0),
('Ocean Breeze', 'Miami', '456-789-0123', 4.2),
('Mountain Retreat', 'Denver', '567-890-1234', 3.9),
('City Lights Hotel', 'Las Vegas', '678-901-2345', 4.7),
('Desert Oasis', 'Phoenix', '789-012-3456', 4.3),
('Lakeview Lodge', 'Minnesota', '890-123-4567', 4.1),
('Sunset Resort', 'California', '345-678-9012', 3.8);



-- Insert sample data into Rooms
INSERT INTO Room (HotelID, RoomNumber, Type, PricePerNight, AvailabilityStatus)
VALUES 
(1, 101, 'Single', 100, 1),
(1, 102, 'Double', 150, 1),
(1, 103, 'Suite', 300, 1),
(2, 201, 'Single', 90, 1),
(2, 202, 'Double', 140, 0),
(3, 301, 'Suite', 250, 1),
(4, 401, 'Single', 120, 1),
(4, 402, 'Double', 180, 1),
(5, 501, 'Suite', 350, 1),
(5, 502, 'Single', 130, 0),
(6, 601, 'Double', 200, 1),
(6, 602, 'Suite', 400, 0),
(7, 701, 'Single', 110, 1),
(7, 702, 'Double', 160, 1),
(8, 801, 'Suite', 380, 1),
(8, 802, 'Single', 140, 1);

-- Insert sample data into Guests

INSERT INTO Guest (Guest_Name, Contact, IDProof_Type, IDProof_Number,Email)
VALUES 
('John Doe', '567-890-1234', 'Passport', 'A1234567', 'John.Doe@gmail.com'),
('Alice Smith', '678-901-2345', 'Driver License', 'D8901234', 'AliceSmith@gmail.com'),
('Robert Brown', '789-012-3456', 'ID Card', 'ID567890', 'RoBro@gmail.com'),
('Sophia Turner', '012-345-6789', 'Passport', 'B2345678', 'ST123@gmail.com'),
('James Lee', '123-456-7890', 'ID Card', 'ID890123', 'JaLee@gmail.com'),
('Emma White', '234-567-8901', 'Driver License', 'DL3456789', 'EmmaW@gmail.com'),
('Daniel Kim', '345-678-9012', 'Passport', 'C3456789', 'DaKim@gmail.com'),
('Olivia Harris', '456-789-0123', 'ID Card', 'ID234567', 'OliviaHarris@gmail.com'),
('Noah Brown', '567-890-1234', 'Driver License', 'DL4567890', 'NoahBro2121@gmail.com'),
('Ava Scott', '678-901-2345', 'Passport', 'D4567890', 'ava.scott@gmail.com'),
('Mason Clark', '789-012-3456', 'ID Card', 'ID345678', 'Mason@gmail.com');

-- Insert sample data into Bookings


INSERT INTO Booking (GuestID, RoomID, BookingDate, CheckInDate, CheckOutDate, Status, PricePerNight)
VALUES 
(2, 1, '2024-10-01', '2024-10-05', '2024-10-10', 'Confirmed', 100),
(3, 2, '2024-10-15', '2024-10-20', '2024-10-25', 'Pending', 150),
(4, 3, '2024-10-05', '2024-10-07', '2024-10-09', 'Check-in', 300),
(5, 4, '2024-10-10', '2024-10-12', '2024-10-15', 'Confirmed', 90),
(6, 5, '2024-10-16', '2024-10-18', '2024-10-21', 'Pending', 140),
(7, 6, '2024-10-05', '2024-10-08', '2024-10-12', 'Check-in', 250),
(8, 7, '2024-10-22', '2024-10-25', '2024-10-28', 'Confirmed', 120),
(9, 8, '2024-10-15', '2024-10-18', '2024-10-20', 'Pending', 350),
(2, 9, '2024-10-25', '2024-10-27', '2024-10-29', 'Confirmed', 130),
(3, 10, '2024-10-19', '2024-10-21', '2024-10-24', 'Check-in', 200);

select * from Booking
-- Insert sample data into Payments
INSERT INTO Payment (BookingID, Date, Amount, Method)
VALUES 
(3, '2024-10-02', 250, 'Credit Card'),
(3, '2024-10-06', 250, 'Credit Card'),
(4, '2024-10-16', 750, 'Debit Card'),
(6, '2024-10-11', 180, 'Credit Card'),
(6, '2024-10-14', 180, 'Credit Card'),
(7, '2024-10-17', 270, 'Debit Card'),
(7, '2024-10-20', 270, 'Credit Card'),
(8, '2024-10-06', 400, 'Cash'),
(8, '2024-10-09', 400, 'Credit Card'),
(9, '2024-10-23', 450, 'Debit Card');

-- Insert sample data into Staff
INSERT INTO StaffMember(Staff_Name, Position, ContactNumber, HotelID)
VALUES 
('Michael Johnson', 'Manager', '890-123-4567', 1),
('Emily Davis', 'Receptionist', '901-234-5678', 2),
('David Wilson', 'Housekeeper', '012-345-6789', 3),
('Laura Thompson', 'Manager', '901-234-5678', 4),
('Ryan Foster', 'Receptionist', '012-345-6789', 5),
('Sophia Roberts', 'Housekeeper', '123-456-7890', 6),
('Ethan Walker', 'Chef', '234-567-8901', 7),
('Liam Mitchell', 'Security', '345-678-9012', 8),
('Isabella Martinez', 'Manager', '456-789-0123', 1)

-- Insert sample data into Reviews


INSERT INTO Review (Comments, Date, Rating)
OUTPUT INSERTED.ReviewID
VALUES 
('Excellent stay!', '2024-10-11', 5),
('Good service, but room was small.', '2024-10-26', 4),
('Average experience.', '2024-10-12', 3),
('Good experience, but room service was slow.', '2024-10-16', 4),
('Amazing ambiance and friendly staff.', '2024-10-20', 5),
('Decent stay, but room cleanliness needs improvement.', '2024-10-25', 3),
('Great location, will visit again!', '2024-10-27', 4),
('Not satisfied with the facilities.', '2024-10-29', 2);
-- Guest_Review Table
INSERT INTO Guest_Review (GuestID, ReviewID)
VALUES 
(2, 1),  -- replace 1 with actual ReviewID from step 2 for the first review
(3, 2),
(4, 3),
(5, 4),
(6, 5),
(7, 6),
(8, 7),
(9, 8);


-- Hotel_Review Table
INSERT INTO Hotel_Review (HotelID, ReviewID)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(1, 4),
(2, 5),
(3, 6),
(4, 7),
(5, 8);


