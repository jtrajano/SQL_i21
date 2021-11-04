CREATE PROCEDURE [dbo].[uspARUpdateLineItemLotDetail]
	 @InvoiceId	INT
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

    DECLARE @tblLotIds TABLE (
          intLotId              INT
        , intInvoiceDetailId    INT
    )

    DELETE IDL
	FROM tblARTransactionDetail TRD
	INNER JOIN tblARInvoiceDetail ID ON TRD.intTransactionId = ID.intInvoiceId
								    AND TRD.intTransactionDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoiceDetailLot IDL ON ID.intInvoiceDetailId = IDL.intInvoiceDetailId
	WHERE ID.intInvoiceId = @InvoiceId
	  AND ID.dblQtyShipped <> TRD.dblQtyShipped
    
	DELETE IDL
	FROM tblARInvoiceDetail ID 
	INNER JOIN tblARInvoiceDetailLot IDL ON ID.intInvoiceDetailId = IDL.intInvoiceDetailId
	WHERE ID.intInvoiceId = @InvoiceId
	  AND ID.intLoadDetailId IS NOT NULL

    INSERT INTO @tblLotIds (
          intLotId
        , intInvoiceDetailId
    )
    SELECT intLotId             = IDL.intLotId
         , intInvoiceDetailId   = ID.intInvoiceDetailId
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
        ,[dblQuantityShipped]       = dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], LOT.[intItemUOMId], ROUND(ISIL.dblQuantityShipped/AVGLOT.dblQuantityShipped, 6) * ARID.[dblQtyShipped])
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
    INNER JOIN (
		SELECT intInventoryShipmentItemId
			 , dblQuantityShipped	= SUM(dblQuantityShipped)
		FROM tblICInventoryShipmentItemLot AISIL
		GROUP BY AISIL.intInventoryShipmentItemId
	) AVGLOT ON AVGLOT.intInventoryShipmentItemId = ARID.intInventoryShipmentItemId
    INNER JOIN (
		SELECT intLotId
			 , intItemUOMId
			 , intTransactionId
			 , intTransactionDetailId
		FROM tblICInventoryLot LOT
		GROUP BY intLotId
			 , intItemUOMId
			 , intTransactionId
			 , intTransactionDetailId
	) LOT ON ISIL.[intLotId] = LOT.[intLotId] 
         AND LOT.[intTransactionId] = ISI.[intInventoryShipmentId]
         AND LOT.[intTransactionDetailId] = ISI.[intInventoryShipmentItemId]
    LEFT JOIN tblARTransactionDetail ARTD ON [ARTD].[intTransactionId] = ARI.[intInvoiceId] 
                                         AND [ARTD].[intTransactionDetailId] = ARID.[intInvoiceDetailId]
    OUTER APPLY (
        SELECT TOP 1 intInvoiceDetailId 
        FROM tblARInvoiceDetailLot ARIDL
        WHERE ARIDL.intInvoiceDetailId = ARID.intInvoiceDetailId
    ) ARIDL
	WHERE ARI.[intInvoiceId] = @InvoiceId
      AND (ARTD.intTransactionDetailId IS NULL OR ARIDL.intInvoiceDetailId IS NULL)
      AND ISNULL(ARID.[intInventoryShipmentItemId], 0) <> 0
      AND ISNULL(ARID.[intLoadDetailId], 0) = 0
      AND ISIL.intLotId NOT IN (SELECT intLotId FROM @tblLotIds LOT WHERE LOT.intInvoiceDetailId = ARID.intInvoiceDetailId)

	UNION ALL

	SELECT 
         [intInvoiceDetailId]       = ARID.[intInvoiceDetailId]
        ,[intLotId]                 = LGDL.[intLotId]
        ,[dblQuantityShipped]       = dbo.fnCalculateQtyBetweenUOM(ARID.[intItemUOMId], LOT.[intItemUOMId], LGDL.dblNet)
        ,[dblGrossWeight]           = LGDL.dblGross
        ,[dblTareWeight]            = LGDL.[dblTare]
        ,[dblWeightPerQty]          = 1
        ,[strWarehouseCargoNumber]  = LGDL.[strWarehouseCargoNumber]
        ,[intSort]                  = LGDL.intSort
        ,[dtmDateCreated]           = GETDATE()
        ,[dtmDateModified]          = GETDATE()
        ,[intCreatedByUserId]       = ARI.[intEntityId]
        ,[intModifiedByUserId]      = ARI.[intEntityId]
        ,[intConcurrencyId]         = LGDL.[intConcurrencyId]
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblLGLoadDetail LGD ON ARID.[intLoadDetailId] = LGD.[intLoadDetailId]
	INNER JOIN tblLGLoadDetailLot LGDL ON LGDL.[intLoadDetailId] = LGD.[intLoadDetailId]
    INNER JOIN (
		SELECT [intLoadDetailId]
			 , dblQuantityShipped	= SUM(dblLotQuantity)
		FROM tblLGLoadDetailLot ALGLD
		GROUP BY ALGLD.[intLoadDetailId]
	) AVGLOT ON AVGLOT.[intLoadDetailId] = ARID.[intLoadDetailId]
    INNER JOIN (
		SELECT intLotId
			 , intItemUOMId
			 , intTransactionId
			 , intTransactionDetailId
		FROM tblICInventoryLot LOT
		GROUP BY intLotId
			 , intItemUOMId
			 , intTransactionId
			 , intTransactionDetailId
	) LOT ON LGDL.[intLotId] = LOT.[intLotId] 
         AND LOT.[intTransactionId] = LGD.[intLoadId]
         AND LOT.[intTransactionDetailId] = LGD.[intLoadDetailId]
    LEFT JOIN tblARTransactionDetail ARTD ON [ARTD].[intTransactionId] = ARI.[intInvoiceId] 
                                         AND [ARTD].[intTransactionDetailId] = ARID.[intInvoiceDetailId]
    OUTER APPLY (
        SELECT TOP 1 intInvoiceDetailId 
        FROM tblARInvoiceDetailLot ARIDL
        WHERE ARIDL.intInvoiceDetailId = ARID.intInvoiceDetailId
    ) ARIDL
	WHERE ARI.[intInvoiceId] = @InvoiceId
      AND ISNULL(ARID.[intInventoryShipmentItemId], 0) = 0
      AND ISNULL(ARID.[intLoadDetailId], 0) <> 0
	 
END