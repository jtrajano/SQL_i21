CREATE PROCEDURE [dbo].[uspGRAdjustSettlementsForPurchase]
(
	@intUserId INT
	,@intItemId INT
	,@intContractDetailId INT = NULL
	,@intAdjustmentTypeId INT
	,@AdjustSettlementsStagingTable AdjustSettlementsStagingTable READONLY
	,@intBillId INT = NULL OUTPUT
	,@BillIds NVARCHAR(MAX) = NULL OUTPUT
)
AS
BEGIN
	DECLARE @intPrepayTypeId INT
	DECLARE @intFreightItemId INT
	DECLARE @voucherPayable VoucherPayable
	DECLARE @voucherPayableTax VoucherDetailTax
	DECLARE @createdVouchersId NVARCHAR(MAX)
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @detailCreated Id

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
		,intLocationId
		,intShipToId
		,intItemId
		,intWeightUOMId
		,dblNetWeight
		,intCostUOMId
		--,intOrderUOMId
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
		,strCheckComment
	)
	SELECT
		intTransactionType		= CASE
									WHEN @intAdjustmentTypeId = 1 THEN 2 --VPRE
									WHEN @intAdjustmentTypeId IN (2,3) THEN 
										CASE WHEN ADJ.dblAdjustmentAmount < 0 THEN 3 /*DM*/ ELSE 1 END --BL
								END
		,intEntityVendorId		= CASE WHEN ADJ.intSplitId IS NULL THEN ADJ.intEntityId ELSE EM.intEntityId END
		,intLocationId			= ADJ.intCompanyLocationId
		,intShipToId			= ADJ.intCompanyLocationId
		,intItemId				= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN CD.intItemId
									WHEN @intAdjustmentTypeId = 2 THEN @intFreightItemId								
									ELSE CASE WHEN ADJ.dblCkoffAdjustment <> 0 THEN ADJ.intItemId ELSE NULL END
								END
		,intWeightUOMId			= CASE WHEN ADJ.dblCkoffAdjustment <> 0 THEN b.intItemUOMId ELSE NULL END
		,dblNetWeight			= CASE WHEN ADJ.dblCkoffAdjustment <> 0 THEN 1 ELSE 0 END
		,intCostUOMId			= CASE WHEN ADJ.dblCkoffAdjustment <> 0 THEN b.intItemUOMId ELSE NULL END
		,dblQuantityToBill		= CASE 
									WHEN @intAdjustmentTypeId = 1 AND ADJ.intContractDetailId IS NOT NULL THEN ROUND(ADJ.dblAdjustmentAmount / CD.dblCashPrice,6)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightUnits,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ADJ.dblFreightUnits
											ELSE 1
										END
									ELSE 1 --3
								END
		,dblOrderQty			= CASE
									WHEN @intAdjustmentTypeId = 1 AND ADJ.intContractDetailId IS NOT NULL THEN ROUND(ADJ.dblAdjustmentAmount / CD.dblCashPrice,6)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightUnits,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ADJ.dblFreightUnits
											ELSE 1
										END
									ELSE 1 --3
								END
		,dblCost				= CASE 
									WHEN @intAdjustmentTypeId = 1 THEN ISNULL(CD.dblCashPrice,ADJ.dblAdjustmentAmount)
									WHEN @intAdjustmentTypeId = 2 THEN
										CASE 
											WHEN ISNULL(ADJ.dblFreightRate,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ABS(ADJ.dblFreightRate)
											ELSE ABS(ADJ.dblAdjustmentAmount)
										END
									ELSE CASE WHEN ADJ.intSplitId IS NULL THEN ABS(ADJ.dblAdjustmentAmount) ELSE (ABS(ADJ.dblAdjustmentAmount) * (ESD.dblSplitPercent / 100)) END
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
		,strCheckComment		= ADJ.strComments
	FROM @AdjustSettlementsStagingTable ADJ
	LEFT JOIN tblICItemUOM b 
		ON b.intItemId = ADJ.intItemId 
			--AND b.intUnitMeasureId = @intUnitMeasureId
			AND b.ysnStockUnit = 1
	LEFT JOIN tblAPVendor AP
		ON AP.intEntityId = ADJ.intEntityId
	LEFT JOIN (
		tblCTContractDetail CD
		INNER JOIN tblCTContractHeader CH
			ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN tblICItem IC
			ON IC.intItemId = CD.intItemId
	) ON CD.intContractDetailId = ADJ.intContractDetailId
	LEFT JOIN (
		tblEMEntitySplit ES
		INNER JOIN tblEMEntitySplitDetail ESD
			ON ESD.intSplitId = ES.intSplitId
		INNER JOIN tblEMEntity EM
			ON EM.intEntityId = ESD.intEntityId
	) ON ES.intSplitId = ADJ.intSplitId	
	LEFT JOIN tblICItem ICF
		ON ICF.intItemId = @intFreightItemId
		--select  '@voucherPayable',* from @voucherPayable

	UPDATE @voucherPayable SET dblQuantityToBill = dblQuantityToBill * -1, dblOrderQty = dblOrderQty * -1 WHERE dblQuantityToBill < 0 AND intTransactionType = 1
	
	EXEC uspAPCreateVoucher
		@voucherPayables = @voucherPayable
		,@voucherPayableTax = @voucherPayableTax
		,@userId = @intUserId
		,@throwError = 1
		,@error = @ErrMsg
		,@createdVouchersId = @createdVouchersId OUTPUT

		--SELECT * FROM @AdjustSettlementsStagingTable

		--SELECT TOP 1 'aa',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail ORDER BY intBillDetailId DESC

	IF @intAdjustmentTypeId = 3 AND ISNULL((SELECT dblCkoffAdjustment FROM @AdjustSettlementsStagingTable),0) <> 0
	BEGIN
		INSERT INTO @detailCreated
		SELECT intBillDetailId
		FROM tblAPBillDetail BD
		INNER JOIN (
			SELECT value FROM dbo.fnCommaSeparatedValueToTable(@createdVouchersId)
		) BL
			ON BL.value = BD.intBillId	

		UPDATE APD
		SET APD.intTaxGroupId = dbo.fnGetTaxGroupIdForVendor(
				CASE WHEN APB.intShipFromEntityId != APB.intEntityVendorId THEN APB.intShipFromEntityId ELSE APB.intEntityVendorId END,
				APB.intShipToId,
				--APD.intItemId,
				NULL,
				APB.intShipFromId,
				EM.intFreightTermId,
				default
			)
		FROM tblAPBillDetail APD 
		INNER JOIN tblAPBill APB
			ON APD.intBillId = APB.intBillId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = APB.intEntityId
		INNER JOIN @detailCreated ON intBillDetailId = intId
		WHERE APD.intTaxGroupId IS NULL		

		--SELECT TOP 1 'bb',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail ORDER BY intBillDetailId DESC

		--calculate the tax first to get the rate
		EXEC [uspAPUpdateVoucherDetailTax] @detailCreated


		--select 'GG2',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,strMiscDescription,* FROM tblAPBillDetail a inner join @detailCreated b on b.intId = a.intBillDetailId ORDER BY intBillDetailId DESC

		--SELECT '@AdjustSettlementsStagingTable',* FROM @AdjustSettlementsStagingTable
		
		--update qty, cost and tax based on the rate above
		UPDATE APD
		SET dblQtyOrdered	= CASE WHEN ISNULL(ADJ.dblCkoffAdjustment,0) = 0 OR BDT.strCalculationMethod = 'Unit' 
								THEN 
									ROUND(
										(ABS(ISNULL(ADJ.dblCkoffAdjustment,0)) * (ISNULL(ADJ.dblSplitPercent,100) / 100)) / BDT.dblRate
									,6)
								ELSE 1 END
			,dblCost		= CASE WHEN ISNULL(ADJ.dblCkoffAdjustment,0) = 0 OR BDT.strCalculationMethod = 'Unit' 
								THEN 
									(
										(ABS(ADJ.dblAdjustmentAmount + ISNULL(ADJ.dblCkoffAdjustment,0)) * (ISNULL(ADJ.dblSplitPercent,100) / 100)) 
										/ 
										ROUND((ABS(ISNULL(ADJ.dblCkoffAdjustment,0)) * (ISNULL(ADJ.dblSplitPercent,100) / 100)) / BDT.dblRate, 6)
									)
							ELSE 							
								ABS(ADJ.dblAdjustmentAmount + ISNULL(ADJ.dblCkoffAdjustment,0)) * (ISNULL(ADJ.dblSplitPercent,100) / 100)
							END
		FROM tblAPBillDetail APD 
		INNER JOIN tblAPBill APB
			ON APD.intBillId = APB.intBillId
		INNER JOIN tblAPBillDetailTax BDT
			ON BDT.intBillDetailId = APD.intBillDetailId
		INNER JOIN @detailCreated 
			ON APD.intBillDetailId = intId
		INNER JOIN (
			SELECT A.dblAdjustmentAmount
				,A.dblCkoffAdjustment
				,ESD.dblSplitPercent
				,A.strAdjustSettlementNumber
				,intEntityId = COALESCE(EM.intEntityId,A.intEntityId)
			FROM @AdjustSettlementsStagingTable A
			LEFT JOIN (
				tblEMEntitySplit ES
				INNER JOIN tblEMEntitySplitDetail ESD
					ON ESD.intSplitId = ES.intSplitId
				INNER JOIN tblEMEntity EM
					ON EM.intEntityId = ESD.intEntityId
			) ON ES.intSplitId = A.intSplitId				
		) ADJ
			ON ADJ.intEntityId = APB.intEntityVendorId
		WHERE APD.dblTax <> 0

		
		--select 'GG3',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail a inner join @detailCreated b on b.intId = a.intBillDetailId ORDER BY intBillDetailId DESC

		UPDATE APD
		SET dblQtyReceived = dblQtyOrdered
			,dblNetWeight	= dblQtyOrdered
		FROM tblAPBillDetail APD 
		INNER JOIN @detailCreated 
			ON APD.intBillDetailId = intId
		WHERE APD.dblTax <> 0

		--select 'GG4',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail a inner join @detailCreated b on b.intId = a.intBillDetailId ORDER BY intBillDetailId DESC

		--recalculate the tax with the updated qty
		EXEC [uspAPUpdateVoucherDetailTax] @detailCreated

		--SELECT TOP 1 'ff',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail ORDER BY intBillDetailId DESC

		/*START *** NOTE: If the Tax's calculation method is Percentage, Override the tax with the CKOFF Adjustment*/
		UPDATE APD
		SET dblTax = CASE 
						WHEN BDT.strCalculationMethod = 'Unit' THEN APD.dblTax 
						ELSE ISNULL(ADJ.dblCkoffAdjustment,0) * (ISNULL(ADJ.dblSplitPercent,100) / 100) * CASE WHEN APD.dblTax < 0 AND APB.intTransactionType = 1 THEN -1 ELSE 1 END
					END
		FROM tblAPBillDetail APD 
		INNER JOIN tblAPBill APB
			ON APD.intBillId = APB.intBillId
		INNER JOIN tblAPBillDetailTax BDT
			ON BDT.intBillDetailId = APD.intBillDetailId
		INNER JOIN @detailCreated 
			ON APD.intBillDetailId = intId
		INNER JOIN (
			SELECT A.dblAdjustmentAmount
				,A.dblCkoffAdjustment
				,ESD.dblSplitPercent
				,A.strAdjustSettlementNumber
				,intEntityId = COALESCE(EM.intEntityId,A.intEntityId)
			FROM @AdjustSettlementsStagingTable A
			LEFT JOIN (
				tblEMEntitySplit ES
				INNER JOIN tblEMEntitySplitDetail ESD
					ON ESD.intSplitId = ES.intSplitId
				INNER JOIN tblEMEntity EM
					ON EM.intEntityId = ESD.intEntityId
			) ON ES.intSplitId = A.intSplitId				
		) ADJ
			ON ADJ.intEntityId = APB.intEntityVendorId

		UPDATE BDT
		SET dblAdjustedTax = CASE 
								WHEN BDT.strCalculationMethod = 'Unit' THEN BDT.dblAdjustedTax
								ELSE ISNULL(ADJ.dblCkoffAdjustment,0) * (ISNULL(ADJ.dblSplitPercent,100) / 100) * CASE WHEN APD.dblTax < 0 AND APB.intTransactionType = 1 THEN -1 ELSE 1 END
							END
			,ysnTaxAdjusted = CAST(CASE 
								WHEN BDT.strCalculationMethod = 'Unit' THEN 0
								ELSE 1
							END AS BIT)
		FROM tblAPBillDetail APD 
		INNER JOIN tblAPBill APB
			ON APD.intBillId = APB.intBillId
		INNER JOIN tblAPBillDetailTax BDT
			ON BDT.intBillDetailId = APD.intBillDetailId
		INNER JOIN @detailCreated 
			ON APD.intBillDetailId = intId
		INNER JOIN (
			SELECT A.dblAdjustmentAmount
				,A.dblCkoffAdjustment
				,ESD.dblSplitPercent
				,A.strAdjustSettlementNumber
				,intEntityId = COALESCE(EM.intEntityId,A.intEntityId)
			FROM @AdjustSettlementsStagingTable A
			LEFT JOIN (
				tblEMEntitySplit ES
				INNER JOIN tblEMEntitySplitDetail ESD
					ON ESD.intSplitId = ES.intSplitId
				INNER JOIN tblEMEntity EM
					ON EM.intEntityId = ESD.intEntityId
			) ON ES.intSplitId = A.intSplitId				
		) ADJ
			ON ADJ.intEntityId = APB.intEntityVendorId
		/*END *** NOTE: If the Tax's calculation method is Percentage, Override the tax with the CKOFF Adjustment*/
		-- select 'GG',dblQtyOrdered,dblQtyReceived,dblNetWeight,dblCost,dblTax,dblTotal,* FROM tblAPBillDetail a inner join @detailCreated b on b.intId = a.intBillDetailId ORDER BY intBillDetailId DESC
	END

	IF @createdVouchersId IS NOT NULL
	BEGIN
		IF @createdVouchersId NOT LIKE '%,%'
		BEGIN
			SET @intBillId = CAST(@createdVouchersId AS INT)
		END
		ELSE
		BEGIN
			INSERT INTO tblGRAdjustSettlementsSplit
			(
				intAdjustSettlementId
				,intBillId
			)
			SELECT intAdjustSettlementId
				,BL.value
			FROM @AdjustSettlementsStagingTable A
			OUTER APPLY (
				SELECT * FROM dbo.fnCommaSeparatedValueToTable(@createdVouchersId)
			) BL

			SET @BillIds = @createdVouchersId
		END
	END

	--RETURN @intBillId;
END