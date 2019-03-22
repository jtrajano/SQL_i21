print('/*******************  BEGIN Update tblARInvoice.strActualCostId  *******************/')
GO

UPDATE
      tblARInvoice
SET
      strActualCostId = NULL
WHERE
      strActualCostId IS NOT NULL AND RTRIM(LTRIM(ISNULL(strActualCostId,''))) = ''

	
GO
print('/*******************  END Update tblARInvoice.strActualCostId  *******************/')
