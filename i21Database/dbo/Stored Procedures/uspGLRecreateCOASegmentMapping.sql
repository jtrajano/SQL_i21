CREATE PROCEDURE  [dbo].[uspGLRecreateCOASegmentMapping]
AS
BEGIN

	DELETE tblGLAccountSegmentMapping 

	SELECT * INTO #tempGLAccount FROM tblGLAccount 
	DECLARE @DIVIdER VARCHAR(200) = (SELECT TOP 1 strMask FROM tblGLAccountStructure WHERE strType = 'Divider')

	WHILE EXISTS(SELECT 1 FROM #tempGLAccount)
	BEGIN
		
		SELECT * INTO #Structure FROM tblGLAccountStructure WHERE strType <> 'Divider'
		
		DECLARE @intAccountId INT = (SELECT TOP 1 intAccountId FROM #tempGLAccount)	
		DECLARE @strAccountId VARCHAR(200) = (SELECT TOP 1 strAccountId FROM #tempGLAccount)	
		DECLARE @segmentCODE VARCHAR(200)
		Declare @segmentCount INT = 0
		Declare @segmentId INT = NULL
		Declare @intAccountStructureId INT = NULL
		DECLARE @strType VARCHAR(200) 

		WHILE EXISTS(SELECT 1 FROM #Structure)
		BEGIN
			SELECT TOP 1 @strType = strType, @intAccountStructureId = intAccountStructureId FROM #Structure ORDER BY intSort
			IF @strType = 'Primary' 
				BEGIN
					SET @segmentCODE = SUBSTRING(@strAccountId, @segmentCount, PATINDEX('%' + @DIVIdER + '%',@strAccountId))			
					SET @segmentId = (SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountStructureId = @intAccountStructureId and strCode = @segmentCODE)
					
					INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@intAccountId, @segmentId)
					SET @segmentCount = @segmentCount + LEN(@segmentCODE)
				END

			ELSE IF @strType = 'Segment'
				BEGIN
					SET @segmentCODE = SUBSTRING(@strAccountId, @segmentCount + 2, PATINDEX('%' + @DIVIdER + '%',@strAccountId))			
					SET @segmentId = (SELECT intAccountSegmentId FROM tblGLAccountSegment WHERE intAccountStructureId = @intAccountStructureId and strCode = @segmentCODE)
					
					INSERT INTO tblGLAccountSegmentMapping ([intAccountId], [intAccountSegmentId]) values (@intAccountId, @segmentId)
					SET @segmentCount = @segmentCount + LEN(@segmentCODE)
				END
			
			DELETE FROM #Structure WHERE intAccountStructureId = @intAccountStructureId	
		END
		
		DROP TABLE #Structure
		DELETE FROM #tempGLAccount WHERE strAccountId = @strAccountId	
	END

	DROP TABLE #tempGLAccount
	
	EXEC [uspGLBuildTempCOASegment]

END
