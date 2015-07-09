CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
	@SalesOrderId			INT
AS
BEGIN

DECLARE	@OrderStatus NVARCHAR(50)
SET @OrderStatus = 'Open'

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
												AND tblICItem.strType IN ('Inventory')
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
												AND tblICItem.strType NOT IN ('Inventory')
											)										
						)										
					)
					
IF(NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intOrderId = @SalesOrderId))
	SET @IsOpen = 1
					
IF @IsOpen <> 0
	BEGIN
		SET @OrderStatus = 'Open'
		GOTO SET_ORDER_STATUS;
	END					
					
					
DECLARE @HasShipment BIT = 0
SET @HasShipment = (	SELECT COUNT(1) 
						FROM
							tblSOSalesOrderDetail
						WHERE
							[intSalesOrderId] = @SalesOrderId 
							AND EXISTS(	SELECT NULL 
										FROM
											tblICInventoryShipmentItem
										WHERE
											intLineNo = tblSOSalesOrderDetail.intSalesOrderDetailId
											AND intOrderId = @SalesOrderId
										)
						)					
					

UPDATE
	tblSOSalesOrderDetail
SET
	dblQtyShipped = SHP.[dblQuantity]
FROM
	(
		SELECT
			 ISD.[intOrderId]
			,ISD.[intLineNo]
			,SUM(ISNULL((CASE WHEN ISH.[ysnPosted] = 1 THEN ISD.[dblQuantity] ELSE 0.00 END), 0.00))	[dblQuantity]
		FROM
			tblICInventoryShipmentItem ISD
		INNER JOIN
			tblICInventoryShipment ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		WHERE
			ISD.[intOrderId] = @SalesOrderId
		GROUP BY
			ISD.[intOrderId]			
			,ISD.[intLineNo]
	) SHP
WHERE
	[intSalesOrderId] = SHP.[intOrderId]
	AND [intSalesOrderDetailId] = SHP.[intLineNo] 


DECLARE @HasMiscItemInInvoice BIT = 0
SET @HasMiscItemInInvoice = (	SELECT COUNT(1) 
								FROM
									tblSOSalesOrderDetail
								WHERE
									[intSalesOrderId] = @SalesOrderId 
									AND EXISTS(	SELECT NULL 
												FROM
													tblARInvoiceDetail
												WHERE
													[intSalesOrderDetailId] = tblSOSalesOrderDetail.[intSalesOrderDetailId]
													AND (intInventoryShipmentItemId IS NULL OR intInventoryShipmentItemId = 0)
												)
									AND NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intLineNo = tblSOSalesOrderDetail.[intSalesOrderDetailId])
								)
								
UPDATE
	tblSOSalesOrderDetail
SET
	dblQtyShipped = SHP.[dblQuantity]
FROM
	(
		SELECT
			 ISD.[intSalesOrderDetailId]
			,SUM(ISNULL((CASE WHEN ISH.[ysnPosted] = 1 THEN ISD.[dblQtyShipped] ELSE 0.00 END), 0.00))	[dblQuantity]
		FROM
			tblARInvoiceDetail ISD
		INNER JOIN
			tblARInvoice ISH
				ON ISD.[intInvoiceId] = ISH.[intInvoiceId]
		WHERE
			(ISD.[intInventoryShipmentItemId] IS NULL OR ISD.[intInventoryShipmentItemId] = 0)			
			AND (ISD.[intSalesOrderDetailId] IS NOT NULL OR ISD.[intSalesOrderDetailId] <> 0)			
		GROUP BY
			ISD.[intSalesOrderDetailId]
	) SHP
WHERE
	[intSalesOrderId] = @SalesOrderId
	AND tblSOSalesOrderDetail.[intSalesOrderDetailId] = SHP.[intSalesOrderDetailId]
	AND NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intLineNo = tblSOSalesOrderDetail.[intSalesOrderDetailId]) 		
		
		

DECLARE	@PartialShipmentCount		INT
		,@CompletedShipmentCount	INT
	
SELECT	@PartialShipmentCount		= 0
		,@CompletedShipmentCount	= 0
			

SET @PartialShipmentCount = (	SELECT COUNT(1) 
								FROM
									tblSOSalesOrderDetail
								WHERE
									[intSalesOrderId] = @SalesOrderId 
									AND ISNULL([dblQtyShipped],0.00) < ISNULL([dblQtyOrdered],0.00)
									AND ISNULL([dblQtyShipped],0.00) <> ISNULL([dblQtyOrdered],0.00)
									AND ISNULL([dblQtyOrdered],0.00) > 0
									AND ISNULL([dblQtyShipped],0.00) > 0
								)		

SET @CompletedShipmentCount = (	SELECT COUNT(1) 
								FROM
									tblSOSalesOrderDetail
								WHERE
									[intSalesOrderId] = @SalesOrderId 
									AND ISNULL([dblQtyShipped],0.00) >= ISNULL([dblQtyOrdered],0.00)									
								)										
		
IF ((@HasShipment <> 0 OR @HasMiscItemInInvoice <> 0) AND @PartialShipmentCount = 0 AND @CompletedShipmentCount = 0)
	BEGIN
		SET @OrderStatus = 'Pending'
		GOTO SET_ORDER_STATUS;
	END	
	
IF ((@HasShipment <> 0 OR @HasMiscItemInInvoice <> 0) AND (@PartialShipmentCount >= @CompletedShipmentCount))
	BEGIN
		SET @OrderStatus = 'Partial'
		GOTO SET_ORDER_STATUS;
	END	

	
SET @OrderStatus = 'Closed'

		

		
SET_ORDER_STATUS:
	UPDATE
		tblSOSalesOrder
	SET
		[strOrderStatus] = @OrderStatus
	WHERE
		[intSalesOrderId] = @SalesOrderId
		
	RETURN;		
	

END