CREATE VIEW vyuCFTransactionItemCostPotentialIssue
AS


SELECT 
	intTransactionId,
	strTransactionId,
	dblQuantity,
	intARItemId,
	intARLocationId,
	strItemNo,
	strLocationName
FROM
(
SELECT 
	tblCFTransaction.intTransactionId,
	tblCFTransaction.strTransactionId,
	tblCFTransaction.dblQuantity,
	tblCFItem.intARItemId,
	tblCFTransaction.intARLocationId,
	tblICItem.strItemNo,
	tblSMCompanyLocation.strLocationName,
	dblCost = (SELECT TOP 1 dblCost FROM vyuICGetInventoryValuation WHERE vyuICGetInventoryValuation.intItemId =  tblICItem.intItemId AND vyuICGetInventoryValuation.intLocationId = tblCFTransaction.intARLocationId AND vyuICGetInventoryValuation.dblQuantity > 0 ORDER BY intInventoryTransactionId DESC)
	 FROM tblCFTransaction
INNER JOIN tblCFItem ON tblCFItem.intItemId = tblCFTransaction.intProductId
INNER JOIN tblICItem ON tblICItem.intItemId = tblCFItem.intARItemId
INNER JOIN tblICItemLocation IL ON IL.intItemId = tblCFItem.intARItemId AND IL.intLocationId = tblCFTransaction.intARLocationId
INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = IL.intLocationId
WHERE ISNULL(tblCFTransaction.dblQuantity, 0) > 0
AND ISNULL(tblCFTransaction.ysnPosted,0) = 0
) as subQuery
WHERE dblCost = 0 


GO

