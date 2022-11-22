CREATE TABLE [dbo].[tblQMSaleYear]
(
	[intSaleYearId] INT IDENTITY(1,1) NOT NULL,
	[strSaleYear] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblQMSaleYear] PRIMARY KEY ([intSaleYearId])
)
