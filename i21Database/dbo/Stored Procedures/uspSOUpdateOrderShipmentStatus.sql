CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	  @intTransactionId			INT
	, @strTransactionType		NVARCHAR(100) = 'Sales Order'
	, @ysnForDelete				BIT = 0
AS
BEGIN

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
								  THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)))
								  ELSE SOD.dblQtyShipped - CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(INVOICEITEMS.dblQtyShipped, 0)))
							 END
		  , @intSalesOrderId = SOD.intSalesOrderId
		FROM tblSOSalesOrderDetail SOD
		LEFT JOIN tblICItemUOM UOM ON SOD.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
		CROSS APPLY (
			SELECT dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ISNULL(UOM.intItemUOMId, ID.intItemUOMId), ID.intItemUOMId, SUM(ID.dblQtyShipped)), 0)
			FROM tblARInvoiceDetail ID
			LEFT JOIN tblICItemUOM UOM ON ID.intItemId = UOM.intItemId AND UOM.ysnStockUnit = 1
			WHERE ISNULL(ID.intSalesOrderDetailId, 0) = SOD.intSalesOrderDetailId
			  AND ISNULL(ID.intInventoryShipmentItemId, 0) = 0
			  AND ID.intInvoiceId = @intTransactionId
			GROUP BY ID.intItemUOMId, UOM.intItemUOMId 
		) INVOICEITEMS
	END
ELSE IF @strTransactionType = 'Inventory'
	BEGIN
		UPDATE SOD
		SET dblQtyShipped  = CASE WHEN @ysnForDelete = 0 
								  THEN CONVERT(NUMERIC(18, 6), dbo.fnCalculateQtyBetweenUOM(SOD.intItemUOMId, ISNULL(UOM.intItemUOMId, SOD.intItemUOMId), ISNULL(SHIPPEDITEMS.dblQuantity, 0)))
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

SELECT @dblTotalQtyOrdered = SUM(dblQtyOrdered)
     , @dblTotalQtyShipped = SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END) 
FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @intSalesOrderId 
GROUP BY intSalesOrderId

IF (@dblTotalQtyShipped = 0)
	SET @strOrderStatus = 'Open'
ELSE IF @dblTotalQtyShipped < @dblTotalQtyOrdered
	SET @strOrderStatus = 'Partial'
ELSE IF @dblTotalQtyShipped = @dblTotalQtyOrdered OR @dblTotalQtyShipped > @dblTotalQtyOrdered
	SET @strOrderStatus = 'Closed'

UPDATE tblSOSalesOrder
SET strOrderStatus = @strOrderStatus
	, dtmProcessDate = GETDATE()
	, ysnProcessed   = CASE WHEN @strOrderStatus <> 'Open' THEN 1 ELSE 0 END
	, ysnShipped     = CASE WHEN @strOrderStatus = 'Open' THEN 0 ELSE ysnShipped END
WHERE intSalesOrderId = @intSalesOrderId
		
	RETURN;
END