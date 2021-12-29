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
	tblCFTransaction.intARItemId,
	tblCFTransaction.intARLocationId,
	tblICItem.strItemNo,
	tblSMCompanyLocation.strLocationName,
	dblCost = (SELECT TOP 1 dblCost FROM vyuICGetInventoryValuation WHERE vyuICGetInventoryValuation.intItemId =  tblICItem.intItemId AND vyuICGetInventoryValuation.intLocationId = tblCFTransaction.intARLocationId AND vyuICGetInventoryValuation.dblQuantity > 0 ORDER BY intInventoryTransactionId DESC)
	 FROM tblCFTransaction
INNER JOIN tblICItem ON tblICItem.intItemId = tblCFTransaction.intARItemId
INNER JOIN tblICItemLocation IL ON IL.intItemId = tblCFTransaction.intARItemId AND IL.intLocationId = tblCFTransaction.intARLocationId
INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = IL.intLocationId
INNER JOIN vyuICGetInventoryValuation ON vyuICGetInventoryValuation.intItemId =  tblICItem.intItemId AND vyuICGetInventoryValuation.intLocationId = tblCFTransaction.intARLocationId AND vyuICGetInventoryValuation.dblQuantity > 0 
WHERE ISNULL(tblCFTransaction.dblQuantity, 0) > 0
AND ISNULL(tblCFTransaction.ysnPosted,0) = 0
) as subQuery
WHERE dblCost = 0 

GO

