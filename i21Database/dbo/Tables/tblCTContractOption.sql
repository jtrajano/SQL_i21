CREATE TABLE [dbo].[tblCTContractOption](
	[intContractOptionId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intBuySell] [int] NOT NULL,
	[intPutCall] [int] NOT NULL,
	[dblStrike] [numeric](5, 4) NOT NULL,
	[dblPremium] [numeric](5, 4) NOT NULL,
	[dblServiceFee] [numeric](5, 4) NOT NULL,
	[dtmExpiration] [datetime] NOT NULL,
	[dblTargetPrice] [numeric](5, 4) NULL,
	[intPremFee] [int] NOT NULL,
 CONSTRAINT [PK_tblCTContractOption_intContractOptionId] PRIMARY KEY CLUSTERED 
(
	[intContractOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTContractOption]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractOption_tblCTBuySell_intBuySell] FOREIGN KEY([intBuySell])
REFERENCES [dbo].[tblCTBuySell] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractOption] CHECK CONSTRAINT [FK_tblCTContractOption_tblCTBuySell_intBuySell]
GO

ALTER TABLE [dbo].[tblCTContractOption]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractOption_tblCTContractDetail_intContractDetailId] FOREIGN KEY([intContractDetailId])
REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId])
GO

ALTER TABLE [dbo].[tblCTContractOption] CHECK CONSTRAINT [FK_tblCTContractOption_tblCTContractDetail_intContractDetailId]
GO

ALTER TABLE [dbo].[tblCTContractOption]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractOption_tblCTPremFee_intPremFee] FOREIGN KEY([intPremFee])
REFERENCES [dbo].[tblCTPremFee] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractOption] CHECK CONSTRAINT [FK_tblCTContractOption_tblCTPremFee_intPremFee]
GO

ALTER TABLE [dbo].[tblCTContractOption]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractOption_tblCTPutCall_intPutCall] FOREIGN KEY([intPutCall])
REFERENCES [dbo].[tblCTPutCall] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractOption] CHECK CONSTRAINT [FK_tblCTContractOption_tblCTPutCall_intPutCall]
GO

