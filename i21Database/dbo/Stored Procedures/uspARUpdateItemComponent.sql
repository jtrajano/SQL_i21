﻿CREATE PROCEDURE [dbo].[uspARUpdateItemComponent]
	 @InvoiceId	INT
	--,@UserId	INT = NULL
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
				
		
	DELETE ARIDC
	FROM			
		tblARInvoiceDetailComponent ARIDC
	INNER JOIN
		tblARInvoiceDetail ARID
			ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN
		tblARInvoice ARI
			ON ARID.intInvoiceId = ARI.intInvoiceId
	INNER JOIN
		tblARTransactionDetail ARTD
			ON ARID.intInvoiceDetailId = ARTD.intTransactionDetailId 
			AND ARID.intInvoiceId = ARTD.intTransactionId 
	WHERE 
		ARI.intInvoiceId = @InvoiceId
		AND ARID.intItemId <> ARTD.intItemId		
		AND ISNULL(ARTD.intInventoryShipmentItemId, 0) = 0
		AND ISNULL(ARTD.intSalesOrderDetailId, 0) = 0		
	
		

	--New
	INSERT INTO [tblARInvoiceDetailComponent]
		([intInvoiceDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intInvoiceDetailId]	= ARID.[intInvoiceDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		vyuARGetItemComponents ARGIC
			ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		tblICItem ICI
			ON ARID.[intItemId] = ICI.[intItemId]
	WHERE 
		ARI.[intInvoiceId] = @InvoiceId
		AND ARID.[intInvoiceDetailId] NOT IN (SELECT [intTransactionDetailId] FROM tblARTransactionDetail WHERE [intTransactionId] = @InvoiceId)
		AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0


	--New > Item Changed
	INSERT INTO [tblARInvoiceDetailComponent]
		([intInvoiceDetailId]
		,[intComponentItemId]
		,[strComponentType]
		,[intItemUOMId]
		,[dblQuantity]
		,[dblUnitQuantity]
		,[intConcurrencyId])
	SELECT 
		 [intInvoiceDetailId]	= ARID.[intInvoiceDetailId] 
		,[intComponentItemId]	= ARGIC.[intComponentItemId] 
		,[strComponentType]		= ARGIC.[strType] 
		,[intItemUOMId]			= ARGIC.[intItemUnitMeasureId] 
		,[dblQuantity]			= ARGIC.[dblQuantity] 
		,[dblUnitQuantity]		= ARGIC.[dblUnitQty] 
		,[intConcurrencyId]		= 1
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		vyuARGetItemComponents ARGIC
			ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN
		tblARTransactionDetail ARTD
			ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId] 
			AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN
		tblICItem ICI
			ON ARID.[intItemId] = ICI.[intItemId]
	WHERE 
		ARI.[intInvoiceId] = @InvoiceId
		AND ARID.[intItemId] <> ARTD.[intItemId]
		AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0	
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')	
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0
						
	 
END

GO