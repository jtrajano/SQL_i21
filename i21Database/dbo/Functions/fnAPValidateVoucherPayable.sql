CREATE FUNCTION [dbo].[fnAPValidateVoucherPayable]
(
	@voucherPayables AS VoucherPayable READONLY
)
RETURNS @returnTable TABLE
(
	intVoucherPayableId INT,
	strError NVARCHAR(1000)
)
AS
BEGIN

	INSERT INTO @returnTable
	--DO NOT ALLOW THE intItemId TO BE NULL IF UOM PROVIDED
	SELECT
		'Payable id(' + CAST(A.intVoucherPayableId AS NVARCHAR) + ') did not provide an item id.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE NULLIF(A.intItemId,0) IS NULL AND (A.intQtyToBillUOMId > 0 OR A.intOrderUOMId > 0 OR A.intWeightUOMId > 0)

	RETURN;

END
