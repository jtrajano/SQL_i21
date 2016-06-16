CREATE PROCEDURE [dbo].[uspAPOriginBalance]
	@UserId INT,
	@balance DECIMAL(18,6) OUTPUT,
	@logKey NVARCHAR(100) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()
SET @logKey = @key;

DECLARE @log TABLE
(
	[strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpOriginAccountBalance') IS NOT NULL DROP TABLE #tmpOriginAccountBalance
CREATE TABLE #tmpOriginAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpOriginAccountBalance
SELECT
	C.stri21Id AS strAccountId,
	SUM(
		(CASE WHEN A.apivc_trans_type IN ('C','A') AND A.apivc_orig_amt > 0
				THEN A.apivc_orig_amt * -1 
			WHEN A.apivc_trans_type IN ('I') AND A.apivc_orig_amt < 0
				THEN A.apivc_orig_amt * -1 
			ELSE A.apivc_orig_amt END))
FROM apivcmst A
INNER JOIN apcbkmst B ON A.apivc_cbk_no = B.apcbk_no
INNER JOIN tblGLCOACrossReference C ON B.apcbk_gl_ap = C.strExternalId COLLATE Latin1_General_CS_AS
WHERE A.apivc_status_ind = 'U'
GROUP BY C.stri21Id

INSERT INTO @log
SELECT
	'Account ' + A.strAccountId + ': ' + CAST(A.dblBalance AS NVARCHAR)
FROM #tmpOriginAccountBalance A

SELECT @balance = SUM(ISNULL(dblBalance,0)) FROM #tmpOriginAccountBalance

INSERT INTO tblAPImportVoucherLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate], 
	[strLogKey]
)
SELECT 
	[strDescription], 
    @UserId, 
    @logDate, 
	@key
FROM @log

RETURN