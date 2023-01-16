CREATE PROCEDURE [dbo].[uspTMReceived]
	  @intReceiptId INT
    , @ysnPost BIT
	, @intUserId INT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Update consumption site's delivery details
UPDATE tcs
SET   tcs.dblLastDeliveredGal = CASE ISNULL(@ysnPost, 0) WHEN 1 THEN ISNULL(tcs.dblLastDeliveredGal, 0) + iri.dblOpenReceive ELSE ISNULL(tcs.dblLastDeliveredGal, 0) - iri.dblOpenReceive END
    , tcs.dtmLastDeliveryDate = CASE ISNULL(@ysnPost, 0) WHEN 1 THEN ir.dtmReceiptDate ELSE cs.dtmLastDeliveryDate END
    , tcs.intConcurrencyId = ISNULL(tcs.intConcurrencyId, 0) + 1
FROM tblICInventoryReceipt ir
JOIN tblICInventoryReceiptItem iri ON iri.intInventoryReceiptId = ir.intInventoryReceiptId
JOIN vyuTMCompanyConsumptionSite cs ON cs.intCompanyLocationId = ir.intLocationId
    AND cs.ysnActive = 1
    AND cs.intItemId = iri.intItemId
    AND cs.intCompanyLocationSubLocationId = iri.intSubLocationId
JOIN tblTMSite tcs ON tcs.intSiteID = cs.intSiteID
where ir.intInventoryReceiptId = @intReceiptId

END 