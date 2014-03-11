CREATE TABLE [dbo].[tblSMUserSecurityControlPermission]
(
	[intUserSecurityControlPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserSecurityId] INT NOT NULL, 
    [intControlId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityControlPermission_tblSMUserSecurity] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intUserSecurityID]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSMUserSecurityControlPermission_tblSMControl] FOREIGN KEY ([intControlId]) REFERENCES [tblSMControl]([intControlId]) ON DELETE CASCADE
)

GO

CREATE INDEX [IX_tblSMUserSecurityControlPermission_intUserSecurityId] ON [dbo].[tblSMUserSecurityControlPermission] ([intUserSecurityId])

GO

CREATE INDEX [IX_tblSMUserSecurityControlPermission_intControlId] ON [dbo].[tblSMUserSecurityControlPermission] ([intControlId])
