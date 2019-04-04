CREATE TABLE [dbo].[tblAPVendorContactInfoSynergy]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intVendorStagingId] INT NOT NULL,
	[strContact] NVARCHAR(100) NULL,
	[strFirstName] NVARCHAR(100) NULL,
	[strLastName] NVARCHAR(100) NULL,
	[strAddress1] NVARCHAR(100) NULL,
	[strAddress2] NVARCHAR(100) NULL,
	[strCity] NVARCHAR(100) NULL,
	[strStateProv] NVARCHAR(100) NULL,
	[strPostalCode] NVARCHAR(100) NULL,
	[strPhone] NVARCHAR(100) NULL,
	[strMobile] NVARCHAR(100) NULL,
	[strFax] NVARCHAR(100) NULL,
	[strEmail] NVARCHAR(100) NULL,
	[strWebsite] NVARCHAR(100) NULL,
	CONSTRAINT [FK_dbo.tblAPVendorStagingSynergy.tblAPVendorContactInfoSynergy_intVendorStagingId] FOREIGN KEY ([intVendorStagingId]) REFERENCES [dbo].tblAPVendorStagingSynergy ([intVendorStagingId]) ON DELETE CASCADE
)
