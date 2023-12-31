﻿CREATE TABLE [dbo].[tblSTstgComboSalesFile]
(
	[intComboSalesFile] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [CBTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PromotionID] INT NULL, 
	[PromotionReason] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [LinkCodeType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[LinkCodeValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[ComboDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[ComboPrice] NUMERIC(18, 6) NULL, 
    [ItemListID] INT NULL, 
    [ComboItemQuantity] INT NULL, 
	[ComboItemQuantityUOM] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [ComboItemUnitPrice] NUMERIC(18, 6) NULL, 
    [StartDate] DATETIME NULL, 
	[StartTime] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [StopDate] DATETIME NULL, 
	[StopTime] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[TransactionLimit] INT NULL, 
	[Priority] INT NULL,
	[WeekdayAvailabilitySunday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[WeekdaySunday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilityMonday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayMonday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilityTuesday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayTuesday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilityWednesday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayWednesday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilityThursday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayThursday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilityFriday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayFriday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdayAvailabilitySaturday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[WeekdaySaturday] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSTstgComboSalesFile] PRIMARY KEY ([intComboSalesFile])  
)
