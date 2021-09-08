CREATE TABLE [dbo].[tblTMTankMonitorInterface]
(
	[intTankMonitorInterfaceId] INT IDENTITY (1, 1) NOT NULL,
	[intInterfaceTypeId] INT NOT NULL,
	[ysnDefault] bit null,
	[strAPIUrl] NVARCHAR(2000) COLLATE Latin1_General_CI_AS NULL,
	[strVendorName] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strCustomerName] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
	[strAPIKey] NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL,
    [ysnFromAPI] bit NOT NULL default 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	[strPassword] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblTankMonitorInterface_intTankMonitorInterfaceId] PRIMARY KEY CLUSTERED ([intTankMonitorInterfaceId] ASC),
	CONSTRAINT [UQ_tblTankMonitorInterface_intInterfaceTypeId] UNIQUE NONCLUSTERED ([intInterfaceTypeId] ASC), 
    CONSTRAINT [FK_tblTankMonitorInterface_tblTMTankMonitorInterfaceType_intInterfaceTypeId] FOREIGN KEY ([intInterfaceTypeId]) REFERENCES [dbo].[tblTMTankMonitorInterfaceType] ([intInterfaceTypeId])
)
