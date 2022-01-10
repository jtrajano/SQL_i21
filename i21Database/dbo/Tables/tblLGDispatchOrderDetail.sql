﻿CREATE TABLE [dbo].[tblLGDispatchOrderDetail]
(
	[intDispatchOrderDetailId] INT NOT NULL IDENTITY(1, 1), 
	[intDispatchOrderId] INT NOT NULL, 
	[intStopType] INT NULL,
	[dtmStartTime] DATETIME NULL,
	[dtmEndTime] DATETIME NULL,
	[intOrderStatus] INT NULL,
	[strOrderNumber] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strOrderType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[intSequence] INT NULL,
	[intEntityId] INT NULL,
	[intEntityLocationId] INT NULL,
	[intCompanyLocationId] INT NULL, 
	[intCompanyLocationSubLocationId] INT NULL,
	[intEntityContactId] INT NULL,
	[strEntityType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEntityContact] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strAddress] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strState] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strZipCode] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strCountry] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] INT NULL,
	[strItemNo] NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[strOrderComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strDeliveryComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intLoadId] INT NULL, 
	[intLoadDetailId] INT NULL,
	[intSalesOrderId] INT NULL, 
	[intSalesOrderDetailId] INT NULL,
	[intInventoryTransferId] INT NULL, 
	[intInventoryTransferDetailId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),

    CONSTRAINT [PK_tblLGDispatchOrderDetail] PRIMARY KEY ([intDispatchOrderDetailId]),
    CONSTRAINT [FK_tblLGDispatchOrderDetail_tblLGDispatchOrder_intDispatchOrderId] FOREIGN KEY ([intDispatchOrderId]) REFERENCES [tblLGDispatchOrder]([intDispatchOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGDispatchOrderDetail_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGDispatchOrderDetail_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGDispatchOrderDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId])
)
