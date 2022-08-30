CREATE TABLE [dbo].[tblSMUserSecurityCompanySegmentRolePermission]
(
	[intUserSecurityCompanySegmentRolePermissionId]		INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityUserSecurityId]							INT NULL, 
	[intEntityId]										INT NOT NULL, 
    [intUserRoleId]										INT NOT NULL, 
	intCompanyAccountSegmentId							INT NOT NULL, 
    [intConcurrencyId]									INT NOT NULL DEFAULT 1, 

    CONSTRAINT [FK_tblSMUserSecurityCompanySegmentRolePermission_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSMUserSecurityCompanySegmentRolePermission_tblSMUserRole] FOREIGN KEY ([intUserRoleId]) REFERENCES [tblSMUserRole]([intUserRoleID]),
	CONSTRAINT [FK_tblSMUserSecurityCompanySegmentRolePermission_tblGLAccountSegment] FOREIGN KEY ([intCompanyAccountSegmentId]) REFERENCES tblGLAccountSegment([intAccountSegmentId]), 
    CONSTRAINT [AK_tblSMUserSecurityCompanySegmentRolePermission_Column] UNIQUE ([intEntityUserSecurityId], [intUserRoleId], [intCompanyAccountSegmentId])
)
GO