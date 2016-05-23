CREATE TABLE [dbo].[tblLGRoute]
(
	[intRouteId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strRouteNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intSourceType] INT NOT NULL,
	[intDriverEntityId] INT NULL,
	[dtmDispatchedDate]	DATETIME NULL,
	[strComments] [nvarchar](500) COLLATE Latin1_General_CI_AS NULL,
	[intFromCompanyLocationId] INT NULL, 
	[intFromCompanyLocationSubLocationId] INT NULL,
	[dblTruckCapacity] NUMERIC(18, 6) NULL,
	[ysnPosted] BIT NULL, 
	[dtmPostedDate] DATETIME NULL,

	CONSTRAINT [PK_tblLGRoute] PRIMARY KEY ([intRouteId]), 
	CONSTRAINT [FK_tblLGRoute_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGRoute_tblSMCompanyLocation_intFromCompanyLocationId] FOREIGN KEY ([intFromCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGRoute_tblSMCompanyLocationSubLocation_intFromCompanyLocationSubLocationId] FOREIGN KEY ([intFromCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId])
)
