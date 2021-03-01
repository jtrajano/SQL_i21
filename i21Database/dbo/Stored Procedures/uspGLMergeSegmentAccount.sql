/*
  This will create stored procedure uspGLMergeAccountSegments for consolidate/ merging of segments
  EXEC uspGLCreateSPMergeSegmentAccount 
	EXEC uspGLMergeSegmentAccount
*/
CREATE PROCEDURE uspGLMergeSegmentAccount
(
  @ysnMergeCOA BIT = 0,
  @ysnClear BIT = 0
)
AS
BEGIN


EXEC uspGLValidateSubsidiarySetting

IF @@ERROR > 0 RETURN


DECLARE @UnionSQL NVARCHAR(max) , @cnt INT
SELECT @cnt = COUNT(1) FROM tblGLSubsidiaryCompany

IF (@cnt > 1)
BEGIN
	SELECT @UnionSQL = COALESCE(@UnionSQL, '') + ' UNION ' + strSQLSegmentAccount from tblGLSubsidiaryCompany
	SELECT @UnionSQL = STUFF (@UnionSQL, 1, 7, '')
END
ELSE
	SELECT @UnionSQL = strSQLSegmentAccount from tblGLSubsidiaryCompany

BEGIN TRANSACTION
BEGIN TRY

IF @ysnClear =  1
BEGIN
  DELETE FROM tblGLAccountSegmentMapping
  DELETE A FROM tblGLAccountSegment A JOIN  vyuGLSegmentDetail B on A.intAccountSegmentId = B.intAccountSegmentId where intStructureType <> 6
END

-- EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLMergeSegmentAccount'' and type = ''P'') 
-- 			DROP PROCEDURE [dbo].[uspGLMergeSegmentAccount];')
DECLARE @SqlMerge NVARCHAR(MAX) =
  REPLACE('
DECLARE @tbl Table(  
    [strCode]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,  
    [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
    [strChartDesc]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
    [strCategory]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strAccountType]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strStructureName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
    [strAccountGroup]		NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL
)
;WITH tblUnionSegments  
as(
	[UnionSQL] 
)
INSERT INTO @tbl( strCode, strAccountGroup, strAccountType,  [strStructureName],[strCategory], strDescription,strChartDesc)  
SELECT strCode,   
MAX(isnull(strAccountGroup,'''')),   
strAccountType, strStructureName,  
MAX(isnull(strAccountCategory,'''')) strAccountCategory,   
MAX(isnull(strDescription,'''')) strDescription,
MAX(isnull(strChartDesc,'''')) strChartDesc
FROM tblUnionSegments   
GROUP BY strCode, strAccountType,strStructureName  
MERGE into tblGLAccountSegment  
WITH (holdlock)  
AS SegmentTable  
USING (   
 select   
 strCode,  
 G.intAccountGroupId,  
 C.intAccountCategoryId,  
 S.intAccountStructureId,  
 A.strStructureName,
 A.strDescription,
 A.strChartDesc
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
    SegmentTable.strDescription = MergedTable.strDescription,
    SegmentTable.strChartDesc = MergedTable.strChartDesc
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  strCode,  
  intAccountGroupId,  
  intAccountCategoryId,  
  intAccountStructureId,
  strDescription,
  strChartDesc
 )  
 VALUES  
 (  
  MergedTable.strCode,  
  MergedTable.intAccountGroupId,  
  MergedTable.intAccountCategoryId,  
  MergedTable.intAccountStructureId,
  MergedTable.strDescription,
  MergedTable.strChartDesc
 );  
', '[UnionSQL]', @UnionSQL)
 
DECLARE  @DBExec NVARCHAR(MAX)
	  
SET @DBExec =  N'.sys.sp_executesql';

EXEC @DBExec @SqlMerge;

IF @@ERROR = 0	
  IF @ysnMergeCOA = 1
    EXEC uspGLMergeGLAccount @ysnClear
		
IF @@ERROR = 0	
		COMMIT TRANSACTION
ELSE
		GOTO EndHere
	

END TRY

BEGIN CATCH

GOTO EndHere


END CATCH

RETURN

EndHere:
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION


END