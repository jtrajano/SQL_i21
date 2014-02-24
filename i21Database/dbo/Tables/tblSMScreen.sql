CREATE TABLE [dbo].[tblSMScreen]
(
	[intScreenId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strScreenId] NVARCHAR(100) NOT NULL, 
	[strScreenName] NVARCHAR(100) NOT NULL, 
    [strNamespace] NVARCHAR(150) NOT NULL, 
    [strModule] NVARCHAR(100) NOT NULL, 
    [intConcurrencyId] NVARCHAR(50) NOT NULL DEFAULT (1)
)

GO

CREATE INDEX [IX_tblSMScreen_strScreenName] ON [dbo].[tblSMScreen] ([strScreenName])

GO

CREATE INDEX [IX_tblSMScreen_strModule] ON [dbo].[tblSMScreen] ([strModule])

GO

CREATE INDEX [IX_tblSMScreen_strScreenId] ON [dbo].[tblSMScreen] ([strScreenId])
