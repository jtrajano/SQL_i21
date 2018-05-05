CREATE TABLE [dbo].[tblICItemLicense]
(
	[intItemLicenseId] INT IDENTITY NOT NULL,
	[intItemId] INT NOT NULL,
	[intLicenseTypeId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
	CONSTRAINT [PK_tblICItemLicense] PRIMARY KEY ([intItemLicenseId]),
	CONSTRAINT [FK_tblICItemLicense_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICItemLicense_tblSMLicenseType] FOREIGN KEY ([intLicenseTypeId]) REFERENCES [tblSMLicenseType]([intLicenseTypeId])
)