CREATE TABLE [dbo].[tblTMTankMonitorInterfaceType]
(
	[intInterfaceTypeId] INT IDENTITY (1, 1) NOT NULL,
	[strInterfaceType] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL,
    [ysnFromAPI] bit NOT NULL default 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblTankMonitorInterfaceType_intInterfaceTypeId] PRIMARY KEY CLUSTERED ([intInterfaceTypeId] ASC),
	CONSTRAINT [UQ_tblTankMonitorInterfaceType_strInterfaceType] UNIQUE NONCLUSTERED ([strInterfaceType] ASC),
)
