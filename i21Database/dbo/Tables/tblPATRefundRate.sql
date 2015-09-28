CREATE TABLE [dbo].[tblPATRefundRate](
	[intRefundTypeId] [int] NOT NULL IDENTITY,
	[strRefundType] [char](5) NOT NULL,
	[strRefundDescription] [nvarchar](max) NOT NULL,
	[ysnQualified] [bit] NULL,
	[intGeneralReserveId] [int] NOT NULL,
	[intAllocatedReserveId] [int] NOT NULL,
	[intUndistributedEquityId] [int] NOT NULL,
	[dblCashPayout] [numeric](18, 6) NOT NULL,
	[intPatronageCategoryId] [nchar](10) NULL,
	[strPurchaseSale] [nvarchar](50) NULL,
	[dblRate] [numeric](18, 6) NULL, 
    [intConcurrencyId] INT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblPATRefundRate] PRIMARY KEY ([intRefundTypeId])
)