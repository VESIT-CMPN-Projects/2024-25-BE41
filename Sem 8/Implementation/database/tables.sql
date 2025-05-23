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
/****** Object:  Table [dbo].[bids]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[bids](
	[bid_id] [int] IDENTITY(1,1) NOT NULL,
	[query_id] [int] NOT NULL,
	[restaurant_id] [int] NOT NULL,
	[bid_price] [decimal](10, 2) NOT NULL,
	[estimated_delivery_time] [int] NOT NULL,
	[additional_info] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
	[status] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[bid_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[bids] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[custom_items]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[custom_items](
	[custom_item_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[item_name] [varchar](255) NOT NULL,
	[item_description] [nvarchar](max) NULL,
	[quantity] [int] NOT NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[custom_item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[custom_items] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[dish_feedback]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dish_feedback](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[order_detail_id] [int] NOT NULL,
	[rating] [int] NULL,
	[comments] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[dish_feedback] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[forgot_password_table]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[forgot_password_table](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[token] [nvarchar](max) NULL,
	[time_to_expire] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[forgot_password_table] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[order_details]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[order_details](
	[order_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[order_id] [int] NOT NULL,
	[item_id] [int] NOT NULL,
	[quantity] [int] NOT NULL,
	[price] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[order_detail_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[order_details] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[orders]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[orders](
	[order_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[restaurant_id] [int] NOT NULL,
	[order_date] [datetime] NULL,
	[order_status] [varchar](50) NULL,
	[quantity] [int] NOT NULL,
	[total_amount] [decimal](10, 2) NULL,
	[query_id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[order_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[orders] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[queries]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[queries](
	[query_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NULL,
	[food_type] [varchar](50) NULL,
	[occasion] [varchar](100) NULL,
	[people] [int] NULL,
	[food_items] [nvarchar](max) NULL,
	[budget] [decimal](10, 2) NULL,
	[event_date] [date] NULL,
	[event_time] [time](7) NULL,
	[additional_info] [nvarchar](max) NULL,
	[status] [varchar](50) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[query_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[queries] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[restaurant_feedback]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[restaurant_feedback](
	[feedback_id] [int] IDENTITY(1,1) NOT NULL,
	[restaurant_id] [int] NOT NULL,
	[hygiene] [int] NULL,
	[packaging] [int] NULL,
	[quality] [int] NULL,
	[delivered_on_time] [int] NULL,
	[comments] [nvarchar](max) NULL,
	[created_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[feedback_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[restaurant_feedback] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[restaurant_menu_items]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[restaurant_menu_items](
	[item_id] [int] IDENTITY(1,1) NOT NULL,
	[restaurant_id] [int] NOT NULL,
	[item_name] [varchar](255) NOT NULL,
	[item_description] [varchar](max) NULL,
	[price] [decimal](10, 2) NOT NULL,
	[veg_nonveg] [int] NULL,
	[item_image] [varchar](255) NULL,
	[is_active_yn] [int] NULL,
	[average_rating] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[item_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[restaurant_menu_items] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[restaurant_queries]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[restaurant_queries](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[query_id] [int] NULL,
	[restaurant_id] [int] NULL,
	[status] [varchar](50) NULL,
	[updated_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[restaurant_queries] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[restaurants]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[restaurants](
	[restaurant_id] [int] IDENTITY(1,1) NOT NULL,
	[restaurant_name] [varchar](255) NOT NULL,
	[restaurant_description] [varchar](max) NULL,
	[address] [varchar](255) NULL,
	[contact_no] [varchar](15) NULL,
	[available_days] [varchar](50) NULL,
	[available_time] [varchar](50) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[active_yn] [int] NULL,
	[user_id] [int] NULL,
	[average_rating] [float] NULL,
PRIMARY KEY CLUSTERED 
(
	[restaurant_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[restaurants] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[user_role]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[user_role](
	[role_id] [int] IDENTITY(1,1) NOT NULL,
	[role_name] [varchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[role_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[user_role] TO  SCHEMA OWNER 
GO
/****** Object:  Table [dbo].[users]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[full_name] [varchar](255) NOT NULL,
	[user_role_id] [int] NOT NULL,
	[dob] [date] NULL,
	[user_phone] [varchar](15) NULL,
	[user_email] [varchar](255) NULL,
	[password] [varchar](255) NOT NULL,
	[profile_image] [varchar](255) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[active_yn] [int] NULL,
	[token] [varchar](max) NULL,
	[time_to_expire] [datetime] NULL,
	[username] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER AUTHORIZATION ON [dbo].[users] TO  SCHEMA OWNER 
GO
ALTER TABLE [dbo].[bids] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[bids] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[custom_items] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[dish_feedback] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[forgot_password_table] ADD  DEFAULT (getdate()) FOR [time_to_expire]
GO
ALTER TABLE [dbo].[orders] ADD  DEFAULT (getdate()) FOR [order_date]
GO
ALTER TABLE [dbo].[queries] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[queries] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[restaurant_feedback] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[restaurant_menu_items] ADD  DEFAULT ((0)) FOR [veg_nonveg]
GO
ALTER TABLE [dbo].[restaurant_menu_items] ADD  DEFAULT ('default.png') FOR [item_image]
GO
ALTER TABLE [dbo].[restaurant_menu_items] ADD  DEFAULT ((1)) FOR [is_active_yn]
GO
ALTER TABLE [dbo].[restaurant_menu_items] ADD  DEFAULT ((0)) FOR [average_rating]
GO
ALTER TABLE [dbo].[restaurant_queries] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[restaurant_queries] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[restaurants] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[restaurants] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[restaurants] ADD  DEFAULT ((1)) FOR [active_yn]
GO
ALTER TABLE [dbo].[restaurants] ADD  DEFAULT ((0)) FOR [average_rating]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ('default.png') FOR [profile_image]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (getdate()) FOR [created_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT (getdate()) FOR [updated_at]
GO
ALTER TABLE [dbo].[users] ADD  DEFAULT ((1)) FOR [active_yn]
GO
ALTER TABLE [dbo].[bids]  WITH CHECK ADD  CONSTRAINT [FK_bids_query] FOREIGN KEY([query_id])
REFERENCES [dbo].[queries] ([query_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bids] CHECK CONSTRAINT [FK_bids_query]
GO
ALTER TABLE [dbo].[bids]  WITH CHECK ADD  CONSTRAINT [FK_bids_restaurant] FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bids] CHECK CONSTRAINT [FK_bids_restaurant]
GO
ALTER TABLE [dbo].[custom_items]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[dish_feedback]  WITH CHECK ADD FOREIGN KEY([order_detail_id])
REFERENCES [dbo].[order_details] ([order_detail_id])
GO
ALTER TABLE [dbo].[forgot_password_table]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
ALTER TABLE [dbo].[forgot_password_table]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD FOREIGN KEY([item_id])
REFERENCES [dbo].[restaurant_menu_items] ([item_id])
GO
ALTER TABLE [dbo].[order_details]  WITH CHECK ADD FOREIGN KEY([order_id])
REFERENCES [dbo].[orders] ([order_id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([query_id])
REFERENCES [dbo].[queries] ([query_id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
ALTER TABLE [dbo].[orders]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
ALTER TABLE [dbo].[queries]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[restaurant_feedback]  WITH CHECK ADD FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[restaurant_menu_items]  WITH CHECK ADD FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
GO
ALTER TABLE [dbo].[restaurant_queries]  WITH CHECK ADD FOREIGN KEY([query_id])
REFERENCES [dbo].[queries] ([query_id])
GO
ALTER TABLE [dbo].[restaurant_queries]  WITH CHECK ADD FOREIGN KEY([restaurant_id])
REFERENCES [dbo].[restaurants] ([restaurant_id])
GO
ALTER TABLE [dbo].[restaurants]  WITH CHECK ADD FOREIGN KEY([user_id])
REFERENCES [dbo].[users] ([user_id])
GO
ALTER TABLE [dbo].[users]  WITH CHECK ADD FOREIGN KEY([user_role_id])
REFERENCES [dbo].[user_role] ([role_id])
GO
ALTER TABLE [dbo].[custom_items]  WITH CHECK ADD CHECK  (([quantity]>(0)))
GO
ALTER TABLE [dbo].[dish_feedback]  WITH CHECK ADD CHECK  (([rating]>=(1) AND [rating]<=(5)))
GO
ALTER TABLE [dbo].[restaurant_feedback]  WITH CHECK ADD CHECK  (([delivered_on_time]>=(1) AND [delivered_on_time]<=(5)))
GO
ALTER TABLE [dbo].[restaurant_feedback]  WITH CHECK ADD CHECK  (([hygiene]>=(1) AND [hygiene]<=(5)))
GO
ALTER TABLE [dbo].[restaurant_feedback]  WITH CHECK ADD CHECK  (([packaging]>=(1) AND [packaging]<=(5)))
GO
ALTER TABLE [dbo].[restaurant_feedback]  WITH CHECK ADD CHECK  (([quality]>=(1) AND [quality]<=(5)))
GO
/****** Object:  Trigger [dbo].[update_dish_rating]    Script Date: 31-03-2025 03:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[update_dish_rating]
ON [dbo].[dish_feedback]
AFTER INSERT
AS
BEGIN
    UPDATE restaurant_menu_items
    SET average_rating = (
        SELECT AVG(rating)
        FROM dish_feedback
        WHERE order_detail_id IN (
            SELECT order_detail_id 
            FROM order_details 
            WHERE item_id = restaurant_menu_items.item_id
        )
    )
    WHERE item_id IN (
        SELECT item_id 
        FROM order_details 
        WHERE order_detail_id IN (SELECT order_detail_id FROM inserted)
    );
END;

GO
ALTER TABLE [dbo].[dish_feedback] ENABLE TRIGGER [update_dish_rating]
GO
/****** Object:  Trigger [dbo].[update_restaurant_rating]    Script Date: 31-03-2025 03:02:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[update_restaurant_rating]
ON [dbo].[restaurant_feedback]
AFTER INSERT
AS
BEGIN
    UPDATE restaurants
    SET average_rating = (
        SELECT AVG((hygiene + packaging + quality + delivered_on_time) / 4.0)
        FROM restaurant_feedback
        WHERE restaurant_id = restaurants.restaurant_id
    )
    WHERE restaurant_id IN (SELECT restaurant_id FROM inserted);
END;
GO
ALTER TABLE [dbo].[restaurant_feedback] ENABLE TRIGGER [update_restaurant_rating]
GO
