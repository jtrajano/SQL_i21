﻿CREATE TABLE [dbo].[tblSTUpdateRegisterHistory]
(
	[intUpdateRegisterHistoryId] [int] IDENTITY(1,1) NOT NULL,
	[intStoreId] [int] NOT NULL,
	[intRegisterId] [int] NULL,
	[ysnPricebookFile] [bit] NULL,
	[ysnPromotionItemList] [bit] NULL,
	[ysnPromotionSalesList] [bit] NULL,
	[dtmBeginningChangeDate] [datetime] NULL,
	[dtmEndingChangeDate] [datetime] NULL,
	[strCategoryCode] [nvarchar](500) NULL,
	[ysnExportEntirePricebookFile] [bit] NULL,
	[intBeginningPromoItemListId] [int] NULL,
	[intEndingPromoItemListId] [int] NULL,
	[strPromoCode] [nvarchar](20) NULL,
	[intBeginningPromoSalesId] [int] NULL,
	[intEndingPromoSalesId] [int] NULL,
	[dtmBuildFileThruEndingDate] [datetime] NULL, 
	)
