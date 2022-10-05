CREATE TABLE [dbo].[tblAPVendorContactInfoSynergy]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intVendorStagingId] INT NOT NULL,
	[strContact] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFirstName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strLastName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAddress1] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strAddress2] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCity] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCountry] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strStateProv] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPostalCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPhone] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strMobile] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strFax] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEmail] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strWebsite] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [FK_dbo.tblAPVendorStagingSynergy.tblAPVendorContactInfoSynergy_intVendorStagingId] FOREIGN KEY ([intVendorStagingId]) REFERENCES [dbo].tblAPVendorStagingSynergy ([intVendorStagingId]) ON DELETE CASCADE
)
