GO

DECLARE @strSQL NVARCHAR(MAX) = 
'ALTER VIEW dbo.vyuGLUnpostedTransaction
AS
SELECT  strTransactionId, dtmDate ,''Inventory'' strModule from [vyuICGetUnpostedTransactions]  
UNION SELECT  strTransactionId, dtmDate , ''Payroll''  from vyuPRUnpostedTransactions 
UNION SELECT  strBillId strTransactionId, dtmDate, ''Purchasing''  FROM [vyuAPBatchPostTransaction] 
UNION SELECT  strTransactionId, dtmDate, ''Sales'' FROM [vyuARBatchPosting]
UNION SELECT  strTransactionId, dtmTransactionDate dtmDate, ''Card Fueling'' FROM vyuCFBatchPostTransactions 
UNION SELECT  strTransactionId, dtmDate, ''Cash Management'' FROM vyuCMUnpostedTransaction 
UNION SELECT  strJournalId strTransactionId, dtmDate, ''General Journal''  FROM tblGLJournal 
    WHERE ysnPosted = 0 and (strTransactionType = ''General Journal'' OR strTransactionType = ''Audit Adjustment'')'

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glijemst]') AND type IN (N'U'))


SET  @strSQL =  @strSQL + 'UNION    SELECT glije_src_no  collate SQL_Latin1_General_CP1_CS_AS as strTransactionId, 
     CAST(SUBSTRING(CAST(glije_date AS NVARCHAR(10)),1,4) + ''-'' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),5,2) + ''-'' + SUBSTRING(CAST(glije_date AS NVARCHAR(10)),7,2) AS DATE) as dtmDate ,
     ''Origin journal'' FROM glijemst group by glije_src_no,glije_src_sys,glije_date '

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aptrxmst]') AND type IN (N'U'))
    SET  @strSQL =  @strSQL + 'UNION SELECT aptrx_ivc_no collate SQL_Latin1_General_CP1_CS_AS as strTransactionId, CAST(SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),1,4) + ''-'' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),5,2) + ''-'' + SUBSTRING(CAST(aptrx_gl_rev_dt AS NVARCHAR(10)),7,2) AS DATE) as dtmDate ,
    ''Origin AP'' FROM aptrxmst GROUP BY aptrx_ivc_no, aptrx_gl_rev_dt'

EXEC(@strSQL)

GO