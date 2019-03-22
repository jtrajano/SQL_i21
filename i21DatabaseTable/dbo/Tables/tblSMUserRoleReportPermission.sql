CREATE TABLE [dbo].[tblSMUserRoleReportPermission]
(
	[intUserRoleReportPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPrinter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnCollate] BIT NOT NULL DEFAULT (0), 
    [intCopies] INT NOT NULL DEFAULT (1), 
    [ysnPreview] BIT NOT NULL DEFAULT (1), 
    [ysnPermission] BIT NOT NULL DEFAULT (0), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserRoleReportPermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserRoleReportPermission_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [tblRMReport]([intReportId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserRoleReportPermission_intUserRoleId] ON [dbo].[tblSMUserRoleReportPermission] ([intUserRoleId])

GO

CREATE INDEX [IX_tblSMUserRoleReportPermission_intReportId] ON [dbo].[tblSMUserRoleReportPermission] ([intReportId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleReportPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Role Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserRoleId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Report Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intReportId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Collate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnCollate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of Copies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intCopies'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preview',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnPreview'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserRoleReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'