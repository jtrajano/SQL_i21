CREATE VIEW [dbo].[vyuAPDeferredPayment]
AS

SELECT 
	intBillId,
	intEntityVendorId,
	strCommodityCode,
	strBillId,
	strName,
	dtmBillDate,
	dtmDate,
	strTerm,
	dtmDueDate,
	strTicketNumber,
	dblDeferred,
	dtmLastDeferred,
	dblAmountDue,
	intDays,
	dblInterest,
	ysnSelected,
	str1099Form,
	str1099Type,
	intDeferredPayableInterestId AS intDeferredAccountId
FROM (
	SELECT
		A.intBillId,
		A.intEntityVendorId,
		ISNULL(commodity.strCommodityCode, 'None') AS strCommodityCode,
		A.strBillId,
		B.strName,
		A.dtmBillDate,
		A.dtmDate,
		term.strTerm,
		A.dtmDueDate,
		ticket.strTicketNumber,
		0.00 AS dblDeferred,
		A.dtmInterestAccruedThru AS dtmLastDeferred, --date of last interest date calculation, if there's no voucher interest yet, this should be blank
		A.dblAmountDue,
		ISNULL(DATEDIFF(DAY, ISNULL(A.dtmInterestAccruedThru, ISNULL(A.dtmDeferredInterestDate, A.dtmBillDate)),deferredInterest.dtmCalculationDate),0) AS intDays,
		dblInterest = CAST((A.dblTotal * ((term.dblAPR / 100) / 365)) * 
				ISNULL(DATEDIFF(DAY, ISNULL(A.dtmInterestAccruedThru, ISNULL(A.dtmDeferredInterestDate, A.dtmBillDate)), deferredInterest.dtmCalculationDate),0) AS DECIMAL(18,2)),		
		-- dblInterest = CAST(A.dblTotal * ((deferredTerm.dblAPR / 100) / 12) * 
		-- 		(CASE WHEN DATEDIFF(MONTH, deferredInterest.dtmCalculationDate, GETDATE()) = 0 
		-- 			THEN 1 ELSE DATEDIFF(MONTH, deferredInterest.dtmCalculationDate, GETDATE()) END) 
		-- 	AS DECIMAL(18,2)),
		CAST(CASE WHEN staging.intBillId IS NOT NULL THEN 1 ELSE 0 END AS BIT) ysnSelected,
		B.str1099Form,
		B.str1099Type,
		deferredInterest.dblMinimum,
		loc.intDeferredPayableInterestId
	FROM tblAPBill A
	INNER JOIN tblEMEntity B ON A.intEntityVendorId = B.intEntityId
	INNER JOIN tblAPVendor C ON B.intEntityId = C.intEntityId
	INNER JOIN tblSMTerm term ON A.intTermsId = term.intTermID
	CROSS APPLY [dbo].[fnAPGetVoucherCommodity](A.intBillId) commodity
	CROSS APPLY tblAPDeferredPaymentInterest deferredInterest
	INNER JOIN tblSMTerm deferredTerm ON deferredInterest.strTerm = deferredTerm.strTerm
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
	LEFT JOIN tblSMCompanyLocation loc ON A.intShipToId = loc.intCompanyLocationId
WHERE A.intTransactionType = 1 AND A.ysnPosted = 1 AND A.ysnPaid = 0 AND term.ysnDeferredPay = 1	
) deferredInterest
WHERE dblInterest >= dblMinimum
