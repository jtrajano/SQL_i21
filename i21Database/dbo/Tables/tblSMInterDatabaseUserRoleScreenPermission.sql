CREATE TABLE [dbo].[tblSMInterDatabaseUserRoleScreenPermission]
(
	[intUserRoleScreenPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intScreenId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT (1), 
)