CREATE TABLE [dbo].[tblARPOSDrawer]
(
	[intPOSDrawerId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[strDrawerName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnAllowMultipleUser] BIT NOT NULL,
	[intCompanyLocationId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [FK_tblARPOSDrawer_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId])
)
