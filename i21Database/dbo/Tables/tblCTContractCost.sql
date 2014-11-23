CREATE TABLE [dbo].[tblCTContractCost](
	[intContractCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intCostTypeId] [int] NOT NULL,
	[intVendorId] [int] NULL,
	[intCostMethod] [int] NOT NULL,
	[dblRate] [numeric](5, 4) NOT NULL,
	[intItemUOMId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblCTContractCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
 CONSTRAINT [PK_tblCTContractCost_intContractCostId] PRIMARY KEY CLUSTERED 
(
	[intContractCostId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblAPVendor_intVendorId] FOREIGN KEY([intVendorId])
REFERENCES [dbo].[tblAPVendor] ([intVendorId])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblAPVendor_intVendorId]
GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY([intContractDetailId])
REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId]
GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblCTCostMethod_intCostMethod] FOREIGN KEY([intCostMethod])
REFERENCES [dbo].[tblCTCostMethod] ([Value])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblCTCostMethod_intCostMethod]
GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblCTCostType_intCostTypeId] FOREIGN KEY([intCostTypeId])
REFERENCES [dbo].[tblCTCostType] ([intCostTypeId])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblCTCostType_intCostTypeId]
GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblICItemUOM_intItemUOMId] FOREIGN KEY([intItemUOMId])
REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblICItemUOM_intItemUOMId]
GO

ALTER TABLE [dbo].[tblCTContractCost]  WITH CHECK ADD  CONSTRAINT [FK_tblCTContractCost_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])
REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
GO

ALTER TABLE [dbo].[tblCTContractCost] CHECK CONSTRAINT [FK_tblCTContractCost_tblSMCurrency_intCurrencyId]
GO

