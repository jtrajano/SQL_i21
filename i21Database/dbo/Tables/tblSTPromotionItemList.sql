CREATE TABLE [dbo].[tblSTPromotionItemList]
(
	[intPromoItemListId] INT NOT NULL IDENTITY, 
    [intStoreId] INT NOT NULL, 
    [intPromoItemListNo] INT NOT NULL, 
    [strPromoItemListId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [ysnDeleteFromRegister] BIT NULL, 
    [intItemId] INT NOT NULL, 
    [intUpcModifier] INT NULL, 
    [dblRetailPrice] NUMERIC(7, 2) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTPromotionItemList] PRIMARY KEY CLUSTERED ([intPromoItemListId]), 
	CONSTRAINT [AK_tblSTPromotionItemList_intStoreId_intPromoItemListNo] UNIQUE NONCLUSTERED ([intStoreId],[intPromoItemListNo]),
    CONSTRAINT [FK_tblSTPromotionItemList_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]), 
    CONSTRAINT [FK_tblSTPromotionItemList_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
  );

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoItemListId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unique key that corresponds to the Promotion Item Number. Origin: stitl_ruby_mix_no',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intPromoItemListNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Item List Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'strPromoItemListId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Promotion Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delete from Register',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'ysnDeleteFromRegister'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK. An item may belong to Inventory. Origin: stitl_upcno',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Upc Modifier',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intUpcModifier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Retail Price',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'dblRetailPrice'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FK.that corresponds to Store Number, Origin:stitl_store_name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSTPromotionItemList',
    @level2type = N'COLUMN',
    @level2name = N'intStoreId'