CREATE VIEW [dbo].[vyuPOPurchaseDetailReceiptNumber]
	AS 



	select
		DISTINCT
		intId = a.intPurchaseDetailId,
		intPurchaseDetailId,
		strSource = dbo.fnPOPurchaseDetailGetReceiptNumber(a.intPurchaseDetailId),
		strFilterId = dbo.fnPOPurchaseDetailGetReceiptId(a.intPurchaseDetailId)
	from 
	tblPOPurchaseDetail a
