CREATE TABLE [dbo].[tblMBILPickupDetail]
(
	[intPickupDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadDetailId] [int] null,
	[intLoadHeaderId] [int] NOT NULL,
	[intSellerId] [int] NULL,
	[intSalespersonId] [int] NULL,
	[strTerminalRefNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId] [int] NULL,
	[intEntityLocationId] [int] NULL,
	[intCompanyLocationId] [int] NULL,
	[intContractDetailId] [int] NULL,
	[intTaxGroupId] [int] NULL,
	[dtmPickupFrom] [datetime] NULL,
	[dtmPickupTo] [datetime] NULL,
	[dtmActualPickupFrom] [datetime] NULL,
	[dtmActualPickupTo] [datetime] NULL,
	[strPONumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strLoadRefNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strBOL] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strNote] [nvarchar](150) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] [int] NULL,
	[dblQuantity] [numeric](18, 6) NULL,
	[dblPickupQuantity] [numeric](18, 6) NULL,
	[dblGross] [numeric](18, 6) NULL,
	[dblNet] [numeric](18, 6) NULL,
	[strItemUOM] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[strRack] [nvarchar](100)  COLLATE Latin1_General_CI_AS NULL,
	[intShiftId] [int] NULL,
	[ysnPickup] bit default 0 NULL,
	[intDispatchOrderDetailId] int NULL,
	[intConcurrencyId] [int] DEFAULT(1) NULL,
	[intDispatchOrderRouteId] INT NULL
	CONSTRAINT [PK_tblMBILPickupDetail] PRIMARY KEY CLUSTERED (intPickupDetailId), 
    CONSTRAINT [FK_tblMBILPickupDetail_tblMBILLoadHeader] FOREIGN KEY ([intLoadHeaderId]) REFERENCES [tblMBILLoadHeader]([intLoadHeaderId]),
	CONSTRAINT [FK_tblMBILPickupDetail_tblLGDispatchRouteId] FOREIGN KEY ([intDispatchOrderRouteId]) REFERENCES [tblLGDispatchOrderRoute]([intDispatchOrderRouteId]) ON DELETE SET NULL
)