CREATE TABLE [dbo].[tblAPImportedVendors]
(
	[strVendorId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL PRIMARY KEY,
	[ysnOrigin]		BIT DEFAULT(0) NOT NULL
)
