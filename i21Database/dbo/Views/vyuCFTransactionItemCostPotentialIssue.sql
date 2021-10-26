CREATE VIEW vyuCFTransactionItemCostPotentialIssue
AS

SELECT 
	tblCFTransaction.intTransactionId,
	tblCFTransaction.strTransactionId,
	tblCFTransaction.dblQuantity,
	tblCFTransaction.intARItemId,
	tblICItem.strItemNo,
	tblSMCompanyLocation.strLocationName
	 FROM tblCFTransaction
INNER JOIN tblICItem ON tblICItem.intItemId = tblCFTransaction.intARItemId
INNER JOIN tblICItemLocation IL ON IL.intItemId = tblCFTransaction.intARItemId
AND IL.intItemLocationId = tblCFTransaction.intARLocationId
			INNER JOIN tblSMCompanyLocation ON tblSMCompanyLocation.intCompanyLocationId = IL.intLocationId
		WHERE ISNULL(tblCFTransaction.dblQuantity, 0) > 0
			AND ISNULL(dbo.fnICGetItemRunningCost(tblCFTransaction.intARItemId,tblCFTransaction.intARLocationId,NULL,NULL,NULL,NUll,NULL,NULL,1),0) = 0
			AND (ISNULL(IL.intAllowZeroCostTypeId, 1) = 1 )
			AND ISNULL(tblCFTransaction.ysnPosted,0) = 0 


GO