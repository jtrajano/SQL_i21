/*
    This will create stored procedure uspGLMergeAccountSegments for consolidate/ merging of GL accounts
    EXEC uspGLCreateSPMergeGLAccount 'select strAccountId, strDescription, strAccountGroup, strAccountType, strUOMCode, strComments from merle01.dbo.vyuGLAccountDetail union   
	select strAccountId, strDescription, strAccountGroup,strAccountType,  strUOMCode, strComments from merle02.dbo.vyuGLAccountDetail'
	EXEC uspGLMergeGLAccount
*/
CREATE PROCEDURE uspGLCreateSPMergeGLAccount
@UnionSQL NVARCHAR(MAX)
AS
BEGIN


EXEC('IF EXISTS (SELECT 1 FROM sys.objects WHERE name = ''uspGLMergeGLAccount'' and type = ''P'') 
			DROP PROCEDURE [dbo].[uspGLMergeGLAccount];')
DECLARE @SqlMerge NVARCHAR(MAX) =
  REPLACE('CREATE PROCEDURE uspGLMergeGLAccount
AS  
BEGIN  
DECLARE @tbl Table(  
    strAccountId		NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,  
	strUOMCode			NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,  
    strDescription		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
	strComments			NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
	strAccountGroup		NVARCHAR (40)  COLLATE Latin1_General_CI_AS  NULL,  
    strAccountType		NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL
)  
  
;WITH tblUnionAccount
as(  
	[UnionSQL]
)  
  
INSERT INTO @tbl( strAccountId, strDescription, strAccountGroup, strAccountType, strComments, strUOMCode)  
select strAccountId, max(isnull(strDescription,'''')),  max(isnull(strAccountGroup,'''')), strAccountType, max(isnull(strComments,'''')),
max(isnull(strUOMCode,''''))  from tblUnionAccount   
group by  strAccountId, strAccountType  
  
  
--SET IDENTITY_INSERT  tblGLAccountSegment ON  
merge into tblGLAccount  
with (holdlock)  
as AccountTable  
using(  
  
 select   
 strAccountId,  
 strDescription,  
 G.intAccountGroupId,  
 strComments,
 U.intAccountUnitId
 from @tbl A   
 left join tblGLAccountGroup G on G.strAccountGroup = A.strAccountGroup  
 left join tblGLAccountUnit U on U.strUOMCode = A.strUOMCode
  
)As MergedTable   
on AccountTable.strAccountId = MergedTable.strAccountId 
  
WHEN MATCHED THEN   
  UPDATE   
  SET  
    AccountTable.intAccountGroupId = MergedTable.intAccountGroupId,  
    AccountTable.strDescription = MergedTable.strDescription,
	AccountTable.intAccountUnitId = MergedTable.intAccountUnitId

WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  strAccountId,  
  intAccountGroupId,  
  intAccountUnitId,  
  strDescription,
  strComments 
 )  
 VALUES  
 (  
  MergedTable.strAccountId,  
  MergedTable.intAccountGroupId,  
  MergedTable.intAccountUnitId,  
  MergedTable.strDescription,
  MergedTable. strComments 
    
 );  
  
END', '[UnionSQL]', @UnionSQL)
 
DECLARE  @DBExec NVARCHAR(MAX)
	  
SET @DBExec =  N'.sys.sp_executesql';

	EXEC @DBExec @SqlMerge;

END