CREATE TABLE [dbo].[tblSMUserSecurityFRPermission]
(
	[intUserSecurityFRPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityFRPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityFRPermission_tblFRReport] FOREIGN KEY ([intReportId]) REFERENCES [tblFRReport]([intReportId]) ON DELETE CASCADE
)

GO


CREATE INDEX [IX_tblSMUserSecurityFRPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityFRPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityFRPermission_intReportId] ON [dbo].[tblSMUserSecurityFRPermission] ([intReportId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityFRPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Report Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intReportId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityFRPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'