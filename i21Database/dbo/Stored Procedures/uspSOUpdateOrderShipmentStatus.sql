CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	@SalesOrderId			INT,
	@ysnOpenStatus			BIT = 0,
	@ForDelete				BIT = 0
AS
BEGIN

DECLARE	@OrderStatus NVARCHAR(50)
SET @OrderStatus = 'Open'

IF @ysnOpenStatus = 1
	BEGIN		
		GOTO SET_ORDER_STATUS;
	END	

DECLARE @IsOpen BIT = 0
SET @IsOpen = (	SELECT COUNT(1) 
					FROM
						tblSOSalesOrderDetail					
					WHERE
						[intSalesOrderId] = @SalesOrderId 
						AND (NOT EXISTS(	SELECT NULL 
											FROM
												tblICInventoryShipmentItem
											WHERE
												intLineNo = tblSOSalesOrderDetail.[intSalesOrderDetailId]
												AND intOrderId = @SalesOrderId
											)
							AND
							EXISTS(			SELECT NULL 
											FROM 
												tblICItem 
											WHERE
												tblICItem.[intItemId] = tblSOSalesOrderDetail.[intSalesOrderDetailId]
												AND ISNULL(tblICItem.strLotTracking, 'No') <> 'No'
											)
						)
						AND (NOT EXISTS(	SELECT NULL 
										FROM
											tblARInvoiceDetail 
										WHERE
											intSalesOrderDetailId = tblSOSalesOrderDetail.intSalesOrderDetailId
										)
							AND
							EXISTS(			SELECT NULL 
											FROM 
												tblICItem 
											WHERE
												tblICItem.[intItemId] = tblSOSalesOrderDetail.[intSalesOrderDetailId]												
												AND ISNULL(tblICItem.strLotTracking, 'No') = 'No'
											)										
						)										
					)
					
IF(NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem ISHI 
					INNER JOIN tblICInventoryShipment ISH
						ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId
					INNER JOIN tblSOSalesOrderDetail SOD
						ON ISHI.intLineNo = SOD.intSalesOrderDetailId
				WHERE SOD.intSalesOrderId = @SalesOrderId) 
AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ISD
					INNER JOIN tblARInvoice ISH
						ON ISD.intInvoiceId = ISH.intInvoiceId
					INNER JOIN tblSOSalesOrderDetail SOD
						ON ISD.intSalesOrderDetailId = SOD.intSalesOrderDetailId
					WHERE SOD.intSalesOrderId = @SalesOrderId
					  AND ISNULL(ISD.[intSalesOrderDetailId], 0) <> 0	
		GROUP BY
			ISD.[intSalesOrderDetailId]))
	SET @IsOpen = 1
					
IF @IsOpen <> 0
	BEGIN
		SET @OrderStatus = 'Open'
		GOTO SET_ORDER_STATUS;
	END					
	
UPDATE
	tblSOSalesOrderDetail
SET
	dblQtyShipped = ISNULL(SHP.[dblQuantity], 0.00)
FROM
	(
		SELECT SOD.intSalesOrderDetailId
			 , dblQuantity			= SUM(ISNULL(CASE WHEN ID.intItemUOMId IS NOT NULL AND SOD.intItemUOMId IS NOT NULL THEN ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, SOD.intItemUOMId, ISNULL(ID.dblQtyShipped,0)), ISNULL(ID.dblQtyShipped,0)) ELSE ISNULL(ID.dblQtyShipped,0) END, 0)) + SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(ISHI.intItemUOMId, SOD.intItemUOMId, ISNULL(ISHI.dblQuantity,0)), 0))			 
		FROM tblSOSalesOrderDetail SOD
			LEFT JOIN (SELECT ID.intSalesOrderDetailId
							, ID.intItemUOMId
							, dblQtyShipped	= CASE WHEN ISNULL(ISHI.dblQuantity, 0) = 0 THEN ID.dblQtyShipped ELSE ID.dblQtyShipped - ISNULL(ISHI.dblQuantity, 0) END
						FROM tblARInvoiceDetail ID 
								INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
								LEFT JOIN (tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH 
											ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId)
												ON ISHI.intLineNo = ID.intSalesOrderDetailId
							) ID
				ON SOD.intSalesOrderDetailId = ID.intSalesOrderDetailId
			LEFT JOIN (tblICInventoryShipmentItem ISHI INNER JOIN tblICInventoryShipment ISH 
							ON ISHI.intInventoryShipmentId = ISH.intInventoryShipmentId)
				ON SOD.intSalesOrderDetailId = ISHI.intLineNo AND SOD.intSalesOrderId = ISHI.intOrderId
		WHERE SOD.dblQtyOrdered > 0
		GROUP BY SOD.intSalesOrderDetailId
	) SHP
WHERE
	[intSalesOrderId] = @SalesOrderId
	AND tblSOSalesOrderDetail.[intSalesOrderDetailId] = SHP.[intSalesOrderDetailId]
	
DECLARE @TotalQtyOrdered	NUMERIC(18,6) = 0,
		@TotalQtyShipped	NUMERIC(18,6) = 0

SELECT @TotalQtyOrdered = SUM(dblQtyOrdered)
     , @TotalQtyShipped = SUM(CASE WHEN dblQtyShipped > dblQtyOrdered THEN dblQtyOrdered ELSE dblQtyShipped END) 
FROM tblSOSalesOrderDetail WHERE intSalesOrderId = @SalesOrderId 
GROUP BY intSalesOrderId

IF (@TotalQtyShipped = 0)
	BEGIN
		SET @OrderStatus = 'Pending'
		GOTO SET_ORDER_STATUS;
	END	

IF (@TotalQtyShipped < @TotalQtyOrdered)
	BEGIN
		SET @OrderStatus = 'Partial'
		GOTO SET_ORDER_STATUS;
	END	
		
SET @OrderStatus = 'Closed'
		
SET_ORDER_STATUS:	
	UPDATE tblSOSalesOrder
	SET [strOrderStatus] = @OrderStatus
	  , [dtmProcessDate] = GETDATE()
	  , [ysnProcessed]   = CASE WHEN @OrderStatus <> 'Open' THEN 1 ELSE 0 END
	  , [ysnShipped]     = CASE WHEN @OrderStatus = 'Open' THEN 0 ELSE ysnShipped END
	WHERE [intSalesOrderId] = @SalesOrderId
		
	RETURN;
END