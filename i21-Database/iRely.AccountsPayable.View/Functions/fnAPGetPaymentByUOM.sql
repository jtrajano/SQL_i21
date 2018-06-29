CREATE FUNCTION [dbo].[fnAPGetPaymentByUOM]
(
	@vendorId INT,
	@currency INT,
	@unitMeasureId INT,
	@quantity DECIMAL(18,2),
	@paymentId INT
)
RETURNS @returnTable TABLE(
	intBillId INT,
	dblPayment DECIMAL(18,2)
)
AS
BEGIN

	DECLARE @billId INT;
	DECLARE @convertedQty DECIMAL(18,2);
	DECLARE @amountToPay DECIMAL(18,2);
	DECLARE @convertedDetailCostFromPaymentUOM DECIMAL(18,2);
	DECLARE @convertedQtyToPaymentUOM DECIMAL(18,2);
	DECLARE @voucherQtyToPay DECIMAL(18,2);
	DECLARE @qtyToPay DECIMAL(18, 2) = @quantity;
	DECLARE @remainingQty DECIMAL(18, 2) = @quantity;
	DECLARE @rate DECIMAL(18,6) = 1;
	DECLARE @subCurrency BIT;
	DECLARE @amountDue DECIMAL(18,2);
	DECLARE @paymentUOM INT, @voucherDetailUOM INT, @costUOM INT;
	DECLARE @voucherDetailPayment TABLE(intBillId INT, dblPayment DECIMAL(18,2));
	DECLARE @remainingInVoucherDetailUOM DECIMAL(18,2);

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
		,dblVoucherDetailQty
		,dblAmountDue
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
			,dblVoucherDetailQty = CASE WHEN voucherDetail.dblNetWeight > 0 THEN voucherDetail.dblNetWeight ELSE voucherDetail.dblQtyReceived END
			,dblAmountDue = CAST(paymentDetail.dblAmountDue AS DECIMAL(18,2))
		FROM tblAPBill voucher 
		INNER JOIN tblAPBillDetail voucherDetail ON voucher.intBillId = voucherDetail.intBillId
		INNER JOIN tblICItemUOM paymentItemUOM ON voucherDetail.intItemId = paymentItemUOM.intItemId AND paymentItemUOM.intUnitMeasureId = @unitMeasureId --it should have conversion unit setup
		CROSS APPLY (
			SELECT TOP 1
				dblAmountDue = paymentDetail.dblAmountDue + paymentDetail.dblInterest - paymentDetail.dblDiscount
			FROM tblAPPaymentDetail paymentDetail 
			WHERE paymentDetail.intPaymentId = @paymentId AND voucher.intBillId = paymentDetail.intBillId
		) paymentDetail
		WHERE voucher.intEntityVendorId = @vendorId AND voucher.intCurrencyId = @currency 
		AND voucherDetail.intUnitOfMeasureId > 0 --get only those have UOM
		AND voucher.ysnPosted = 1
		AND voucher.dblAmountDue != 0
		AND voucher.intTransactionType = 1
		 
	)
	SELECT 
		intBillId
		,dblAmountDue
		,dblVoucherQtyToPay = SUM(dblDetailQtyToPay)
	FROM (
		SELECT 
			voucherDetailsUOM.intBillId
			,voucherDetailsUOM.intPaymentItemUOMId
			,voucherDetailsUOM.intVoucherDetailItemUOMId
			,voucherDetailsUOM.intCostUOMId
			,voucherDetailsUOM.ysnSubCurrency
			,voucherDetailsUOM.dblRate
			,voucherDetailsUOM.dtmDueDate
			,dblDetailQtyToPay = dbo.fnCalculateQtyBetweenUOM(voucherDetailsUOM.intVoucherDetailItemUOMId, intPaymentItemUOMId, dblVoucherDetailQty)
			,dblAmountDue = voucherDetailsUOM.dblAmountDue
			,dblVoucherDetailCost--dbo.fnCalculateCostBetweenUOM(intPaymentItemUOMId, voucherDetailsUOM.intVoucherDetailItemUOMId, dblVoucherDetailCost)
		FROM voucherDetails voucherDetailsUOM
	) vouchersToPay
	GROUP BY intBillId, dblAmountDue, dtmDueDate
	ORDER BY dtmDueDate DESC

	OPEN c;

	FETCH c INTO @billId, @amountDue, @voucherQtyToPay--@amountToPay, @paymentUOM, @voucherDetailUOM, @costUOM, @subCurrency, @rate, @convertedQtyToPaymentUOM, @convertedDetailCostFromPaymentUOM;

	WHILE @@FETCH_STATUS = 0 AND @remainingQty != 0
	BEGIN
		IF @voucherQtyToPay <= @remainingQty
		BEGIN
			INSERT INTO @voucherDetailPayment
			SELECT @billId, (@amountDue / @voucherQtyToPay) * @voucherQtyToPay
			SET @remainingQty = @remainingQty - @voucherQtyToPay
		END
		ELSE
		BEGIN
			-- --CONVERT PAYMENT QTY UOM TO VOUCHER DETAIL UOM
			-- SET @remainingInVoucherDetailUOM = (SELECT dbo.fnCalculateQtyBetweenUOM(@paymentUOM, @voucherDetailUOM, @remainingQty));
			-- --CONVERT REMAINING QTY TO THE UOM OF THE COST
			-- IF(@costUOM > 0)
			-- BEGIN
			-- 	SET @remainingInVoucherDetailUOM = (SELECT dbo.fnCalculateQtyBetweenUOM(@voucherDetailUOM, @costUOM, @remainingInVoucherDetailUOM));
			-- END
			-- --CONVERT THE COST TO CORRECT AMOUNT
			-- IF(@subCurrency = 1)
			-- BEGIN
			-- 	SET @convertedDetailCostFromPaymentUOM = @convertedDetailCostFromPaymentUOM / 100;
			-- END

			-- INSERT INTO @voucherDetailPayment
			-- SELECT @billId, CAST(@convertedDetailCostFromPaymentUOM * @remainingInVoucherDetailUOM * @rate AS DECIMAL(18,2)) --pay the remaining available qty

			INSERT INTO @voucherDetailPayment
			SELECT @billId, (@amountDue / @voucherQtyToPay) * @remainingQty
			SET @remainingQty = 0
		END
		FETCH c INTO @billId, @amountDue, @voucherQtyToPay --@amountToPay, @paymentUOM, @voucherDetailUOM, @costUOM, @subCurrency, @rate, @convertedQtyToPaymentUOM, @convertedDetailCostFromPaymentUOM;
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