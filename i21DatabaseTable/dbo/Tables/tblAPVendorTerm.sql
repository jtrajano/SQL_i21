CREATE TABLE [dbo].[tblAPVendorTerm]
(
	[intVendorTermId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityVendorId] INT NOT NULL,
	[intTermId] INT NOT NULL,

	[intConcurrencyId] INT NOT NULL DEFAULT(0),
	CONSTRAINT [FK_tblAPVendorTerm_tblAPVendor_intEntityVendorId] FOREIGN KEY ([intEntityVendorId]) REFERENCES tblAPVendor([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPVendorTerm_tblSMTerm_intTermId] FOREIGN KEY ([intTermId]) REFERENCES tblSMTerm([intTermID])

)
