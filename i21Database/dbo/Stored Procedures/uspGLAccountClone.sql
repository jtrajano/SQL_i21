CREATE PROCEDURE  [dbo].[uspGLAccountClone]
@intUserId INT,
@intCodes NVARCHAR(200)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

	DECLARE @query VARCHAR(2000)			
	DECLARE @tblQuery TABLE
	(
		 intAccountSegmentId INT
	)
	
	SET @query = 'SELECT intAccountSegmentId FROM tblGLAccountSegment
						WHERE intAccountSegmentId IN (
								SELECT intAccountSegmentId FROM tblGLAccountSegmentMapping 
									WHERE intAccountId IN (
											SELECT intAccountId FROM tblGLAccountSegmentMapping 
												WHERE intAccountSegmentId IN (' + @intCodes + ')
												GROUP BY intAccountId 
												HAVING count(*) = (SELECT COUNT(*) FROM tblGLAccountStructure WHERE strType = ''Segment'')))	
						AND intAccountStructureId = (SELECT intAccountStructureId FROM tblGLAccountStructure WHERE strType = ''Primary'')'

	INSERT INTO @tblQuery EXEC (@query)	

	INSERT INTO tblGLTempAccountToBuild
	SELECT
		intAccountSegmentId
		,@intUserId
		,dtmCreated = getDate()
	FROM
	@tblQuery
	
	EXEC uspGLBuildAccountTemporary @intUserId
		
	SELECT '1'
	
END