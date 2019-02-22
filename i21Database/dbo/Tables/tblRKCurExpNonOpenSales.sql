CREATE TABLE [dbo].[tblRKCurExpNonOpenSales]
(
	[intCurExpNonOpenSalesId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intCustomerId] INT NULL,
	[dblQuantity]  NUMERIC(24, 6) NULL,	
	[intQuantityUOMId]  INT NULL,	
	[dblOrigPrice]  NUMERIC(24, 6) NULL,	
	[intOrigPriceUOMId]  INT NULL,	
	[intOrigPriceCurrencyId]  INT NULL,	
	[dblPrice] NUMERIC(24, 6) NULL,
	[strPeriod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strContractType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL,
	[dblValueUSD] NUMERIC(24, 6) NULL,
	[intCompanyId] INT NULL,   
	[intContractDetailId] INT NULL,
	CONSTRAINT [PK_tblRKCurExpNonOpenSales_intCurExpNonOpenSalesId] PRIMARY KEY (intCurExpNonOpenSalesId),   
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblICUnitMeasure_intQuantityUOMId] FOREIGN KEY(intQuantityUOMId)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblICUnitMeasure_intOrigPriceUOMId] FOREIGN KEY(intOrigPriceUOMId)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblSMCurrency_intOrigPriceCurrencyId] FOREIGN KEY(intOrigPriceCurrencyId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID), 
    CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intEntityId]),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblCTContractDetail_intContractDetailId] FOREIGN KEY(intContractDetailId)REFERENCES [dbo].[tblCTContractDetail] (intContractDetailId)
	
)
