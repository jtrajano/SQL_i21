CREATE PROCEDURE [dbo].[uspARUpdateLineItemsLotDetail]
	@InvoiceIds	InvoiceId	READONLY
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
					

    INSERT INTO [dbo].[tblARInvoiceDetailLot]
        ([intInvoiceDetailId]
        ,[intLotId]
        ,[dblQuantityShipped]
        ,[dblGrossWeight]
        ,[dblTareWeight]
        ,[dblWeightPerQty]
        ,[strWarehouseCargoNumber]
        ,[intSort]
        ,[dtmDateCreated]
        ,[dtmDateModified]
        ,[intCreatedByUserId]
        ,[intModifiedByUserId]
        ,[intConcurrencyId])
	SELECT 
         [intInvoiceDetailId]       = ARID.[intInvoiceDetailId]
        ,[intLotId]                 = ISIL.[intLotId]
        ,[dblQuantityShipped]       = ISIL.[dblQuantityShipped]
        ,[dblGrossWeight]           = ISIL.[dblGrossWeight]
        ,[dblTareWeight]            = ISIL.[dblTareWeight]
        ,[dblWeightPerQty]          = ISIL.[dblWeightPerQty]
        ,[strWarehouseCargoNumber]  = ISIL.[strWarehouseCargoNumber]
        ,[intSort]                  = ISIL.[intSort]
        ,[dtmDateCreated]           = ISIL.[dtmDateCreated]
        ,[dtmDateModified]          = ISIL.[dtmDateModified]
        ,[intCreatedByUserId]       = ISIL.[intCreatedByUserId]
        ,[intModifiedByUserId]      = ISIL.[intModifiedByUserId]
        ,[intConcurrencyId]         = ISIL.[intConcurrencyId]
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
		tblARInvoice ARI
			ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN
		tblICInventoryShipmentItem ISI
			ON ARID.[intInventoryShipmentItemId] = ISI.[intInventoryShipmentItemId]
	INNER JOIN
		tblICInventoryShipmentItemLot ISIL
			ON ISI.[intInventoryShipmentItemId] = ISIL.[intInventoryShipmentItemId]
    INNER JOIN
        @InvoiceIds II
			ON ARI.[intInvoiceId] = II.[intHeaderId]
	WHERE 
		ARID.[intInvoiceDetailId] NOT IN (SELECT [intTransactionDetailId] FROM tblARTransactionDetail WHERE [intTransactionId] = ARI.[intInvoiceId] AND [intTransactionDetailId] = ARID.[intInvoiceDetailId])
		AND ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0
		AND ISNULL(ARID.[intLoadDetailId], 0) = 0		
	 
END

GO
