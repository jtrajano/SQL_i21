CREATE VIEW [dbo].[vyuGLSegmentDetail]
AS
SELECT        
	S.intAccountSegmentId, 
	U.intSort, S.strCode, 
	C.strAccountCategory, 
	S.intAccountCategoryId, 
	S.strDescription, 
	S.strChartDesc, 
	G.strAccountType, 
	S.intAccountStructureId,
    G.intAccountGroupId,
    G.strAccountGroup,
	U.intStructureType,
	U.strType,
	U.strStructureName,
	ISNULL(Mapping.c,0)  ysnUsed,
	S.intConcurrencyId
FROM            
	dbo.tblGLAccountSegment AS S LEFT OUTER JOIN
	dbo.tblGLAccountGroup AS G ON S.intAccountGroupId = G.intAccountGroupId LEFT OUTER JOIN
	dbo.tblGLAccountCategory AS C ON S.intAccountCategoryId = C.intAccountCategoryId LEFT OUTER JOIN
	dbo.tblGLAccountStructure AS U ON S.intAccountStructureId = U.intAccountStructureId 
	outer APPLY (
		SELECT  TOP 1 CONVERT(BIT,1)    c FROM tblGLAccountSegmentMapping M WHERE M.intAccountSegmentId = S.intAccountSegmentId
	)Mapping
GO


