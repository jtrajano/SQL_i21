CREATE VIEW [dbo].[vyuTRGetLoadReceiptToDistribution]
	AS

SELECT TT.strTransaction
	, TT.intLoadHeaderId
	, RR.intLoadReceiptId
	, RR.intItemId
	, HH.strDestination
	, dblQty = HD.dblUnits
FROM tblTRLoadHeader TT
JOIN tblTRLoadReceipt RR ON TT.intLoadHeaderId = RR.intLoadHeaderId
JOIN tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
JOIN tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
WHERE ((RR.strOrigin = 'Terminal' AND HH.strDestination = 'Customer') OR (RR.strOrigin = 'Terminal' AND HH.strDestination = 'Location' AND RR.intCompanyLocationId != HH.intCompanyLocationId))
	AND RR.intItemId = HD.intItemId
	AND HD.strReceiptLink = RR.strReceiptLine