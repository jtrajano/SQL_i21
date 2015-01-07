CREATE TABLE [dbo].[tblCTContractDetail](
	[intContractDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractHeaderId] [int] NOT NULL,
	[intContractSeq] [int] NOT NULL,
	[intCompanyLocationId] [int] NOT NULL,
	[dtmStartDate] [datetime] NOT NULL,
	[intItemId] [int] NOT NULL,
	[dtmEndDate] [datetime] NOT NULL,
	[intFreightTermId] [int] NOT NULL,
	[intShipViaId] [int] NOT NULL,
	[dblQuantity] [numeric](12, 4) NOT NULL,
	[intUnitMeasureId] [int] NOT NULL,
	[intPricingType] [int] NOT NULL,
	[dblFutures] [numeric](8, 4) NULL,
	[dblBasis] [numeric](8, 4) NULL,
	[intFutureMarketId] [int] NULL,
	[intFuturesMonthYearId] [int] NULL,
	[dblCashPrice] [numeric](5, 2) NULL,
	[intCurrencyId] [int] NOT NULL,
	[dblRate] [numeric](8, 4) NOT NULL,
	[strCurrencyReference] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[intMarketZoneId] [int] NOT NULL,
	[intDiscount] [int] NOT NULL CONSTRAINT [DF_tblCTContractDetail_intDiscount]  DEFAULT ((1)),
	[intDiscountSchedule] [int] NULL,
	[intContractOptHeaderId] [int] NULL,
	[strBuyerSeller] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intBillTo] [int] NULL,
	[intFreightRateId] [int] NULL,
	[strFobBasis] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intGrade] [int] NOT NULL,
	[strRemark] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
 [dblOriginalQty] NUMERIC(12, 4) NULL, 
    [dblBalance] NUMERIC(12, 4) NULL, 
    [dblIntransitQty] NUMERIC(12, 4) NULL, 
    [dblScheduleQty] NUMERIC(12, 4) NULL, 
    CONSTRAINT [PK_tblCTContractDetail_intContractDetailId] PRIMARY KEY CLUSTERED 
(
	[intContractDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblARMarketZone_intMarketZoneId] FOREIGN KEY([intMarketZoneId])
REFERENCES [dbo].[tblARMarketZone] ([intMarketZoneId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblARMarketZone_intMarketZoneId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY([intContractHeaderId])
REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblCTContractHeader_intContractHeaderId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblCTContractOptHeader_intContractOptHeaderId] FOREIGN KEY([intContractOptHeaderId])
REFERENCES [dbo].[tblCTContractOptHeader] ([intContractOptHeaderId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblCTContractOptHeader_intContractOptHeaderId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblCTFreightRate_intFreightRateId] FOREIGN KEY([intFreightRateId])
REFERENCES [dbo].[tblCTFreightRate] ([intFreightRateId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblCTFreightRate_intFreightRateId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblCTPricingType_intPricingType] FOREIGN KEY([intPricingType])
REFERENCES [dbo].[tblCTPricingType] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblCTPricingType_intPricingType]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblCTRailGrade_intGrade] FOREIGN KEY([intGrade])
REFERENCES [dbo].[tblCTRailGrade] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblCTRailGrade_intGrade]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblICItem_intItemId] FOREIGN KEY([intItemId])
REFERENCES [dbo].[tblICItem] ([intItemId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblICItem_intItemId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY([intUnitMeasureId])
REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblICUnitMeasure_intUnitMeasureId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY([intCompanyLocationId])
REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblSMCompanyLocation_intCompanyLocationId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])
REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblSMCurrency_intCurrencyId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblSMFreightTerms_intFreightTermId] FOREIGN KEY([intFreightTermId])
REFERENCES [dbo].[tblSMFreightTerms] ([intFreightTermId])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblSMFreightTerms_intFreightTermId]
GO

ALTER TABLE [dbo].[tblCTContractDetail]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractDetail_tblSMShipVia_intShipViaId] FOREIGN KEY([intShipViaId])
REFERENCES [dbo].[tblSMShipVia] ([intShipViaID])
GO

ALTER TABLE [dbo].[tblCTContractDetail] CHECK CONSTRAINT [FK_tblCTContractDetail_tblSMShipVia_intShipViaId]
GO

