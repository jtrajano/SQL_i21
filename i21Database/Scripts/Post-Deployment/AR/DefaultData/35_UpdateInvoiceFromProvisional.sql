print('/*******************  BEGIN Update Invoice From Provisional  *******************/')
GO

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

UPDATE tblARInvoice
SET
	[ysnFromProvisional] = CAST(0 AS BIT)
WHERE
	[ysnFromProvisional] IS NULL

UPDATE ARI1
SET
	ARI1.[ysnFromProvisional] = CAST(1 AS BIT)
FROM
	tblARInvoice ARI1	
WHERE
	EXISTS(SELECT NULL FROM tblARInvoice ARI2 WHERE ARI1.[intOriginalInvoiceId] = ARI2.[intInvoiceId] AND ARI2.[strType] = 'Provisional')


UPDATE tblARInvoice
SET
	[ysnImpactInventory] = CAST(1 AS BIT)
WHERE
	[ysnImpactInventory] IS NULL AND [ysnPosted] = CAST(0 AS BIT)
			
GO
print('/*******************  END Update  Invoice From Provisional  *******************/')