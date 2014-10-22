CREATE FUNCTION [dbo].[fnGetGLAccountIdFromProfitCenter]
(
	@intGLAccountId AS INT 
	,@intAccountSegmentId AS INT
)
RETURNS INT
AS 
BEGIN
	DECLARE @strAccountId AS NVARCHAR(40)
	DECLARE @strDivider AS NVARCHAR(100)
	DECLARE @Length AS INT

	DECLARE @intFoundGLAccountId INT
	
	-- Retrieve the account structure to modify. 
	DECLARE @intAccountStructureToModify AS INT	
	SELECT	@intAccountStructureToModify = Structure.intAccountStructureId
	FROM	tblGLAccountSegment Segment INNER JOIN tblGLAccountStructure Structure
				ON Segment.intAccountStructureId = Structure.intAccountStructureId
	WHERE	Segment.intAccountSegmentId = @intAccountSegmentId 

	-- Retrieve the divider to use. 
	SELECT	@strDivider = strMask
	FROM	tblGLAccountStructure
	WHERE	strType = 'Divider'
	
	SET @Length = ISNULL(LEN(@strDivider), 0)
	
	-- Re-create the strAccountId (Original Account + Account Structure to modify)
	SELECT	@strAccountId = STUFF((	
					SELECT	@strDivider + RecreateStructure.strCode
					FROM	tblGLAccountSegment RecreateStructure INNER JOIN (
								SELECT	intAccountSegmentId = CASE WHEN @intAccountStructureToModify = Structure.intAccountStructureId THEN @intAccountSegmentId ELSE SegmentMap.intAccountSegmentId END 
										,Structure.intSort 
								FROM	tblGLAccountStructure Structure INNER JOIN tblGLAccountSegment Segment
											ON Structure.intAccountStructureId = Segment.intAccountStructureId
										INNER JOIN tblGLAccountSegmentMapping SegmentMap
											ON Segment.intAccountSegmentId = SegmentMap.intAccountSegmentId
								WHERE	Structure.strType <> 'Divider'
										AND SegmentMap.intAccountId = @intGLAccountId
							) TemplateStructure 
								ON RecreateStructure.intAccountSegmentId = TemplateStructure.intAccountSegmentId
					ORDER BY TemplateStructure.intSort
					FOR XML PATH('')
				), 1, @Length, '' 
			)

	-- Try to retrieve the intAccountId based on the re-created strAccountId
	SELECT	@intFoundGLAccountId = intAccountId
	FROM	tblGLAccount
	WHERE	strAccountId = 	@strAccountId 

	RETURN @intFoundGLAccountId
END