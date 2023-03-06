CREATE TABLE [dbo].[tblTRCrossReference]
(
	[intCrossReferenceId] INT NOT NULL IDENTITY,
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDateCreated] DATETIME NOT NULL DEFAULT (GETDATE()),
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)),
    CONSTRAINT [PK_tblTRCrossReference_intCrossReferenceId] PRIMARY KEY CLUSTERED ([intCrossReferenceId] ASC), 
    CONSTRAINT [UK_tblTRCrossReference_strName] UNIQUE NONCLUSTERED ([strName] ASC) 
)
