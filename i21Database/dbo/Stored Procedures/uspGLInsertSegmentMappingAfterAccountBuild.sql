CREATE PROCEDURE uspGLInsertSegmentMappingAfterAccountBuild
@intUserId INT
AS


CREATE TABLE #Structure
(
    strStructureName		NVARCHAR(30)
    ,strMask				NVARCHAR(100)
    ,intLength				int
    ,strType				NVARCHAR(17)
    ,intAccountStructureId	INT
    ,intSort				INT
)

DECLARE @intLength int, @intAccountStructureId INT
, @strCode nvarchar(20)
, @strAccountId NVARCHAR(50),@strAccountId1 NVARCHAR(50)
, @intAccountSegmentId INT,@intAccountId int, @strMask NVARCHAR(1)
, @strStructureName NVARCHAR(30),@updateTempCOA NVARCHAR(500)
DECLARE @c INT
SELECT top 1 @strMask = strMask FROM tblGLAccountStructure WHERE strType = 'Divider'

WHILE EXISTS (SELECT 1 FROM tblGLTempAccount WHERE intUserId = @intUserId)
BEGIN
	
	SET @c =1
	SELECT top 1  @strAccountId1 = strAccountId ,
	@strAccountId=REPLACE(strAccountId,@strMask,'') FROM tblGLTempAccount WHERE intUserId = @intUserId

	SELECT TOP 1 @intAccountId =intAccountId FROM tblGLAccount WHERE strAccountId=@strAccountId1

	-- IF NOT EXISTS(SELECT 1 FROM tblGLTempCOASegment where strAccountId = @strAccountId1)
	-- 	INSERT INTO tblGLTempCOASegment (intAccountId, strAccountId) SELECT @intAccountId, @strAccountId1

	INSERT INTO #Structure (strStructureName, intLength, strMask, strType, intAccountStructureId, intSort)
	SELECT strStructureName, intLength, strMask, strType, intAccountStructureId, intSort
	FROM tblGLAccountStructure WHERE strType <> 'Divider'
	ORDER BY intSort DESC

	WHILE EXISTS (SELECT 1 FROM #Structure)
	BEGIN
		SELECT TOP 1 @strStructureName = strStructureName,@intLength = intLength , @intAccountStructureId = intAccountStructureId
		FROM #Structure ORDER BY intSort
		
		SELECT @strCode = SUBSTRING(@strAccountId,@c, @intLength) 

		SELECT @intAccountSegmentId = intAccountSegmentId
		FROM tblGLAccountSegment WHERE strCode = @strCode AND @intAccountStructureId = intAccountStructureId

		INSERT INTO tblGLAccountSegmentMapping(intAccountId, intAccountSegmentId, intConcurrencyId)
		SELECT @intAccountId,@intAccountSegmentId,1
		SET @c = @c + @intLength

		-- IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        --   WHERE  TABLE_NAME = 'tblGLTempCOASegment'
        --          AND COLUMN_NAME = @strStructureName)
		-- BEGIN
		-- 	SET @updateTempCOA =
		-- 	'Update tblGLTempCOASegment SET [' + @strStructureName + '] = ''' + @strCode  + ''' where ' +
		-- 	CAST(@intAccountId AS NVARCHAR(10)) + '=intAccountId'
		-- 	EXEC sp_executesql @updateTempCOA
		-- END
		DELETE FROM #Structure WHERE intAccountStructureId = @intAccountStructureId
	END
	DELETE FROM tblGLTempAccount WHERE @strAccountId1 = strAccountId AND intUserId = @intUserId
END

