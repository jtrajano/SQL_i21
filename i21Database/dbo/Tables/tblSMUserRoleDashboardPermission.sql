CREATE TABLE [dbo].[tblSMUserRoleDashboardPermission]
(
	[intUserRoleDashboardPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intPanelId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleDashboardPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserRoleDashboardPermission_tblDBPanel] FOREIGN KEY ([intPanelId]) REFERENCES [tblDBPanel]([intPanelId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserRoleDashboardPermission_intPanelId] ON [dbo].[tblSMUserRoleDashboardPermission] ([intPanelId])

GO

CREATE INDEX [IX_tblSMUserRoleDashboardPermission_intUserRoleId] ON [dbo].[tblSMUserRoleDashboardPermission] ([intUserRoleId])
