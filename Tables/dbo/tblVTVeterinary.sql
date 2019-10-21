CREATE TABLE [dbo].[tblVTVeterinary]
(
	[intEntityId] INT NOT NULL,
	[strLicenseNumber] NVARCHAR(100) NOT NULL,
	[strLicensingState] NVARCHAR(50) NULL,
	[dtmLicenseExpiration] DATETIME NULL,
	[ysnActive] BIT DEFAULT(1),
    [intConcurrencyId] INT DEFAULT ((0)) NOT NULL,

	CONSTRAINT [PK_tblVTVeterinary_intEntityId] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
	CONSTRAINT [FK_tblVTVeterinary_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId])  ON DELETE CASCADE,
)
