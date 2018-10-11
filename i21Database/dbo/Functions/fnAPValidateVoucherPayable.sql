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
	--DO NOT ALLOW ZERO COST

	--DO NOT ALLOW THE intItemId TO BE NULL IF UOM PROVIDED
	SELECT TOP 1
		'Payable id(' + CAST(A.intVoucherPayableId AS NVARCHAR) + ') did not provide an item id.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE NULLIF(A.intItemId,0) IS NULL AND (A.intQtyToBillUOMId > 0 OR A.intOrderUOMId > 0 OR A.intWeightUOMId > 0)
	UNION ALL
	--IF dblTax IS NOT 0, MAKE SURE THAT THEY PROVIDED VoucherDetailTax
	SELECT TOP 1
		'Payable id(' + CAST(A.intVoucherPayableId AS NVARCHAR) + ') did not provide tax data.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE A.dblTax != 0 AND NOT EXISTS (
		SELECT 1 FROM @voucherPayableTax taxes WHERE taxes.intVoucherPayableId = A.intVoucherPayableId
	)
	UNION ALL
	--IF intPartitionId was provided, make sure all payables have values
	SELECT TOP 1
		'Not all payables have intPartitionId provided.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE A.intPartitionId > 0 AND EXISTS (
		SELECT TOP 1 1 FROM @voucherPayables WHERE NULLIF(A.intPartitionId,0) IS NULL
	)
	UNION ALL
	--IF intPartitionId was provided, make sure we can group to these fields and it matched with the partition
	--intEntityVendorId,intTransactionType,intLocationId,intShipToId,intShipFromId,intShipFromEntityId,intPayToAddressId,intCurrencyId,strVendorOrderNumber
	SELECT TOP 1
		'Payables partition provided is invalid. Please check the values.'
		,A.intVoucherPayableId
	FROM @voucherPayables A
	WHERE A.intPartitionId > 0
	AND EXISTS (
		SELECT
			1
		FROM (
			SELECT
				COUNT(*) intTotalHeader
			FROM (
				SELECT
					ROW_NUMBER() OVER(PARTITION BY intEntityVendorId,
												intTransactionType,
												intLocationId,
												intShipToId,
												intShipFromId,
												intShipFromEntityId,
												intPayToAddressId,
												intCurrencyId,
												strVendorOrderNumber,
												strCheckComment,
												intPartitionId
										ORDER BY intLineNo) AS intCountId
				FROM @voucherPayables B
			) voucherHeaders
			WHERE voucherHeaders.intCountId = 1
			GROUP BY voucherHeaders.intCountId
		) totalHeader
		, (
			SELECT 
				COUNT(DISTINCT intPartitionId) intTotalPartition
			FROM @voucherPayables C 
		) totalPartition
		WHERE totalHeader.intTotalHeader != totalPartition.intTotalPartition
	)
	RETURN;

END
