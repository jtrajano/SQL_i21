GO
	PRINT N'BEGIN INSERT DEFAULT SEGMENT TEMPLATE'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment')
	BEGIN
		INSERT [dbo].[tblGLCOATemplate] ([strAccountTemplateName], [strType], [intConcurrencyId]) VALUES (N'Location', N'Segment', 1)
	END	
GO
	PRINT N'END INSERT DEFAULT SEGMENT TEMPLATE'
	PRINT N'BEGIN INSERT DEFAULT SEGMENT TEMPLATE DETAIL'
GO
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '00' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0000', N'All', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '10' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0001', N'Location 001', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '20' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0002', N'Location 002', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '30' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0003', N'Location 003', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '40' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0004', N'Location 004', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '50' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0005', N'Location 005', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '60' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0006', N'Location 006', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '70' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0007', N'Location 007', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '80' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0008', N'Location 008', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '90' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'0009', N'Location 009', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
GO
	PRINT N'END INSERT DEFAULT SEGMENT TEMPLATE DETAIL'
GO
