CREATE VIEW [dbo].[vyuPATCustomerVolumeLog]
	AS
-- SELECT	id = NEWID(),
-- 		A.intBillId,
-- 		A.intInvoiceId,
-- 		A.strTransactionNo,
-- 		strCategorySource = A.strCategorySource COLLATE Latin1_General_CI_AS,
-- 		intCustomerId = A.intEntityId,
-- 		EM.strEntityNo,
-- 		EM.strName,
-- 		A.dtmTransactionDate,
-- 		A.dtmPostDate,
-- 		dblTotalVolume = SUM(A.dblVolume)
-- FROM (
-- 	SELECT  intEntityId = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.intEntityVendorId ELSE ARI.intEntityCustomerId END, 
-- 		CVL.intBillId,
-- 		CVL.intInvoiceId,
-- 		CVL.ysnDirectSale,
-- 		CVL.ysnIsUnposted,
-- 		strCategorySource = CASE WHEN CVL.intBillId IS NOT NULL THEN 'Purchase' 
-- 							ELSE (CASE WHEN CVL.ysnDirectSale = 1 THEN 'Direct' ELSE 'Sale' END) END,
-- 		strTransactionNo = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.strBillId ELSE ARI.strInvoiceNumber END,
-- 		dtmTransactionDate = CASE WHEN CVL.intBillId IS NOT NULL THEN APB.dtmDate ELSE ARI.dtmDate END,
-- 		CVL.dtmPostDate,
-- 		CVL.dblVolume
-- 	FROM tblPATCustomerVolumeLog CVL
-- 	LEFT OUTER JOIN tblAPBill APB
-- 		ON APB.intBillId = CVL.intBillId
-- 	LEFT OUTER JOIN tblARInvoice ARI
-- 		ON ARI.intInvoiceId = CVL.intInvoiceId
-- ) A
-- INNER JOIN tblEMEntity EM
-- 	ON EM.intEntityId = A.intEntityId
-- WHERE A.ysnIsUnposted <> 1
-- GROUP BY	A.intBillId,
-- 			A.intInvoiceId,
-- 			A.intBillId,
-- 			A.strTransactionNo,
-- 			A.intEntityId,
-- 			EM.strEntityNo,
-- 			EM.strName,
-- 			A.dtmTransactionDate,
-- 			A.dtmPostDate,
-- 			A.strCategorySource


---===voucher details=====
	SELECT  
		id = NEWID(),
		strFiscalYear = F.strFiscalYear, 
		strCustomerNo = V.strVendorId, 
		strCustomer = E.strName,
		strStockStatus = C.strStockStatus,
		strCategoryCode =  PC.strCategoryCode,  
		strUnitAmount = PC.strUnitAmount,
		strTransactionNo =  B.strBillId,
		dtmTransactionDate = B.dtmDate,
		strTransactionType = case when B.intTransactionType = 3 then 'Debit Memo' else 'Voucher' end,
		strItemNo = I.strItemNo, 
		strItem = I.strDescription, 
		dblQuantity = BD.dblQtyReceived, 
		dblRate = BD.dblCost,
		dblVolume = vl.dblVolume
	FROM 
	tblPATCustomerVolumeLog vl
	join tblAPBill B on B.intBillId = vl.intBillId
	inner join tblAPBillDetail BD on BD.intBillId = B.intBillId and BD.intItemId = vl.intItemId
	inner join tblICItem I on BD.intItemId = I.intItemId
	inner join tblAPVendor V on B.intEntityVendorId = V.intEntityId
	inner join tblARCustomer C on V.intEntityId = C.intEntityId
	inner join tblPATPatronageCategory PC on I.intPatronageCategoryId = PC.intPatronageCategoryId
	join tblEMEntity E on V.intEntityId = E.intEntityId
	join tblGLFiscalYear F on B.dtmDate between F.dtmDateFrom and F.dtmDateTo

	UNION ALL
	--====invoice details====
	select 
		id = NEWID(),
		strFiscalYear = F.strFiscalYear,
		strCustomerNo =  C.strCustomerNumber,
		strCustomer =  E.strName,
		strStockStatus = C.strStockStatus, 
		strCategoryCode = PC.strCategoryCode,  
		strUnitAmount = PC.strUnitAmount,
		strTransactionNo = IH.strInvoiceNumber, 
		dtmTransactionDate = IH.dtmDate,
		strTransactionType = IH.strTransactionType,
		strItemNo = I.strItemNo, 
		strItem = I.strDescription,
		dblQuantity =  ID.dblQtyShipped, 
		dblRate = ID.dblPrice,
		dblVolume = vl.dblVolume
	FROM 
	tblPATCustomerVolumeLog vl
	join tblARInvoice IH on IH.intInvoiceId = vl.intInvoiceId
		inner join tblARInvoiceDetail ID on IH.intInvoiceId = ID.intInvoiceId and ID.intItemId = vl.intItemId
		inner join tblICItem I on ID.intItemId = I.intItemId
		inner join tblARCustomer C on IH.intEntityCustomerId = C.intEntityId
		inner join tblPATPatronageCategory PC on I.intPatronageCategoryId = PC.intPatronageCategoryId
		join tblEMEntity E on C.intEntityId = E.intEntityId
		join tblGLFiscalYear F on IH.dtmDate between F.dtmDateFrom and F.dtmDateTo

	UNION ALL
	--====volume adjustment details======
	SELECT  
		id = NEWID(),
		strFiscalYear = f.strFiscalYear, 
		strCustomerNo = c.strCustomerNumber,
		strCustomer =  e.strName,
		strStockStatus = c.strStockStatus, 
		strCategoryCode = pc.strCategoryCode, 
		strUnitAmount = pc.strUnitAmount,
		strTransactionNo = av.strAdjustmentNo,
		dtmTransactionDate = av.dtmAdjustmentDate,
		strTransactionType = null,
		strItemNo = null,
		strItem = null,
		dblQuantity = null,
		dblRate = null,
		dblVolume = avd.dblQuantityAdjusted
	from tblPATAdjustVolume av
	join tblPATAdjustVolumeDetails avd on av.intAdjustmentId = avd.intAdjustmentId
	join tblGLFiscalYear f on avd.intFiscalYearId = f.intFiscalYearId
	join tblARCustomer c on c.intEntityId = av.intCustomerId
	join tblEMEntity e on c.intEntityId = e.intEntityId
	join tblPATPatronageCategory pc on avd.intPatronageCategoryId = pc.intPatronageCategoryId



	



	