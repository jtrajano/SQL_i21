CREATE TABLE [dbo].[tblAPVendorImportInfo]
(
	[intId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	[intEntityVendorId] INT NOT NULL,
	[intCompanyLocationId] INT NOT NULL,
	[strLocationXRef] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 0,
	CONSTRAINT [FK_tblAPVendorImportInfo_intCompanyLocationId] FOREIGN KEY ([intCompanyLocationId]) REFERENCES tblSMCompanyLocation([intCompanyLocationId]),
	CONSTRAINT [FK_dbo.tblAPVendorImportInfo_dbo.tblAPVendor_intVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor([intEntityId])
)
