﻿CREATE TABLE [dbo].[tblSTPromotionItemList]
(
	[intPromoItemListId] INT NOT NULL IDENTITY , 
    [intStoreId] INT NOT NULL, 
    [intPromoItemListNo] INT NOT NULL, 
    [strPromoItemListId] NVARCHAR(250) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strPromoItemListDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDeleteFromRegister] BIT NULL, 
    [dtmLastUpdateDate] DATETIME NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [strFamily] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strClass] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblSTPromotionItemList_intPromoItemListId] PRIMARY KEY CLUSTERED ([intPromoItemListId] ASC), 
    CONSTRAINT [AK_tblSTPromotionItemList_intStoreId_intPromoItemListNo] UNIQUE NONCLUSTERED ([intStoreId],[intPromoItemListNo] ASC), 
    CONSTRAINT [FK_tblSTPromotionItemList_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) 
);
