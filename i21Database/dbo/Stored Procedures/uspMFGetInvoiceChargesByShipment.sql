CREATE PROCEDURE [dbo].[uspMFGetInvoiceChargesByShipment]
	@intInventoryShipmentItemId int,
	@intSalesOrderId int
AS

Select 
	 MFG.intItemId
	,MFG.strItemNo
	,MFG.strDescription
	,MFG.dblPrice
	,MFG.dblLineTotal 
From 
	[dbo].[fnGetMFGetInvoiceChargesByShipment](@intInventoryShipmentItemId,@intSalesOrderId) MFG