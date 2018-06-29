CREATE TABLE [dbo].[tblRKCurExpNonOpenSales]
(
	[intCurExpNonOpenSalesId] INT IDENTITY(1,1) NOT NULL,	
	[intConcurrencyId] INT NOT NULL, 
	[intCurrencyExposureId] INT NOT NULL, 
	[intContractDetailId] INT NOT NULL, 
	[strCustomer] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblQuantity]  NUMERIC(24, 6) NOT NULL,	
	[intQuantityUOMId]  int NOT NULL,	
	[dblOrigPrice]  NUMERIC(24, 6) NOT NULL,	
	[intOrigPriceUOMId]  int NOT NULL,	
	[intOrigPriceCurrencyId]  int NOT NULL,	
	[dblPrice] NUMERIC(24, 6) NOT NULL,
	[strPeriod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strContractType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblValueUSD] NUMERIC(24, 6) NOT NULL,
	[intCompanyId] int NULL,   

	CONSTRAINT [PK_tblRKCurExpNonOpenSales_intCurExpNonOpenSalesId] PRIMARY KEY (intCurExpNonOpenSalesId),   
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblRKCurrencyExposure_intCurrencyExposureId] FOREIGN KEY([intCurrencyExposureId])REFERENCES [dbo].[tblRKCurrencyExposure] (intCurrencyExposureId) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblCTContractDetail_intContractDetailId] FOREIGN KEY(intContractDetailId)REFERENCES [dbo].[tblCTContractDetail] (intContractDetailId),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblICUnitMeasure_intQuantityUOMId] FOREIGN KEY(intQuantityUOMId)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblSMCurrency_intOrigPriceUOMId] FOREIGN KEY(intOrigPriceUOMId)REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKCurExpNonOpenSales_tblICUnitMeasure_intOrigPriceCurrencyId] FOREIGN KEY(intOrigPriceCurrencyId)REFERENCES [dbo].[tblICUnitMeasure] (intUnitMeasureId)
	
)
