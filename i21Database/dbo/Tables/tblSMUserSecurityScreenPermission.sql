CREATE TABLE [dbo].[tblSMUserSecurityScreenPermission]
(
	[intUserSecurityScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [strScreenName] NVARCHAR(100) NOT NULL, 
    [strScreenNameSpace] NVARCHAR(150) NOT NULL, 
    [strModuleName] NVARCHAR(50) NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityScreenPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) 
)

GO

CREATE INDEX [IX_tblSMUserSecurityScreenPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityScreenPermission] ([intUserSecurityId])
