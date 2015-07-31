﻿CREATE PROCEDURE [dbo].[uspSOUpdateOrderShipmentStatus]
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
												AND intSourceId = @SalesOrderId
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
					
IF(NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intSourceId = @SalesOrderId) 
		AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ISD
		INNER JOIN tblARInvoice ISH
			ON ISD.intInvoiceId = ISH.intInvoiceId
		INNER JOIN tblSOSalesOrderDetail SOD
			ON ISD.intSalesOrderDetailId = SOD.intSalesOrderDetailId
		WHERE (ISD.[intInventoryShipmentId] IS NULL OR ISD.[intInventoryShipmentId] = 0)			
		  AND (ISD.[intSalesOrderDetailId] IS NOT NULL OR ISD.[intSalesOrderDetailId] <> 0)	
		  AND SOD.intSalesOrderId = @SalesOrderId
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
	dblQtyShipped = SHP.[dblQuantity]
FROM
	(
		SELECT
			 ISD.intSourceId
			,ISD.[intLineNo]
			,SUM(ISNULL((CASE WHEN ISH.[ysnPosted] = 1 THEN ISD.[dblQuantity] ELSE 0.00 END), 0.00))	[dblQuantity]
		FROM
			tblICInventoryShipmentItem ISD
		INNER JOIN
			tblICInventoryShipment ISH
				ON ISD.[intInventoryShipmentId] = ISH.[intInventoryShipmentId]
		WHERE
			ISD.intSourceId = @SalesOrderId
		GROUP BY
			ISD.intSourceId			
			,ISD.[intLineNo]
	) SHP
WHERE
	[intSalesOrderId] = SHP.intSourceId
	AND [intSalesOrderDetailId] = SHP.[intLineNo] 

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
			(ISD.[intInventoryShipmentId] IS NULL OR ISD.[intInventoryShipmentId] = 0)			
			AND (ISD.[intSalesOrderDetailId] IS NOT NULL OR ISD.[intSalesOrderDetailId] <> 0)			
		GROUP BY
			ISD.[intSalesOrderDetailId]
	) SHP
WHERE
	[intSalesOrderId] = @SalesOrderId
	AND tblSOSalesOrderDetail.[intSalesOrderDetailId] = SHP.[intSalesOrderDetailId]
	AND NOT EXISTS(SELECT NULL FROM tblICInventoryShipmentItem WHERE intLineNo = tblSOSalesOrderDetail.[intSalesOrderDetailId]) 		
	
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
	WHERE [intSalesOrderId] = @SalesOrderId
		
	RETURN;		
END