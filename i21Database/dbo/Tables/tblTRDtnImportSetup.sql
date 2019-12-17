CREATE TABLE [dbo].[tblTRDtnImportSetup]
(
	[intDtnImportSetupId] INT NOT NULL IDENTITY,
	[strImportSetupName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblTRDtnImportSetup] PRIMARY KEY ([intDtnImportSetupId]),
	CONSTRAINT [UK_tblTRDtnImportSetup_strImportSetupName] UNIQUE NONCLUSTERED ([strImportSetupName] ASC)
)
