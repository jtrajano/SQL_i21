CREATE PROCEDURE [dbo].[uspLGRecalculateLoadCosts]
	@intLoadId INT,
	@intEntityUserSecurityId INT
AS 
BEGIN TRY
	DECLARE @intLoadCostId INT
	DECLARE @intCostItemId INT
	DECLARE @strErrorMessage NVARCHAR(MAX)

	SELECT intLoadCostId, intItemId INTO #tmpLoadCost FROM tblLGLoadCost WHERE intLoadId = @intLoadId

	--Loop through each Cost
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpLoadCost)
	BEGIN

		SELECT TOP 1 @intLoadCostId = intLoadCostId 
					,@intCostItemId = intItemId
		FROM #tmpLoadCost

		--If Posted Inventory Receipt is present with Inventory Cost enabled, use IR Qty, otherwise use Load Schedule Qty
		UPDATE LGC
		SET dblAmount = LGC_Calc.dblAmount
			,dblRate = LGC_Calc.dblRate
			,strCostMethod = LGC_Calc.strCostMethod
		FROM
			tblLGLoadCost LGC
			INNER JOIN 
			(SELECT 
			intLoadCostId = LGC.intLoadCostId,
			strCostMethod = ISNULL(IRC.strCostMethod, LGC.strCostMethod),
			dblAmount = CASE WHEN (CTC.intContractCostId IS NOT NULL)
							THEN 
								--If Cost is in the original contract, apply only to the detail associated to the contract 
								ROUND(CASE WHEN (IRC.dblAmount IS NOT NULL) 
										THEN IRC.dblAmount
										ELSE 		
											CASE (LGC.strCostMethod) 
											WHEN 'Per Unit' THEN
												LGC.dblRate * dbo.fnCalculateQtyBetweenUOM(
														ISNULL(LGD.intWeightItemUOMId, IU.intUnitMeasureId), 
														dbo.fnGetMatchingItemUOMId(LGD.intItemId, LGC.intItemUOMId), 
														CASE WHEN LGD.intWeightItemUOMId IS NOT NULL THEN ISNULL(LGD.dblNet, 0) ELSE ISNULL(LGD.dblQuantity, 0) END 
													)
											WHEN 'Percentage' THEN
												(LGC.dblRate / 100) * LGD.dblAmount
											ELSE 
												LGC.dblRate
											END
										END,2)
							ELSE 
								--If Cost is not present in the original contract, apply to all Load Details
								SUM(ROUND(CASE WHEN (IRC.dblAmount IS NOT NULL) 
										THEN IRC.dblAmount
										ELSE 		
											
											CASE (LGC.strCostMethod) 
											WHEN 'Per Unit' THEN
												LGC.dblRate * dbo.fnCalculateQtyBetweenUOM(
														ISNULL(LGD.intWeightItemUOMId, IU.intUnitMeasureId), 
														dbo.fnGetMatchingItemUOMId(LGD.intItemId, LGC.intItemUOMId), 
														CASE WHEN LGD.intWeightItemUOMId IS NOT NULL THEN ISNULL(LGD.dblNet, 0) ELSE ISNULL(LGD.dblQuantity, 0) END 
													)
											WHEN 'Percentage' THEN
												(LGC.dblRate / 100) * LGD.dblAmount
											ELSE 
												LGC.dblRate
											END

										END,2))
							END
			,dblRate = ISNULL(IRC.dblRate, LGC.dblRate)
			FROM
				tblLGLoadCost LGC
				INNER JOIN tblLGLoad LG
					ON LG.intLoadId = LGC.intLoadId
				LEFT JOIN
					(SELECT TOP 1 
						IRC.intInventoryReceiptChargeId
						,IRC.intChargeId
						,IRC.intEntityVendorId
						,IRC.dblRate
						,IRC.strCostMethod 
						,IRC.dblAmount
						,IRC.ysnInventoryCost
						,IR.dblReceived
						,IR.dblOpenReceive
						,IR.dblNet
						,IR.ysnPosted
						FROM tblICInventoryReceiptCharge IRC
						INNER JOIN 
							(SELECT TOP 1 
									IR.intInventoryReceiptId
									,IRI.dblReceived
									,IRI.dblOpenReceive
									,IRI.dblNet
									,IR.ysnPosted 
								FROM tblICInventoryReceiptItem IRI
								INNER JOIN tblICInventoryReceipt IR 
									ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
								WHERE ysnPosted = 1 AND intSourceId IN (
								SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId)
							) IR
							ON IR.intInventoryReceiptId = IRC.intInventoryReceiptId
					) [IRC] --Join with Posted IR Costs on the same Item, Vendor, and Cost Method
					ON LGC.intItemId = IRC.intChargeId
					AND LGC.intVendorId = IRC.intEntityVendorId
					--AND LGC.strCostMethod = IRC.strCostMethod
					AND IRC.ysnInventoryCost = 1
				LEFT JOIN tblLGLoadDetail LGD
					ON LGD.intLoadId = @intLoadId
				LEFT JOIN tblICItemUOM IU
					ON IU.intItemUOMId = LGD.intItemUOMId
				LEFT JOIN tblICItemUOM WU
					ON WU.intWeightUOMId = LGD.intWeightItemUOMId
				LEFT JOIN 
				(SELECT TOP 1 
					CTC.intContractCostId
					,CTC.intItemId
					,CTC.intVendorId
					,CTC.dblRate
					,CTC.strCostMethod
					,CTC.intItemUOMId
					,CTC.dblAccruedAmount
					,CTD.intContractDetailId
					,CTD.dblQuantity
					FROM tblCTContractCost CTC
					INNER JOIN tblCTContractDetail CTD
						ON CTC.intContractDetailId = CTD.intContractDetailId
					WHERE CTC.intContractDetailId IN (
						SELECT intPContractDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId)
					) [CTC] --Join with Contract Costs on the same Item, Vendor, and Cost Method
				ON LGC.intItemId = CTC.intItemId
					AND LGC.intVendorId = CTC.intVendorId
					--AND LGC.strCostMethod = CTC.strCostMethod
					AND LGD.intPContractDetailId = CTC.intContractDetailId
			WHERE LGC.intLoadCostId = @intLoadCostId
			GROUP BY
				LGC.intLoadCostId,
				LGC.dblRate,
				LGC.strCostMethod,
				LGC.intItemUOMId,
				LGD.intItemId,
				LGD.intWeightItemUOMId,
				LGD.dblNet,
				LGD.dblQuantity,
				LGD.dblAmount,
				IRC.dblAmount,
				IRC.strCostMethod,
				CTC.intContractCostId,
				ISNULL(LGD.intWeightItemUOMId, IU.intUnitMeasureId),
				ISNULL(IRC.dblRate, LGC.dblRate)) LGC_Calc ON LGC_Calc.intLoadCostId = LGC.intLoadCostId
		WHERE LGC.intLoadCostId = @intLoadCostId

		DELETE FROM #tmpLoadCost WHERE intLoadCostId = @intLoadCostId
	END
END TRY
BEGIN CATCH
	SELECT @strErrorMessage = ERROR_MESSAGE();

	RAISERROR (@strErrorMessage,16,1)
END CATCH

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpLoadCost')) DROP TABLE #tmpLoadCost

GO