CREATE TABLE [dbo].[tblMBILDeliveryDetail]
(
	[intDeliveryDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intDeliveryHeaderId] [int] NULL,
	[intPickupDetailId] [int] NULL,
	[intItemId] [int] NULL,
	[strTank] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[dblStickStartReading] [numeric](18, 6) NULL,
	[dblStickEndReading] [numeric](18, 6) NULL,
	[dblWaterInches] [numeric](18, 6) NULL,
	[dblQuantity] [numeric](18, 6) NULL,
	[dblDeliveredQty] [numeric](18, 6) NULL,
	[ysnDelivered] bit default 0,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblMBILLoadDeliveryDetail] PRIMARY KEY CLUSTERED ([intDeliveryDetailId]),
 CONSTRAINT [FK_tblMBILLoadDeliveryDetail_tblMBILDeliveryHeader] FOREIGN KEY ([intDeliveryHeaderId]) REFERENCES [tblMBILDeliveryHeader]([intDeliveryHeaderId])
)
