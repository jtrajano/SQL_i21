CREATE TABLE [dbo].[tblSTStoreTaxTotals]
(
	[intStoreTaxTotalId] INT NOT NULL IDENTITY, 
	[intStoreId] INT NOT NULL, 
	[intTaxCodeId] INT NOT NULL,
    [intItemId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSTStoreTaxTotals] PRIMARY KEY ([intStoreTaxTotalId]),
	CONSTRAINT [FK_tblSTStoreTaxTotals_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
	CONSTRAINT [FK_tblSTStoreTaxTotals_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
	CONSTRAINT [FK_tblSTStoreTaxTotals_tblSMTaxCode_intTaxCodeId] FOREIGN KEY ([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId])
)
