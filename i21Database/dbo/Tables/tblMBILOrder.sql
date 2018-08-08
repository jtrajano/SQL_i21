﻿CREATE TABLE [dbo].[tblMBILOrder](
	[intOrderId] INT IDENTITY(1,1) NOT NULL,
	[intDispatchId] INT NULL,
	[strOrderNumber] NVARCHAR (30) COLLATE Latin1_General_CI_AS NULL,
	[strOrderStatus] NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[dtmRequestedDate] DATETIME NULL,
	[intEntityId] INT NULL,
	[intTermId] INT NULL,
	[strComments] NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[intDriverId] INT				NULL,
	[intRouteId] INT NULL,
	[intStopNumber] INT	NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NOT NULL,
	CONSTRAINT [PK_tblMBILOrder] PRIMARY KEY CLUSTERED ([intOrderId] ASC), 
    CONSTRAINT [FK_tblMBILOrder_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [tblEMEntity]([intEntityId]), 
    CONSTRAINT [FK_tblMBILOrder_tblSMTerm] FOREIGN KEY ([intTermId]) REFERENCES [tblSMTerm]([intTermID]), 
    CONSTRAINT [FK_tblMBILOrder_tblEMEntityDriver] FOREIGN KEY ([intDriverId]) REFERENCES [tblEMEntity]([intEntityId]), 
    CONSTRAINT [FK_tblMBILOrder_tblLGRoute] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId])
)