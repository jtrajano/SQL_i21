CREATE TABLE [dbo].[tblSTSubcategoryRegProd]
(
	[intRegProdId] INT NOT NULL IDENTITY,
    [strRegProdCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strRegProdDesc] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strRegProdComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategoryRegProd] PRIMARY KEY CLUSTERED ([intRegProdId] ASC),
    --CONSTRAINT [AK_tblSTSubcategoryRegProd_strRegProdCode] UNIQUE NONCLUSTERED ([strRegProdCode] ASC), 
);
