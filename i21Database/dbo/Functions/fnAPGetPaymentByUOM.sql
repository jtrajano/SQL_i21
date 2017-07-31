CREATE FUNCTION [dbo].[fnAPGetPaymentByUOM]
(
	@vendorId INT,
	@currency INT,
	@unitMeasureId INT,
	@quantity DECIMAL(18,6),
	@paymentId INT = NULL
)
RETURNS @returnTable TABLE(
	intBillId INT PRIMARY KEY,
	dblPayment DECIMAL(18,2)
)
AS
BEGIN

	DECLARE @billId INT;
	DECLARE @convertedQty DECIMAL(18,2);
	DECLARE @amountToPay DECIMAL(18,6);
	DECLARE @qtyToPay DECIMAL(18,6);
	DECLARE @convertedDetailCostFromPaymentUOM DECIMAL(18,6);
	DECLARE @convertedQtyToPaymentUOM DECIMAL(18,6);
	DECLARE @remainingQty DECIMAL(18, 6);
	DECLARE @voucherDetailPayment TABLE(intBillId INT, dblPayment DECIMAL(18,2));

	DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
	WITH voucherDetails (
		intBillId
		,intBillDetailId
		,dtmDueDate
		,intVoucherDetailItemUOMId
		,intPaymentItemUOMId
		,dblVoucherDetailCost
		,dblQuantityToPay
		,dblAmountToPay
		,dblVoucherDetailQty
	) AS (
		SELECT
			intBIllId = voucher.intBillId
			,voucherDetail.intBillDetailId
			,dtmDueDate =voucher.dtmDueDate
			,intVoucherDetailItemUOMId = CASE WHEN voucherDetail.intWeightUOMId > 0 
										THEN voucherDetail.intWeightUOMId 
										ELSE voucherDetail.intUnitOfMeasureId END
			,intPaymentItemUOMId = paymentItemUOM.intItemUOMId
			,dblVoucherDetailCost = voucherDetail.dblCost
			,dblQtyToPay = @quantity
			,dblAmountToPay = voucherDetail.dblTotal
			,dblVoucherDetailQty = CASE WHEN voucherDetail.dblNetWeight > 0 THEN voucherDetail.dblNetWeight ELSE voucherDetail.dblQtyReceived END
		FROM tblAPBill voucher 
		INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
		LEFT JOIN tblICItemUOM paymentItemUOM ON voucherDetail.intItemId = paymentItemUOM.intItemId AND paymentItemUOM.intUnitMeasureId = @unitMeasureId
		WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency 
		AND voucherDetail.intUnitOfMeasureId > 0 --get only those have UOM
	)
	SELECT
		voucherDetailsUOM.intBillId
		,voucherDetailsUOM.dblQuantityToPay
		,voucherDetailsUOM.dblAmountToPay
		,dbo.fnCalculateQtyBetweenUOM(voucherDetailsUOM.intVoucherDetailItemUOMId, intPaymentItemUOMId, dblVoucherDetailQty)
		,dbo.fnCalculateCostBetweenUOM(intPaymentItemUOMId, voucherDetailsUOM.intVoucherDetailItemUOMId, dblVoucherDetailCost)
	FROM voucherDetails voucherDetailsUOM
	ORDER BY voucherDetailsUOM.dtmDueDate DESC

	OPEN c;

	FETCH c INTO @billId, @qtyToPay, @amountToPay, @convertedQtyToPaymentUOM, @convertedDetailCostFromPaymentUOM;

	WHILE @@FETCH_STATUS = 0 AND @remainingQty != 0
	BEGIN
		IF @convertedQty <= @qtyToPay
		BEGIN
			INSERT INTO @voucherDetailPayment
			SELECT @billId, @amountToPay --pay to whole total of voucher detail
			SET @remainingQty = @remainingQty - @convertedQtyToPaymentUOM
		END
		ELSE
		BEGIN
			INSERT INTO @voucherDetailPayment
			SELECT @billId, CAST(@convertedDetailCostFromPaymentUOM * @remainingQty AS DECIMAL(18,2)) --pay the remaining available qty
			SET @remainingQty = 0
		END
		FETCH c INTO @billId, @qtyToPay, @amountToPay, @convertedQty;;
	END

	CLOSE c; DEALLOCATE c;

	INSERT INTO @returnTable
	SELECT
		intBillId
		,CAST(SUM(dblPayment) AS DECIMAL(18,2))
	FROM @voucherDetailPayment 
	GROUP BY intBillId

	RETURN;
END 