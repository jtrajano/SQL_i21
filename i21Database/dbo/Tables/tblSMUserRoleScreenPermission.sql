CREATE TABLE [dbo].[tblSMUserRoleScreenPermission]
(
	[intUserRoleScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [strScreenName] NVARCHAR(100) NOT NULL, 
    [strScreenNameSpace] NVARCHAR(150) NOT NULL, 
    [strModuleName] NVARCHAR(50) NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleScreenPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) 
)

GO

CREATE INDEX [IX_tblSMUserRoleScreenPermission_intUserRoleId] ON [dbo].[tblSMUserRoleScreenPermission] ([intUserRoleId])
