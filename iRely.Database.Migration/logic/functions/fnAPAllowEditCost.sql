--liquibase formatted sql

-- changeset Von:fnAPAllowEditCost.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPAllowEditCost]
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
			@allowed = CASE WHEN ysnInventoryCost = 1 THEN 1 ELSE 0 END
		FROM tblICInventoryReceiptCharge A
		WHERE intInventoryReceiptChargeId = @inventoryChargeId
	END

	RETURN @allowed;
END



