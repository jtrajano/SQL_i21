print('/*******************  BEGIN Update Invoice Bill To Information  *******************/')
GO

UPDATE
	ARI
SET
	 strBillToAddress		= EMEL.strAddress
	,strBillToCity			= EMEL.strCity
	,strBillToCountry		= EMEL.strCountry 
	,strBillToLocationName	= EMEL.strLocationName
	,strBillToState			= EMEL.strState 
	,strBillToZipCode		= EMEL.strZipCode 
FROM
	tblARInvoice ARI
LEFT OUTER JOIN
	[tblEMEntityLocation] EMEL
		ON ARI.intBillToLocationId = EMEL.intEntityLocationId 	
WHERE
	ARI.intShipToLocationId <> ARI.intBillToLocationId
	AND (
			(CHARINDEX('INVSHP-',ARI.strComments) <> 0 AND CHARINDEX(': SO-',ARI.strComments) <> 0) 
			OR (ISNULL(ARI.intDistributionHeaderId,0) <> 0 OR ISNULL(ARI.intLoadDistributionHeaderId,0) <> 0)
			OR ISNULL(ARI.intShipmentId,0) <> 0
			OR ISNULL(ARI.intTransactionId,0) <> 0
			OR ISNULL(ARI.intOriginalInvoiceId,0) <> 0
		)

GO
print('/*******************  END Update Invoice Bill To Information  *******************/')