  
CREATE FUNCTION fnGLOverridePostAccounts(  
    @PostGLEntries RecapTableType READONLY  
 )  
RETURNS   
 @tbl  TABLE(  
    [dtmDate]                   DATETIME         NOT NULL,  
 [strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,  
 [intAccountId]              INT              NULL,  
 [dblDebit]                  NUMERIC (18, 6)  NULL,  
 [dblCredit]                 NUMERIC (18, 6)  NULL,  
 [dblDebitUnit]              NUMERIC (18, 6)  NULL,  
 [dblCreditUnit]             NUMERIC (18, 6)  NULL,  
 [strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,  
 [strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,      
 [strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,  
 [intCurrencyId]             INT              NULL,  
 [dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,  
 [dtmDateEntered]            DATETIME         NOT NULL,  
 [dtmTransactionDate]        DATETIME         NULL,  
 [strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,  
 [intJournalLineNo]   INT              NULL,  
 [ysnIsUnposted]             BIT              NOT NULL,      
 [intUserId]                 INT              NULL,  
 [intEntityId]    INT              NULL,  
 [strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,  
 [intTransactionId]          INT              NULL,  
 [strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,  
 [strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,  
 [strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,  
 [intConcurrencyId]          INT              DEFAULT 1 NOT NULL,  
 [dblDebitForeign]   NUMERIC (18, 6) NULL,  
 [dblDebitReport]   NUMERIC (18, 6) NULL,  
 [dblCreditForeign]   NUMERIC (18, 6) NULL,  
 [dblCreditReport]   NUMERIC (18, 6) NULL,  
 [dblReportingRate]   NUMERIC (18, 6) NULL,  
 [dblForeignRate]   NUMERIC (18, 6) NULL,  
 [intCurrencyExchangeRateTypeId] INT NULL,  
 [strRateType]       NVARCHAR(50) COLLATE Latin1_General_CI_AS,  
 [strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,  
 [strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,  
 -- new columns GL-3550  
 [strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,  
 [intSourceLocationId]  INT NULL,  
 [intSourceUOMId]   INT NULL,  
 [dblSourceUnitDebit]  NUMERIC (18, 6)  NULL,  
 [dblSourceUnitCredit]  NUMERIC (18, 6)  NULL,  
 [intCommodityId]   INT NULL,  
 intSourceEntityId INT NULL,  
 ysnRebuild BIT NULL,  
 -- new columns GL-3550  
  
 --strModuleCode nvarchar(5) Collate Latin1_General_CI_AS,  
    intAccountIdOverride INT,  
    intLocationSegmentOverrideId INT,  
    intLOBSegmentOverrideId INT,  
    intCompanySegmentOverrideId INT,  
    strNewAccountIdOverride nvarchar(40) Collate Latin1_General_CI_AS,  
    intNewAccountIdOverride INT,  
    strOverrideAccountError nvarchar(800) Collate Latin1_General_CI_AS  
)  
AS  
BEGIN  
  
  
INSERT INTO @tbl (  
    dtmDate,  
 strBatchId,  
 intAccountId,  
 dblDebit,  
 dblCredit,  
 dblDebitUnit,  
 dblCreditUnit,  
 strDescription,  
 strCode,  
 strReference,  
 intCurrencyId,  
 dblExchangeRate,  
 dtmDateEntered,  
 dtmTransactionDate,  
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
 dblDebitForeign,  
 dblDebitReport,  
 dblCreditForeign,  
 dblCreditReport,  
 dblReportingRate,  
 dblForeignRate,  
 intCurrencyExchangeRateTypeId,  
 strRateType,  
 strDocument,  
 strComments,  
 strSourceDocumentId,  
 intSourceLocationId,  
 intSourceUOMId,  
 dblSourceUnitDebit,  
 dblSourceUnitCredit,  
 intCommodityId,  
 intSourceEntityId,  
 ysnRebuild,  
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
 dblDebitUnit,  
 dblCreditUnit,  
 strDescription,  
 strCode,  
 strReference,  
 intCurrencyId,  
 dblExchangeRate,  
 dtmDateEntered,  
 dtmTransactionDate,  
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
 dblDebitForeign,  
 dblDebitReport,  
 dblCreditForeign,  
 dblCreditReport,  
 dblReportingRate,  
 dblForeignRate,  
 intCurrencyExchangeRateTypeId,  
 strRateType,  
 strDocument,  
 strComments,  
 strSourceDocumentId,  
 intSourceLocationId,  
 intSourceUOMId,  
 dblSourceUnitDebit,  
 dblSourceUnitCredit,  
 intCommodityId,  
 intSourceEntityId,  
 ysnRebuild,  
 intAccountIdOverride,  
 intLocationSegmentOverrideId,  
 intLOBSegmentOverrideId,  
 intCompanySegmentOverrideId,  
 strNewAccountIdOverride,  
 intNewAccountIdOverride,  
 strOverrideAccountError  
from @PostGLEntries  
  
  
UPDATE A   
SET strNewAccountIdOverride = dbo.fnGLGetOverrideAccountByAccount(   
    A.intAccountIdOverride,   
    A.intAccountId,1,1,1)  
FROM @tbl A   
WHERE ISNULL(intAccountIdOverride,0) <> 0  
  
 UPDATE A   
 SET A.intAccountId = U.intAccountId,  
 strOverrideAccountError = CASE WHEN U.intAccountId = 0 THEN 'Account Override Error. ' +  
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