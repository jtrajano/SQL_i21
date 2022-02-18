CREATE TABLE [dbo].[tblSTUpdateRegisterItemReport]
(
	[intUpdateRegisterItemReport] INT NOT NULL IDENTITY, 
	[intStoreId] INT,
	[strGuid] UNIQUEIDENTIFIER NOT NULL, 
	[strActionType] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
	[strUpcCode] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[strUnitMeasure] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	[dblSalePrice] DECIMAL(18, 6) NULL,
	[ysnSalesTaxed] BIT,
	[ysnIdRequiredLiquor] BIT,
	[ysnIdRequiredCigarette] BIT,
	[strRegProdCode] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT,
	[intConcurrencyId] INT
)