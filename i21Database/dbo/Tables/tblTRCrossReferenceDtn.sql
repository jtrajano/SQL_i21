CREATE TABLE [dbo].[tblTRCrossReferenceDtn]
(
	[intCrossReferenceDtnId] INT NOT NULL IDENTITY,
    [intCrossReferenceId] INT NOT NULL,
    [strType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strImportValue] NVARCHAR(500) COLLATE Latin1_General_CI_AS NOT NULL,
    [intVendorId] INT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRCrossReferenceDtn_intCrossReferenceDtnId] PRIMARY KEY CLUSTERED ([intCrossReferenceDtnId] ASC),
	CONSTRAINT [FK_tblTRCrossReferenceDtn_tblTRCrossReference_intCrossReferenceId] FOREIGN KEY ([intCrossReferenceId]) REFERENCES [dbo].[tblTRCrossReference] ([intCrossReferenceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTRCrossReferenceDtn_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityId])
)
