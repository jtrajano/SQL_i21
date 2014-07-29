CREATE TABLE [dbo].[tblSMUserSecurityReportPermission]
(
	[intUserSecurityReportPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intReportId] INT NOT NULL, 
    [strPrinter] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [ysnCollate] BIT NOT NULL DEFAULT (0), 
    [intCopies] INT NOT NULL DEFAULT (1), 
    [ysnPreview] BIT NOT NULL DEFAULT (1), 
    [ysnPermission] BIT NOT NULL DEFAULT (0), 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityReportPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityReportPermission_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [tblRMReport]([intReportId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityReportPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityReportPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityReportPermission_intReportId] ON [dbo].[tblSMUserSecurityReportPermission] ([intReportId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityReportPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Report Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intReportId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Printer',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPrinter'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Collate',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnCollate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Number of Copies',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intCopies'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Preview',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnPreview'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'ysnPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityReportPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'