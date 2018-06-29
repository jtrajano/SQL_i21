CREATE TABLE [dbo].[tblSTPromotionItemListDetail]
(
	[intPromoItemListDetailId] INT NOT NULL IDENTITY, 
    [intPromoItemListId] INT NOT NULL, 
    [intItemUOMId] INT NULL, 
	[strUpcDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
    [intUpcModifier] INT NOT NULL, 
    [dblRetailPrice] NUMERIC(18, 6) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionItemListDetail] PRIMARY KEY ([intPromoItemListDetailId]), 
    CONSTRAINT [FK_tblSTPromotionItemListDetail_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblSTPromotionItemListDetail_tblSTPromotionItemList_intPromoItemListId] FOREIGN KEY ([intPromoItemListId]) REFERENCES [tblSTPromotionItemList]([intPromoItemListId]) ON DELETE CASCADE
);
