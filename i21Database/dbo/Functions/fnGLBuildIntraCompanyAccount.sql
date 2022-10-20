CREATE FUNCTION [dbo].[fnGLBuildIntraCompanyAccount]
(
	@strPrimarySegment NVARCHAR(20),
	@strCompanySegment NVARCHAR(20)
)
RETURNS NVARCHAR(40)
AS
BEGIN
	DECLARE @tblAccountStructure TABLE (
		intRowId INT,
		intAccountStructureId INT,
		intStructureType INT,
		intLength INT,
		intStartPosition INT,
		intEndPosition INT
	)

	INSERT INTO @tblAccountStructure
	SELECT
		ROW_NUMBER() OVER (ORDER BY intSort)
		,intAccountStructureId
		,intStructureType
		,intLength
		,0
		,0
	FROM tblGLAccountStructure 
	WHERE strType <> 'Divider'
	ORDER BY intSort

	UPDATE A 
	SET
		intStartPosition = CASE WHEN intRowId = 1 THEN 0 ELSE intLengthSum - intLength + intRowId - 1 END
		,intEndPosition = CASE WHEN intRowId = 1 THEN intLength - 1 ELSE (intLengthSum - intLength + intRowId - 1) + intLength - 1 END
	FROM @tblAccountStructure A
	OUTER APPLY (
		SELECT SUM (intLength) intLengthSum FROM @tblAccountStructure WHERE A.intRowId >= intRowId
	) Total

	DECLARE 
		@strMaskedSegment NVARCHAR(100),
		@intPrimaryStart INT,
		@intPrimaryEnd INT,
		@intPrimaryLength INT,
		@intCompanyStart INT,
		@intCompanyEnd INT,
		@intCompanyLength INT

	SELECT TOP 1 @strMaskedSegment = strMaskedSegment FROM tblGLCompanyPreferenceOption
	SELECT TOP 1 @intPrimaryStart = intStartPosition + 1, @intPrimaryEnd =  intEndPosition + 1, @intPrimaryLength = intLength FROM @tblAccountStructure WHERE intStructureType = 1
	SELECT TOP 1 @intCompanyStart = intStartPosition + 1, @intCompanyEnd =  intEndPosition + 1, @intCompanyLength = intLength FROM @tblAccountStructure WHERE intStructureType = 6
	
	RETURN REPLACE(STUFF(@strMaskedSegment, @intPrimaryStart, @intPrimaryEnd, 
							REPLACE(SUBSTRING(@strPrimarySegment, @intPrimaryStart, @intPrimaryEnd), 'X', @strPrimarySegment)),
							REPLICATE('X', @intCompanyLength), @strCompanySegment)
END
