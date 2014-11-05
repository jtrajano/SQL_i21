CREATE TABLE [dbo].[tblSTSubcategoryRegProd]
(
	[intRegProdId] INT NOT NULL IDENTITY,
    [intStoreId] INT NOT NULL, 
    [strRegProdCode] NCHAR(8) NOT NULL, 
    [strRegProdDesc] NCHAR(30) NULL, 
    [strRegProdComment ] NCHAR(90) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategoryRegProd] PRIMARY KEY CLUSTERED ([intRegProdId] ASC),
    CONSTRAINT [AK_tblSTSubcategoryRegProd_strRegProdCode] UNIQUE NONCLUSTERED ([intStoreId],[strRegProdCode] ASC), 
    CONSTRAINT [FK_tblSTSubcategoryRegProd_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]),
);
