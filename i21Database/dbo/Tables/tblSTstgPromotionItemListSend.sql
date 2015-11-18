﻿CREATE TABLE [dbo].[tblSTstgPromotionItemListSend]
(
	[intPromotionItemListSend] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ILTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ItemListID] INT NULL, 
    [ItemListDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeFormat] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [POSCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeModifierName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeModifierValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[MerchandiseCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSTstgPromotionItemListSend] PRIMARY KEY ([intPromotionItemListSend])
)
