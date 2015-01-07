CREATE TABLE [dbo].[tblSTPromotionItemListDetail]
(
	[intPromoItemListDetailId] INT NOT NULL IDENTITY, 
    [intPromoItemListId] INT NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [intUpcModifier] INT NOT NULL, 
    [dblRetailPrice] NUMERIC(7, 2) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionItemListDetail] PRIMARY KEY ([intPromoItemListDetailId]), 
    CONSTRAINT [FK_tblSTPromotionItemListDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
);
Go
ALTER TABLE [dbo].[tblSTPromotionItemListDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblSTPromotionItemListDetail_tblSTPromotionItemList_intPromoItemListId] FOREIGN KEY([intPromoItemListId])
REFERENCES [dbo].[tblSTPromotionItemList] ([intPromoItemListId]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblSTPromotionItemListDetail] CHECK CONSTRAINT [FK_tblSTPromotionItemListDetail_tblSTPromotionItemList_intPromoItemListId]
GO
