CREATE PROCEDURE [dbo].[uspAPRefreshClearing]
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

INSERT INTO tblAPForClearing
(
	[intInventoryReceiptItemId]		
	,[intInventoryReceiptChargeId]	
	,[intInventoryShipmentChargeId]	
	,[intLoadShipmentDetailId]		
	,[intCustomerStorageId]			
	,[intItemId]
)
SELECT
	[intInventoryReceiptItemId]			=	A.[intInventoryReceiptItemId]	
	,[intInventoryReceiptChargeId]		=	A.[intInventoryReceiptChargeId]
	,[intInventoryShipmentChargeId]		=	A.[intInventoryShipmentChargeId]
	,[intLoadShipmentDetailId]			=	A.[intLoadDetailId]
	,[intCustomerStorageId]				=	A.[intCustomerStorageId]
	,[intItemId]						=	A.[intItemId]
FROM vyuAPForClearing A

RETURN 0
