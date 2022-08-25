CREATE TABLE [dbo].[tblAPSearchRecordVoucher](
	[intId] [int] IDENTITY(1,1) NOT NULL,
	[intInventoryRecordId] [int] NOT NULL,
	[intInventoryRecordItemId] [int] NULL,
	[intInventoryRecordChargeId] [int] NULL,
	[dtmRecordDate] [datetime] NULL,
	[strVendor] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[strLocationName] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strRecordNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strOrderType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strRecordType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strOrderNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strItemDescription] [nvarchar](250) COLLATE Latin1_General_CI_AS NULL,
	[dblUnitCost] [numeric](38, 20) NULL,
	[dblRecordQty] [numeric](38, 20) NULL,
	[dblVoucherQty] [numeric](38, 20) NULL,
	[dblRecordLineTotal] [numeric](38, 20) NULL,
	[dblVoucherLineTotal] [numeric](38, 20) NULL,
	[dblRecordTax] [numeric](38, 20) NULL,
	[dblVoucherTax] [numeric](38, 20) NULL,
	[dblOpenQty] [numeric](38, 20) NULL,
	[dblItemsPayable] [numeric](38, 20) NULL,
	[dblTaxesPayable] [numeric](38, 20) NULL,
	[dtmLastVoucherDate] [datetime] NULL,
	[strAllVouchers] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFilterString] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[dtmCreated] [datetime] NULL,
	[intCurrencyId] [int] NULL,
	[strCurrency] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strContainerNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intLoadContainerId] [int] NULL,
	[strItemUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intItemUOMId] [int] NULL,
	[strCostUOM] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intCostUOMId] [int] NULL,
 CONSTRAINT [PK_tblAPSearchRecordVoucher] PRIMARY KEY NONCLUSTERED 
(
	[intId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblUnitCost]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblRecordQty]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblVoucherQty]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblRecordLineTotal]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblVoucherLineTotal]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblRecordTax]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblVoucherTax]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblOpenQty]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblItemsPayable]
GO

ALTER TABLE [dbo].[tblAPSearchRecordVoucher] ADD  DEFAULT ((0)) FOR [dblTaxesPayable]
GO


