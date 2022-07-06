CREATE TABLE [dbo].[tblSTPumpItem]
(
	[intStorePumpItemId] INT NOT NULL IDENTITY, 
	[intStoreId] INT NOT NULL, 
    [intItemUOMId] INT NOT NULL, 
	[strUnitMeasure] VARCHAR(200) NULL,
    [dblPrice] NUMERIC(18, 6) NULL  DEFAULT 0, 
    [intTaxGroupId] int NULL,
	[intCategoryId] int NULL,
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSTPumpItem] PRIMARY KEY ([intStorePumpItemId]),
    CONSTRAINT [AK_tblSTPumpItem_intStoreId_intItemUOMId] UNIQUE NONCLUSTERED ([intStoreId],[intItemUOMId] ASC),
	CONSTRAINT [FK_tblSTPumpItem_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTPumpItem_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblSTPumpItem_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblSTPumpItem_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)