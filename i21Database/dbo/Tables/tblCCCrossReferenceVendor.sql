CREATE TABLE [dbo].[tblCCCrossReferenceVendor]
(
	[intCrossReferenceVendorId] INT NOT NULL IDENTITY,
	[intVendorId] INT NOT NULL,
	[strImportValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblCCCrossReferenceVendor_intCrossReferenceVendorId] PRIMARY KEY CLUSTERED ([intCrossReferenceVendorId] ASC),
	CONSTRAINT [FK_tblCCCrossReferenceVendor_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityId])
)
