CREATE TABLE [dbo].[tblSMUserRoleDashboardPermission]
(
	[intUserRoleDashboardPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intPanelId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleDashboardPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserRoleDashboardPermission_tblDBPanel] FOREIGN KEY ([intPanelId]) REFERENCES [tblDBPanel]([intPanelId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserRoleDashboardPermission_intPanelId] ON [dbo].[tblSMUserRoleDashboardPermission] ([intPanelId])

GO

CREATE INDEX [IX_tblSMUserRoleDashboardPermission_intUserRoleId] ON [dbo].[tblSMUserRoleDashboardPermission] ([intUserRoleId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleDashboardPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Panel Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intPanelId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'