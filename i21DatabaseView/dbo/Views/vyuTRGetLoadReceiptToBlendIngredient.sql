CREATE VIEW [dbo].[vyuTRGetLoadReceiptToBlendIngredient]
	AS

SELECT DISTINCT TT.strTransaction
	, TT.intLoadHeaderId
	, RR.intLoadReceiptId
	, RR.intItemId
	, HH.strDestination
	, dblQty = BI.dblQuantity
FROM tblTRLoadHeader TT
LEFT JOIN tblTRLoadReceipt RR ON TT.intLoadHeaderId = RR.intLoadHeaderId
LEFT JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId
LEFT JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId
LEFT JOIN vyuTRGetLoadBlendIngredient BI ON BI.intLoadDistributionDetailId = HD.intLoadDistributionDetailId
WHERE RR.strOrigin = 'Terminal'
	AND BI.intIngredientItemId = RR.intItemId