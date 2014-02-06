CREATE PROCEDURE  [dbo].[usp_GLAccountClone]
@intUserID INT,
@intCodes NVARCHAR(200)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

	DECLARE @query VARCHAR(2000)			
	DECLARE @tblQuery TABLE
	(
		 intAccountSegmentID INT
	)
	
	SET @query = 'SELECT intAccountSegmentID FROM tblGLAccountSegment
						WHERE intAccountSegmentID IN (
								SELECT intAccountSegmentID FROM tblGLAccountSegmentMapping 
									WHERE intAccountID IN (
											SELECT intAccountID FROM tblGLAccountSegmentMapping 
												WHERE intAccountSegmentID IN (' + @intCodes + ')
												GROUP BY intAccountID 
												HAVING count(*) = (SELECT COUNT(*) FROM tblGLAccountStructure WHERE strType = ''Segment'')))	
						AND intAccountStructureID = (SELECT intAccountStructureID FROM tblGLAccountStructure WHERE strType = ''Primary'')'

	INSERT INTO @tblQuery EXEC (@query)	

	INSERT INTO tblGLTempAccountToBuild
	SELECT
		intAccountSegmentID
		,@intUserID
		,dtmCreated = getDate()
	FROM
	@tblQuery
	
	EXEC usp_GLBuildAccountTemporary @intUserID
		
	SELECT '1'
	
END