CREATE PROCEDURE [dbo].[uspARUpdateLineItemLotDetail]
	 @InvoiceId	INT
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

    DECLARE @tblLotIds TABLE (intLotId INT)
    
    INSERT INTO @tblLotIds
    SELECT IDL.intLotId
    FROM tblARInvoice I
    INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
    INNER JOIN tblARInvoiceDetailLot IDL ON ID.intInvoiceDetailId = IDL.intInvoiceDetailId
    WHERE I.intInvoiceId = @InvoiceId

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
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblICInventoryShipmentItem ISI ON ARID.[intInventoryShipmentItemId] = ISI.[intInventoryShipmentItemId]
	INNER JOIN tblICInventoryShipmentItemLot ISIL ON ISI.[intInventoryShipmentItemId] = ISIL.[intInventoryShipmentItemId]
	WHERE ARI.[intInvoiceId] = @InvoiceId
      AND ARID.[intInvoiceDetailId] NOT IN (SELECT [intTransactionDetailId] FROM tblARTransactionDetail WHERE [intTransactionId] = @InvoiceId)
      AND ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0
      AND ISNULL(ARID.[intLoadDetailId], 0) = 0
      AND ISIL.intLotId NOT IN (SELECT intLotId FROM @tblLotIds)
	 
END

GO
