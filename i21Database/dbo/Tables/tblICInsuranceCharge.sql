CREATE TABLE [dbo].[tblICInsuranceCharge](
	[intInsuranceChargeId] [int] IDENTITY(1,1) NOT NULL,
	[intCommodityId] [int] NOT NULL,
	[strStorageLocationIds] NVARCHAR(500) COLLATE Latin1_General_CI_AS,
	[intInsurerId] [int] NOT NULL,
	[dtmChargeDateUTC] [datetime] NULL,
	[intM2MBatchId] [int] NULL,
	[strChargeNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS ,
	[intConcurrencyId] [int] NOT NULL DEFAULT 0,
	[ysnPosted] [bit] NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblICInsuranceCharge] PRIMARY KEY CLUSTERED ([intInsuranceChargeId] ASC)
) 
GO

