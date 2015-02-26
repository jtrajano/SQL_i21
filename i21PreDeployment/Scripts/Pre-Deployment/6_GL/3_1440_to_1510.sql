--CHECKS FOR PROFIT CENTER OR LOCATION IS PRESENT IN ACCOUNT STRUCTURE TABLE
GO
EXEC('IF EXISTS(SELECT  *  FROM  sys.objects WHERE    object_id = OBJECT_ID(N''[dbo].[tblGLAccountStructure]'') AND type in (N''U''))
	  BEGIN
		 IF EXISTS(SELECT TOP 1 1 FROM tblGLAccountStructure)	
			BEGIN
				IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLAccountStructure WHERE strType = ''Segment'' and (LOWER(strStructureName) like ''profit center%'' OR strStructureName = ''Location''))
				RAISERROR(N''Missing valid structure (i.e. location/profit center) in tblGLAccountStructure, Deployment Terminated.'', 16,1)
			END
		ELSE
			BEGIN
				INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (1, N''Primary Account'', N''Primary'', 5, N''0'', 0, 1, 1, 4, NULL, NULL)
				INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (2, N''Hypen/Separator'', N''Divider'', 1, N''-'', 1, 0, 1, 0, NULL, NULL)
				INSERT [dbo].[tblGLAccountStructure] ([intStructureType], [strStructureName], [strType], [intLength], [strMask], [intSort], [ysnBuild], [intConcurrencyId], [intStartingPosition], [intOriginLength], [strOtherSoftwareColumn]) VALUES (3, N''Location'', N''Segment'', 4, N''0'', 2, 1, 1, 5, NULL, NULL)
			END
	  END')
GO