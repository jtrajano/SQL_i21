CREATE VIEW [dbo].[vyuGLSegmentDetail]
AS
SELECT        
	S.intAccountSegmentId, 
	U.intSort, S.strCode, 
	C.strAccountCategory, 
	S.intAccountCategoryId, 
	S.strDescription, 
	G.strAccountType, 
	S.intAccountStructureId,
	U.intStructureType,
	U.strStructureName 
FROM            
	dbo.tblGLAccountSegment AS S LEFT OUTER JOIN
	dbo.tblGLAccountGroup AS G ON S.intAccountGroupId = G.intAccountGroupId LEFT OUTER JOIN
	dbo.tblGLAccountCategory AS C ON S.intAccountCategoryId = C.intAccountCategoryId LEFT OUTER JOIN
	dbo.tblGLAccountStructure AS U ON S.intAccountStructureId = U.intAccountStructureId
GO
