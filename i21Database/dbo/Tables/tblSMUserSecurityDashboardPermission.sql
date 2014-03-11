CREATE TABLE [dbo].[tblSMUserSecurityDashboardPermission]
(
	[intUserSecurityDashboardPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intPanelId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityDashboardPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityDashboardPermission_tblDBPanel] FOREIGN KEY ([intPanelId]) REFERENCES [tblDBPanel]([intPanelId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityDashboardPermission_intPanelId] ON [dbo].[tblSMUserSecurityDashboardPermission] ([intPanelId])

GO

CREATE INDEX [IX_tblSMUserSecurityDashboardPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityDashboardPermission] ([intUserSecurityId])
