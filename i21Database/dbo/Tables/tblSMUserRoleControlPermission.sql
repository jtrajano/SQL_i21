CREATE TABLE [dbo].[tblSMUserRoleControlPermission]
(
	[intUserRoleControlPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intControlId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleControlPermission_tblSMControl] FOREIGN KEY ([intControlId]) REFERENCES [tblSMControl]([intControlId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserRoleControlPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserRoleControlPermission_intUserRoleId] ON [dbo].[tblSMUserRoleControlPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleControlPermission_intControlId] ON [dbo].[tblSMUserRoleControlPermission] ([intControlId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleControlPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Control Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intControlId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'