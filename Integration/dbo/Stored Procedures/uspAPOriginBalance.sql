CREATE PROCEDURE [dbo].[uspAPOriginBalance]
	@balance DECIMAL(18,6) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--GET THE BALANCE
IF OBJECT_ID(N'tempdb..#tmpAPAccountBalance') IS NOT NULL DROP TABLE #tmpAPAccountBalance
CREATE TABLE #tmpAPAccountBalance(strAccountId NVARCHAR(40), dblBalance DECIMAL(18,6))

INSERT INTO #tmpAPAccountBalance
SELECT
	C.stri21Id AS strAccountId,
	SUM(
		(CASE WHEN A.apivc_trans_type IN ('C','A') OR A.apivc_orig_amt < 0 
			THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END)
		- ISNULL(A.apivc_disc_taken,0)) AS dblBalance
FROM apivcmst A
INNER JOIN apcbkmst B ON A.apivc_cbk_no = B.apcbk_no
INNER JOIN tblGLCOACrossReference C ON B.apcbk_gl_ap = C.strExternalId COLLATE Latin1_General_CS_AS
WHERE A.apivc_status_ind = 'U'
GROUP BY C.stri21Id

SELECT @balance = SUM(ISNULL(dblBalance,0)) FROM #tmpAPAccountBalance

SELECT * FROM #tmpAPAccountBalance

RETURN