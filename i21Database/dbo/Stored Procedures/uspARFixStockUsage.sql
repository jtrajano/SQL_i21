CREATE PROCEDURE uspARFixStockUsage	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Clear the tables
TRUNCATE TABLE tblICItemStockUsagePerPeriod
DELETE FROM tblICItemStockDetail WHERE intItemStockTypeId = 11

-- Regenerate the data. 
DECLARE @UsageItems AS ItemCostingTableType
INSERT INTO @UsageItems (
	intTransactionId
	,strTransactionId
	,intItemId
	,intItemLocationId
	,intItemUOMId
	,dtmDate
	,dblQty
	,dblUOMQty
	,intSubLocationId
	,intStorageLocationId
	,intTransactionTypeId
)

SELECT	
	Inv.intInvoiceId
	,Inv.strInvoiceNumber
	,InvDet.intItemId
	,ItemLocation.intItemLocationId
	,iu.intItemUOMId
	,Inv.dtmDate
	,dblQty = 
		CASE 
			WHEN Inv.strTransactionType = 'Credit Memo' THEN 
				-InvDet.dblQtyShipped
								
			ELSE
				InvDet.dblQtyShipped								
		END
	,iu.dblUnitQty
	,InvDet.intSubLocationId
	,InvDet.intStorageLocationId
	,intTransactionTypeId = 
		CASE 
			WHEN Inv.strTransactionType = 'Credit Memo' THEN 
				45								
			ELSE
				33
		END
FROM 
	tblARInvoice Inv
	INNER JOIN tblARInvoiceDetail InvDet
		ON InvDet.intInvoiceId = Inv.intInvoiceId
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemId = InvDet.intItemId
		AND ItemLocation.intLocationId = Inv.intCompanyLocationId
	INNER JOIN tblICItemUOM iu
		ON iu.intItemId = InvDet.intItemId
		AND iu.intItemUOMId = InvDet.intItemUOMId
WHERE 				
	Inv.ysnPosted = 1 
	AND Inv.strTransactionType IN(
		'Invoice'
		,'Cash'
		,'Credit Memo'
		,'Debit Memo'
	)				


INSERT INTO @UsageItems (
	intTransactionId
	,strTransactionId
	,intItemId
	,intItemLocationId
	,intItemUOMId
	,dtmDate
	,dblQty
	,dblUOMQty
	,intSubLocationId
	,intStorageLocationId
	,intTransactionTypeId
)
SELECT	
	Inv.intInvoiceId
	,Inv.strInvoiceNumber
	,PrepaidDetail.intItemId
	,ItemLocation.intItemLocationId
	,iu.intItemUOMId
	,Inv.dtmDate
	,dblQty = -PrepaidDetail.dblQtyShipped
	,iu.dblUnitQty
	,PrepaidDetail.intSubLocationId
	,PrepaidDetail.intStorageLocationId
	,intTransactionTypeId = 
		CASE 
			WHEN Inv.strTransactionType = 'Credit Memo' THEN 
				45								
			ELSE
				33
		END
FROM 
	tblARInvoice Inv
	INNER JOIN tblARPrepaidAndCredit Prepaid
		ON Prepaid.intInvoiceId = Inv.intInvoiceId
	INNER JOIN tblARInvoiceDetail PrepaidDetail
		ON PrepaidDetail.intInvoiceId = Prepaid.intPrepaymentId
	INNER JOIN tblICItemLocation ItemLocation
		ON ItemLocation.intItemId = PrepaidDetail.intItemId
		AND ItemLocation.intLocationId = Inv.intCompanyLocationId
	INNER JOIN tblICItemUOM iu
		ON iu.intItemId = PrepaidDetail.intItemId
		AND iu.intItemUOMId = PrepaidDetail.intItemUOMId

WHERE 
	Inv.ysnPosted = 1 
	AND Inv.strTransactionType IN(
		'Cash Refund'
	)	

EXEC uspICIncreaseUsageQty @UsageItems