CREATE VIEW [dbo].[vyuGLSegmentDetail]
AS
SELECT        
	S.intAccountSegmentId, 
	U.intSort, 
	S.strCode  COLLATE Latin1_General_CI_AS strCode, 
	C.strAccountCategory  COLLATE Latin1_General_CI_AS strAccountCategory, 
	S.intAccountCategoryId, 
	S.strDescription  COLLATE Latin1_General_CI_AS strDescription, 
	S.strChartDesc  COLLATE Latin1_General_CI_AS strChartDesc, 
	G.strAccountType  COLLATE Latin1_General_CI_AS strAccountType, 
	S.intAccountStructureId,
    G.intAccountGroupId,
    G.strAccountGroup  COLLATE Latin1_General_CI_AS strAccountGroup,
	U.intStructureType,
	U.strType  COLLATE Latin1_General_CI_AS strType,
	U.strStructureName  COLLATE Latin1_General_CI_AS strStructureName,
	ISNULL(Mapping.c,0)  ysnUsed,
	S.dtmObsoleteDate,
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


