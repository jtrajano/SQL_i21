CREATE TABLE [dbo].[tblMBILDeliveryDetail]
(
	[intDeliveryDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intDeliveryHeaderId] [int] NULL,
	[intPickupDetailId] [int] NULL,
	[intItemId] [int] NULL,
	[strTank] [nvarchar](150) NULL,
	[dblStickStartReading] [numeric](18, 6) NULL,
	[dblStickEndReading] [numeric](18, 6) NULL,
	[dblWaterInches] [numeric](18, 6) NULL,
	[dblQuantity] [numeric](10, 6) NULL,
	[dblDeliveredQty] [numeric](10, 6) NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblMBILLoadDeliveryDetail] PRIMARY KEY CLUSTERED ([intDeliveryDetailId])
)