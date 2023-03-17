CREATE TABLE [dbo].[tblAPVendorCompanyLocation]
(
	[intVendorCompanyLocationId] INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[intEntityVendorId] INT NOT NULL,
	[intCompanyLocationId] INT NOT NULL,
	[intConcurrencyId] INT NOT NULL,

	CONSTRAINT [FK_dbo.tblAPVendorCompanyLocation_dbo.tblAPVendor_intVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor([intEntityId])  ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblAPVendorCompanyLocation_dbo.tblSMCompanyLocation_intCompanyLocationId] FOREIGN KEY (intCompanyLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId)
)
