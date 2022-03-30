CREATE TABLE [dbo].[tblICStorageCharge](
	[intStorageChargeId] [int] IDENTITY(1,1) NOT NULL,
	[dtmBillDateUTC] [datetime] NOT NULL,
	[intStorageLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[intCommodityId] [int] NULL,
	[intStorageRateId] [int] NOT NULL,
	[strStorageChargeNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId] [int] NOT NULL,
	[strDescription] [nvarchar](200) COLLATE Latin1_General_CI_AS NULL,
	[ysnPosted] NCHAR(10) NOT NULL DEFAULT 0, 
	[intConcurrencyId] [int] NOT NULL DEFAULT ((0)) ,
    CONSTRAINT [PK_tblICStorageCharge] PRIMARY KEY CLUSTERED ([intStorageChargeId] ASC)
) 
GO

