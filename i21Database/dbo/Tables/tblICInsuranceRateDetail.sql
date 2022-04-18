CREATE TABLE [dbo].[tblICInsuranceRateDetail](
	[intInsuranceRateDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intInsuranceRateId] [int] NOT NULL,
	[intStorageLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[strRateType] [nvarchar](15) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Unit',
	[strAppliedTo] [nvarchar](15) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Blank',
	[dblRate] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[intCurrencyId] [int] NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 0,
    CONSTRAINT [PK_tblICInsuranceRateDetail] PRIMARY KEY CLUSTERED ([intInsuranceRateDetailId] ASC)
) 
GO

