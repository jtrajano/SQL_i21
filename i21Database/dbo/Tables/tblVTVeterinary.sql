CREATE TABLE [dbo].[tblVTVeterinary]
(
	[intEntityVeterinaryId] INT NOT NULL,
	[strLicenseNumber] NVARCHAR(100) NOT NULL,
	[strLicensingState] NVARCHAR(50) NULL,
	[dtmLicenseExpiration] DATETIME NULL,
	[ysnActive] BIT DEFAULT(1),
    [intConcurrencyId] INT DEFAULT ((0)) NOT NULL,

	CONSTRAINT [PK_tblVTVeterinary_intEntityId] PRIMARY KEY CLUSTERED ([intEntityVeterinaryId] ASC),
	CONSTRAINT [FK_tblVTVeterinary_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityVeterinaryId]) REFERENCES [dbo].tblEMEntity ([intEntityId])  ON DELETE CASCADE,
)
