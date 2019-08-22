CREATE TABLE [dbo].[tblTROverrideTaxGroup]
(
	[intOverrideTaxGroupId] INT NOT NULL IDENTITY,
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDateCreated] DATETIME NOT NULL DEFAULT (GETDATE()),
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblTROverrideTaxGroup_intOverrideTaxGroupId] PRIMARY KEY CLUSTERED ([intOverrideTaxGroupId] ASC), 
    CONSTRAINT [UK_tblTROverrideTaxGroup_strName] UNIQUE NONCLUSTERED ([strName] ASC)   
)
