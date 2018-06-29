CREATE VIEW [dbo].[vyuPATCustomerVolumeLog]
	AS
SELECT	id = NEWID(),
		A.intBillId,
		A.intInvoiceId,
		A.strTransactionNo,
		A.strCategorySource,
		A.intEntityId,
		EM.strEntityNo,
		EM.strName,
		A.dtmTransactionDate,
		dblTotalVolume = SUM(A.dblVolume)
FROM (
	SELECT  intEntityId = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.intEntityVendorId ELSE ARI.intEntityCustomerId END, 
		CVL.intBillId,
		CVL.intInvoiceId,
		CVL.ysnDirectSale,
		CVL.ysnIsUnposted,
		strCategorySource = CASE WHEN CVL.intBillId IS NOT NULL THEN 'Purchase' 
							ELSE (CASE WHEN CVL.ysnDirectSale = 1 THEN 'Direct' ELSE 'Sale' END) END,
		strTransactionNo = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.strBillId ELSE ARI.strInvoiceNumber END,
		dtmTransactionDate = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.dtmDate ELSE ARI.dtmDate END,
		CVL.dblVolume
	FROM tblPATCustomerVolumeLog CVL
	LEFT OUTER JOIN tblAPBill APB
		ON APB.intBillId = CVL.intBillId
	LEFT OUTER JOIN tblARInvoice ARI
		ON ARI.intInvoiceId = CVL.intInvoiceId
) A
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = A.intEntityId
WHERE A.ysnIsUnposted <> 1
GROUP BY	A.intBillId,
			A.intInvoiceId,
			A.intBillId,
			A.strTransactionNo,
			A.intEntityId,
			EM.strEntityNo,
			EM.strName,
			A.dtmTransactionDate,
			A.strCategorySource