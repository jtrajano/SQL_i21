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
    CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionItemList] FOREIGN KEY ([intPromoItemListId]) REFERENCES [tblSTPromotionItemList]([intPromoItemListId])
	);
GO
ALTER TABLE [dbo].[tblSTPromotionSalesListDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionSalesList_intPromoSalesListId] FOREIGN KEY([intPromoSalesListId])
REFERENCES [dbo].[tblSTPromotionSalesList] ([intPromoSalesListId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblSTPromotionSalesListDetail] CHECK CONSTRAINT [FK_tblSTPromotionSalesListDetail_tblSTPromotionSalesList_intPromoSalesListId]
GO
