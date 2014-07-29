CREATE TABLE [dbo].[tblSMUserSecurityDashboardPermission]
(
	[intUserSecurityDashboardPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intPanelId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityDashboardPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityDashboardPermission_tblDBPanel] FOREIGN KEY ([intPanelId]) REFERENCES [tblDBPanel]([intPanelId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityDashboardPermission_intPanelId] ON [dbo].[tblSMUserSecurityDashboardPermission] ([intPanelId])

GO

CREATE INDEX [IX_tblSMUserSecurityDashboardPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityDashboardPermission] ([intUserSecurityId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityDashboardPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Panel Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intPanelId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityDashboardPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'