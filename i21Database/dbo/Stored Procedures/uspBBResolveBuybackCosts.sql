CREATE PROCEDURE [dbo].uspBBResolveBuybackCosts (@strBuybackIds NVARCHAR(MAX))
AS
BEGIN
    DECLARE @Ids TABLE (intBuybackId INT)
    
    INSERT INTO @Ids
    SELECT intID
    FROM dbo.fnGetRowsFromDelimitedValues(@strBuybackIds)

    UPDATE bbd
    SET 
        bbd.dblBuybackRate = CASE WHEN bc.intBuybackChargeId IS NOT NULL THEN bbd.dblBuybackRate ELSE dbo.fnBBGetItemCostByCostType(vs.strCostType, i.intItemId, il.intItemLocationId, ivd.intItemUOMId, iv.dtmDate) END,
        bbd.dblReimbursementAmount = CASE WHEN bc.intBuybackChargeId IS NOT NULL THEN bbd.dblBuybackRate ELSE dbo.fnBBGetItemCostByCostType(vs.strCostType, i.intItemId, il.intItemLocationId, ivd.intItemUOMId, iv.dtmDate) END * bbd.dblBuybackQuantity
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
    JOIN tblICItemLocation il ON il.intLocationId = iv.intCompanyLocationId
        AND il.intItemId = i.intItemId
    LEFT JOIN tblBBBuybackCharge bc ON bc.intBuybackId = bb.intBuybackId
        AND bc.strCharge = bbd.strCharge

END