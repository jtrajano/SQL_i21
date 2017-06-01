CREATE PROCEDURE [dbo].[uspARUpdateItemComponent]
	 @InvoiceId	INT
	,@Delete	BIT = 0
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
				
	IF ISNULL(@Delete,0) <> 0
	BEGIN
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
		INNER JOIN
			tblICItem ICI
				ON ARTD.[intItemId] = ICI.[intItemId]
		WHERE 
			ARI.intInvoiceId = @InvoiceId
			AND ARID.intItemId <> ARTD.intItemId
			AND ICI.strType = 'Bundle'		
			
			
		DELETE ARIDC
		FROM			
			tblARInvoiceDetailComponent ARIDC
		LEFT OUTER JOIN
			tblARInvoiceDetail ARID
				ON ARIDC.[intInvoiceDetailId] = ARID.[intInvoiceDetailId]
		WHERE 
			ISNULL(ARID.[intInvoiceDetailId],0) = 0

		RETURN
	END		
		

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
	FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
	INNER JOIN (SELECT intInvoiceId
					 , intCompanyLocationId
				FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN (SELECT intItemId
					 , intCompanyLocationId
					 , intComponentItemId
					 , strType
					 , intItemUnitMeasureId
					 , dblQuantity
					 , dblUnitQty
				FROM dbo.vyuARGetItemComponents WITH (NOLOCK)
	) ARGIC ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN (SELECT intItemId
					 , ysnListBundleSeparately
				FROM dbo.tblICItem WITH (NOLOCK)
	) ICI ON ARID.[intItemId] = ICI.[intItemId]
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
	FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
	INNER JOIN (SELECT intInvoiceId
					 , intCompanyLocationId
				FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN (SELECT intComponentItemId
					 , intItemId
					 , intCompanyLocationId
					 , strType
					 , intItemUnitMeasureId
					 , dblQuantity
					 , dblUnitQty
				FROM dbo.vyuARGetItemComponents WITH (NOLOCK)
	) ARGIC ON ARID.[intItemId] = ARGIC.[intItemId] 
			AND ARI.[intCompanyLocationId] = ARGIC.[intCompanyLocationId]
	INNER JOIN (SELECT intTransactionDetailId
					 , intTransactionId
					 , intItemId
				FROM dbo.tblARTransactionDetail WITH (NOLOCK)
	) ARTD ON ARID.[intInvoiceDetailId] = ARTD.[intTransactionDetailId] 
			AND ARID.[intInvoiceId] = ARTD.[intTransactionId]
	INNER JOIN (SELECT intItemId
					 , ysnListBundleSeparately
				FROM dbo.tblICItem WITH (NOLOCK)
	) ICI ON ARID.[intItemId] = ICI.[intItemId]
	WHERE 
		ARI.[intInvoiceId] = @InvoiceId
		AND ARID.[intItemId] <> ARTD.[intItemId]
		AND ISNULL(ICI.[ysnListBundleSeparately],0) = 0	
		AND ARGIC.[strType] IN ('Bundle') -- ('Bundle', 'Finished Good')	
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
		AND ISNULL(ARID.[intSalesOrderDetailId], 0) = 0
						
	 
END

GO