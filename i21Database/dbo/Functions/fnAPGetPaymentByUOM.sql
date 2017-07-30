CREATE FUNCTION [dbo].[fnAPGetPaymentByUOM]
(
	@vendorId INT,
	@currency INT,
	@unitMeasureId INT,
	@quantity DECIMAL(18,6)
)
RETURNS @returnTable TABLE(
	intBillId INT PRIMARY KEY,
	dblPayment DECIMAL(18,6)
)
AS
BEGIN

	WITH voucherDetails (
		intBillId
		,intBillDetailId
		,dtmDueDate
		,intVoucherDetailItemUOMId
		,dblQuantityToPay
	) AS (
		SELECT
			intBIllId = voucher.intBillId
			,voucherDetail.intBillDetailId
			,dtmDueDate =voucher.dtmDueDate
			,intVoucherDetailItemUOMId = CASE WHEN voucherDetail.intWeightUOMId > 0 
										THEN voucherDetail.intWeightUOMId 
										ELSE voucherDetail.intUnitOfMeasureId END
			,CASE WHEN itemUOMQty.intUnitMeasureId IS NOT NULL THEN uomQty.intUnitMeasureId
						WHEN itemUOMNetWeight.intUnitMeasureId IS NOT NULL THEN uomNetWeight.intUnitMeasureId
						ELSE NULL END
			,CASE WHEN voucherDetail.dblNetWeight > 0 THEN voucherDetail.dblNetWeight ELSE voucherDetail.dblQtyReceived END
		FROM tblAPBill voucher 
		INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
		LEFT JOIN (tblICItemUOM itemUOMQty INNER JOIN tblICUnitMeasure uomQty 
											ON itemUOMQty.intUnitMeasureId = uomQty.intUnitMeasureId)
			ON itemUOMQty.intItemUOMId = voucherDetail.intUnitOfMeasureId
		LEFT JOIN (tblICItemUOM itemUOMNetWeight INNER JOIN tblICUnitMeasure uomNetWeight
											ON itemUOMNetWeight.intUnitMeasureId = uomNetWeight.intUnitMeasureId) 
			ON itemUOMNetWeight.intItemUOMId = voucherDetail.intWeightUOMId 
		WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency 
		AND voucherDetail.intUnitOfMeasureId > 0
		AND (uomQty.intUnitMeasureId = @unitMeasureId OR uomNetWeight.intUnitMeasureId = @unitMeasureId)
	)

	SELECT
		*
	FROM voucherDetails voucherDetailsUOM
	GROUP BY voucherDetailsUOM.intBillId
	ORDER BY voucherDetailsUOM.dtmDueDate DESC

	RETURN;
END 