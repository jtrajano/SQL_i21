CREATE TABLE [dbo].[tblAGRestrictedChemical]
(
    [intRestrictedChemicalId] INT IDENTITY(1,1) NOT NULL,
    [intItemRestrictedId] INT NOT NULL,
    [intApplicatorLicenseCategoryId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_dbo.tblAGRestrictedChemical_intRestrictedChemicalId] PRIMARY KEY CLUSTERED ([intRestrictedChemicalId] ASC),
    CONSTRAINT [FK_tblAGRestrictedChemical_intApplicatorLicenseCategoryId] FOREIGN KEY([intApplicatorLicenseCategoryId]) REFERENCES [dbo].[tblAGApplicatorLicenseCategory] ([intApplicatorLicenseCategoryId]),
    CONSTRAINT [FK_tblAGRestrictedChemical_intItemRestrictedId] FOREIGN KEY ([intItemRestrictedId]) REFERENCES [dbo].[tblICItem] ([intItemId]),
    CONSTRAINT [UK_tblAGRestrictedChemical_intApplicatorLicenseCategoryId_intItemRestrictedId] UNIQUE ([intApplicatorLicenseCategoryId],[intItemRestrictedId])
)