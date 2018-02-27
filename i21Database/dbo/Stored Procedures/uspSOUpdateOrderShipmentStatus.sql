CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	  @intTransactionId			INT
	, @strTransactionType		NVARCHAR(100) = 'Sales Order'
	, @ysnForDelete				BIT = 0
AS
BEGIN

DECLARE @tblSOToUpdate			Id
DECLARE	@strOrderStatus			NVARCHAR(50) = 'Open'	  
	  , @dblTotalQtyOrdered		NUMERIC(18,6) = 0
	  , @dblTotalQtyShipped		NUMERIC(18,6) = 0
	  , @intSalesOrderId		INT = NULL	  

IF @strTransactionType = 'Sales Order' 
	SET @intSalesOrderId = @intTransactionId

IF @strTransactionType = 'Invoice'
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN ISNULL(OTHERITEMS.dblQtyShipped, 0) + CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)))
							 END
		  , @intSalesOrderId = SOD.intSalesOrderId
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		CROSS APPLY (
			SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ID.intItemUOMId), ID.intItemUOMId, SUM(ID.dblQtyShipped)), 0)
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnRecurring = 0 AND I.strType <> 'Software'
			LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
			  AND ID.intInvoiceId = @intTransactionId
			GROUP BY ID.intItemUOMId, UOM.intItemUOMId 
		) INVOICEITEMS
		OUTER APPLY (
			SELECT dblQtyShipped = SUM(ISNULL(ITEMS.dblQtyShipped, 0))
			FROM (

				SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ID.intItemUOMId), ID.intItemUOMId, SUM(ID.dblQtyShipped)), 0)
				FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnRecurring = 0 AND I.strType <> 'Software'
				LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
				  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
				  AND ID.intInvoiceId <> @intTransactionId
				GROUP BY ID.intItemUOMId, UOM.intItemUOMId 

				UNION ALL

				SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ISI.intItemUOMId), ISI.intItemUOMId, SUM(ISI.dblQuantity)), 0)
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
								  THEN ISNULL(OTHERITEMS.dblQuantity, 0) + CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(SHIPPEDITEMS.dblQuantity, 0)))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(SHIPPEDITEMS.dblQuantity, 0)))
							 END
		  , @intSalesOrderId = SOD.intSalesOrderId
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		CROSS APPLY (
			SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ISI.intItemUOMId), ISI.intItemUOMId, SUM(ISI.dblQuantity)), 0)
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
				SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ISI.intItemUOMId), ISI.intItemUOMId, SUM(ISI.dblQuantity)), 0)
				FROM tblICInventoryShipmentItem ISI
				LEFT JOIN tblICItemUOM UOM ON ISI.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ISI.intOrderId, 0) = SOD.intSalesOrderId
				  AND ISNULL(ISI.intLineNo, 0) = SOD.intSalesOrderDetailId
				  AND ISI.intInventoryShipmentId <> @intTransactionId
				GROUP BY ISI.intItemUOMId, UOM.intItemUOMId
			
				UNION ALL
			
				SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ID.intItemUOMId), ID.intItemUOMId, SUM(ID.dblQtyShipped)), 0)
				FROM tblARInvoiceDetail ID
				INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnRecurring = 0 AND I.strType <> 'Software'
				LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
				WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
				  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
				  AND ID.intInvoiceId <> @intTransactionId
				GROUP BY ID.intItemUOMId, UOM.intItemUOMId
			) ITEMS
		) OTHERITEMS
		
		UPDATE tblSOSalesOrder
		SET ysnShipped = CASE WHEN @ysnForDelete = 0 THEN 1 ELSE 0 END
		WHERE intSalesOrderId = @intSalesOrderId
	END
ELSE
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), (ISNULL(INVOICEITEMS.dblQtyShipped, 0) + ISNULL(SHIPPEDITEMS.dblQuantity, 0))))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), (ISNULL(INVOICEITEMS.dblQtyShipped, 0) + ISNULL(SHIPPEDITEMS.dblQuantity, 0))))
							 END		  
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		OUTER APPLY (
			SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ID.intItemUOMId), ID.intItemUOMId, SUM(ID.dblQtyShipped)), 0)
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId AND I.ysnRecurring = 0 AND I.strType <> 'Software'
			LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
			GROUP BY ID.intItemUOMId, UOM.intItemUOMId 
		) INVOICEITEMS
		OUTER APPLY (
			SELECT dblQuantity = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ISI.intItemUOMId), ISI.intItemUOMId, SUM(ISI.dblQuantity)), 0)
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
	END
ELSE
	BEGIN
		INSERT INTO @tblSOToUpdate
		SELECT @intSalesOrderId
	END

WHILE EXISTS (SELECT TOP 1 NULL FROM @tblSOToUpdate)
	BEGIN
		DECLARE @intSOToUpdate INT = NULL		
		DECLARE @ysnShipmentPosted BIT = 0

		SELECT TOP 1 @intSOToUpdate = intId FROM @tblSOToUpdate
		SET @dblTotalQtyOrdered = 0
		SET @dblTotalQtyShipped = 0

		SELECT @dblTotalQtyOrdered = SUM(dblQtyOrdered)
			  ,@dblTotalQtyShipped = SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END)
			  ,@ysnShipmentPosted = [IS].ysnPosted
		FROM tblSOSalesOrderDetail [SOD]
		INNER JOIN tblSOSalesOrder [SO]
			ON [SO].intSalesOrderId = [SOD].intSalesOrderId
		LEFT JOIN tblICInventoryShipment [IS]
			ON [IS].strReferenceNumber = SO.strSalesOrderNumber
		WHERE [SO].intSalesOrderId = @intSOToUpdate
		GROUP BY [SO].intSalesOrderId, [IS].ysnPosted

		IF (@dblTotalQtyShipped = 0)
			SET @strOrderStatus = 'Open'
		ELSE IF @dblTotalQtyShipped < @dblTotalQtyOrdered
			SET @strOrderStatus = 'Partial'
		ELSE IF (@dblTotalQtyShipped = @dblTotalQtyOrdered OR @dblTotalQtyShipped > @dblTotalQtyOrdered) AND @ysnShipmentPosted = 0
			SET @strOrderStatus = 'Pending'
		ELSE IF (@dblTotalQtyShipped = @dblTotalQtyOrdered OR @dblTotalQtyShipped > @dblTotalQtyOrdered) AND @ysnShipmentPosted = 1
			SET @strOrderStatus = 'Closed'

		UPDATE tblSOSalesOrder
		SET strOrderStatus = @strOrderStatus
			, dtmProcessDate = GETDATE()
			, ysnProcessed   = CASE WHEN @strOrderStatus <> 'Open' THEN 1 ELSE 0 END
			, ysnShipped     = CASE WHEN @strOrderStatus = 'Open' THEN 0 ELSE ysnShipped END
		WHERE intSalesOrderId = @intSOToUpdate

		DELETE FROM @tblSOToUpdate WHERE intId = @intSOToUpdate
	END
		
	RETURN;
END