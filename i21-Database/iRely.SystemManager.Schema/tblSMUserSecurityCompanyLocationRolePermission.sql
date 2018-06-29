CREATE TABLE [dbo].[tblSMUserSecurityCompanyLocationRolePermission]
(
	[intUserSecurityCompanyLocationRolePermissionId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityUserSecurityId] INT NULL, 
	[intEntityId] INT NOT NULL, 
    [intUserRoleId] INT NOT NULL, 
	[intMultiCompanyId] INT NULL, 
	[intCompanyLocationId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]),
	CONSTRAINT [FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMMultiCompany] FOREIGN KEY ([intMultiCompanyId]) REFERENCES [tblSMMultiCompany]([intMultiCompanyId]),
	CONSTRAINT [FK_tblSMUserSecurityCompanyLocationRolePermission_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) ON DELETE CASCADE, 
    CONSTRAINT [AK_tblSMUserSecurityCompanyLocationRolePermission_Column] UNIQUE ([intEntityUserSecurityId], [intUserRoleId], [intCompanyLocationId])
)
GO