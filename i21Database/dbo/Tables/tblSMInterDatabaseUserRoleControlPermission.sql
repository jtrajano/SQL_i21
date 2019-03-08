CREATE TABLE [dbo].[tblSMInterDatabaseUserRoleControlPermission]
(
	[intUserRoleControlPermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intUserRoleId] INT NOT NULL, 
    [intControlId] INT NOT NULL, 
    [strPermission] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
	[strLabel]			NVARCHAR (50)  COLLATE Latin1_General_CI_AS  NULL,
    [strDefaultValue]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS  NULL,
    [ysnRequired]		BIT	NULL,  
    [intConcurrencyId] INT NOT NULL DEFAULT (1)
)