CREATE PROCEDURE [dbo].[uspAPRptPostPreviewPayVoucherSummary]
	@intPaymentId INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @query NVARCHAR(MAX);

IF @intPaymentId = 0
BEGIN
--Add this so that XtraReports have fields to get
SELECT
    0 AS intPaymentId,
    NULL AS strDescription,
    0 AS dblDebit,
    0 AS dblCredit
    RETURN
END

SET @query = '
                SELECT 
                SM.intPaymentId, 
                SM.strDescription, 
                SUM(SM.dblDebit) AS dblDebit, 
                SUM(SM.dblCredit) AS dblCredit 
                FROM 
                (		
				SELECT
                P.intPaymentId,
                CAST(A.strAccountId + A.strDescription AS VARCHAR(50)) AS strDescription,
                CASE WHEN A.intAccountId = B.intAccountId THEN CAST(PD.dblTotal AS DECIMAL(10, 2)) ELSE 0.00 END AS dblDebit, 
                CASE WHEN A.intAccountId = B.intAccountId THEN 0.00 ELSE CAST(PD.dblTotal AS DECIMAL(10, 2)) END AS dblCredit
                FROM tblAPPayment P
				LEFT JOIN tblCMBankTransaction BT ON BT.strTransactionId = P.strPaymentRecordNum
				JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
                JOIN tblAPBill B ON B.intBillId = ISNULL(PD.intBillId, PD.intOrigBillId)
                JOIN tblGLAccount A ON A.intAccountId IN (B.intAccountId, P.intAccountId)
				) SM
            '

 IF @intPaymentId != 0
 BEGIN
    SET @query = @query + ' WHERE SM.intPaymentId IN (' + CONVERT(VARCHAR(20), @intPaymentId) + ') GROUP BY SM.intPaymentId, SM.strDescription'
 END
 ELSE
 BEGIN
    SET @query = @query + ' WHERE SM.intPaymentId = -1 GROUP BY SM.intPaymentId, SM.strDescription'
 END

EXEC sp_executesql @query