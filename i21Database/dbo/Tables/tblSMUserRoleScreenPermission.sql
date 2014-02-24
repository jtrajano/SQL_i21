CREATE TABLE [dbo].[tblSMUserRoleScreenPermission]
(
	[intUserRoleScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleScreenPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]), 
    CONSTRAINT [FK_tblSMUserRoleScreenPermission_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) 
)

GO

CREATE INDEX [IX_tblSMUserRoleScreenPermission_intUserRoleId] ON [dbo].[tblSMUserRoleScreenPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleScreenPermission_intScreenId] ON [dbo].[tblSMUserRoleScreenPermission] ([intScreenId])
