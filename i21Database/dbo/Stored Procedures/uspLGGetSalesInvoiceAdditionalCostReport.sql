CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceAdditionalCostReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intInvoiceId INT

	SET @intInvoiceId = @xmlParam

	    SELECT 
		strItemDescription = WS.strActivity,
		dblAmount = WS.dblBillAmount,
		InvCur.strCurrency
	FROM tblARInvoice Inv
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	JOIN tblLGLoad L ON L.intLoadId = Inv.intLoadId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	LEFT JOIN tblLGLoadWarehouseServices WS ON WS.intLoadWarehouseId = LW.intLoadWarehouseId
	WHERE Inv.intInvoiceId = @intInvoiceId AND WS.dblBillAmount > 0.00

	UNION ALL

	SELECT 
		strItemDescription = Item.strDescription,
		dblAmount = LC.dblAmount,
		InvCur.strCurrency
	FROM tblARInvoice Inv
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	JOIN tblLGLoad L ON L.intLoadId = Inv.intLoadId
	JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId AND LC.strEntityType='Customer'
	JOIN tblICItem Item on Item.intItemId = LC.intItemId
	WHERE Inv.intInvoiceId = @intInvoiceId AND LC.dblAmount > 0.0
END