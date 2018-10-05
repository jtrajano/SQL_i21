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
		SET dblAmount = CASE WHEN (CTC.intContractCostId IS NOT NULL)
							THEN ISNULL(IRC.dblRate, LGC.dblRate) 
								* CASE WHEN (LGC.strCostMethod = 'Amount') THEN 1 
									ELSE ISNULL(IRC.dblOpenReceive, LGD.dblQuantity) END
							ELSE LGC.dblAmount END
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
					,IRI.dblReceived
					,IRI.dblOpenReceive
					FROM tblICInventoryReceiptCharge IRC
					INNER JOIN tblICInventoryReceipt IR 
						ON IR.intInventoryReceiptId = IRC.intInventoryReceiptId
					INNER JOIN (SELECT TOP 1 * FROM tblICInventoryReceiptItem
								WHERE intSourceId IN (
								SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId)
							) IRI
						ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IR.ysnPosted = 1
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