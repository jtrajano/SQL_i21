CREATE VIEW [dbo].[vyuICBlendReport]
AS

SELECT it.intTransactionId, lh.intLoadHeaderId,lh.strTransaction,lh.dtmLoadDateTime,cl.strLocationNumber,cl.strLocationName,i.strItemNo, i.strDescription, 
	it.strTransactionId,itt.strName,it.dblQty, it.dblCost, i1.strItemNo strProduce
FROM tblICInventoryTransaction it 
	JOIN tblICItem i on i.intItemId = it.intItemId
	JOIN tblICItemLocation il on it.intItemLocationId = il.intItemLocationId
	JOIN tblSMCompanyLocation cl on il.intLocationId = cl.intCompanyLocationId
	JOIN tblICInventoryTransactionType itt on it.intTransactionTypeId = itt.intTransactionTypeId
	JOIN tblMFWorkOrder wo on it.intTransactionId = wo.intBatchID 
	JOIN tblTRLoadDistributionDetail ldd on ldd.intLoadDistributionDetailId = wo.intLoadDistributionDetailId
	JOIN tblTRLoadDistributionHeader ldh on ldh.intLoadDistributionHeaderId = ldd.intLoadDistributionHeaderId
	JOIN tblTRLoadHeader lh on lh.intLoadHeaderId = ldh.intLoadHeaderId
	LEFT JOIN tblICInventoryTransaction it1 on it1.strTransactionId = it.strTransactionId 
	LEFT JOIN tblICItem i1 on it1.intItemId = i1.intItemId 
WHERE it.intTransactionTypeId in (8,9) and it.ysnIsUnposted = 0
	AND it1.intTransactionTypeId = 9
--and @DATE@
--ORDER BY lh.intLoadHeaderId, it.strTransactionId,itt.strName
GO