CREATE TABLE [dbo].[tblICInsuranceChargeDetail](
	[intInsuranceChargeDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intInsuranceChargeId] [int] NOT NULL,
	[intStorageLocationId] [int] NOT NULL,
	[dblQuantity] NUMERIC(36, 20) NOT NULL DEFAULT 0,
	[dblWeight] NUMERIC(36, 20) NOT NULL DEFAULT 0,
	[intWeightUOMId] [int] NULL,
	[dblInventoryValue] NUMERIC(18, 6) NULL,
	[dblM2MValue] NUMERIC(18, 6) NULL,
	[strRateType] NVARCHAR(20) COLLATE Latin1_General_CI_AS ,
	[dblRate] NUMERIC(18, 6) NULL,
	[intCurrencyId] [int] NULL,
	[intRateUOMId] [int] NULL,
	[dblAmount] NUMERIC(18, 6) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblICInsuranceChargeDetail] PRIMARY KEY CLUSTERED ([intInsuranceChargeDetailId] ASC)
) 
GO

