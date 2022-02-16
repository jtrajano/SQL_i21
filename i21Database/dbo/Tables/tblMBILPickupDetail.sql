CREATE TABLE [dbo].[tblMBILPickupDetail]
(
	[intPickupDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intPickupHeaderId] [int] NOT NULL,
	[intItemId] [int] NULL,
	[dblQuantity] [numeric](18, 6) NULL,
	[dblPickupQuantity] [numeric](18, 6) NULL,
	[strItemUOM] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strRack] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] DEFAULT(1) NULL,
 CONSTRAINT [PK_tblMBILPickupDetail] PRIMARY KEY CLUSTERED ([intPickupDetailId]),
 CONSTRAINT [FK_tblMBILPickupDetail_tblMBILPickupHeader] FOREIGN KEY ([intPickupHeaderId]) REFERENCES [tblMBILPickupHeader]([intPickupHeaderId])
)