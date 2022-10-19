CREATE TABLE [dbo].[tblQMSaleYear]
(
	[intSaleYearId] INT NOT NULL IDENTITY,
	[strSaleYear] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblQMSaleYear] PRIMARY KEY ([intSaleYearId]), 
)
