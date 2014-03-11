CREATE TABLE [dbo].[tblSMUserSecurityScreenPermission]
(
	[intUserSecurityScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
	[strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityScreenPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityScreenPermission_tblSMScreen] FOREIGN KEY ([intScreenId]) REFERENCES [tblSMScreen]([intScreenId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityScreenPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityScreenPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityScreenPermission_intScreenId] ON [dbo].[tblSMUserSecurityScreenPermission] ([intScreenId])
