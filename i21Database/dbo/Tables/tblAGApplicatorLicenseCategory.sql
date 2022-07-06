CREATE TABLE [dbo].[tblAGApplicatorLicenseCategory]
(
    [intApplicatorLicenseCategoryId] INT IDENTITY(1,1) NOT NULL,
    [strCategoryNumber] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strCategoryName] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [strDescription] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
    [intTypeTaxStateId] INT NULL,
    [strComment] NVARCHAR(MAX) NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_dbo.tblAGApplicatorLicenseCategory_intApplicatorLicenseCategoryId] PRIMARY KEY CLUSTERED ([intApplicatorLicenseCategoryId] ASC),
    CONSTRAINT [FK_tblAGApplicatorLicenseCategory_intTypeTaxStateId] FOREIGN KEY([intTypeTaxStateId]) REFERENCES [dbo].[tblPRTypeTaxState] ([intTypeTaxStateId])
    
)
