CREATE TABLE [dbo].[tblSMUserRoleSubRole]
(
	[intUserRoleSubRoleId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intSubRoleId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblSMUserRoleSubRole_tblSMUserRole1] FOREIGN KEY ([intSubRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]),
	CONSTRAINT [FK_tblSMUserRoleSubRole_tblSMUserRole2] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]) ON DELETE CASCADE
)
