CREATE VIEW [dbo].[vyuTRGetLoadReceiptToBlendIngredient]
	AS

SELECT DISTINCT LH.strTransaction 
	, LH.intLoadHeaderId
	, LR.intLoadReceiptId
	, LR.intItemId
	, DH.strDestination
	, BI.dblQuantity
FROM vyuTRGetLoadBlendIngredient BI 
INNER JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionDetailId = BI.intLoadDistributionDetailId
INNER JOIN tblTRLoadDistributionHeader DH ON DH.intLoadDistributionHeaderId = DD.intLoadDistributionHeaderId
INNER JOIN tblTRLoadHeader LH ON LH.intLoadHeaderId = DH.intLoadHeaderId
INNER JOIN tblTRLoadReceipt LR ON LR.intLoadHeaderId = DH.intLoadHeaderId 
WHERE LR.strOrigin = 'Terminal'
	AND LR.strReceiptLine = BI.strReceiptLink
	AND DD.ysnBlendedItem = 1