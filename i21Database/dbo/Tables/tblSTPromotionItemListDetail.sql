CREATE TABLE [dbo].[tblSTPromotionItemListDetail]
(
	[intPromoItemListDetailId] INT NOT NULL IDENTITY, 
    [intPromoItemListId] INT NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
    [intUpcModifier] INT NOT NULL, 
    [dblRetailPrice] NUMERIC(7, 2) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionItemListDetail] PRIMARY KEY ([intPromoItemListDetailId]), 
    CONSTRAINT [FK_tblSTPromotionItemListDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblSTPromotionItemListDetail_tblSTPromotionItemList_intPromoItemListId] FOREIGN KEY ([intPromoItemListId]) REFERENCES [tblSTPromotionItemList]([intPromoItemListId]) ON DELETE CASCADE
);
