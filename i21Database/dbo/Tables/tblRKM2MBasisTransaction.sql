CREATE TABLE [dbo].[tblRKM2MBasisTransaction]
(
	[intM2MBasisTransactionId] INT IDENTITY(1,1) NOT NULL,
	[intM2MBasisId] INT NULL, 
    [intConcurrencyId] INT  NULL, 
	[intFutureMarketId] INT  NULL, 
    [intCommodityId] INT  NULL, 
    [intItemId] INT NULL,     
    [intCurrencyId] INT NULL, 
    [dblBasis] NUMERIC(18, 6) NULL, 
    [intUnitMeasureId] INT NULL,

	CONSTRAINT [PK_tblRKM2MBasisTransaction_intM2MBasisTransactionId] PRIMARY KEY (intM2MBasisTransactionId),
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblRKM2MBasis_intM2MBasisId] FOREIGN KEY ([intM2MBasisId]) REFERENCES [dbo].[tblRKM2MBasis] ([intM2MBasisId]) ON DELETE CASCADE,  
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [dbo].[tblICCommodity] ([intCommodityId]),  
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblICItem_intItemId] FOREIGN KEY (intItemId) REFERENCES [dbo].[tblICItem] (intItemId),  
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblRKFutureMarket_intFutureMarketId] FOREIGN KEY (intFutureMarketId) REFERENCES [dbo].[tblRKFutureMarket] (intFutureMarketId),
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblSMCurrency_intCurrencyId] FOREIGN KEY (intCurrencyId) REFERENCES [dbo].[tblSMCurrency] (intCurrencyID),
	CONSTRAINT [FK_tblRKM2MBasisTransaction_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])

)
