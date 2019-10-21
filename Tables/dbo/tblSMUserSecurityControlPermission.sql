CREATE TABLE [dbo].[tblSMUserSecurityControlPermission]
(
	[intUserSecurityControlPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityUserSecurityId] INT NOT NULL, 
    [intControlId]		INT NOT NULL, 
    [strPermission]		NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strLabel]			NVARCHAR (50)  COLLATE Latin1_General_CI_AS  NULL,
    [strDefaultValue]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS  NULL,
    [ysnRequired]		BIT	NULL,    
    [intConcurrencyId]	INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityControlPermission_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityControlPermission_tblSMControl] FOREIGN KEY ([intControlId]) REFERENCES [tblSMControl]([intControlId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityControlPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityControlPermission] ([intEntityUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityControlPermission_intControlId] ON [dbo].[tblSMUserSecurityControlPermission] ([intControlId])

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intUserSecurityControlPermissionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Security Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intEntityUserSecurityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Control Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intControlId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Permission',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'strPermission'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Check',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblSMUserSecurityControlPermission',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'