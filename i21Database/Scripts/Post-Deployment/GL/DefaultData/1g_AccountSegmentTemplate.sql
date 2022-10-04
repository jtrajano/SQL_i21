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
	-- Get length of Location segment in Account Structure
	DECLARE @intLength INT, @strCode NVARCHAR(20), @intCounter INT = 0
	SELECT TOP 1 @intLength = intLength FROM [dbo].[tblGLAccountStructure] WHERE [intStructureType] = 3

	WHILE (@intCounter <= 9)
	BEGIN
		SET @strCode = REPLICATE('0', @intLength - 1) + CAST(@intCounter AS NVARCHAR)

		-- Delete existing default templates
		DELETE Detail
		FROM tblGLCOATemplateDetail Detail
		JOIN tblGLCOATemplate Header
			ON Header.intAccountTemplateId = Detail.intAccountTemplateId
		WHERE Header.strAccountTemplateName = N'Location' AND strType = N'Segment' AND Detail.strCode = @strCode

		INSERT [dbo].[tblGLCOATemplateDetail] ([intAccountTemplateId], [strCode], [strDescription], [intAccountGroupId], [intAccountStructureId], [intConcurrencyId]) 
			VALUES ((SELECT TOP 1 intAccountTemplateId FROM tblGLCOATemplate WHERE strAccountTemplateName = N'Location' and strType = N'Segment'), @strCode, CASE WHEN @intCounter = 0 THEN N'All' ELSE N'Location ' + @strCode END, NULL, (SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = N'Segment' and strStructureName = N'Location'), 1)
		
		SET @intCounter += 1
	END
GO
	PRINT N'END INSERT DEFAULT SEGMENT TEMPLATE DETAIL'
GO
