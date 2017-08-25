CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceAdditionalCostReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intInvoiceId INT

	SET @intInvoiceId = @xmlParam

	SELECT
		Inv.intLoadId,
		InvDet.intItemId,
		strItemDescription = Item.strDescription,
		dblAmount = InvDet.dblTotal,
		InvCur.strCurrency
	FROM tblARInvoice Inv
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId 
		AND InvDet.intItemId NOT IN (SELECT IsNull(SC.intCostType, 0) FROM tblLGLoadStorageCost SC WHERE SC.intLoadId=Inv.intLoadId)
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	WHERE Inv.intInvoiceId = @intInvoiceId AND Item.strType = 'Other Charge'
END
