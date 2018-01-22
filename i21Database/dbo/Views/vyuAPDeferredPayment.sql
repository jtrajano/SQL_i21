CREATE VIEW [dbo].[vyuAPDeferredPayment]
AS

SELECT
	A.intBillId,
	ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
	A.strBillId,
	B.strName,
	A.dtmBillDate,
	A.dtmDate,
	term.strTerm,
	A.dtmDueDate,
	ticket.strTicketNumber,
	0.00 AS dblDeferred,
	GETDATE() AS dtmLastDeferred,
	A.dblAmountDue,
	0 AS intDays,
	0.00 AS dblInterest,
	CAST(CASE WHEN staging.intBillId IS NOT NULL THEN 1 ELSE 0 END AS BIT) ysnSelected
FROM tblAPBill A
INNER JOIN tblEMEntity B ON A.intEntityVendorId = B.intEntityId
CROSS APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
LEFT JOIN tblSMTerm term ON A.intTermsId = term.intTermID
OUTER APPLY (
	SELECT 
		SUBSTRING(
			(SELECT ',' + CAST(tkt2.strTicketNumber AS NVARCHAR)
			FROM tblSCTicket tkt2
			WHERE tkt2.intTicketId = tkt.intTicketId
			FOR XML PATH ('')) , 2, 200000) AS strTicketNumber
	FROM tblAPBillDetail voucherDetail
	INNER JOIN tblSCTicket tkt ON tkt.intTicketId = voucherDetail.intScaleTicketId
	WHERE voucherDetail.intBillId = A.intBillId
) ticket
OUTER APPLY (
	SELECT TOP 1
		dp.dtmDate
	FROM tblAPBill dp
	WHERE dp.intTransactionType = 14
	ORDER BY dp.dtmDate DESC
) lastDeferredPayment
LEFT JOIN tblAPDeferredPaymentStaging staging ON staging.intBillId = A.intBillId
WHERE A.intTransactionType = 1 AND A.ysnPosted = 1 AND A.ysnPaid = 0
