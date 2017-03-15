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
	[intQuantity] [int] NULL,
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


