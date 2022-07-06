CREATE VIEW [dbo].[vyuFAAssetInvoice]
AS 
SELECT
	AI.intAssetInvoiceId,
	AI.intAssetId,
	FA.strAssetId,
	AI.intInvoiceId,
	AR.strInvoiceNumber,
	AR.dtmDate,
	AR.dblInvoiceTotal,
	AR.dtmShipDate,
	AR.intEntityCustomerId,
	AR.strCustomerName,
	AI.intConcurrencyId
FROM tblFAAssetInvoice AI
JOIN tblFAFixedAsset FA
	ON FA.intAssetId = AI.intAssetId
LEFT JOIN vyuFAARInvoice AR
	ON AR.intInvoiceId = AI.intInvoiceId
