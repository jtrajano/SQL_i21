/*
    This will create stored procedure uspGLMergeAccountSegments for consolidate/ merging of GL accounts
	EXEC uspGLCreateSPMergeGLAccount
	EXEC uspGLMergeGLAccount
*/
CREATE PROCEDURE uspGLMergeGLAccount
    @ysnClear BIT  = 0
AS
BEGIN

IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLSubsidiaryCompany)
BEGIN
    RAISERROR( 'Subsidiary company is empty.',  16,1 )
    RETURN
END

DECLARE @UnionSQL NVARCHAR(max) , @cnt INT
SELECT @cnt = COUNT(1) FROM tblGLSubsidiaryCompany

IF (@cnt > 1)
BEGIN
	SELECT @UnionSQL = COALESCE(@UnionSQL, '') + ' UNION ' + strSQLGLAccount from tblGLSubsidiaryCompany
	SELECT @UnionSQL = STUFF (@UnionSQL, 1, 7, '')
END
ELSE
	SELECT @UnionSQL = strSQLGLAccount from tblGLSubsidiaryCompany



IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountSegment)
BEGIN
    RAISERROR( 'Account Segments are missing.',  16,1 )
    RETURN
END

IF @ysnClear = 1
BEGIN
    DELETE FROM tblGLAccount
    DELETE FROM tblGLDetail
END


DECLARE @SqlMerge NVARCHAR(MAX) =
  REPLACE('
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
  
 EXEC uspGLRebuildSegmentMapping
 
 EXEC uspGLCreateSubsidiaryAccountMapping
 
 ', '[UnionSQL]', @UnionSQL)
 
DECLARE  @DBExec NVARCHAR(40)
	  
SET @DBExec =  N'.sys.sp_executesql';

EXEC @DBExec @SqlMerge;

END