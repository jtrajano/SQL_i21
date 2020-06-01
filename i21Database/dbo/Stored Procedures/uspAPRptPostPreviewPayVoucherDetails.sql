CREATE PROCEDURE [dbo].[uspAPRptPostPreviewPayVoucherDetails]
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
    NULL AS strCheckNo,
    NULL AS dtmCheckPrinted,
    0 AS dblCheckAmount,
    NULL AS strVendorOrderNumber,
    NULL AS dtmBillDate,
    NULL AS strName,
    0 AS dblTotalVouchered,
    0 AS dblTotalPaid,
    NULL AS strPaymentMethod,
    NULL AS strDescription,
    0 AS dblDebit,
    0 AS dblCredit
    RETURN
END

SET @query = '
                SELECT
                P.intPaymentId,
				''None'' AS strCheckNo,
				''None'' AS dtmCheckPrinted,
				0.00 AS dblCheckAmount,
                B.strVendorOrderNumber,
                CONVERT(VARCHAR, B.dtmBillDate, 1) AS dtmBillDate,
                E.strName, 
                CAST(B.dblTotal AS DECIMAL(10, 2)) AS dblTotalVouchered, 
                CAST(PD.dblTotal AS DECIMAL(10, 2)) AS dblTotalPaid, 
                M.strPaymentMethod,
                CAST(A.strAccountId + A.strDescription AS VARCHAR(50)) AS strDescription,
                CASE WHEN A.intAccountId = B.intAccountId THEN CAST(PD.dblTotal AS DECIMAL(10, 2)) ELSE 0.00 END AS dblDebit, 
                CASE WHEN A.intAccountId = B.intAccountId THEN 0.00 ELSE CAST(PD.dblTotal AS DECIMAL(10, 2)) END AS dblCredit
                FROM tblAPPayment P
				--LEFT JOIN tblCMBankTransaction BT ON BT.strTransactionId = P.strPaymentRecordNum
				JOIN tblAPPaymentDetail PD ON PD.intPaymentId = P.intPaymentId
                JOIN tblAPBill B ON B.intBillId = ISNULL(PD.intBillId, PD.intOrigBillId)
				JOIN (tblAPVendor V JOIN tblEMEntity E ON V.intEntityId = E.intEntityId) ON V.intEntityId = B.intEntityVendorId
                JOIN tblSMPaymentMethod M ON M.intPaymentMethodID = P.intPaymentMethodId
                JOIN tblGLAccount A ON A.intAccountId IN (B.intAccountId, P.intAccountId)
            '

 IF @intPaymentId != 0
 BEGIN
    SET @query = @query + ' WHERE P.intPaymentId IN (' + CONVERT(VARCHAR(20), @intPaymentId) + ')'
 END
 ELSE
 BEGIN
    SET @query = @query + ' WHERE P.intPaymentId = -1'
 END

EXEC sp_executesql @query