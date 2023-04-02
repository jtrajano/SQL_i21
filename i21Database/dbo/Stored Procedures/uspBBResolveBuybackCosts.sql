CREATE PROCEDURE [dbo].uspBBResolveBuybackCosts (@strBuybackIds NVARCHAR(MAX))
AS
BEGIN

    DECLARE @Ids TABLE (intBuybackId INT)
    INSERT INTO @Ids
    SELECT intID
    FROM dbo.fnGetRowsFromDelimitedValues(@strBuybackIds)

    UPDATE bbd
    SET 
        bbd.dblBuybackRate = CASE WHEN bc.intBuybackChargeId IS NOT NULL THEN bbd.dblBuybackRate ELSE COALESCE(NULLIF(dbo.fnBBGetItemCostByCostType(vs.strCostType, i.intItemId, il.intItemLocationId, ivd.intItemUOMId, iv.dtmDate), 0), NULLIF(ip.dblLastCost, 0), ip.dblStandardCost) END,
        bbd.dblReimbursementAmount = dbo.fnCalculateQtyBetweenUOM(iu.intItemUOMId, su.intItemUOMId, CASE WHEN bc.intBuybackChargeId IS NOT NULL THEN bbd.dblBuybackRate ELSE COALESCE(NULLIF(dbo.fnBBGetItemCostByCostType(vs.strCostType, i.intItemId, il.intItemLocationId, ivd.intItemUOMId, iv.dtmDate), 0), NULLIF(ip.dblLastCost, 0), ip.dblStandardCost) END * bbd.dblBuybackQuantity)
    FROM tblBBBuybackDetail bbd
    JOIN tblBBBuyback bb ON bb.intBuybackId = bbd.intBuybackId
    JOIN @Ids id ON id.intBuybackId = bb.intBuybackId
    OUTER APPLY (
        SELECT TOP 1 xvs.intVendorSetupId, xvs.strCostType
        FROM tblVRVendorSetup xvs
        WHERE xvs.intEntityId = bb.intEntityId
    ) vs
    JOIN tblARInvoiceDetail ivd ON ivd.intInvoiceDetailId = bbd.intInvoiceDetailId
    JOIN tblARInvoice iv ON iv.intInvoiceId = ivd.intInvoiceId
    JOIN tblICItem i ON i.intItemId = ivd.intItemId
    LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = ivd.intItemUOMId
	LEFT JOIN tblICItemUOM su ON su.intItemId = ivd.intItemId
		AND su.ysnStockUnit = 1
    JOIN tblICItemLocation il ON il.intLocationId = iv.intCompanyLocationId
        AND il.intItemId = i.intItemId
    LEFT JOIN tblICItemPricing ip ON ip.intItemId = i.intItemId
        AND ip.intItemLocationId = il.intItemLocationId
    LEFT JOIN tblBBBuybackCharge bc ON bc.intBuybackId = bb.intBuybackId
        AND bc.strCharge = bbd.strCharge

	UPDATE bb
	SET bb.dblReimbursementAmount = (SELECT SUM(bbd.dblReimbursementAmount) FROM tblBBBuybackDetail bbd WHERE bb.intBuybackId = bbd.intBuybackId)
	FROM tblBBBuyback bb 
    JOIN @Ids id ON id.intBuybackId = bb.intBuybackId

END

