CREATE TABLE [dbo].[tblSMUserSecurityScreenPermission]
(
	[intUserSecurityScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
	[strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityScreenPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityScreenPermission_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityScreenPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityScreenPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityScreenPermission_intScreenId] ON [dbo].[tblSMUserSecurityScreenPermission] ([intScreenId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityScreenPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Screen Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intScreenId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityScreenPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'