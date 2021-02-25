/*
    This will create stored procedure uspGLMergeAccountSegments for consolidate/ merging of segments
    EXEC uspGLCreateSPMergeSegmentAccount 'select  strCode, strDescription, strAccountCategory, strAccountGroup,strAccountType, strStructureName  from merle01.dbo.vyuGLSegmentDetail     union select  strCode, strDescription, strAccountCategory, strAccountGroup,strAccountType, strStructureName  from merle02.dbo.vyuGLSegmentDetail'
	EXEC uspGLMergeSegmentAccount
*/
CREATE PROCEDURE uspGLCreateSPMergeSegmentAccount
@UnionSQL NVARCHAR(MAX)
AS
BEGIN


EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLMergeSegmentAccount'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLMergeSegmentAccount];')
DECLARE @SqlMerge NVARCHAR(MAX) =
  REPLACE(' CREATE PROCEDURE uspGLMergeSegmentAccount  
AS  
BEGIN  
DECLARE @tbl Table(  
    [strCode]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,  
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
    [strCategory]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strAccountType]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strStructureName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strAccountGroup]		NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL
)
;WITH tblUnionSegments  
as(
	[UnionSQL] 
)
INSERT INTO @tbl( strCode, strAccountGroup, strAccountType,  [strStructureName],[strCategory], strDescription)  
SELECT strCode,   
MAX(isnull(strAccountGroup,'''')),   
strAccountType, strStructureName,  
MAX(isnull(strAccountCategory,'''')) strAccountCategory,   
MAX(isnull(strDescription,'''')) strDescription
FROM tblUnionSegments   
GROUP BY strCode, strAccountType,strStructureName  
MERGE into tblGLAccountSegment  
WITH (holdlock)  
AS SegmentTable  
USING (   
 select   
 strCode,  
 strDescription,  
 G.intAccountGroupId,  
 C.intAccountCategoryId,  
 S.intAccountStructureId,  
 A.strStructureName  
 from @tbl A   
 left join tblGLAccountGroup G on G.strAccountGroup = A.strAccountGroup  
 left join tblGLAccountCategory C on C.strAccountCategory = A.strCategory  
 join tblGLAccountStructure S on S.strStructureName = A.[strStructureName]   
)As MergedTable   
ON SegmentTable.strCode = MergedTable.strCode AND SegmentTable.intAccountStructureId = MergedTable.intAccountStructureId  
  
WHEN MATCHED THEN   
  UPDATE   
  SET  SegmentTable.intAccountGroupId = MergedTable.intAccountGroupId,  
    SegmentTable.intAccountCategoryId = MergedTable.intAccountCategoryId,  
    SegmentTable.strDescription = MergedTable.strDescription  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  strCode,  
  intAccountGroupId,  
  intAccountCategoryId,  
  intAccountStructureId  
 )  
 VALUES  
 (  
  MergedTable.strCode,  
  MergedTable.intAccountGroupId,  
  MergedTable.intAccountCategoryId,  
  MergedTable.intAccountStructureId    
 );  
END', '[UnionSQL]', @UnionSQL)
 
DECLARE  @DBExec NVARCHAR(MAX)
	  
SET @DBExec =  N'.sys.sp_executesql';

	EXEC @DBExec @SqlMerge;

END