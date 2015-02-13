CREATE TABLE [dbo].[tblSMTaxGroup]
(
	[intTaxGroupId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strTaxGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
