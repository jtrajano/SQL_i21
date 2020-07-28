CREATE TABLE [dbo].[tblSMUserSecurityBookPermission]
(
	[intUserSecurityBookPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityId]       INT NOT NULL, 
    [intBookId]		    INT NOT NULL, 
    [intSubBookId]		INT NULL,    
    [intConcurrencyId]	INT NOT NULL DEFAULT (1), 
    CONSTRAINT [FK_tblSMUserSecurityBookPermission_tblSMUserSecurity_intEntityId] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityBookPermission_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [FK_tblSMUserSecurityBookPermission_tblCTSubBook_intSubBookId] FOREIGN KEY ([intSubBookId]) REFERENCES [tblCTSubBook]([intSubBookId])
)

GO