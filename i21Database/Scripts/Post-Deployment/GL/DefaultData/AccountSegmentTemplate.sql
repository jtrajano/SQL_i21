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
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'00', N'All', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '10' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'10', N'Location 001', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '20' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'20', N'Location 002', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '30' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'30', N'Location 003', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '40' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'40', N'Location 004', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '50' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'50', N'Location 005', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '60' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'60', N'Location 006', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '70' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'70', N'Location 007', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '80' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'80', N'Location 008', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLCOATemplateDetail WHERE strCode = '90' and intAccountTemplateId =(SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'))
	BEGIN
		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), N'90', N'Location 009', NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
	END	
GO
	PRINT N'END INSERT DEFAULT SEGMENT TEMPLATE DETAIL'
GO
