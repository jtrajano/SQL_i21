CREATE TABLE [dbo].[tblSTPromotionSalesListDetail]
(
	[intPromoSalesListDetailId] INT NOT NULL IDENTITY, 
    [intPromoSalesListId] INT NOT NULL, 
    [intPromoItemListId] INT NOT NULL, 
    [intQuantity] INT NULL, 
    [dblPrice] NUMERIC(5, 2) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionSalesListDetail] PRIMARY KEY ([intPromoSalesListDetailId]), 
	CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionSalesList] FOREIGN KEY ([intPromoSalesListId]) REFERENCES [tblSTPromotionSalesList]([intPromoSalesListId]),
    CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionItemList] FOREIGN KEY ([intPromoItemListId]) REFERENCES [tblSTPromotionItemList]([intPromoItemListId]),
	CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionSalesList_intPromoSalesListId] FOREIGN KEY ([intPromoSalesListId]) REFERENCES [tblSTPromotionSalesList]([intPromoSalesListId]) ON DELETE CASCADE
);
