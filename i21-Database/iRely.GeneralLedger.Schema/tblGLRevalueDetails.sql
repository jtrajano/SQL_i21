CREATE TABLE [dbo].[tblGLRevalueDetails](
	[intConsolidationDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intConsolidationId] [int] NOT NULL,
	[strTransactionType] [nvarchar](30) COLLATE Latin1_General_CI_AS,
	[strTransactionId] [nvarchar](30) COLLATE Latin1_General_CI_AS,
	[dtmDate] [date] NULL,
	[dtmDueDate] [date] NULL,
	[strVendorName] [nvarchar](100) COLLATE Latin1_General_CI_AS,
	[strCommodity] [nvarchar](100) COLLATE Latin1_General_CI_AS,
	[strLineOfBusiness] [nvarchar](30) COLLATE Latin1_General_CI_AS,
	[strLocation] [nvarchar](50) COLLATE Latin1_General_CI_AS,
	[strTicket] [nvarchar](50) COLLATE Latin1_General_CI_AS,
	[strContractId] [nvarchar](50) COLLATE Latin1_General_CI_AS,
	[strItemId] [nvarchar](50) COLLATE Latin1_General_CI_AS,
	[dblQuantity] [numeric](18, 6) NULL,
	[dblUnitPrice] [numeric](18, 6) NULL,
	[dblTransactionAmount] [numeric](18, 6) NULL,
	[intCurrencyId] [int] NULL,
	[intCurrencyExchangeRateTypeId] [int] NULL,
	[dblHistoricForexRate] [numeric](18, 6) NOT NULL,
	[dblHistoricAmount] [numeric](18, 6) NOT NULL,
	[dblNewForexRate] [numeric](18, 6) NOT NULL,
	[dblNewAmount] [numeric](18, 6) NOT NULL,
	[dblUnrealizedGain] [numeric](18, 6) NOT NULL,
	[dblUnrealizedLoss] [numeric](18, 6) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS,
 CONSTRAINT [PK_tblGLRevalueDetails] PRIMARY KEY CLUSTERED 
(
	[intConsolidationDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblHistoricForexRate]  DEFAULT ((0)) FOR [dblHistoricForexRate]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblHistoricAmount]  DEFAULT ((0)) FOR [dblHistoricAmount]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblNewForexRate]  DEFAULT ((0)) FOR [dblNewForexRate]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblNewAmount]  DEFAULT ((0)) FOR [dblNewAmount]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblUnrealizedGain]  DEFAULT ((0)) FOR [dblUnrealizedGain]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] ADD  CONSTRAINT [DF_tblGLRevalueDetails_dblUnrealizedLoss]  DEFAULT ((0)) FOR [dblUnrealizedLoss]
GO

ALTER TABLE [dbo].[tblGLRevalueDetails]  WITH CHECK ADD  CONSTRAINT [FK_tblGLRevalueDetails_tblGLRevalue] FOREIGN KEY([intConsolidationId])
REFERENCES [dbo].[tblGLRevalue] ([intConsolidationId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblGLRevalueDetails] CHECK CONSTRAINT [FK_tblGLRevalueDetails_tblGLRevalue]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Table Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'intConsolidationDetailId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Consolidation Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'intConsolidationId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strTransactionType' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strTransactionId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dtmDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date Due Date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dtmDueDate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vendor Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strVendorName' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Commodity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strCommodity' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Line Of Business' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strLineOfBusiness' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Location' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strLocation' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Ticket' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strTicket' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contract Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strContractId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Item Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strItemId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quantity' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblQuantity' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unit Price' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblUnitPrice' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transaction Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblTransactionAmount' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'intCurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Currency Exchange Rate Type Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'intCurrencyExchangeRateTypeId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Historic Forex Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblHistoricForexRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Historic Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblHistoricAmount' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'New Forex Rate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblNewForexRate' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'New Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblNewAmount' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unrealized Gain' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblUnrealizedGain' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Unrealized Loss' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'dblUnrealizedLoss' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Concurrency Id' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'intConcurrencyId' 
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'tblGLRevalueDetails', @level2type=N'COLUMN',@level2name=N'strType' 
GO
