CREATE TABLE [dbo].[tblSMUserRoleSubRole]
(
	[intUserRoleSubRoleId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intSubRoleId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1
)
