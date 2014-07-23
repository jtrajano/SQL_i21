CREATE TABLE [dbo].[tblSMEULA]
(
	[intEULAId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strVersionNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strText] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)

GO

CREATE INDEX [IX_tblSMEULA_strVersionNumber] ON [dbo].[tblSMEULA] ([strVersionNumber])
