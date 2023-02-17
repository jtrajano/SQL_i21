CREATE TABLE [dbo].[tblLGDispatchOrderRoute]
(
	[intDispatchOrderRouteId] INT NOT NULL IDENTITY(1, 1), 
	[intDispatchOrderId] INT NOT NULL, 
	[intDispatchOrderDetailId] INT NULL,
	[intEntityShipViaTruckId] INT NULL,
	[intDriverEntityId] INT NULL, 

	[intRouteSeq] INT NULL,
	[intStopType] INT NULL,
	[dtmStartTime] DATETIME NULL,
	[dtmEndTime] DATETIME NULL,
	[intOrderStatus] INT NULL,

	[strEntityName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEntityLocation] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strSiteNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCountry] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblLongitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [dblLatitude] NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,	

	[strOrderNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strOrderType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[dblStandardWeight] NUMERIC(18, 6) NULL,
	[strOrderComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDeliveryComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,

	[intConcurrencyId] INT NULL DEFAULT((1)),

    CONSTRAINT [PK_tblLGDispatchOrderRoute] PRIMARY KEY ([intDispatchOrderRouteId]),
    CONSTRAINT [FK_tblLGDispatchOrderRoute_tblLGDispatchOrder_intDispatchOrderId] FOREIGN KEY ([intDispatchOrderId]) REFERENCES [tblLGDispatchOrder]([intDispatchOrderId]) ON DELETE CASCADE
)
