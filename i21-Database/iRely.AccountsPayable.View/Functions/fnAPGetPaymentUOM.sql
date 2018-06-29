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
WHERE itemUOM.intItemId IN(
	SELECT DISTINCT
		voucherDetail.intItemId
	FROM tblAPBill voucher
	INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
	WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency
	AND voucherDetail.intItemId > 0
	AND voucher.ysnPosted = 1
	AND voucher.dblAmountDue != 0
) 
