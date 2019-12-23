Create View vyuIPGetWeightClaim
As
SELECT WC.[intWeightClaimId]
	,WC.[intConcurrencyId]
	,WC.[strReferenceNumber]
	,WC.[dtmTransDate]
	,WC.[intLoadId]
	,WC.[strComments]
	,WC.[dtmETAPOD]
	,WC.[dtmLastWeighingDate]
	,WC.[dtmActualWeighingDate]
	,WC.[dtmClaimValidTill]
	,WC.[intPurchaseSale]
	,WC.[ysnPosted]
	,WC.[dtmPosted]
	,WC.[intCompanyId]
	,B.strBook 
	,SB.strSubBook 
	,PM.strPaymentMethod 
FROM tblLGWeightClaim WC
JOIN [tblCTBook] B on B.intBookId=WC.intBookId
JOIN [tblCTSubBook] SB on SB.intSubBookId=WC.intSubBookId
Left JOIN tblSMPaymentMethod PM on PM.intPaymentMethodID=WC.intPaymentMethodId
