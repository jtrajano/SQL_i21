CREATE TABLE [dbo].[tblRKCurrencyExposure]
(
	[intCurrencyExposureId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[strBatchName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmBatchDate] datetime NULL,
	[intWeightUnit] int NULL,
	[dtmCurrencyExposureAsOn] datetime NULL,
	[intCompanyId] int NULL,
	[dtmMarketPremiumAsOn] datetime NULL,
	[intCommodityId] int NULL,	
	[dtmFutureClosingDate] datetime NULL,
	[intCurrencyId] int NULL
    CONSTRAINT [PK_tblRKCurrencyExposure_intCurrencyExposureId] PRIMARY KEY (intCurrencyExposureId),   
	CONSTRAINT [UK_tblRKCurrencyExposure_strBatchName] UNIQUE ([strBatchName]),
	CONSTRAINT [FK_tblRKCurrencyExposure_tblICUnitMeasure_intWeightUnit] FOREIGN KEY(intWeightUnit)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId),
	CONSTRAINT [FK_tblRKCurrencyExposure_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [dbo].[tblICCommodity] ([intCommodityId]), 
	CONSTRAINT [FK_tblRKCurrencyExposure_tblSMCurrency_intCurrencyId] FOREIGN KEY(intCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID)
)