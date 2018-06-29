CREATE TABLE [dbo].[tblSMUserRoleScreenPermission]
(
	[intUserRoleScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleScreenPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserRoleScreenPermission_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserRoleScreenPermission_intUserRoleId] ON [dbo].[tblSMUserRoleScreenPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleScreenPermission_intScreenId] ON [dbo].[tblSMUserRoleScreenPermission] ([intScreenId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleScreenPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intScreenId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'