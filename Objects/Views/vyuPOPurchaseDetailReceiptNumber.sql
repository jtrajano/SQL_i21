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
INNER JOIN tblPOPurchase b ON a.intPurchaseId = b.intPurchaseId
WHERE b.intOrderStatusId != 1
