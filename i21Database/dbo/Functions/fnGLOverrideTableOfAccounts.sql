  
CREATE FUNCTION fnGLOverrideTableOfAccounts(  
    @OverrideTableType [OverrideTableType] READONLY,
    @ysnOverrideLocation BIT =0,
    @ysnOverrideLOB BIT = 0,
    @ysnOverrideCompany BIT = 0

 )  
RETURNS   
 @tbl  TABLE (
	[intAccountId]              INT              NULL,
	intAccountIdOverride INT NULL,
    intLocationSegmentOverrideId INT NULL,
    intLOBSegmentOverrideId INT NULL,
    intCompanySegmentOverrideId INT NULL,
    strNewAccountIdOverride NVARCHAR(40) Collate Latin1_General_CI_AS NULL,
    intNewAccountIdOverride INT NULL,
    strOverrideAccountError NVARCHAR(800) Collate Latin1_General_CI_AS NULL
)  
AS  
BEGIN  
  
  
INSERT INTO @tbl (
 intAccountId,
 intAccountIdOverride,  
 intLocationSegmentOverrideId,  
 intLOBSegmentOverrideId,  
 intCompanySegmentOverrideId,  
 strNewAccountIdOverride,  
 intNewAccountIdOverride,  
 strOverrideAccountError
)  
SELECT   
 intAccountId,  
 intAccountIdOverride,  
 intLocationSegmentOverrideId,  
 intLOBSegmentOverrideId,  
 intCompanySegmentOverrideId,  
 strNewAccountIdOverride,  
 intNewAccountIdOverride = intAccountId, -- default to base account 
 strOverrideAccountError
from @OverrideTableType 


IF ( @ysnOverrideLocation | @ysnOverrideLOB | @ysnOverrideCompany  = 0 )
    RETURN

IF ( @ysnOverrideLocation | @ysnOverrideLOB | @ysnOverrideCompany  = 1 )
BEGIN
    UPDATE A   
    SET strNewAccountIdOverride = dbo.fnGLGetOverrideAccountByAccount(   
        A.intAccountIdOverride,   
        A.intAccountId,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany)  
    FROM @tbl A   
    WHERE ISNULL(intAccountIdOverride,0) <> 0  

END
  
 UPDATE A   
 SET A.intNewAccountIdOverride = U.intAccountId,  
 strOverrideAccountError = CASE WHEN ISNULL(U.intAccountId,0) = 0 THEN 'Account Override Error. ' +  
 A.strNewAccountIdOverride + ' is not an existing GL Account Id.' ELSE NULL END  
 FROM @tbl A   
 OUTER APPLY(  
     SELECT ISNULL(intAccountId,0) intAccountId from tblGLAccount WHERE strAccountId = A.strNewAccountIdOverride  
 )U  
 WHERE   
 ISNULL(strNewAccountIdOverride,'') <> '' AND ISNULL(intAccountIdOverride,0) <> 0  

IF EXISTS(SELECT 1 FROM  @tbl WHERE strOverrideAccountError IS NOT NULL)
    RETURN

UPDATE A   
SET strNewAccountIdOverride =   
dbo.fnGLGetOverrideAccountBySegment(   
    A.intNewAccountIdOverride,  
     A.intLocationSegmentOverrideId ,   
     A.intLOBSegmentOverrideId,   
     A.intCompanySegmentOverrideId)  
FROM @tbl A   
WHERE (  
ISNULL(intLocationSegmentOverrideId,0)<> 0  
OR ISNULL(intLOBSegmentOverrideId,0) <> 0  
OR ISNULL(intCompanySegmentOverrideId,0) <> 0)  
--AND ISNULL(intAccountIdOverride,0) = 0  
  
  
UPDATE A   
SET A.intNewAccountIdOverride = U.intAccountId,  
strOverrideAccountError = CASE WHEN ISNULL(U.intAccountId,0) =0 THEN 'Segment Override Error. ' +  
A.strNewAccountIdOverride + ' is not an existing GL Account Id.' ELSE NULL END  
FROM @tbl A   
OUTER APPLY(  
    SELECT ISNULL(intAccountId,0) intAccountId from tblGLAccount WHERE strAccountId = A.strNewAccountIdOverride  
)U  
WHERE   
 (  
 ISNULL(intLocationSegmentOverrideId,0)<> 0  
OR ISNULL(intLOBSegmentOverrideId,0) <> 0  
OR ISNULL(intCompanySegmentOverrideId,0) <> 0)  
--AND ISNULL(intAccountIdOverride,0) = 0  
AND  
ISNULL(strNewAccountIdOverride,'') <> ''  
  
  
  
  
RETURN  
  
END