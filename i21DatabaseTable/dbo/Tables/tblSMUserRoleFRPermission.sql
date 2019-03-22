CREATE TABLE [dbo].[tblSMUserRoleFRPermission]
(
	[intUserRoleFRPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleFRPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserRoleFRPermission_tblFRReport] FOREIGN KEY ([intReportId]) REFERENCES [tblFRReport]([intReportId]) ON DELETE CASCADE
)

GO


CREATE INDEX [IX_tblSMUserRoleFRPermission_intUserRoleId] ON [dbo].[tblSMUserRoleFRPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleFRPermission_intReportId] ON [dbo].[tblSMUserRoleFRPermission] ([intReportId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleFRPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Report Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intReportId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'