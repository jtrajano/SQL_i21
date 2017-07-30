CREATE FUNCTION [dbo].[fnAPGetPaymentUOM]
(
	@vendorId INT,
	@currency INT
)
RETURNS TABLE
AS
RETURN
SELECT DISTINCT
	uom.intUnitMeasureId
	,uom.strUnitMeasure
FROM tblICItemUOM itemUOM
INNER JOIN tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId
WHERE itemUOM.intItemUOMId IN(
SELECT DISTINCT
	intItemUOMId = CASE WHEN voucherDetail.dblNetWeight > 0
						THEN voucherDetail.intWeightUOMId
						ELSE voucherDetail.intUnitOfMeasureId
					END
FROM tblAPBill voucher
INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency
) 
