print('/*******************  BEGIN Update Unit Price and Unit UOM & QTY  *******************/')
GO

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

UPDATE
	tblARInvoiceDetail
SET	 
	 [dblUnitPrice] 			= ISNULL([dblPrice], @ZeroDecimal)
	,[dblBaseUnitPrice]			= ISNULL([dblBasePrice], @ZeroDecimal)
WHERE
	ISNULL([dblUnitPrice], @ZeroDecimal) <> ISNULL([dblPrice], @ZeroDecimal)
	AND ISNULL([intLoadDetailId],0) = 0
	AND [intPriceUOMId] IS NULL

UPDATE
	tblARInvoiceDetail
SET	 
	[dblUnitQuantity]			= CASE WHEN (ISNULL([dblUnitQuantity],0) <> @ZeroDecimal) THEN [dblUnitQuantity] ELSE (CASE WHEN (ISNULL([intLoadDetailId],0) <> 0) THEN ISNULL([dblShipmentGrossWt], @ZeroDecimal) - ISNULL([dblShipmentTareWt], @ZeroDecimal) ELSE ISNULL([dblQtyShipped], @ZeroDecimal) END) END	
WHERE
	ISNULL([dblUnitQuantity], @ZeroDecimal) = @ZeroDecimal
	AND (
			ISNULL([dblShipmentNetWt], @ZeroDecimal) <> @ZeroDecimal
			OR
			ISNULL([dblQtyShipped], @ZeroDecimal) <> @ZeroDecimal
		)
	AND [intPriceUOMId] IS NULL

UPDATE
	tblARInvoiceDetail
SET	 
	[intPriceUOMId]				= CASE WHEN (ISNULL([intLoadDetailId],0) <> 0) THEN [intItemWeightUOMId] ELSE [intItemUOMId] END	
WHERE
	[intPriceUOMId] IS NULL


UPDATE
	tblSOSalesOrderDetail
SET	 
	 [dblUnitPrice] 			= ISNULL([dblPrice], @ZeroDecimal)
	,[dblBaseUnitPrice]			= ISNULL([dblBasePrice], @ZeroDecimal)
WHERE
	ISNULL([dblUnitPrice], @ZeroDecimal) <> ISNULL([dblPrice], @ZeroDecimal)
	AND ISNULL([dblUnitPrice], @ZeroDecimal) = @ZeroDecimal
	AND [intPriceUOMId] IS NULL

UPDATE
	tblSOSalesOrderDetail
SET	 
	[dblUnitQuantity]			= CASE WHEN (ISNULL([dblUnitQuantity],0) <> @ZeroDecimal) THEN [dblUnitQuantity] ELSE [dblQtyOrdered] END	
WHERE
	ISNULL([dblUnitQuantity], @ZeroDecimal) = @ZeroDecimal
	AND ISNULL([dblQtyOrdered], @ZeroDecimal) <> @ZeroDecimal			
	AND [intPriceUOMId] IS NULL

UPDATE
	tblSOSalesOrderDetail
SET	 
	[intPriceUOMId]				= [intItemUOMId]	
WHERE
	[intPriceUOMId] IS NULL

			
GO
print('/*******************  END Update Unit Price and Unit UOM & QTY  *******************/')