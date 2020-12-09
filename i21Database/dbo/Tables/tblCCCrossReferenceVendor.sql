CREATE TABLE [dbo].[tblCCCrossReferenceVendor]
(
	[intCrossReferenceVendorId] INT NOT NULL IDENTITY,
	[intCrossReferenceId] INT NOT NULL,
	[intVendorDefaultId] INT NOT NULL,
	[strImportValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblCCCrossReferenceVendor_intCrossReferenceVendorId] PRIMARY KEY CLUSTERED ([intCrossReferenceVendorId] ASC),
	CONSTRAINT [FK_tblCCCrossReferenceVendor_tblCCCrossReference_intCrossReferenceId] FOREIGN KEY ([intCrossReferenceId]) REFERENCES [dbo].[tblCCCrossReference] ([intCrossReferenceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCCCrossReferenceVendor_tblCCVendorDefault_intVendorDefaultId] FOREIGN KEY ([intVendorDefaultId]) REFERENCES [tblCCVendorDefault]([intVendorDefaultId]),
	CONSTRAINT [UK_tblCCCrossReferenceVendor_strImportValue] UNIQUE ([strImportValue])
)
