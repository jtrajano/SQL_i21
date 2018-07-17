CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	  @intTransactionId			INT = NULL
	, @strTransactionType		NVARCHAR(100) = 'Sales Order'
	, @ysnForDelete				BIT = 0
	, @intSalesOrderDetailId	INT = NULL
	, @dblQuantity				NUMERIC(18,6) = 0.000000
	, @intItemUOMId				INT = NULL
AS
BEGIN

DECLARE @tblSOToUpdate			Id
DECLARE	@strOrderStatus			NVARCHAR(50) = 'Open'	  
	  , @dblTotalQtyOrdered		NUMERIC(18,6) = 0.000000
	  , @dblTotalQtyShipped		NUMERIC(18,6) = 0.000000
	  , @intSalesOrderId		INT = NULL	  

IF @strTransactionType = 'Sales Order' 
	SET @intSalesOrderId = @intTransactionId

IF @strTransactionType = 'Invoice'
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN ISNULL(OTHERITEMS.dblQtyShipped, 0) + CONVERT(NUMERIC(18, 6), CASE WHEN SOD.intItemUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)) ELSE ISNULL(INVOICEITEMS.dblQtyShipped, 0) END)
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), CASE WHEN SOD.intItemUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)) ELSE ISNULL(INVOICEITEMS.dblQtyShipped, 0) END)
							 END
		  , @intSalesOrderId = SOD.intSalesOrderId
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		CROSS APPLY (
			SELECT dblQtyShipped = CASE WHEN ID.intItemUOMId IS NOT NULL THEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ID.intItemUOMId, UOM.intItemUOMId), SUM(ID.dblQtyShipped)), 0) ELSE SUM(ID.dblQtyShipped) END
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
			  AND ID.intInvoiceId = @intTransactionId
			  AND ((ISNULL(SOD.strMaintenanceType, '') = 'Maintenance Only' AND I.ysnRecurring = 1) OR (ISNULL(SOD.strMaintenanceType, '') <> 'Maintenance Only' AND I.ysnRecurring = 0))
			GROUP BY ID.intItemUOMId, UOM.intItemUOMId 
		) INVOICEITEMS
		OUTER APPLY (
			SELECT dblQtyShipped = SUM(ISNULL(ITEMS.dblQtyShipped, 0))
			FROM (

				SELECT dblQtyShipped = CASE WHEN ID.intItemUOMId IS NOT NULL THEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ID.intItemUOMId, UOM.intItemUOMId), SUM(ID.dblQtyShipped)), 0) ELSE SUM(ID.dblQtyShipped) END
				FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
				  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
				  AND ID.intInvoiceId <> @intTransactionId
				  AND ((ISNULL(SOD.strMaintenanceType, '') = 'Maintenance Only' AND I.ysnRecurring = 1) OR (ISNULL(SOD.strMaintenanceType, '') <> 'Maintenance Only' AND I.ysnRecurring = 0))
				GROUP BY ID.intItemUOMId, UOM.intItemUOMId 

				UNION ALL

				SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId, ISNULL(ISI.intItemUOMId, UOM.intItemUOMId), SUM(ISI.dblQuantity)), 0)
				FROM tblICInventoryShipmentItem ISI
				LEFT JOIN tblICItemUOM UOM ON ISI.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ISI.intOrderId, 0) = SOD.intSalesOrderId
				  AND ISNULL(ISI.intLineNo, 0) = SOD.intSalesOrderDetailId
				  AND ISI.intInventoryShipmentId <> @intTransactionId
				GROUP BY ISI.intItemUOMId, UOM.intItemUOMId
			) ITEMS
		) OTHERITEMS
	END
ELSE IF @strTransactionType = 'Inventory'
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN ISNULL(OTHERITEMS.dblQuantity, 0) + CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), ISNULL(SHIPPEDITEMS.dblQuantity, 0)))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), ISNULL(SHIPPEDITEMS.dblQuantity, 0)))
							 END
		  , @intSalesOrderId = SOD.intSalesOrderId
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		CROSS APPLY (
			SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId, ISNULL(ISI.intItemUOMId, UOM.intItemUOMId), SUM(ISI.dblQuantity)), 0)
			FROM tblICInventoryShipmentItem ISI
			LEFT JOIN tblICItemUOM UOM ON ISI.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ISI.intOrderId, 0) = SOD.intSalesOrderId
			  AND ISNULL(ISI.intLineNo, 0) = SOD.intSalesOrderDetailId
			  AND ISI.intInventoryShipmentId = @intTransactionId
			GROUP BY ISI.intItemUOMId, UOM.intItemUOMId  
		) SHIPPEDITEMS	
		OUTER APPLY (
			SELECT dblQuantity = SUM(ISNULL(ITEMS.dblQuantity, 0))
			FROM (
				SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId, ISNULL(ISI.intItemUOMId, UOM.intItemUOMId), SUM(ISI.dblQuantity)), 0)
				FROM tblICInventoryShipmentItem ISI
				LEFT JOIN tblICItemUOM UOM ON ISI.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ISI.intOrderId, 0) = SOD.intSalesOrderId
				  AND ISNULL(ISI.intLineNo, 0) = SOD.intSalesOrderDetailId
				  AND ISI.intInventoryShipmentId <> @intTransactionId
				GROUP BY ISI.intItemUOMId, UOM.intItemUOMId
			
				UNION ALL
			
				SELECT dblQuantity = CASE WHEN ID.intItemUOMId IS NOT NULL THEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ID.intItemUOMId, UOM.intItemUOMId), SUM(ID.dblQtyShipped)), 0) ELSE SUM(ID.dblQtyShipped) END 
				FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
				LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
				  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
				  AND ID.intInvoiceId <> @intTransactionId
				  AND ((ISNULL(SOD.strMaintenanceType, '') = 'Maintenance Only' AND I.ysnRecurring = 1) OR (ISNULL(SOD.strMaintenanceType, '') <> 'Maintenance Only' AND I.ysnRecurring = 0))
				GROUP BY ID.intItemUOMId, UOM.intItemUOMId
			) ITEMS
		) OTHERITEMS

		UPDATE tblSOSalesOrderDetail
		SET
			dblQtyShipped = dblQtyShipped + dbo.fnCalculateQtyBetweenUOM(intItemUOMId, ISNULL(@intItemUOMId, intItemUOMId), ISNULL(@dblQuantity, 0))
		WHERE
			intSalesOrderDetailId = @intSalesOrderDetailId
			
		
		UPDATE tblSOSalesOrder
		SET ysnShipped = CASE WHEN @ysnForDelete = 0 THEN 1 ELSE 0 END
		WHERE intSalesOrderId = @intSalesOrderId
	END
ELSE
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), (ISNULL(INVOICEITEMS.dblQtyShipped, 0) + ISNULL(SHIPPEDITEMS.dblQuantity, 0))))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(SOD.intItemUOMId, UOM.intItemUOMId), (ISNULL(INVOICEITEMS.dblQtyShipped, 0) + ISNULL(SHIPPEDITEMS.dblQuantity, 0))))
							 END,
			@intSalesOrderId = SOD.intSalesOrderId		  
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		OUTER APPLY (
			SELECT dblQtyShipped = CASE WHEN ID.intItemUOMId IS NOT NULL THEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, ISNULL(ID.intItemUOMId, UOM.intItemUOMId), SUM(ID.dblQtyShipped)), 0) ELSE SUM(ID.dblQtyShipped) END
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
			  AND ((ISNULL(SOD.strMaintenanceType, '') = 'Maintenance Only' AND I.ysnRecurring = 1) OR (ISNULL(SOD.strMaintenanceType, '') <> 'Maintenance Only' AND I.ysnRecurring = 0))
			GROUP BY ID.intItemUOMId, UOM.intItemUOMId 
		) INVOICEITEMS
		OUTER APPLY (
			SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISI.intItemUOMId, ISNULL(ISI.intItemUOMId, UOM.intItemUOMId), SUM(ISI.dblQuantity)), 0)
			FROM tblICInventoryShipmentItem ISI
			LEFT JOIN tblICItemUOM UOM ON ISI.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ISI.intOrderId, 0) = SOD.intSalesOrderId
			  AND ISNULL(ISI.intLineNo, 0) = SOD.intSalesOrderDetailId
			GROUP BY ISI.intItemUOMId, UOM.intItemUOMId  
		) SHIPPEDITEMS
		WHERE intSalesOrderId = @intTransactionId
	END

IF @strTransactionType = 'Invoice'
	BEGIN
		INSERT INTO @tblSOToUpdate
		SELECT DISTINCT SOD.intSalesOrderId
		FROM tblARInvoiceDetail ID
		INNER JOIN tblSOSalesOrderDetail SOD ON ID.intSalesOrderDetailId = SOD.intSalesOrderDetailId
		WHERE ID.intSalesOrderDetailId IS NOT NULL
		  AND ID.intInvoiceId = @intTransactionId
	END
ELSE IF @strTransactionType = 'Inventory'
	BEGIN
		INSERT INTO @tblSOToUpdate
		SELECT DISTINCT SOD.intSalesOrderId
		FROM tblICInventoryShipmentItem ISI
		INNER JOIN tblSOSalesOrderDetail SOD ON ISI.intLineNo = SOD.intSalesOrderDetailId AND ISI.intOrderId = SOD.intSalesOrderId
		WHERE ISI.intLineNo IS NOT NULL
		  AND ISI.intOrderId IS NOT NULL
		  AND ISI.intInventoryShipmentId = @intTransactionId
		UNION
		SELECT intSalesOrderId
		FROM tblSOSalesOrderDetail
		WHERE intSalesOrderDetailId = @intSalesOrderDetailId
	END
ELSE
	BEGIN
		IF @intSalesOrderId IS NOT NULL
			INSERT INTO @tblSOToUpdate
			SELECT @intSalesOrderId
	END

WHILE EXISTS (SELECT TOP 1 NULL FROM @tblSOToUpdate)
	BEGIN
		DECLARE @intSOToUpdate		INT = NULL		
		      , @ysnShipmentPosted	BIT = 0
			  , @intUserId			INT = NULL

		SELECT TOP 1 @intSOToUpdate = intId 
		FROM @tblSOToUpdate

		SET @dblTotalQtyOrdered = 0
		SET @dblTotalQtyShipped = 0

		SELECT @dblTotalQtyOrdered	= SUM(dblQtyOrdered)
			  ,@dblTotalQtyShipped	= SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END)
			  ,@ysnShipmentPosted	= [IS].ysnPosted
			  ,@intUserId			= [SO].intEntityId
		FROM tblSOSalesOrderDetail [SOD]
		INNER JOIN tblSOSalesOrder [SO]
			ON [SO].intSalesOrderId = [SOD].intSalesOrderId
		LEFT JOIN tblICInventoryShipment [IS]
			ON [IS].strReferenceNumber = SO.strSalesOrderNumber
		WHERE [SO].intSalesOrderId = @intSOToUpdate
		GROUP BY [SO].intSalesOrderId, [IS].ysnPosted, [SO].intEntityId

		IF (@dblTotalQtyShipped = 0)
			SET @strOrderStatus = 'Open'
		ELSE IF @dblTotalQtyShipped < @dblTotalQtyOrdered
			SET @strOrderStatus = 'Partial'
		ELSE IF (@dblTotalQtyShipped = @dblTotalQtyOrdered OR @dblTotalQtyShipped > @dblTotalQtyOrdered)
			SET @strOrderStatus = 'Closed'

		UPDATE tblSOSalesOrder
		SET strOrderStatus = @strOrderStatus
			, dtmProcessDate = GETDATE()
			, ysnProcessed   = CASE WHEN @strOrderStatus <> 'Open' THEN 1 ELSE 0 END
			, ysnShipped     = CASE WHEN @strOrderStatus = 'Open' THEN 0 ELSE ysnShipped END
		WHERE intSalesOrderId = @intSOToUpdate

		IF @ysnForDelete = 1 AND @strTransactionType = 'Sales Order' 
			EXEC dbo.uspARAutoBlendSalesOrderItems @intSalesOrderId = @intSOToUpdate, @intUserId = @intUserId, @ysnDelete = 1

		DELETE FROM @tblSOToUpdate WHERE intId = @intSOToUpdate
	END
		
	RETURN;
END