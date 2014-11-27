CREATE TABLE [dbo].[tblSTPromotionSalesList]
(
	[intPromoSalesListId] INT NOT NULL IDENTITY, 
    [strPromoType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intStoreId] INT NOT NULL, 
    [intPromoSalesId] INT NOT NULL, 
    [intPromoDepartment] INT NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intPromoCode] INT NOT NULL, 
    [strPromoReason] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intPromoUnits] INT NULL, 
    [dblPromoPrice] NUMERIC(5, 2) NULL, 
    [intPromoFeeType] INT NOT NULL, 
    [intRegProdId] INT NOT NULL, 
    [dtmPromoBegPeriod] DATETIME NULL, 
    [dtmPromoBegTime] DATETIME NULL, 
    [dtmPromoEndPeriod] DATETIME NULL, 
    [dtmPromoEndTime] DATETIME NULL, 
    [intPurchaseLimit] INT NULL, 
    [intSalesRestrictCode] INT NULL, 
    [ysnPurchaseAtleastMin] BIT NULL, 
    [ysnPurchaseExactMultiples] BIT NULL, 
    [ysnRecieptItemSize] BIT NULL, 
    [ysnReturnable] BIT NULL, 
    [ysnFoodStampable] BIT NULL, 
    [ysnId1Required] BIT NULL, 
    [ysnId2Required] BIT NULL, 
    [ysnDiscountAllowed] BIT NULL, 
    [ysnBlueLaw1] BIT NULL, 
    [ysnBlueLaw2] BIT NULL, 
    [ysnUserTaxFlag1] BIT NULL, 
    [ysnUserTaxFlag2] BIT NULL, 
    [ysnUserTaxFlag3] BIT NULL, 
    [ysnUserTaxFlag4] BIT NULL, 
    [ysnDeleteFromRegister] BIT NULL, 
    [ysnSentToRuby] BIT NULL, 
    [intPromoItemListId] INT NOT NULL, 
    [intQuantity] INT NULL, 
    [dblPrice] NUMERIC(5, 2) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionSalesList] PRIMARY KEY CLUSTERED ([intPromoSalesListId]), 
    CONSTRAINT [AK_tblSTPromotionSalesList_intStoreId_intPromoSalesId] UNIQUE NONCLUSTERED([intStoreId],[intPromoSalesId]), 
    CONSTRAINT [FK_tblSTPromotionSalesList_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
    CONSTRAINT [FK_tblSTPromotionSalesList_tblSTPromotionItemList] FOREIGN KEY ([intPromoItemListId]) REFERENCES [tblSTPromotionItemList]([intPromoItemListId]), 
    CONSTRAINT [FK_tblSTPromotionSalesList_tblSTSubcategoryRegProd] FOREIGN KEY ([intRegProdId]) REFERENCES [tblSTSubcategoryRegProd]([intRegProdId]) 
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoSalesListId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Type:Combo OR Mix/Match',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'strPromoType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK. that corresponds to store number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intStoreId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique key that correspnds to Promotion Sales Id;origin:stcbo_id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoSalesId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Department;Origin:stcbo_dept_9',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoDepartment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Description;origin:stcbo_combo_description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promtion Code; origin:stcbo_promo_code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Reason; orgin:stcbo_promo_reason',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'strPromoReason'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Units; origin:stmix_mm_units',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoUnits'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Price; Origin:stcbo_combo_price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dblPromoPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Fee Type; Origin:stcbo_fee_type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoFeeType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK.that corresponds to Register product code; Origin:stcbo_prod_code_n',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intRegProdId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Begining Period Date;Origin:stcbo_beg_dat',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dtmPromoBegPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Begining Period Time; Origin:stcbo_beg_time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dtmPromoBegTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Ending Period date;Origin:stcbo_end_date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dtmPromoEndPeriod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Ending Period Time; Origin:stcbo_end_time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dtmPromoEndTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Limit;Origin:stcbo_tran_limit',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intPurchaseLimit'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Restrict Code; Origin:stmix_salesrestrict',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intSalesRestrictCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase at Least Min;Origin:stmix_strict_high',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnPurchaseAtleastMin'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Purchase Exact Multiples;Origin:stmix_strict_low',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnPurchaseExactMultiples'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reciept Item Size;Origin:stcbo_receipt_itemize',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnRecieptItemSize'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Returnable;Origin:stcbo_returnable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnReturnable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Food Stampables;Origin:stcbo_food_stamp',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnFoodStampable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ID1 Required;Origin:stcbo_id1_req',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnId1Required'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ID2 Required;Origin:stcbo_id2_req',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnId2Required'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Discount Allowed;Origin:stcbo_disc_allowed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnDiscountAllowed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Blue Law1;Origin:stcbo_bluelaw_1_applies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnBlueLaw1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Blue Law2;Origin:stcbo_bluelaw_2_applies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnBlueLaw2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Tax Flag1;Origin:stcbo_taxflag1',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnUserTaxFlag1'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Tax Flag2;Origin:stcbo_taxflag2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnUserTaxFlag2'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Tax Flag3;Origin:stcbo_taxflag2',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnUserTaxFlag3'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Tax Flag4;Origin:stcbo_taxflag4',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnUserTaxFlag4'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delete from Register;Origin:stcbo_deleted_yn',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnDeleteFromRegister'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sent to Ruby;Origin:stcbo_sent_to_ruby_yn',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'ysnSentToRuby'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK.that corresponds to Promotion Item List;Origin:stcbo-itemlist-id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = 'intPromoItemListId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Sales Quantity;Origin:stcbo-item-qty',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intQuantity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Item Price;Origin:stcbo-item-unitprice',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'dblPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionSalesList',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'