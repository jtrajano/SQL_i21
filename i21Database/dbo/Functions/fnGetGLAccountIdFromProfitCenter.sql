CREATE FUNCTION [dbo].[fnGetGLAccountIdFromProfitCenter]
(
	@intGLAccountId AS INT 
	,@intAccountSegmentId AS INT
)
RETURNS INT
AS 
BEGIN
	DECLARE @intFoundGLAccountId AS INT 
	
	-- Compare the re-created account id to the tblGLAccount table
	SELECT @intFoundGLAccountId = tblGLAccount.intAccountId	
	FROM	(
				-- Re-create the strAccountId (Original Account + Account Structure to modify)
				SELECT strAccountId = STUFF(
									(	
										SELECT	Divider.strMask + RecreateStructure.strCode
										FROM	tblGLAccountSegment RecreateStructure INNER JOIN (
													SELECT	intAccountSegmentId = 
																CASE	WHEN EXISTS (
																			-- Get the structure id for @intAccountSegmentId. if it matches, use it as the override. 
																			SELECT	B.intAccountStructureId
																			FROM	tblGLAccountSegment A INNER JOIN tblGLAccountStructure B
																						ON A.intAccountStructureId = B.intAccountStructureId
																			WHERE	A.intAccountSegmentId = @intAccountSegmentId 
																					AND B.intAccountStructureId = Structure.intAccountStructureId
																		) 
																		THEN 
																			@intAccountSegmentId 
																		ELSE 
																			SegmentMap.intAccountSegmentId 
																END 
															,Structure.intSort 
													FROM	tblGLAccountStructure Structure INNER JOIN tblGLAccountSegment Segment
																ON Structure.intAccountStructureId = Segment.intAccountStructureId
															INNER JOIN tblGLAccountSegmentMapping SegmentMap
																ON Segment.intAccountSegmentId = SegmentMap.intAccountSegmentId
													WHERE	Structure.strType <> 'Divider'
															AND SegmentMap.intAccountId = @intGLAccountId
												) AS TemplateStructure 
													ON RecreateStructure.intAccountSegmentId = TemplateStructure.intAccountSegmentId
												,(
													SELECT TOP 1 
															strMask = ISNULL(strMask, '')
													FROM	tblGLAccountStructure
													WHERE	strType = 'Divider'
												) AS Divider							
										ORDER BY TemplateStructure.intSort
										FOR XML PATH('')
									)
									, 1
									, 1 -- We expect the divider used in COA setup is always one character. 
									, '' 
							)	
			) AS RecreatedAccount INNER JOIN tblGLAccount 
				ON RecreatedAccount.strAccountId = tblGLAccount.strAccountId COLLATE Latin1_General_CI_AS


	RETURN @intFoundGLAccountId
END