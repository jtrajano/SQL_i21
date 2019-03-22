CREATE TABLE [dbo].[tblSMCompanyLocationPOSDrawer]
(
	[intCompanyLocationPOSDrawerId] INT NOT NULL PRIMARY KEY IDENTITY,
	[intCompanyLocationId] INT NOT NULL, 
    [strPOSDrawerName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
	[ysnAllowMultipleUser] BIT NOT NULL DEFAULT (0),
	[intConcurrencyId] INT NOT NULL DEFAULT 1, 
	CONSTRAINT [FK_tblSMCompanyLocationPOSDrawer_tblSMCompanyLocation] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId) ON DELETE CASCADE
)
