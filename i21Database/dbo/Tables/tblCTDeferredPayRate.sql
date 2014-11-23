CREATE TABLE [dbo].[tblCTDeferredPayRate](
	[intDeferPayRateId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intDeferredPayId] [int] NOT NULL,
	[dtmFromDate] [datetime] NOT NULL,
	[dtmToDate] [datetime] NOT NULL,
	[dblDeferPayRate] [numeric](5, 4) NOT NULL,
 CONSTRAINT [PK_tblCTDeferredPayRate_intDeferPayRateId] PRIMARY KEY CLUSTERED 
(
	[intDeferPayRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTDeferredPayRate]  WITH CHECK ADD  CONSTRAINT [FK_tblCTDeferredPayRate_tblCTDeferredPay_intDeferredPayId] FOREIGN KEY([intDeferredPayId])
REFERENCES [dbo].[tblCTDeferredPay] ([intDeferredPayId])
GO

ALTER TABLE [dbo].[tblCTDeferredPayRate] CHECK CONSTRAINT [FK_tblCTDeferredPayRate_tblCTDeferredPay_intDeferredPayId]
GO

