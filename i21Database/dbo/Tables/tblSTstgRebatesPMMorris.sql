﻿CREATE TABLE [dbo].[tblSTstgRebatesPMMorris]
(
    [intPMMId] int IDENTITY(1,1) NOT NULL,
	[intManagementOrRetailNumber] int NULL,
	[strWeekEndingDate] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionDate] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionTime] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionIdCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strStoreNumber] nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	[strStoreName] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strStoreAddress] nvarchar(60) COLLATE Latin1_General_CI_AS NULL,
	[strStoreCity] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strStoreState] nvarchar(2) COLLATE Latin1_General_CI_AS NULL,
	[intStoreZipCode] int NULL,
	[strCategory] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strManufacturerName] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[strSKUCode] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strUpcCode] nvarchar(14) COLLATE Latin1_General_CI_AS NULL,
	[strSkuUpcDescription] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[strUnitOfMeasure] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[intQuantitySold] numeric(10, 2) NULL,
	[intConsumerUnits] int NULL,
	[strMultiPackIndicator] nvarchar(1) COLLATE Latin1_General_CI_AS NULL,
	[intMultiPackRequiredQuantity] int NULL,
	[dblMultiPackDiscountAmount] numeric(10, 2) NULL,
	[strRetailerFundedDIscountName] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblRetailerFundedDiscountAmount] numeric(10, 2) NULL,
	[strMFGDealNameONE] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblMFGDealDiscountAmountONE] numeric(10, 2) NULL,
	[strMFGDealNameTWO] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblMFGDealDiscountAmountTWO] numeric(10, 2) NULL,
	[strMFGDealNameTHREE] nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	[dblMFGDealDiscountAmountTHREE] numeric(10, 2) NULL,
	[dblFinalSalesPrice] numeric(10, 2) NULL,
)