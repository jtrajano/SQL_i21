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
		--If Cost is not present in the original contract, do not update
		UPDATE LGC
		SET dblAmount = ROUND (CASE WHEN (CTC.intContractCostId IS NOT NULL)
							THEN 
								CASE WHEN (IRC.dblAmount IS NOT NULL) 
									THEN IRC.dblAmount
									ELSE 		
										LGC.dblRate 
										* dbo.fnCalculateQtyBetweenUOM(
											ISNULL(LGD.intWeightItemUOMId, IU.intUnitMeasureId), 
											dbo.fnGetMatchingItemUOMId(LGD.intItemId, LGC.intItemUOMId), 
											CASE WHEN LGD.intWeightItemUOMId IS NOT NULL THEN ISNULL(LGD.dblNet, 0) ELSE ISNULL(LGD.dblQuantity, 0) END 
										)
									END
							ELSE LGC.dblAmount END
						 ,2)
			,dblRate = CASE WHEN (CTC.intContractCostId IS NOT NULL) 
							THEN ISNULL(IRC.dblRate, LGC.dblRate)
							ELSE LGC.dblRate END
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
				AND LGC.strCostMethod = IRC.strCostMethod
				AND IRC.ysnInventoryCost = 1
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
					AND LGC.strCostMethod = CTC.strCostMethod
			LEFT JOIN tblLGLoadDetail LGD
				ON LGD.intPContractDetailId = CTC.intContractDetailId
				AND LGD.intLoadId = @intLoadId
			LEFT JOIN tblICItemUOM IU
				ON IU.intItemUOMId = LGD.intItemUOMId
			LEFT JOIN tblICItemUOM WU
				ON WU.intWeightUOMId = LGD.intWeightItemUOMId
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