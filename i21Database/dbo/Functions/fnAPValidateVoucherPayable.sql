CREATE FUNCTION [dbo].[fnAPValidateVoucherPayable]
(
	@voucherPayables AS VoucherPayable READONLY,
	@voucherPayableTax AS VoucherDetailTax READONLY
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
	UNION ALL
	--IF dblTax IS NOT 0, MAKE SURE THAT THEY PROVIDED VoucherDetailTax
	SELECT
		'Payable id(' + CAST(A.intVoucherPayableId AS NVARCHAR) + ') did not provide tax data.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE A.dblTax != 0 AND NOT EXISTS (
		SELECT 1 FROM @voucherPayableTax taxes WHERE taxes.intVoucherPayableId = A.intVoucherPayableId
	)
	

	RETURN;

END
