CREATE TABLE [dbo].[tblSMEULA]
(
	[intEULAId] INT NOT NULL PRIMARY KEY, 
    [strVersionNumber] NVARCHAR(50) NOT NULL, 
    [strText] NVARCHAR(MAX) NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)

GO

CREATE INDEX [IX_tblSMEULA_strVersionNumber] ON [dbo].[tblSMEULA] ([strVersionNumber])
