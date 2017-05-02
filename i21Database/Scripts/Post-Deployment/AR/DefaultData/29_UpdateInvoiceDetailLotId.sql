print('/*******************  BEGIN Update Invoice Detail Lot Id  *******************/')
GO


UPDATE
	ARID
SET
	[intLotId] = LGL.[intLotId]
FROM
	tblARInvoiceDetail ARID
OUTER APPLY
	dbo.[fnGetLoadDetailLots](ARID.intLoadDetailId) LGL
WHERE
	ARID.[intLoadDetailId] IS NOT NULL
	AND ARID.[intLotId] IS NULL
	AND LGL.[intLotId] IS NOT NULL	

GO
print('/*******************  END Update Update Invoice Detail Lot Id  *******************/')