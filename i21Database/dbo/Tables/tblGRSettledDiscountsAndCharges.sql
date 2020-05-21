CREATE TABLE [dbo].[tblGRSettledDiscountsAndCharges](
	[intSettledDiscountsAndCharges] [int] IDENTITY(1,1) NOT NULL,
	[intSettleStorageId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[ysnInventoryCost] [bit] NULL,
	[ysnAccrue] [bit] NULL,
	[ysnPrice] [bit] NULL,
	[strItemType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[dblDiscountChargeDue] [decimal](18, 6) NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT(1),
	CONSTRAINT [FK_tblGRSettledDiscountsAndCharges_tblGRSettleStorage] FOREIGN KEY([intSettleStorageId]) REFERENCES [dbo].[tblGRSettleStorage] ([intSettleStorageId])
)
