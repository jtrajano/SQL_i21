CREATE FUNCTION [dbo].[fnAPAllowEditCost]
(
	@inventoryChargeId INT = NULL
)
RETURNS BIT
AS
BEGIN
	DECLARE @allowed BIT = 1;

	IF @inventoryChargeId > 0
	BEGIN
		SELECT
			@allowed = CASE WHEN ysnInventoryCost = 0 THEN 1 ELSE 0 END
		FROM tblICInventoryReceiptCharge A
		WHERE intInventoryReceiptChargeId = @inventoryChargeId
	END

	RETURN @allowed;
END
