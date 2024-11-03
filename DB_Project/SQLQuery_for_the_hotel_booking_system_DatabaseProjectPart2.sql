--                                       Database Project Part 2 

-- 1. Indexing Requirements 
--    • Hotel Table Indexes 
--      ✓ Add a non-clustered index on the Name column to 
--         optimize queries that search for hotels by name. 
           create nonclustered index idx_hotel_name
           on hotel (Hotel_Name)


--      ✓ Add a non-clustered index on the Rating column 
--         to speed up queries that filter hotels by rating. 
           create nonclustered index idx_hotel_rating
           on hotel (Rating)



--    • Room Table Indexes 
--      ✓ Add a clustered index on the HotelID and RoomNumber 
--         columns to optimize room lookup within a hotel 
		   create nonclustered index idx_Room_HotelID_RoomNumber
           on Room (HotelID, RoomNumber)


--      ✓ Add a non-clustered index on the RoomType column 
--         to improve searches filtering by room type. 
           create nonclustered index idx_Room_RoomType
           on Room (Type)



--    • Booking Table Indexes 
--      ✓ Add a non-clustered index on GuestID to optimize 
--         guest-related booking searches. 
           create nonclustered index idx_Booking_Guestid 
           on Booking (Guestid)


--      ✓ Add a non-clustered index on the Status column to 
--         improve filtering of bookings by status. 
           create nonclustered index idx_Booking_Status 
           on Booking (status)
		   

--      ✓ Add a composite index on RoomID, CheckInDate, and 
--         CheckOutDate for efficient querying of booking schedules.
           create nonclustered index idx_Booking_Roomid_Checkin_Checkout 
		   on Booking (RoomID, CheckinDate, CheckoutDate)

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- 2. Views 
--    • View 1: ViewTopRatedHotels 
--      ✓Create a view that displays the top-rated hotels (rating above 4.5)
--        along with the total number of rooms and average room price for each hotel. 

         create view viewTopRatedHotels as
         select h.HotelID, h.Hotel_Name as HotelName,h.Rating,
                count(r.RoomID) as TotalRooms,
                avg(r.PricePerNight) as AverageRoomPrice
         from Hotel h join 
              Room r on h.HotelID = r.HotelID
         where h.Rating > 4.5
         group by h.HotelID, h.Hotel_Name, h.Rating
         --test
		 select * from ViewTopRatedHotels

--    • View 2: ViewGuestBookings 
--      ✓Create a view that lists each guest along with their total number of bookings
--        and the total amount spent on all bookings. 
        create view ViewGuestBookings as
        select g.GuestID, g.Guest_Name,
		      count(b.BookingID) as TotalBookings,
              sum(b.TotalCost) as TotalAmountSpent
        from Guest g left join 
             Booking b on g.GuestID = b.GuestID
        group by g.GuestID, g.Guest_Name
         --test
		select * from ViewGuestBookings

--    • View 3: ViewAvailableRooms 
--      ✓Create a view that lists available rooms for each hotel, grouped by room type 
--        and sorted by price in ascending order. 
        create view ViewAvailableRooms as
        select r.RoomID,r.RoomNumber,r.Type,r.PricePerNight,h.HotelID,h.Hotel_Name
        from Room r join 
             Hotel h on r.HotelID = h.HotelID
         where r.AvailabilityStatus = 1 
         --test
		 select *
         from ViewAvailableRooms
         order by HotelID, Type, PricePerNight asc



--    • View 4: ViewBookingSummary 
--      ✓Create a view that summarizes bookings by hotel, showing the total number 
--        of bookings, confirmed bookings, pending bookings, and canceled bookings. 

        create view ViewBookingSummary as
        select h.HotelID, h.Hotel_Name,
               count(b.BookingID) AS TotalBookings,
               sum(case when b.Status = 'Confirmed' then 1 else 0 end) as ConfirmedBookings,
               sum(case when b.Status = 'Pending' then 1 else 0 end) as PendingBookings,
               sum(case when b.Status = 'Canceled' then 1 else 0 end) as CanceledBookings
        from Booking b join 
             Hotel h on b.RoomID in (select RoomID 
			                         from Room 
									 where HotelID = h.HotelID)
        group by  h.HotelID, h.Hotel_Name
		
         --test		
		select *
         from ViewBookingSummary

--    • View 5: ViewPaymentHistory 
--      ✓Create a view that lists all payment records along with the guest name, 
--        hotel name, booking status, and total payment made by each guest for each booking. 
        create view ViewPaymentHistory as
        select g.Guest_Name, h.Hotel_Name,
               b.Status as BookingStatus,
               p.Amount as TotalPayment,
               p.Date as PaymentDate
        from Payment p 
		     join
             Booking b on p.BookingID = b.BookingID
			 join
			 Guest g on b.GuestID = g.GuestID
			 join 
			 Room r on b.RoomID = r.RoomID
			 join 
			 Hotel h ON r.HotelID = h.HotelID
         --test
		select *
         from ViewPaymentHistory

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
-- 3. Functions 
--    • Function 1: GetHotelAverageRating 
--      ✓Create a function that takes HotelID as an input and returns 
--        the average rating of that hotel based on guest reviews. 

         create function GetHotelAverageRating (@HotelID int)
         returns decimal(3, 2)
         as
         begin
              declare @AverageRating DECIMAL(3, 2)

             select @AverageRating = avg(rev.Rating)
             from Review rev join 
	              Hotel_Review hr on rev.ReviewID = hr.ReviewID
             where hr.HotelID = @HotelID

             return @AverageRating
         end

		 --test
		 select dbo.GetHotelAverageRating(5) AS AverageRatingForHotel1
		 
		 select HotelID, Hotel_Name,
		        dbo.GetHotelAverageRating(HotelID) AS AverageRating
		 from Hotel 

--    • Function 2: GetNextAvailableRoom 
--      ✓Create a function that finds the next available room of 
--        a specific type within a given hotel. 
         create function GetNextAvailableRoom 
         ( @HotelID int , 
		   @RoomType nvarchar(50)
		   )
         returns int
         as
         begin
             declare @NextAvailableRoom int

             select top 1 @NextAvailableRoom = RoomNumber 
             from Room
             where HotelID = @HotelID
                   and Type = @RoomType
                   and RoomID not in (select RoomID
				                      from Booking 
									  where (CheckInDate <= getdate() AND CheckOutDate >= getdate())
									  )
			 order by RoomNumber

         return @NextAvailableRoom
         end


         --test
		 select dbo.GetNextAvailableRoom(1, 'Double') as NextAvailableRoom
		 select dbo.GetNextAvailableRoom(1, 'Single') as NextAvailableRoom


--    • Function 3: CalculateOccupancyRate 
--      ✓Create a function that takes HotelID as input and returns 
--        the occupancy rate of that hotel based on bookings made within the last 30 days. 
         create function CalculateOccupancyRate (@HotelID int)
         returns float
         as
         begin
             declare @TotalRooms int
             declare @BookedRooms int
             declare @OccupancyRate float

             -- get the total number of rooms
             select @TotalRooms = count(*)
             from Room
             where HotelID = @HotelID

             -- get the number of booked rooms in the last 30 days
             select @BookedRooms = count( distinct r.RoomID)
             from Booking b inner join
                  Room r on b.RoomID = r.RoomID
             where r.HotelID = @HotelID
               and b.CheckInDate <= getdate() and b.CheckOutDate >= dateadd(day, -30, getdate())
               and b.Status in ('Confirmed', 'Check-in')

             -- Calculate occupancy rate
             if @TotalRooms > 0
                 set @OccupancyRate = (@BookedRooms * 1.0 / @TotalRooms) * 100
             else
                 set @OccupancyRate = 0

             return @OccupancyRate
         end
         --test
		 select dbo.CalculateOccupancyRate(1) as OccupancyRate
		 select dbo.CalculateOccupancyRate(4) as OccupancyRate

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--4. Stored Procedures 
--    • Stored Procedure 1: sp_MarkRoomUnavailable 
--      ✓Create a stored procedure that updates the room’s availability status 
--        to unavailable once a booking is confirmed. 
         create procedure sp_MarkRoomUnavailable
		 @RoomID int
		 as
		 begin
             update Room
			 set AvailabilityStatus=0
			 where RoomID =@RoomID
		 end
		 
		 --test
		 exec sp_MarkRoomUnavailable @RoomID =2
		 select * from Room

--    • Stored Procedure 2: sp_UpdateBookingStatus 
--      ✓Create a stored procedure to change the status of a booking to ‘Check-in’,
--        ‘Check-out’, or ‘Canceled’ based on the current date and booking details. 
         create procedure sp_UpdateBookingStatus
             @BookingID int
         as
         begin
             declare @CurrentDate date = getdate()
             declare @CheckInDate date
             declare @CheckOutDate date

             -- to get the check-in and check-out dates for the specified booking
             select @CheckInDate = CheckInDate, @CheckOutDate = CheckOutDate
             from Booking
             where BookingID = @BookingID

             -- to update the booking status based on current date
             if @CurrentDate < @CheckInDate
             begin
                 update Booking
                 set Status = 'Pending'  -- Or whatever is appropriate before check-in
                 where BookingID = @BookingID
             end
             else if @CurrentDate >= @CheckInDate AND @CurrentDate < @CheckOutDate
             begin
                 update Booking
                 set Status = 'Check-in'
                 where BookingID = @BookingID
             end
             else if @CurrentDate >= @CheckOutDate
             begin
                 update Booking
                 set Status = 'Check-out'
                 where BookingID = @BookingID
             end
         end

		 --test 
		 exec sp_UpdateBookingStatus @BookingID = 1


--    • Stored Procedure 3: sp_RankGuestsBySpending 
--      ✓Create a stored procedure that ranks guests by total spending across 
--        all bookings.
         create procedure sp_RankGuestsBySpending
		 as
		 begin
		 select g.GuestID, g.Guest_Name,
		        sum(b.TotalCost) as TotalSpending,
				rank() over (order by sum(b.TotalCost) desc) as [Spending Rank]
		 from Guest g inner join
		      Booking b on g.GuestID = b.GuestID
		 group by g.guestID, g.Guest_Name
		 order by TotalSpending
		 end


		 --test
		 exec sp_RankGuestsBySpending

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--5. Triggers 
--    • Trigger 1: trg_UpdateRoomAvailability 
--      ✓Create a trigger that automatically updates the room’s 
--        availability to ‘Unavailable’ when a new booking is added. 
		 alter trigger trg_UpdateRoomAvailability
		 on Booking
		 after insert
		 as 
		 begin
                 update Room
				 set AvailabilityStatus=0
				 from Room r inner join
				 inserted i on r.RoomID=i.RoomID
				 where r.AvailabilityStatus !=0
		 end

		 --test
		 INSERT INTO Booking (dbo.GuestID, RoomID, BookingDate, CheckInDate, CheckOutDate, Status,PricePerNight)
         VALUES (7, 9, '2024-11-01', '2024-11-05', '2024-11-10', 'Confirmed',350)



--    • Trigger 2: trg_CalculateTotalRevenue 
--      ✓Create a trigger that calculates the total revenue for 
--        a hotel whenever a new payment is added. 

		 Alter trigger trg_CalculateTotalRevenue
		 on Payment
		 after insert 
		 as
		 begin
 		    declare @HotelID int
			declare @TotalRevenue DECIMAL(18, 2)

			--
			SELECT @HotelID = h.HotelID,
                   @TotalRevenue = ( SELECT SUM(p.Amount)
				                     FROM Payment p
									 JOIN Booking b ON p.BookingID = b.BookingID
									 JOIN Room r ON b.RoomID = r.RoomID
									 WHERE r.HotelID = h.HotelID
									 )
            FROM  Booking b
             JOIN Room r ON b.RoomID = r.RoomID
             JOIN Hotel h ON r.HotelID = h.HotelID
             JOIN Payment p ON b.BookingID = p.BookingID
            ORDER BY h.HotelID
			--

			select 'Total Revenue for HotelID ' + CAST(@HotelID AS NVARCHAR(10)) + 
          ' is: ' + CAST(@TotalRevenue AS NVARCHAR(18))
	   end

	   -- test
	   insert into Payment (BookingID, Amount, Date,Method) 
       values (12, 600.00, getdate(),'Credit Card')

	   insert into Payment (BookingID, Amount, Date,Method) 
       values (7, 420, getdate(),'Credit Card')

--    • Trigger 3: trg_CheckInDateValidation 
--      ✓Create a trigger that prevents the insertion of bookings
--        with a check-in date greater than the check out date. 
		 create trigger trg_CheckInDateValidation
		 on Booking
		 after insert 
		 as
		 begin
		    if exists (
			     select 1
				 from Booking b
				 join inserted i on b.BookingID=i.BookingID
				 where i.CheckInDate>i.CheckOutDate)
			begin
			   RAISERROR('Check-in date cannot be greater than check-out date.', 16, 1);
        ROLLBACK TRANSACTION;
		end
		end

