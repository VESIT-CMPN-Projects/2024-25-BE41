/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2022 (16.0.1135)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2022
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [smartserve]
GO
/****** Object:  StoredProcedure [dbo].[AddMenuItem]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[AddMenuItem]
    @user_id INT,
    @item_name NVARCHAR(255),
    @item_description NVARCHAR(MAX),
    @price DECIMAL(10,2),
    @veg_nonveg NVARCHAR(10) -- Assuming 'Veg' or 'Non-Veg'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @restaurant_id INT;

    -- Get restaurant_id for the given user_id (owner)
    SELECT @restaurant_id = restaurant_id 
    FROM restaurants 
    WHERE user_id = @user_id;

    -- Check if a restaurant exists for this user_id
    IF @restaurant_id IS NOT NULL
    BEGIN
        -- Insert the new menu item
        INSERT INTO [restaurant_menu_items] (restaurant_id, item_name, item_description, price, veg_nonveg, is_active_yn, average_rating)
        VALUES (@restaurant_id, @item_name, @item_description, @price, @veg_nonveg, 1, 0);

        PRINT 'Menu item added successfully!';
    END
    ELSE
    BEGIN
        -- Raise an error if no restaurant is found
        THROW 50000, 'No restaurant found for the given user_id', 1;
    END
END;
GO
ALTER AUTHORIZATION ON [dbo].[AddMenuItem] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[InsertOrderAndDetails]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[InsertOrderAndDetails](
    @user_id INT,
    @restaurant_id INT,
    @order_date DATETIME,
    @order_status VARCHAR(50),
    @quantity INT,
    @total_amount DECIMAL(10,2),
    @cart_items NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @order_id INT;
    
    BEGIN TRANSACTION;

    -- Insert into orders table
    INSERT INTO orders (user_id, restaurant_id, order_date, order_status, quantity, total_amount)
    VALUES (@user_id, @restaurant_id, @order_date, @order_status, @quantity, @total_amount);

    -- Get generated order ID
    SET @order_id = SCOPE_IDENTITY();

    IF @order_id IS NULL OR @order_id = 0
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN -1;
    END

    -- Insert into order_details
    INSERT INTO order_details (order_id, item_id, quantity, price)
    SELECT 
        @order_id, 
        JSON_VALUE(cart.value, '$.item_id') AS item_id,
        JSON_VALUE(cart.value, '$.quantity') AS quantity,
        JSON_VALUE(cart.value, '$.price') AS price
    FROM OPENJSON(@cart_items) AS cart;

    COMMIT TRANSACTION;
    RETURN @order_id;
END;
GO
ALTER AUTHORIZATION ON [dbo].[InsertOrderAndDetails] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[PlaceOrderFromBid]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[PlaceOrderFromBid]
    @bid_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @query_id INT, @restaurant_id INT, @user_id INT, @food_items NVARCHAR(MAX),  @price INT,
            @order_id INT, @quantity INT, @total_amount DECIMAL(10,2);

    -- Start transaction for data consistency
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- 1️⃣ Get Query ID and Restaurant ID from Bid
        SELECT @query_id = query_id, @restaurant_id = restaurant_id , @price = bid_price
        FROM bids
        WHERE bid_id = @bid_id;

        -- 2️⃣ Get User ID, food items, and quantity from Queries table
        SELECT @user_id = user_id, @food_items = food_items, @quantity = people
        FROM queries
        WHERE query_id = @query_id;

        -- 3️⃣ Create Order
        INSERT INTO orders (user_id, restaurant_id, order_date, order_status, query_id, quantity, total_amount)
        VALUES (@user_id, @restaurant_id, GETDATE(), 'Pending', @query_id, @quantity, @price);

        SET @order_id = SCOPE_IDENTITY(); -- Get newly created order ID

        -- 4️⃣ Process each food item
        DECLARE @item_name NVARCHAR(255), @existing_item_id INT, @pricee DECIMAL(10,2);

        DECLARE food_cursor CURSOR FOR 
        SELECT value FROM STRING_SPLIT(@food_items, ','); -- Splitting food items

        OPEN food_cursor;
        
        FETCH NEXT FROM food_cursor INTO @item_name;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Reset variables for each item
            SET @existing_item_id = NULL;
            SET @pricee = NULL;

            PRINT 'Processing food item: ' + @item_name; -- Debugging

            -- 4.1️⃣ Check if item exists in restaurant's menu
            SELECT @existing_item_id = item_id, @pricee = price
            FROM restaurant_menu_items
            WHERE item_name = @item_name AND restaurant_id = @restaurant_id;

            IF @existing_item_id IS NOT NULL
            BEGIN
                -- 4.2️⃣ Insert into order_details if item exists
                INSERT INTO order_details (order_id, item_id, quantity, price)
                VALUES (@order_id, @existing_item_id, @quantity, @pricee);
            END
            ELSE
            BEGIN
                -- 4.3️⃣ Insert into restaurant_menu_items first
                INSERT INTO restaurant_menu_items (restaurant_id, item_name, price)
                VALUES (@restaurant_id, @item_name, 100); -- Default price 100

                SET @existing_item_id = SCOPE_IDENTITY(); -- Get newly created menu item ID

                -- 4.4️⃣ Insert into order_details referencing newly added item
                INSERT INTO order_details (order_id, item_id, quantity, price)
                VALUES (@order_id, @existing_item_id, @quantity, 100);
            END

            -- Fetch next item
            FETCH NEXT FROM food_cursor INTO @item_name;
        END

        CLOSE food_cursor;
        DEALLOCATE food_cursor;

        -- 5️⃣ Update total order amount
        SELECT @total_amount = COALESCE(SUM(price * quantity), 0)
        FROM order_details
        WHERE order_id = @order_id;

        UPDATE bids 
        SET status = 'Accepted'
        WHERE bid_id = @bid_id;

        UPDATE orders
        SET total_amount = @total_amount
        WHERE order_id = @order_id;

        -- 6️⃣ Update order status to 'Processed'
        UPDATE orders
        SET order_status = 'Processed'
        WHERE order_id = @order_id;

        UPDATE queries
        SET status = 'Accepted'
        WHERE query_id = @query_id;

        -- Commit the transaction
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback in case of any failure
        ROLLBACK TRANSACTION;
        PRINT 'Error Occurred: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
ALTER AUTHORIZATION ON [dbo].[PlaceOrderFromBid] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_DecideQuery]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [dbo].[sp_DecideQuery]
    @query_id INT,
    @status VARCHAR(50)  -- 'accepted' or 'rejected'
AS
BEGIN
    SET NOCOUNT ON;

    -- Update the restaurant_queries table
    UPDATE restaurant_queries
    SET status = @status, updated_at = GETDATE()
    WHERE query_id = @query_id  ;

   
        UPDATE queries
        SET status = @status 
        WHERE query_id = @query_id;

    return 1
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_DecideQuery] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_fetch_restaurant_details]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [dbo].[sp_fetch_restaurant_details]
    @restaurant_id INT
AS
BEGIN
    SELECT 
        *
    FROM 
        restaurants r inner join users u on r.user_id = u.user_id
    WHERE 
        restaurant_id = @restaurant_id;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_fetch_restaurant_details] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_generate_token]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_generate_token] 
    @email VARCHAR(100)
AS
BEGIN
    DECLARE @userid INT
	Declare @token NVARCHAR(MAX) = NEWID();
    SELECT @userid = user_id FROM users WHERE user_email = @email;
    INSERT INTO dbo.forgot_password_table (user_id, token, time_to_expire) 
    VALUES (@userid, @token, DATEADD(mi, 15, GETDATE()));
	
	select @token As GeneratedToken 
END
GO
ALTER AUTHORIZATION ON [dbo].[sp_generate_token] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_get_order_details]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [dbo].[sp_get_order_details]
    @order_id INT 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.order_id,
        o.order_date,
        o.order_status,
        o.quantity AS total_quantity,
        o.total_amount AS total_amount,

        -- User Details
        u.user_id,
        u.full_name AS customer_name,
        u.user_email,
        u.user_phone,

        -- Restaurant Details
        r.restaurant_id,
        r.restaurant_name,
        r.address AS restaurant_address,
        r.contact_no AS restaurant_contact,

        -- JSON Array of Items
        (
            SELECT 
			oi.order_detail_id,
                oi.item_id,
                mi.item_name,
                mi.item_description,
                mi.price AS item_price,
                oi.quantity AS item_quantity
            FROM order_details oi
            JOIN restaurant_menu_items mi ON oi.item_id = mi.item_id
            WHERE oi.order_id = o.order_id
            FOR JSON PATH
        ) AS order_items_json

    FROM orders o
    JOIN users u ON o.user_id = u.user_id
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.order_id = @order_id;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_get_order_details] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_get_queries]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE   procedure [dbo].[sp_get_queries]
  AS
  BEGIn 
  SELECT TOP (1000) [query_id]
      ,q.[user_id]
      ,q.[food_type]
      ,q.[occasion]
      ,q.[people]
      ,q.[food_items]
      ,q.[budget]
      ,q.[event_date]
      ,q.[event_time]
      ,q.[additional_info]
      ,q.[status]
      ,q.[created_at],
	  u.user_email,u.full_name
  FROM [smartserve].[dbo].[queries] q inner join dbo.users u on q.user_id = u.user_id 
  end
GO
ALTER AUTHORIZATION ON [dbo].[sp_get_queries] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_get_restaurant_menu]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE     PROCEDURE [dbo].[sp_get_restaurant_menu]
    @restaurant_id INT
AS
BEGIN
    SELECT item_id, item_name, item_description, price, veg_nonveg, item_image, is_active_yn
    FROM restaurant_menu_items
    WHERE restaurant_id = @restaurant_id AND is_active_yn = 1
END
GO
ALTER AUTHORIZATION ON [dbo].[sp_get_restaurant_menu] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_get_restaurants]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE       PROCEDURE [dbo].[sp_get_restaurants]
AS
BEGIN
    SELECT 
        *
    FROM 
        restaurants r inner join users u on r.user_id = u.user_id
    WHERE r.active_yn = 1
END
GO
ALTER AUTHORIZATION ON [dbo].[sp_get_restaurants] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetQueriesForRestaurant]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROCEDURE [dbo].[sp_GetQueriesForRestaurant]
    @restaurant_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        q.query_id,
        q.food_type,
        q.occasion,
        q.people,
        q.food_items,
        q.budget,
        q.event_date,
        q.event_time,
        q.additional_info,
        q.status AS query_status,
        q.created_at,
        u.user_id,
        u.full_name,
        u.user_phone,
        u.user_email
    FROM 
        restaurant_queries rq
    JOIN 
        queries q ON rq.query_id = q.query_id
    JOIN 
        users u ON q.user_id = u.user_id
    WHERE 
        rq.restaurant_id = @restaurant_id and rq.status != 'accepted'
    ORDER BY 
        q.created_at DESC; -- Show latest queries first
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_GetQueriesForRestaurant] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_GetQueriesForUser]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE         PROCEDURE [dbo].[sp_GetQueriesForUser]
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        q.query_id,
        q.food_type,
        q.occasion,
        q.people,
        q.food_items,
        q.budget,
        q.event_date,
        q.event_time,
        q.additional_info,
        q.status AS query_status,
        q.created_at,
        u.user_id,
        u.full_name,
        u.user_phone,
        u.user_email
    FROM 
       
        queries q 
    JOIN 
        users u ON q.user_id = u.user_id
    WHERE 
        q.user_id = @user_id
		ORDER BY 
        q.created_at DESC; -- Show latest queries first
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_GetQueriesForUser] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_InsertQuery]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[sp_InsertQuery]
    @user_id INT,
    @food_type VARCHAR(50),
    @occasion VARCHAR(50),
    @people INT,
    @food_items NVARCHAR(MAX),
    @budget DECIMAL(10,2),
    @event_date DATE,
    @event_time TIME,
    @additional_info NVARCHAR(MAX)
    
AS
BEGIN
    
	SET NOCOUNT ON;

    INSERT INTO queries (user_id, food_type, occasion, people, food_items, budget, event_date, event_time, additional_info, status, created_at)
    VALUES (@user_id, @food_type, @occasion, @people, @food_items, @budget, @event_date, @event_time, @additional_info, 'pending', GETDATE());
	DECLARE @query_id INT;
    -- Get the newly inserted query ID
    SET @query_id = SCOPE_IDENTITY();

    -- Insert into restaurant_queries so all restaurants can see it
    INSERT INTO restaurant_queries (query_id, restaurant_id, status)
    SELECT @query_id, restaurant_id, 'pending' FROM restaurants;
END;
GO
ALTER AUTHORIZATION ON [dbo].[sp_InsertQuery] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_login_user]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE                 PROCEDURE [dbo].[sp_login_user]
    @username VARCHAR(100),
    @password NVARCHAR(MAX)
AS
BEGIN
    DECLARE @count INT;
            SELECT @count = COUNT(1)
            FROM dbo.users
            WHERE username = @username
                AND password = @password 
    IF @count = 1
    BEGIN
	UPDATE dbo.users 
	SET token = NEWID(),
	time_to_expire =  DATEADD(MI, 30, GETDATE())
	where username = @username
	
        SELECT *
        FROM dbo.users
        WHERE username = @username
        AND password = @password;
        
    END
    ELSE
    BEGIN
        SELECT 0 as validYN;
    END
END

GO
ALTER AUTHORIZATION ON [dbo].[sp_login_user] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_register_restaurant]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_register_restaurant]
    @full_name VARCHAR(255),
    @password NVARCHAR(MAX),
    @user_email VARCHAR(255),
    @user_phone VARCHAR(15),
    @dob VARCHAR(255),
    @restaurant_name VARCHAR(255),           -- New parameter for restaurant name
    @restaurant_description VARCHAR(MAX),    -- New parameter for restaurant description
    @address VARCHAR(255),                   -- New parameter for restaurant address
    @contact_no VARCHAR(15),                 -- New parameter for restaurant contact number
    @available_days VARCHAR(50),             -- New parameter for available days
    @available_time VARCHAR(50),             -- New parameter for available time
    @token VARCHAR(MAX) = NULL,              -- Optional token (default NULL)
    @time_to_expire DATETIME = NULL          -- Optional expiration (default NULL)
AS
BEGIN
    BEGIN TRY
        -- Check if the user already exists (based on email or phone number)
        IF EXISTS (SELECT 1 FROM dbo.users WHERE user_email = @user_email OR user_phone = @user_phone)
        BEGIN
            RAISERROR('User with this email or phone number already exists', 16, 1);
            RETURN;
        END

        DECLARE @username VARCHAR(255);
        DECLARE @base_username VARCHAR(255);
        DECLARE @username_attempt VARCHAR(255);
        DECLARE @counter INT = 0;

        -- Generate base username
        SET @base_username = LOWER(LEFT(@full_name, CHARINDEX(' ', @full_name) - 1)) + 
                             LOWER(RIGHT(@full_name, LEN(@full_name) - CHARINDEX(' ', @full_name)));

        -- Check if the username exists and handle conflicts
        SET @username_attempt = @base_username;

        WHILE EXISTS (SELECT 1 FROM dbo.users WHERE username = @username_attempt)
        BEGIN
            SET @counter = @counter + 1;
            SET @username_attempt = @base_username + CAST(@counter AS VARCHAR(10));
        END

        SET @username = @username_attempt;

        -- Insert new user
        INSERT INTO dbo.users
            (full_name, password, username, user_email, user_phone, dob, user_role_id, created_at, updated_at, active_yn, token, time_to_expire)
        VALUES
            (@full_name, @password, @username, @user_email, @user_phone, CONVERT(DATE, @dob, 120), 2, GETDATE(), GETDATE(), 1, @token, @time_to_expire);

        DECLARE @user_id INT;
        SET @user_id = SCOPE_IDENTITY(); -- Capture the newly inserted user's ID

        -- Insert new restaurant details linked to the user
        INSERT INTO dbo.restaurants
            (restaurant_name, restaurant_description, address, contact_no, available_days, available_time, created_at, updated_at, active_yn, user_id)
        VALUES
            (@restaurant_name, @restaurant_description, @address, @contact_no, @available_days, @available_time, GETDATE(), GETDATE(), 1, @user_id);

        -- Return success message
        SELECT 'User and restaurant registered successfully' AS message;
    END TRY
    BEGIN CATCH
        -- Handle errors and return error message
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO
ALTER AUTHORIZATION ON [dbo].[sp_register_restaurant] TO  SCHEMA OWNER 
GO
/****** Object:  StoredProcedure [dbo].[sp_register_user]    Script Date: 31-03-2025 03:04:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE       PROCEDURE [dbo].[sp_register_user]
    @full_name VARCHAR(255),
	    @password NVARCHAR(MAX),
    @user_email VARCHAR(255),
    @user_phone VARCHAR(15),
    @dob VARCHAR(255),
    @token VARCHAR(MAX) = NULL,            -- Optional token (default NULL)
    @time_to_expire DATETIME = NULL        -- Optional expiration (default NULL)
AS
BEGIN
    -- Error handling
    BEGIN TRY
     
		  DECLARE @username VARCHAR(255);
    DECLARE @base_username VARCHAR(255);
    DECLARE @username_attempt VARCHAR(255);
    DECLARE @counter INT = 0;
		  -- Generate base username by concatenating the first letter of first name with the last name
    SET @base_username = LOWER(LEFT(@full_name, CHARINDEX(' ', @full_name) - 1)) + 
                         LOWER(RIGHT(@full_name, LEN(@full_name) - CHARINDEX(' ', @full_name)));

    -- Check if this username already exists
    SET @username_attempt = @base_username;

    WHILE EXISTS (SELECT 1 FROM dbo.users WHERE username = @username_attempt)
    BEGIN
        -- Increment the counter and append it to the base username
        SET @counter = @counter + 1;
        SET @username_attempt = @base_username + CAST(@counter AS VARCHAR(10));
    END

    -- Set the final username
    SET @username = @username_attempt;
        -- Insert new user with default values where needed
        INSERT INTO dbo.users
            (full_name, password, username ,user_email, user_phone, dob, user_role_id, created_at, updated_at, active_yn, token, time_to_expire)
        VALUES
            (@full_name, @password,@username, @user_email, @user_phone,  CONVERT(DATE, @dob, 120) , 1, GETDATE(), GETDATE(), 1, @token, @time_to_expire);

        -- Return success message
        SELECT 'User registered successfully' AS message;
    END TRY
    BEGIN CATCH
        -- Handle errors and return error message
        SELECT ERROR_MESSAGE() AS message;
    END CATCH
END
GO
ALTER AUTHORIZATION ON [dbo].[sp_register_user] TO  SCHEMA OWNER 
GO
