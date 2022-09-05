CREATE PROCEDURE [dbo].[uspGRAdjustSettlementsForPurchase]
(
	@intUserId INT
	,@intItemId INT
	,@intContractDetailId INT = NULL
	,@intAdjustmentTypeId INT
	,@AdjustSettlementsStagingTable AdjustSettlementsStagingTable READONLY
	,@intBillId INT OUTPUT
)
AS
BEGIN
	DECLARE @intPrepayTypeId INT
	DECLARE @intFreightItemId INT
	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax
	DECLARE @createdVouchersId NVARCHAR(MAX)
	DECLARE @ErrMsg NVARCHAR(MAX)

	SET @intPrepayTypeId = CASE WHEN @intAdjustmentTypeId = 1 THEN CASE WHEN @intContractDetailId IS NULL THEN 1 /*Standard*/ ELSE 2 /*Unit*/ END ELSE NULL END

	SELECT @intFreightItemId = FR.intItemId
	FROM tblICItem IC
	OUTER APPLY (
		SELECT TOP 1 intItemId
		FROM tblICItem
		WHERE intCommodityId = IC.intCommodityId
			AND strCostType = 'Freight'
	) FR
	WHERE IC.intItemId = @intItemId

	IF @intFreightItemId IS NULL
	BEGIN
		SELECT TOP 1 @intFreightItemId = intItemId FROM tblICItem WHERE intCommodityId IS NULL AND strCostType = 'Freight'
	END

	DELETE FROM @voucherPayable
	INSERT INTO @voucherPayable
	(
		intTransactionType
		,intEntityVendorId		
		,intShipToId
		,intItemId
		,dblQuantityToBill
		,dblOrderQty
		,dblCost
		,intAccountId
		,strVendorOrderNumber
		,strMiscDescription
		,intPrepayTypeId
		,intContractDetailId
		,intContractHeaderId
		,intContractSeqId
		,intTermId
		,ysnStage
	)
	SELECT
		intTransactionType		= CASE
									WHEN @intAdjustmentTypeId = 1 THEN 2 --VPRE
									WHEN @intAdjustmentTypeId IN (2,3) THEN 
										CASE WHEN ADJ.dblAdjustmentAmount < 0 THEN 3 /*DM*/ ELSE 1 END --BL
								END
		,intEntityVendorId		= ADJ.intEntityId
		,intShipToId			= ADJ.intCompanyLocationId
		,intItemId				= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN CD.intItemId
									WHEN @intAdjustmentTypeId = 2 THEN @intFreightItemId								
									ELSE NULL --3
								END
		,dblQuantityToBill		= CASE 
									WHEN @intAdjustmentTypeId = 1 AND ADJ.intContractDetailId IS NOT NULL THEN ROUND(ADJ.dblAdjustmentAmount / CD.dblCashPrice,6)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightUnits,0) > 0 THEN ADJ.dblFreightUnits
											ELSE 1
										END
									ELSE 1 --3
								END
		,dblOrderQty			= CASE
									WHEN @intAdjustmentTypeId = 1 AND ADJ.intContractDetailId IS NOT NULL THEN ROUND(ADJ.dblAdjustmentAmount / CD.dblCashPrice,6)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightUnits,0) > 0 THEN ADJ.dblFreightUnits
											ELSE 1
										END
									ELSE 1 --3
								END
		,dblCost				= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN ISNULL(CD.dblCashPrice,ADJ.dblAdjustmentAmount)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightRate,0) > 0 THEN ADJ.dblFreightRate
											ELSE ABS(ADJ.dblAdjustmentAmount)
										END
									ELSE ABS(ADJ.dblAdjustmentAmount)
								END
		,intAccountId			= intGLAccountId
		,strVendorOrderNumber	= strTicketNumber
		,strMiscDescription		= CASE 
									WHEN @intAdjustmentTypeId = 1 AND ADJ.intContractDetailId IS NOT NULL THEN IC.strItemNo
									WHEN @intAdjustmentTypeId = 2 THEN ICF.strItemNo
									ELSE ADJ.strAdjustSettlementNumber
								END
		,intPrepayTypeId		= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN @intPrepayTypeId
									ELSE NULL
								END
		,intContractDetailId	= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN ADJ.intContractDetailId
									ELSE NULL
								END
		,intContractHeaderId	= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN ADJ.intContractHeaderId
									ELSE NULL
								END
		,intContractSeqId		= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN CD.intContractSeq
									ELSE NULL
								END
		,intTermId				= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN CH.intTermId
									ELSE AP.intTermsId
								END
		,ysnStage				= 0
	FROM @AdjustSettlementsStagingTable ADJ
	LEFT JOIN tblAPVendor AP
		ON AP.intEntityId = ADJ.intEntityId
	LEFT JOIN (
		tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem IC
			ON IC.intItemId = CD.intItemId
	)
	ON CD.intContractDetailId = ADJ.intContractDetailId
	LEFT JOIN tblICItem ICF
		ON ICF.intItemId = @intFreightItemId
		select '@voucherPayable',* from @voucherPayable
	EXEC uspAPCreateVoucher
		@voucherPayables = @voucherPayable
		,@voucherPayableTax = @voucherPayableTax
		,@userId = @intUserId
		,@throwError = 1
		,@error = @ErrMsg
		,@createdVouchersId = @createdVouchersId OUTPUT

		SELECT * FROM tblAPBill ORDER BY intBillId DESC

	IF @createdVouchersId IS NOT NULL
	BEGIN
		SET @intBillId = CAST(@createdVouchersId AS int)
	END

	RETURN @intBillId;
END