﻿CREATE TABLE [dbo].[tblLGRouteOrder]
(
	[intRouteOrderId] INT NOT NULL IDENTITY(1, 1), 
    [intConcurrencyId] INT NOT NULL, 
	[intRouteId] INT NOT NULL, 
	[intDispatchID] INT NULL,
	[intLoadDetailId] INT NULL,
	[intSequence] INT NULL,
	[dblToLatitude] NUMERIC(18, 6) NULL,
	[dblToLongitude] NUMERIC(18, 6) NULL,
	[strToAddress] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToCity] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToState] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToZipCode] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,
	[strToCountry] [NVARCHAR](MAX) COLLATE Latin1_General_CI_AS NULL,

	[strLocationType] [NVARCHAR](200) COLLATE Latin1_General_CI_AS NULL,
	
	[intCompanyLocationId] INT NULL, 
	[intCompanyLocationSubLocationId] INT NULL,

	[dblBalance] NUMERIC(18, 6) NULL,
	[dblTimeTakenInMinutes] NUMERIC(18, 6) NULL,

    CONSTRAINT [PK_tblLGRouteOrder] PRIMARY KEY ([intRouteOrderId]),
    CONSTRAINT [FK_tblLGRouteOrder_tblLGRoute_intRouteId] FOREIGN KEY ([intRouteId]) REFERENCES [tblLGRoute]([intRouteId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGRouteOrder_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),
	CONSTRAINT [FK_tblLGRouteOrder_tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGRouteOrder_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId])
)
