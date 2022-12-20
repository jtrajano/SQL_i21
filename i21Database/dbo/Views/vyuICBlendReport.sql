CREATE VIEW [dbo].[vyuICBlendReport]
AS
SELECT it.intTransactionId
	 , lh.intLoadHeaderId
	 , lh.strTransaction
	 , IsNULL(lh.dtmLoadDateTime, it.dtmDate) AS dtmLoadDateTime
	 , cl.strLocationNumber
	 , cl.strLocationName
	 , i.strItemNo
	 , i.strDescription
	 , it.strTransactionId
	 , itt.strName
	 , it.dblQty
	 , it.dblCost
	 , i1.strItemNo strProduce
	 , wo.dblQuantity AS dblWorkOrderQty
FROM tblICInventoryTransaction it
JOIN tblICItem i ON i.intItemId = it.intItemId
JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId
JOIN tblSMCompanyLocation cl ON il.intLocationId = cl.intCompanyLocationId
JOIN tblICInventoryTransactionType itt ON it.intTransactionTypeId = itt.intTransactionTypeId
JOIN tblMFWorkOrder wo ON it.intTransactionId = wo.intBatchID
	AND wo.strWorkOrderNo = it.strTransactionId
LEFT JOIN tblTRLoadDistributionDetail ldd ON ldd.intLoadDistributionDetailId = wo.intLoadDistributionDetailId
LEFT JOIN tblTRLoadDistributionHeader ldh ON ldh.intLoadDistributionHeaderId = ldd.intLoadDistributionHeaderId
LEFT JOIN tblTRLoadHeader lh ON lh.intLoadHeaderId = ldh.intLoadHeaderId
LEFT JOIN tblICItem i1 ON wo.intItemId = i1.intItemId
WHERE it.intTransactionTypeId IN (
		8
		,9
		)
	AND it.ysnIsUnposted = 0
GO


