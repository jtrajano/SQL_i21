CREATE TABLE [dbo].[tblAPVendorSynergyExported]
(
	[intId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[intVendorId] INT NOT NULL,
	CONSTRAINT [UK_dbo.tblAPVendorSynergyExported_intVendorId] UNIQUE (intVendorId)

)
