CREATE TABLE [dbo].[tblCTContractHeader](
	[intContractHeaderId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intPurchaseSale] [int] NOT NULL,
	[intCustomerId] [int] NOT NULL,
	[intCommodityId] [int] NOT NULL,
	[dblQuantity] [numeric](8, 4) NOT NULL,
	[intCommodityUnitMeasureId] [int] NOT NULL,
	[intContractNumber] [int] NOT NULL,
	[dtmContractDate] [datetime] NOT NULL,
	[strCustomerContract] [nvarchar](30) COLLATE Latin1_General_CI_AS NULL,
	[dtmDeferPayDate] [datetime] NULL,
	[dblDeferPayRate] [numeric](5, 2) NULL,
	[intContractTextId] [int] NOT NULL,
	[strInternalComments] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[ysnSigned] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnSigned]  DEFAULT ((0)),
	[ysnPrinted] [bit] NOT NULL CONSTRAINT [DF_tblCTContractHeader_ysnPrinted]  DEFAULT ((0)),
	[intSalespersonId] [int] NOT NULL,
	[intGradeId] [int] NOT NULL,
	[intWeightId] [int] NOT NULL,
	[intCropYearId] [int] NULL,
	[strContractComments] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
 CONSTRAINT [PK_tblCTContractHeader_intContractHeaderId] PRIMARY KEY CLUSTERED 
(
	[intContractHeaderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblARCustomer_intCustomerId] FOREIGN KEY([intCustomerId])
REFERENCES [dbo].[tblARCustomer] ([intCustomerId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblARCustomer_intCustomerId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblARSalesperson_intSalespersonId] FOREIGN KEY([intSalespersonId])
REFERENCES [dbo].[tblARSalesperson] ([intSalespersonId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblARSalesperson_intSalespersonId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblCTContractText_intContractTextId] FOREIGN KEY([intContractTextId])
REFERENCES [dbo].[tblCTContractText] ([intContractTextId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblCTContractText_intContractTextId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblCTCropYear_intCropYearId] FOREIGN KEY([intCropYearId])
REFERENCES [dbo].[tblCTCropYear] ([intCropYearId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblCTCropYear_intCropYearId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intGradeId] FOREIGN KEY([intGradeId])
REFERENCES [dbo].[tblCTWeightGrade] ([intWeightGradeId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intGradeId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intWeightId] FOREIGN KEY([intWeightId])
REFERENCES [dbo].[tblCTWeightGrade] ([intWeightGradeId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblCTWeightGrade_intWeightGradeId_intWeightId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])
REFERENCES [dbo].[tblICCommodity] ([intCommodityId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblICCommodity_intCommodityId]
GO

ALTER TABLE [dbo].[tblCTContractHeader]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractHeader_tblICCommodityUnitMeasure_intCommodityUnitMeasureId] FOREIGN KEY([intCommodityUnitMeasureId])
REFERENCES [dbo].[tblICCommodityUnitMeasure] ([intCommodityUnitMeasureId])
GO

ALTER TABLE [dbo].[tblCTContractHeader] CHECK CONSTRAINT [FK_tblCTContractHeader_tblICCommodityUnitMeasure_intCommodityUnitMeasureId]
GO

