  
CREATE FUNCTION fnGLOverridePostAccounts(  
    @PostGLEntries RevalTableType READONLY,
    @ysnOverrideLocation BIT =0,
    @ysnOverrideLOB BIT = 0,
    @ysnOverrideCompany BIT = 0

 )  
RETURNS   
 @tbl  TABLE (  
    [dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
    [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL, 
	[intCurrencyId]             INT              NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[strJournalLineDescription] NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
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
 dtmDate,  
 strBatchId,  
 intAccountId,  
 dblDebit,  
 dblCredit, 
 strDescription,      
 dtmTransactionDate,   
 strCode, 
 intCurrencyId,  
 dtmDateEntered,  
 strJournalLineDescription,  
 intJournalLineNo,  
 ysnIsUnposted,  
 intUserId,  
 intEntityId,  
 strTransactionId,  
 intTransactionId,  
 strTransactionType,  
 strTransactionForm,  
 strModuleName,  
 intConcurrencyId,  
 intAccountIdOverride,  
 intLocationSegmentOverrideId,  
 intLOBSegmentOverrideId,  
 intCompanySegmentOverrideId,  
 strNewAccountIdOverride,  
 intNewAccountIdOverride,  
 strOverrideAccountError
)  
SELECT   
 dtmDate,  
 strBatchId,  
 intAccountId,  
 dblDebit,  
 dblCredit, 
 strDescription,      
 dtmTransactionDate, 
 strCode, 
 intCurrencyId,  
 dtmDateEntered,  
 strJournalLineDescription,  
 intJournalLineNo,  
 ysnIsUnposted,  
 intUserId,  
 intEntityId,  
 strTransactionId,  
 intTransactionId,  
 strTransactionType,  
 strTransactionForm,  
 strModuleName,  
 intConcurrencyId,  
 intAccountIdOverride,  
 intLocationSegmentOverrideId,  
 intLOBSegmentOverrideId,  
 intCompanySegmentOverrideId,  
 strNewAccountIdOverride,  
 intNewAccountIdOverride,  
 strOverrideAccountError
from @PostGLEntries  

IF ( @ysnOverrideLocation | @ysnOverrideLOB | @ysnOverrideCompany  = 0 )
    RETURN

  
  
UPDATE A   
SET strNewAccountIdOverride = dbo.fnGLGetOverrideAccountByAccount(   
    A.intAccountIdOverride,   
    A.intAccountId,@ysnOverrideLocation,@ysnOverrideLOB,@ysnOverrideCompany)  
FROM @tbl A   
WHERE ISNULL(intAccountIdOverride,0) <> 0  
  
 UPDATE A   
 SET A.intAccountId = U.intAccountId,  
 strOverrideAccountError = CASE WHEN ISNULL(U.intAccountId,0) = 0 THEN 'Account Override Error. ' +  
 A.strNewAccountIdOverride + ' is not an existing GL Account Id.' ELSE NULL END  
 FROM @tbl A   
 OUTER APPLY(  
     SELECT ISNULL(intAccountId,0) intAccountId from tblGLAccount WHERE strAccountId = A.strNewAccountIdOverride  
 )U  
 WHERE   
 ISNULL(strNewAccountIdOverride,'') <> '' AND ISNULL(intAccountIdOverride,0) <> 0  
  
UPDATE A   
SET strNewAccountIdOverride =   
dbo.fnGLGetOverrideAccountBySegment(   
    A.intAccountId,  
     A.intLocationSegmentOverrideId ,   
     A.intLOBSegmentOverrideId,   
     A.intCompanySegmentOverrideId)  
FROM @tbl A   
WHERE (  
ISNULL(intLocationSegmentOverrideId,0)<> 0  
OR ISNULL(intLOBSegmentOverrideId,0) <> 0  
OR ISNULL(intCompanySegmentOverrideId,0) <> 0)  
AND ISNULL(intAccountIdOverride,0) = 0  
  
  
UPDATE A   
SET A.intAccountId = U.intAccountId,  
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
AND ISNULL(intAccountIdOverride,0) = 0  
AND  
ISNULL(strNewAccountIdOverride,'') <> ''  
  
  
  
  
RETURN  
  
END