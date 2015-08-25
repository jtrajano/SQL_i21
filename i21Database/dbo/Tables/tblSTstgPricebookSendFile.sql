﻿CREATE TABLE [dbo].[tblSTstgPricebookSendFile]
(
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeFormat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [POSCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PosCodeModifierName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [ActiveFlagValue] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [MerchandiseCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RegularSellPrice] INT NULL DEFAULT 0, 
    [Description] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [ItemTypeCode] INT NULL, 
    [ItemTypeSubCode] INT NULL, 
    [PaymentSystemsProductCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictCode] INT NULL, 
    [SellingUnits] NUMERIC(18, 10) NULL, 
    [TaxStrategyID] INT NULL, 
    [ProhibitSaleLocationType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [ProhibitSaleLocationValue] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictionStrategyID] INT NULL  
)
