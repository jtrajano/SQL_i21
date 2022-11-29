﻿CREATE TABLE [dbo].[tblSTstgPricebookSendFile]
(
	[intPricebookSendFile] INT NOT NULL IDENTITY,
	[StoreLocationID] INT NULL, 
    [VendorName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [VendorModelVersion] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [TableActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[RecordActionEffectiveDate] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
    [ITTDetailRecordActionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [POSCodeFormat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [POSCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [PosCodeModifierName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [PosCodeModifierValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [ActiveFlagValue] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
	[InventoryValuePrice]  NUMERIC(18, 6) NULL,
    [MerchandiseCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [RegularSellPrice] NUMERIC(18, 6) NULL DEFAULT 0, 
    [Description] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[LinkCodeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[LinkCodeValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
    [ItemTypeCode] INT NULL, 
    [ItemTypeSubCode] INT NULL, 
    [PaymentSystemsProductCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictCode] INT NULL, 
    [SellingUnits] NUMERIC(18, 6) NULL, 
    [TaxStrategyID] INT NULL, 
    [ProhibitSaleLocationType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [ProhibitSaleLocationValue] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
    [SalesRestrictionStrategyID] INT NULL, 
    [SalesRestrictionStrategyID2] INT NULL, 
	[PriceMethodCode] INT NULL,
	[ReceiptDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[FoodStampableFlg] BIT NULL ,
	[DiscountableFlg] BIT NULL,
	[QuantityRequiredFlg] BIT NULL,
	[UPCValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[UPCCheckDigit] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[UPCSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[Fee] INT NULL,
	[FlagSysId1] INT NULL,
	[FlagSysId2] INT NULL,
	[FlagSysId3] INT NULL,
	[FlagSysId4] INT NULL,
	[TaxRateSysId1] INT NULL,
	[TaxRateSysId2] INT NULL,
	[TaxRateSysId3] INT NULL,
	[TaxRateSysId4] INT NULL,
	[IdCheckSysId1] INT NULL,
	[IdCheckSysId2] INT NULL,
	[BlueLawSysId1] INT NULL,
	[BlueLawSysId2] INT NULL,
    CONSTRAINT [PK_tblSTstgPricebookSendFile] PRIMARY KEY ([intPricebookSendFile])  
)
