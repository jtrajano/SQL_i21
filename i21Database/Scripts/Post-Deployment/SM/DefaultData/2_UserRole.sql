GO
	PRINT N'BEGIN INSERT DEFAULT USER ROLE'
GO
	ALTER TABLE tblSMUserSecurity NOCHECK CONSTRAINT FK_UserSecurity_UserRole
GO
	SET IDENTITY_INSERT [dbo].[tblSMUserRole] ON
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'ADMIN') INSERT [dbo].[tblSMUserRole] ([intUserRoleID], [strName], [strDescription], [ysnAdmin]) VALUES (1, N'ADMIN', N'Do not use in Production! For Demo Purposes Only!', 1)
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMUserRole WHERE strName = 'USER') INSERT [dbo].[tblSMUserRole] ([intUserRoleID], [strName], [strDescription], [ysnAdmin]) VALUES (2, N'USER', N'Do not use in Production! For Demo Purposes Only!', 0)
	SET IDENTITY_INSERT [dbo].[tblSMUserRole] OFF
GO
	UPDATE tblSMUserRole
	SET strDescription = 'Do not use in Production! For Demo Purposes Only!'
	WHERE strName IN ('USER', 'ADMIN')
GO
	ALTER TABLE tblSMUserSecurity CHECK CONSTRAINT FK_UserSecurity_UserRole
GO
	PRINT N'END INSERT DEFAULT USER ROLE'
GO