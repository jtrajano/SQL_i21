CREATE FUNCTION [dbo].[fnAPGetPaymentByUOM]
(
	@vendorId INT,
	@currency INT,
	@unitMeasureId INT,
	@quantity DECIMAL(18,6),
	@paymentId INT = NULL
)
RETURNS @returnTable TABLE(
	intBillId INT,
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
	DECLARE @remainingQty DECIMAL(18, 6) = @quantity;
	DECLARE @rate DECIMAL(18,6) = 1;
	DECLARE @subCurrency BIT;
	DECLARE @paymentUOM INT, @voucherDetailUOM INT, @costUOM INT;
	DECLARE @voucherDetailPayment TABLE(intBillId INT, dblPayment DECIMAL(18,2));
	DECLARE @remainingInVoucherDetailUOM DECIMAL(18,6);

	DECLARE c CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY
	FOR
	WITH voucherDetails (
		intBillId
		,intBillDetailId
		,dtmDueDate
		,intVoucherDetailItemUOMId
		,intPaymentItemUOMId
		,intCostUOMId
		,ysnSubCurrency
		,dblRate
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
			,voucherDetail.intCostUOMId
			,voucherDetail.ysnSubCurrency
			,voucherDetail.dblRate
			,dblVoucherDetailCost = voucherDetail.dblCost
			,dblQtyToPay = @quantity
			,dblAmountToPay = voucherDetail.dblTotal
			,dblVoucherDetailQty = CASE WHEN voucherDetail.dblNetWeight > 0 THEN voucherDetail.dblNetWeight ELSE voucherDetail.dblQtyReceived END
		FROM tblAPBill voucher 
		INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
		INNER JOIN tblICItemUOM paymentItemUOM ON voucherDetail.intItemId = paymentItemUOM.intItemId AND paymentItemUOM.intUnitMeasureId = @unitMeasureId --it should have conversion unit setup
		WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency 
		AND voucherDetail.intUnitOfMeasureId > 0 --get only those have UOM
		AND voucher.ysnPosted = 1
		AND voucher.dblAmountDue != 0
		AND voucher.intBillId IN (CASE WHEN @paymentId > 0  --if it has payment, calculte only on the payment detail records
										THEN (SELECT intBillId FROM tblAPPaymentDetail WHERE intPaymentId = @paymentId) 
									ELSE voucher.intBillId END)
			)
	SELECT
		voucherDetailsUOM.intBillId
		,voucherDetailsUOM.dblQuantityToPay
		,voucherDetailsUOM.dblAmountToPay
		,voucherDetailsUOM.intPaymentItemUOMId
		,voucherDetailsUOM.intVoucherDetailItemUOMId
		,voucherDetailsUOM.intCostUOMId
		,voucherDetailsUOM.ysnSubCurrency
		,voucherDetailsUOM.dblRate
		,dbo.fnCalculateQtyBetweenUOM(voucherDetailsUOM.intVoucherDetailItemUOMId, intPaymentItemUOMId, dblVoucherDetailQty)
		,dblVoucherDetailCost--dbo.fnCalculateCostBetweenUOM(intPaymentItemUOMId, voucherDetailsUOM.intVoucherDetailItemUOMId, dblVoucherDetailCost)
	FROM voucherDetails voucherDetailsUOM
	ORDER BY voucherDetailsUOM.dtmDueDate DESC

	OPEN c;

	FETCH c INTO @billId, @qtyToPay, @amountToPay, @paymentUOM, @voucherDetailUOM, @costUOM, @subCurrency, @rate, @convertedQtyToPaymentUOM, @convertedDetailCostFromPaymentUOM;

	WHILE @@FETCH_STATUS = 0 AND @remainingQty != 0
	BEGIN
		IF @convertedQtyToPaymentUOM <= @qtyToPay
		BEGIN
			INSERT INTO @voucherDetailPayment
			SELECT @billId, @amountToPay --pay to whole total of voucher detail
			SET @remainingQty = @remainingQty - @convertedQtyToPaymentUOM
		END
		ELSE
		BEGIN
			--CONVERT PAYMENT QTY UOM TO VOUCHER DETAIL UOM
			SET @remainingInVoucherDetailUOM = (SELECT dbo.fnCalculateQtyBetweenUOM(@paymentUOM, @voucherDetailUOM, @remainingQty));
			--CONVERT REMAINING QTY TO THE UOM OF THE COST
			IF(@costUOM > 0)
			BEGIN
				SET @remainingInVoucherDetailUOM = (SELECT dbo.fnCalculateQtyBetweenUOM(@voucherDetailUOM, @costUOM, @remainingInVoucherDetailUOM));
			END
			--CONVERT THE COST TO CORRECT AMOUNT
			IF(@subCurrency = 1)
			BEGIN
				SET @convertedDetailCostFromPaymentUOM = convertedDetailCostFromPaymentUOM / 100;
			END

			INSERT INTO @voucherDetailPayment
			SELECT @billId, CAST(@convertedDetailCostFromPaymentUOM * @remainingInVoucherDetailUOM * @rate AS DECIMAL(18,2)) --pay the remaining available qty
			SET @remainingQty = 0
		END
		FETCH c INTO @billId, @qtyToPay, @amountToPay, @paymentUOM, @voucherDetailUOM, @costUOM, @subCurrency, @rate, @convertedQtyToPaymentUOM, @convertedDetailCostFromPaymentUOM;
	END

	IF @remainingQty != 0
	BEGIN
		INSERT INTO @voucherDetailPayment
		SELECT NULL, @remainingQty
	END

	CLOSE c; DEALLOCATE c;

	INSERT INTO @returnTable
	SELECT
		voucherPayment.intBillId
		,CAST(SUM(voucherPayment.dblPayment) AS DECIMAL(18,2))
	FROM @voucherDetailPayment voucherPayment
	GROUP BY voucherPayment.intBillId
	RETURN;
END 