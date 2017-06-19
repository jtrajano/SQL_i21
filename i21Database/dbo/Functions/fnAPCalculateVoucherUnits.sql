CREATE FUNCTION [dbo].[fnAPCalculateVoucherUnits]
(
	@billId INT
)
RETURNS @returnTable TABLE(dblTotalUnits DECIMAL(18,6))
AS
BEGIN

	INSERT INTO @returnTable
	SELECT
		SUM(CASE WHEN item.intItemId IS NULL THEN billDetails.dblQtyReceived ELSE
									dbo.fnCalculateQtyBetweenUOM(CASE WHEN billDetails.intWeightUOMId > 0 
											THEN billDetails.intWeightUOMId ELSE billDetails.intUnitOfMeasureId 
									END, 
									itemUOM.intItemUOMId, CASE WHEN billDetails.intWeightUOMId > 0 THEN billDetails.dblNetWeight ELSE billDetails.dblQtyReceived END)
				END)
	FROM tblAPBillDetail billDetails
	LEFT JOIN tblICItem item ON billDetails.intItemId = item.intItemId
	LEFT JOIN tblICItemUOM itemUOM ON item.intItemId = itemUOM.intItemId AND itemUOM.ysnStockUnit = 1
	WHERE billDetails.intBillId = @billId

	RETURN;
END
