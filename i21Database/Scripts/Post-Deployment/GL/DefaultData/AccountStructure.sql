GO
	PRINT N'BEGIN INSERT DEFAULT ACCOUNT STRUCTURE'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = N'Primary') AND NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount)
	BEGIN
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (1, N'Primary Account', N'Primary', 5, N'0', 0, 1, 1, 4, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = N'Divider' and strStructureName = N'Hypen/Separator') AND NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount)
	BEGIN
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (2, N'Hypen/Separator', N'Divider', 1, N'-', 1, 0, 1, 0, NULL, NULL)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Profit Center') AND NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccount)
	BEGIN
		INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (3, N'Profit Center', N'Segment', 4, N'0', 2, 1, 1, 5, NULL, NULL)
	END
GO
	PRINT N'END INSERT DEFAULT ACCOUNT STRUCTURE'
GO
