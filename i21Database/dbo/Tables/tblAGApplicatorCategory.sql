CREATE TABLE [dbo].[tblAGApplicatorCategory]
(
	[intApplicatorCategoryId]				INT				NOT NULL PRIMARY KEY IDENTITY(1,1),
	[intEntityId]							INT				NOT NULL,
	[intApplicatorLicenseCategoryId]		INT				NOT NULL,
    [intConcurrencyId]						INT				NOT NULL DEFAULT (1), 

	CONSTRAINT [FK_dbo_tblAGApplicatorCategory_tblEMEntity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAGApplicatorCategroy_tblAGApplicatorLicenseCategory] FOREIGN KEY ([intApplicatorLicenseCategoryId]) REFERENCES [tblAGApplicatorLicenseCategory]([intApplicatorLicenseCategoryId])
);