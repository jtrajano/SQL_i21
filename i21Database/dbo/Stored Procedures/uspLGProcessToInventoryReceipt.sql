﻿CREATE PROCEDURE [dbo].[uspLGProcessToInventoryReceipt] 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intInventoryReceiptId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @LotEntries ReceiptItemLotStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @ReceiptTradeFinance ReceiptTradeFinance
	DECLARE @intPContractDetailId INT
	DECLARE @intPEntityId INT
	DECLARE @intPItemId INT
	DECLARE @intMinInvRecItemId INT
	DECLARE @dblVoucherQty NUMERIC(18,6)
	DECLARE @dblBillQty NUMERIC(18, 6)
	DECLARE @dblPContractDetailQty NUMERIC(18, 6)
	DECLARE @strLotCondition NVARCHAR(50)
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @strFOBPoint AS NVARCHAR(50)

	SELECT @strFOBPoint = FT.strFobPoint 
	FROM tblLGLoad L
	JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId 
	WHERE intLoadId = @intLoadId

	SELECT TOP 1 @strLotCondition = strLotCondition
	FROM tblICCompanyPreference

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult'))
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END

	IF ((SELECT ISNULL(intSourceType, 0) FROM tblLGLoad WHERE intLoadId = @intLoadId) = 1) 
	BEGIN /* Source Type: None */
		IF EXISTS (
				SELECT LD.intItemId
				FROM tblLGLoadDetail LD
				JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				WHERE LD.intLoadId = @intLoadId
					AND LD.intItemId <> U.intItemId
				)
		BEGIN
			UPDATE LD
			SET intItemUOMId = IU.intItemUOMId
			FROM tblLGLoad L
				JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
				JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				JOIN tblICItemUOM IU ON IU.intUnitMeasureId = U.intUnitMeasureId AND IU.intItemId = LD.intItemId
			WHERE LD.intLoadId = @intLoadId
				AND LD.intItemId <> U.intItemId

			UPDATE LDCL
			SET intItemUOMId = LD.intItemUOMId
			FROM tblLGLoadDetail LD
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			WHERE LD.intItemUOMId <> LDCL.intItemUOMId AND LD.intLoadId = @intLoadId
		END

		INSERT INTO @ReceiptStagingTable (
			[strReceiptType]
			,[intEntityVendorId]
			,[intShipFromId]
			,[intLocationId]
			,[strBillOfLadding]
			,[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[dtmDate]
			,[intShipViaId]
			,[dblQty]
			,[intGrossNetUOMId]
			,[dblGross]
			,[dblTare]
			,[dblNet]
			,[dblCost]
			,[intCostUOMId]
			,[intCurrencyId]
			,[intSubCurrencyCents]
			,[dblExchangeRate]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[intSourceId]
			,[intSourceType]
			,[strSourceId]
			,[strSourceScreenName]
			,[ysnSubCurrency]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[intContainerId]
			,[intFreightTermId]
			,[intBookId]
			,[intSubBookId]
			,[intSort]
			,[intLoadShipmentId]
			,[intLoadShipmentDetailId]
			,[intTaxGroupId]
			,[strTaxPoint]
			,[intTaxLocationId]
			)
		SELECT 
			[strReceiptType] = 'Direct'
			,[intEntityVendorId] = LD.intVendorEntityId
			,[intShipFromId] = EL.intEntityLocationId
			,[intLocationId] = LD.intPCompanyLocationId
			,[strBillOfLadding] = L.strBLNumber
			,[intItemId] = LD.intItemId
			,[intItemLocationId] = LD.intPCompanyLocationId
			,[intItemUOMId] = LD.intItemUOMId
			,[intContractHeaderId] = NULL
			,[intContractDetailId] = NULL
			,[dtmDate] = GETDATE()
			,[intShipViaId] = NULL
			,[dblQty] = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) 
							THEN ISNULL(LDCL.dblQuantity, LD.dblQuantity) 
							ELSE LD.dblQuantity - ISNULL(LD.dblDeliveredQuantity,0) END
			,[intGrossNetUOMId] = LD.intWeightItemUOMId
			,[dblGross] = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) 
							THEN ISNULL(LDCL.dblLinkGrossWt, LD.dblGross)
							ELSE LD.dblGross - ISNULL(LD.dblDeliveredGross,0) END
			,[dblTare] = 
					CASE 
						WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) THEN 
							ISNULL(LDCL.dblLinkTareWt, LD.dblTare)
						ELSE 
							LD.dblTare - ISNULL(LD.dblDeliveredTare,0) 
					END
			,[dblNet] = CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NOT NULL) 
							THEN ISNULL(LDCL.dblLinkNetWt, LD.dblNet)
							ELSE LD.dblNet -ISNULL(LD.dblDeliveredNet,0) END
			,[dblCost] = ISNULL(LD.dblUnitPrice,0)
			,[intCostUOMId] = LD.intPriceUOMId
			,[intCurrencyId] = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
			,[intSubCurrencyCents] = ISNULL(SC.intCent, 1)
			,[dblExchangeRate] = 1
			,[intLotId] = NULL
			,[intSubLocationId] = ISNULL(LW.intSubLocationId, LD.intPSubLocationId)
			,[intStorageLocationId] = LW.intStorageLocationId
			,[ysnIsStorage] = 0
			,[intSourceId] = NULL
			,[intSourceType] = 0
			,[strSourceId] = NULL
			,[strSourceScreenName] = NULL
			,[ysnSubCurrency] = SC.ysnSubCurrency
			,[intForexRateTypeId] = NULL
			,[dblForexRate] = NULL
			,[intContainerId] = ISNULL(LC.intLoadContainerId, -1)
			,[intFreightTermId] = L.intFreightTermId
			,[intBookId] = L.intBookId
			,[intSubBookId] = L.intSubBookId
			,[intSort] = ISNULL(LC.intLoadContainerId, 0)
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentDetailId] = LD.intLoadDetailId
			,[intTaxGroupId] = LD.intTaxGroupId
			,[strTaxPoint] = L.strTaxPoint
			,[intTaxLocationId] = L.intTaxLocationId
		FROM tblLGLoad L 
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId 
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId AND ISNULL(LC.ysnRejected, 0) = 0
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		WHERE L.intLoadId = @intLoadId
			AND 1 = (CASE WHEN (LDCL.intLoadDetailContainerLinkId IS NULL AND LD.dblQuantity - ISNULL(LD.dblDeliveredQuantity,0) > 0)
							OR (LDCL.intLoadDetailContainerLinkId IS NOT NULL 
								AND ISNULL(LC.ysnRejected, 0) <> 1 
								AND NOT EXISTS (SELECT 1 FROM tblICInventoryReceiptItem IRI 
												INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
												WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intContainerId = LC.intLoadContainerId AND IR.intSourceType = 2)
								) 
						THEN 1  ELSE 0 END)
		ORDER BY LDCL.intLoadDetailContainerLinkId
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink LDCL 
						INNER JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
						WHERE ISNULL(LC.ysnRejected, 0) = 0 AND LC.intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'Receipt already exists for all the containers in the inbound shipment.'
			END
			ELSE 
			BEGIN
				SET @strErrorMessage = 'Item has already been received.'			
			END
			RAISERROR (@strErrorMessage,16,1)
		END

		INSERT INTO @OtherCharges (
			[intOtherChargeEntityVendorId]
			,[intChargeId]
			,[strCostMethod]
			,[dblRate]
			,[dblAmount]
			,[dblQuantity]
			,[intCostUOMId]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[ysnAccrue]
			,[strReceiptType]
			,[intShipViaId]
			,[intCurrencyId]
			,[intEntityVendorId]
			,[intLocationId]
			,[ysnPrice]
			,[ysnSubCurrency]
			,[intCostCurrencyId]
			,[intShipFromId]
			,[strBillOfLadding]
			,[ysnInventoryCost]
			,[intLoadShipmentId]
			,[intLoadShipmentCostId]
			)
		SELECT 
			[intOtherChargeEntityVendorId] = CV.intEntityVendorId
			,[intChargeId] = CV.intItemId
			,[strCostMethod] = CV.strCostMethod
			,[dblRate] = CASE WHEN CV.strCostMethod = 'Amount' THEN 0
							ELSE (CV.[dblShipmentUnitPrice] / LOD.dblQuantityTotal) * LD.dblQuantity
							END
			,[dblAmount] = (CV.[dblTotal] / LOD.dblQuantityTotal) * LD.dblQuantity
			,[dblQuantity] = NULL
			,[intCostUOMId] = CV.intPriceItemUOMId
			,[intContractHeaderId] = CD.intContractHeaderId
			,[intContractDetailId] = LD.intPContractDetailId
			,[ysnAccrue] = 1
			,[strReceiptType] = 'Direct'
			,[intShipViaId] = NULL
			,[intCurrencyId] = L.intCurrencyId
			,[intEntityVendorId] = LD.intVendorEntityId
			,[intLocationId] = LD.intPCompanyLocationId
			,[ysnPrice] = CV.ysnPrice
			,[ysnSubCurrency] = CUR.ysnSubCurrency
			,[intCostCurrencyId] = CV.intCurrencyId
			,[intShipFromId] = EL.intEntityLocationId
			,[strBillOfLadding] = L.strBLNumber
			,[ysnInventoryCost] = I.ysnInventoryCost
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentCostId] = CV.intLoadCostId
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1
		LEFT JOIN tblAPBillDetail VP ON VP.intLoadId = L.intLoadId AND VP.intItemId = CV.intItemId
		LEFT JOIN tblAPBill AB ON AB.intBillId = VP.intBillId
		OUTER APPLY (SELECT dblQuantityTotal = SUM(LOD.dblQuantity) FROM tblLGLoadDetail LOD WHERE LOD.intLoadId = L.intLoadId) LOD
		OUTER APPLY (SELECT TOP 1 B.intBillId, B.ysnPosted FROM tblAPBill B JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId WHERE BD.intLoadShipmentCostId = CV.intLoadCostId) VCHR
		WHERE CV.intLoadId = @intLoadId AND ISNULL(AB.intTransactionType, 0) <> 3

		UNION ALL

		SELECT 
			[intOtherChargeEntityVendorId] = CLSL.intVendorId
			,[intChargeId] = LWS.intItemId
			,[strCostMethod] = CASE WHEN ISNULL(WRMD.intCalculateQty, 8) = 8 THEN 'Custom Unit' ELSE 'Per Unit' END -- If Calculate Qty is = 'Manual Entry', pass cost method 'Custom Unit' to the IR charges
			,[dblRate] = LWS.dblUnitRate
			,[dblAmount] = LWS.dblActualAmount
			,[dblQuantity] = CASE WHEN ISNULL(WRMD.intCalculateQty, 8) = 8 THEN LWS.dblQuantity ELSE NULL END
			,[intCostUOMId] = LWS.intItemUOMId
			,[intContractHeaderId] = CT.intContractHeaderId
			,[intContractDetailId] = CT.intContractDetailId
			,[ysnAccrue] = 1
			,[strReceiptType] = 'Direct'
			,[intShipViaId] = NULL
			,[intCurrencyId] = L.intCurrencyId
			,[intEntityVendorId] = CT.intVendorEntityId
			,[intLocationId] = CT.intPCompanyLocationId
			,[ysnPrice] = 0
			,[ysnSubCurrency] = CUR.ysnSubCurrency
			,[intCostCurrencyId] = L.intCurrencyId
			,[intShipFromId] = CT.intEntityLocationId
			,[strBillOfLadding] = L.strBLNumber
			,[ysnInventoryCost] = I.ysnInventoryCost
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentCostId] = NULL
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
		LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId
		OUTER APPLY (SELECT TOP 1 CD.intContractHeaderId, CD.intContractDetailId, 
						LD.intVendorEntityId, LD.intPCompanyLocationId, EL.intEntityLocationId
					FROM tblLGLoadDetail LD 
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId AND EL.ysnDefaultLocation = 1
					WHERE intLoadId = @intLoadId) CT
		WHERE L.intLoadId = @intLoadId
	
		INSERT INTO @LotEntries (
			[intLotId]
			,[strLotNumber]
			,[strLotAlias]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intContractHeaderId] 
			,[intContractDetailId]
			,[intItemUnitMeasureId]
			,[intItemId]
			,[dblQuantity]
			,[dblGrossWeight]
			,[dblTareWeight]
			,[strContainerNo]
			,[intSort]
			,[strMarkings]
			,[strCondition]
			,[intEntityVendorId]
			,[strReceiptType]
			,[intLocationId]
			,[intShipViaId]
			,[intShipFromId]
			,[intCurrencyId]
			,[intSourceType]
			,[strBillOfLadding]
			,[intSeasonCropYear]
			)
		SELECT DISTINCT [intLotId] = NULL
			,[strLotNumber] = NULL
			,[strLotAlias] = NULL
			,[intSubLocationId] = ISNULL(LW.intSubLocationId,LD.intPSubLocationId)
			,[intStorageLocationId] = LW.intStorageLocationId
			,[intContractHeaderId] = NULL
			,[intContractDetailId] = NULL
			,[intItemUnitMeasureId] = LD.intItemUOMId
			,[intItemId] = LD.intItemId
			,[dblQuantity] = ISNULL(LDCL.dblQuantity, ISNULL(LC.dblQuantity, LD.dblQuantity))
			,[dblGrossWeight] = ISNULL(LDCL.dblLinkGrossWt, ISNULL(LC.dblGrossWt, LD.dblGross))
			,[dblTareWeight] = ISNULL(LDCL.dblLinkTareWt, ISNULL(LC.dblTareWt, LD.dblTare))
			,[strContainerNo] = LC.strContainerNumber
			,[intSort] = ISNULL(LC.intLoadContainerId,0)
			,[strMarkings] = LC.strMarks
			,[strCondition] = @strLotCondition
			,[intEntityVendorId] = LD.intVendorEntityId
			,[strReceiptType] = 'Direct'
			,[intLocationId] = LD.intPCompanyLocationId
			,[intShipViaId] = NULL
			,[intShipFromId] = EL.intEntityLocationId
			,[intCurrencyId] = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
			,[intSourceType] = 0
			,[strBillOfLadding] = L.strBLNumber
			,[intSeasonCropYear] = LD.intCropYearId
		FROM tblLGLoad L  
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId 
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId AND ISNULL(LC.ysnRejected, 0) = 0
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId		
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
		WHERE LD.intLoadId = @intLoadId


		INSERT INTO @ReceiptTradeFinance (
			[strTradeFinanceNumber]
			,[intBankId]
			,[intBankAccountId] 
			,[intBorrowingFacilityId] 
			,[strBankReferenceNo] 
			,[intLimitTypeId] 
			,[intSublimitTypeId] 
			,[ysnSubmittedToBank]
			,[dtmDateSubmitted] 
			,[strApprovalStatus] 
			,[dtmDateApproved] 
			,[strWarrantNo] 
			,[intWarrantStatus] 
			,[strReferenceNo] 
			,[intOverrideFacilityValuation] 
			,[strComments] 
			
			,[intEntityVendorId]
			,[strReceiptType]
			,[intLocationId]
			,[intShipViaId]
			,[intShipFromId]
			,[intCurrencyId]
			,[intSourceType]
			,[strBillOfLadding]
			)
		SELECT 
			[strTradeFinanceNumber] = L.strTradeFinanceNo
			,[intBankId] = ba.intBankId
			,[intBankAccountId] = L.intBankAccountId
			,[intBorrowingFacilityId] = L.intBorrowingFacilityId
			,[strBankReferenceNo] = L.strBankReferenceNo
			,[intLimitTypeId] = L.intBorrowingFacilityLimitId
			,[intSublimitTypeId] = L.intBorrowingFacilityLimitDetailId
			,[ysnSubmittedToBank] = L.ysnSubmittedToBank
			,[dtmDateSubmitted] = L.dtmDateSubmitted
			,[strApprovalStatus] = approvalStatus.strApprovalStatus
			,[dtmDateApproved] = L.dtmDateApproved
			,[strWarrantNo] = L.strWarrantNo
			,[intWarrantStatus] = L.intWarrantStatus
			,[strReferenceNo] = L.strTradeFinanceReferenceNo
			,[intOverrideFacilityValuation] = L.intBankValuationRuleId
			,[strComments] = L.strTradeFinanceComments

			,[intEntityVendorId] = LD.intVendorEntityId
			,[strReceiptType] = 'Direct'
			,[intLocationId] = LD.intPCompanyLocationId
			,[intShipViaId] = NULL
			,[intShipFromId] = EL.intEntityLocationId
			,[intCurrencyId] = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
			,[intSourceType] = 0
			,[strBillOfLadding] = L.strBLNumber
		FROM tblLGLoad L  
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblCMBankAccount ba ON ba.intBankAccountId = L.intBankAccountId
			LEFT JOIN tblCTApprovalStatusTF approvalStatus ON approvalStatus.intApprovalStatusId = L.intApprovalStatusId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
		WHERE 
			L.intLoadId = @intLoadId

		IF NOT EXISTS (SELECT 1 FROM @ReceiptStagingTable)
		BEGIN
			RETURN
		END

		EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
									,@OtherCharges = @OtherCharges
									,@intUserId = @intEntityUserSecurityId
									,@LotEntries = @LotEntries
									,@ReceiptTradeFinance = @ReceiptTradeFinance

		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
		FROM #tmpAddItemReceiptResult

		SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
		FROM tblICInventoryReceiptItem
		WHERE intInventoryReceiptId = @intInventoryReceiptId

		WHILE @intMinInvRecItemId > 0
		BEGIN
			SET @intPContractDetailId = NULL
			SET @dblVoucherQty = NULL
			SET @dblBillQty = NULL

			SELECT @intPContractDetailId = intLineNo
				  ,@intPItemId = intItemId
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptItemId = @intMinInvRecItemId

			SELECT @dblPContractDetailQty = dblQuantity
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intPContractDetailId

			SELECT @intPEntityId = intEntityVendorId
			FROM tblICInventoryReceipt
			WHERE intInventoryReceiptId = @intInventoryReceiptId

			IF EXISTS (
					SELECT TOP 1 1
					FROM tblAPBill BI
					JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
					WHERE BID.intLoadId = @intLoadId
						AND BID.intContractDetailId = @intPContractDetailId
						AND BI.intTransactionType IN (1,2)
						AND BI.intEntityVendorId = @intPEntityId
						AND BID.intItemId = @intPItemId
					)
			BEGIN
				SELECT @dblVoucherQty = BID.dblQtyReceived
				FROM tblAPBill BI
				JOIN tblAPBillDetail BID ON BI.intBillId = BID.intBillId
				WHERE BID.intLoadId = @intLoadId
					AND BID.intContractDetailId = @intPContractDetailId
					AND BI.intTransactionType IN (1,2)
					AND BI.intEntityVendorId = @intPEntityId
					AND BID.intItemId = @intPItemId

				UPDATE tblICInventoryReceiptItem
				SET dblBillQty = (@dblVoucherQty / @dblPContractDetailQty) * dblReceived
				WHERE intInventoryReceiptItemId = @intMinInvRecItemId
			END

			SELECT @intMinInvRecItemId = MIN(intInventoryReceiptItemId)
			FROM tblICInventoryReceiptItem
			WHERE intInventoryReceiptId = @intInventoryReceiptId
			  AND intInventoryReceiptItemId > @intMinInvRecItemId
		END
	END
	ELSE 
	BEGIN /* Source Type: Not None */
		IF EXISTS (
				SELECT LD.intItemId
				FROM tblLGLoadDetail LD
				JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				WHERE LD.intLoadId = @intLoadId
					AND LD.intItemId <> U.intItemId
				)
		BEGIN
			UPDATE LD
			SET intItemUOMId = IU.intItemUOMId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
			JOIN tblICItemUOM IU ON IU.intUnitMeasureId = U.intUnitMeasureId
				AND IU.intItemId = LD.intItemId
			WHERE LD.intLoadId = @intLoadId
				AND LD.intItemId <> U.intItemId

			UPDATE LDCL
			SET intItemUOMId = LD.intItemUOMId
			FROM tblLGLoadDetail LD
			JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			WHERE LD.intItemUOMId <> LDCL.intItemUOMId AND LD.intLoadId = @intLoadId
		END

		/* Auto-correct Storage Location and Storage Unit */
		DECLARE @intPCompanyLocationId INT
		SELECT TOP 1 @intPCompanyLocationId = intPCompanyLocationId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId

		IF (@intPCompanyLocationId IS NOT NULL)
		BEGIN
			UPDATE LW
			SET intSubLocationId = (SELECT TOP 1 intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation 
									WHERE intCompanyLocationId = @intPCompanyLocationId AND strSubLocationName = CLSL.strSubLocationName)
			FROM tblLGLoadWarehouse LW
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
			WHERE intLoadId = @intLoadId
				AND LW.intSubLocationId NOT IN (SELECT intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationId = @intPCompanyLocationId)
		
			UPDATE LW
			SET intStorageLocationId = (SELECT TOP 1 intStorageLocationId FROM tblICStorageLocation 
									WHERE intLocationId = @intPCompanyLocationId AND intSubLocationId = LW.intSubLocationId AND strName = SL.strName)
			FROM tblLGLoadWarehouse LW
			LEFT JOIN tblICStorageLocation SL ON LW.intStorageLocationId = SL.intStorageLocationId
			WHERE intLoadId = @intLoadId
				AND LW.intStorageLocationId NOT IN (SELECT intStorageLocationId FROM tblICStorageLocation 
									WHERE intLocationId = @intPCompanyLocationId AND intSubLocationId = LW.intSubLocationId)
		END

		/* Update LS Unit Cost for Unpriced Contracts */
		UPDATE LD 
		SET dblUnitPrice = dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)
			,dblAmount = dbo.fnCalculateCostBetweenUOM(
								LD.intPriceUOMId
								, ISNULL(LD.intWeightItemUOMId, LD.intItemUOMId) 
								,(dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL) / CASE WHEN (CUR.ysnSubCurrency = 1) THEN CUR.intCent ELSE 1 END)
							) * CASE WHEN (LD.intWeightItemUOMId IS NOT NULL) THEN LD.dblNet ELSE LD.dblQuantity END		
		FROM tblLGLoadDetail LD
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
			LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
		WHERE ISNULL(LD.dblUnitPrice, 0) = 0 AND LD.intLoadId = @intLoadId

		IF EXISTS(SELECT TOP 1 1 FROM tblLGLoadDetail LD
			INNER JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
			WHERE L.intPurchaseSale <> 3 AND LD.intLoadId = @intLoadId AND ISNULL(LD.dblUnitPrice, 0) = 0) AND @strFOBPoint = 'Origin'
		BEGIN
			RAISERROR('One or more contracts is not yet priced. Please price the contracts or provide a provisional price to proceed.', 16, 1);
		END
	
		IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink LDCL 
					INNER JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
					WHERE ISNULL(LC.ysnRejected, 0) = 0 AND LC.intLoadId = @intLoadId)
		BEGIN
			INSERT INTO @ReceiptStagingTable (
				[strReceiptType]
				,[intEntityVendorId]
				,[intShipFromId]
				,[intLocationId]
				,[strBillOfLadding]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[dtmDate]
				,[intShipViaId]
				,[dblQty]
				,[intGrossNetUOMId]
				,[dblGross]
				,[dblTare]
				,[dblNet]
				,[dblCost]
				,[intCostUOMId]
				,[intCurrencyId]
				,[intSubCurrencyCents]
				,[dblExchangeRate]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[ysnIsStorage]
				,[intSourceId]
				,[intSourceType]
				,[strSourceId]
				,[strSourceScreenName]
				,[ysnSubCurrency]
				,[intForexRateTypeId]
				,[dblForexRate]
				,[intContainerId]
				,[intFreightTermId]
				,[intBookId]
				,[intSubBookId]
				,[intSort]
				,[intLoadShipmentId]
				,[intLoadShipmentDetailId]
				,[intTaxGroupId]
				,[strTaxPoint]
				,[intTaxLocationId]
				)
			SELECT [strReceiptType] = 'Purchase Contract'
				,[intEntityVendorId] = LD.intVendorEntityId
				,[intShipFromId] = EL.intEntityLocationId
				,[intLocationId] = CD.intCompanyLocationId
				,[strBillOfLadding] = L.strBLNumber
				,[intItemId] = LD.intItemId
				,[intItemLocationId] = CD.intCompanyLocationId
				,[intItemUOMId] = LD.intItemUOMId
				,[intContractHeaderId] = CD.intContractHeaderId
				,[intContractDetailId] = LD.intPContractDetailId
				,[dtmDate] = GETDATE()
				,[intShipViaId] = CD.intShipViaId
				,[dblQty] = ISNULL(LDCL.dblQuantity, 0) - ISNULL(LDCL.dblReceivedQty, 0)
				,[intGrossNetUOMId] = COALESCE(LCUOM.intItemUOMId, LD.intWeightItemUOMId, CD.intNetWeightUOMId)
				,[dblGross] = CASE WHEN ISNULL(LDCL.dblReceivedQty, 0) <> 0 THEN
								dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, COALESCE(LCUOM.intItemUOMId, LD.intWeightItemUOMId, CD.intNetWeightUOMId),
									ISNULL(LDCL.dblQuantity, 0) - ISNULL(LDCL.dblReceivedQty, 0))
								ELSE 
									ISNULL(LDCL.dblLinkGrossWt, 0)
								END
				,[dblTare] = 
						CASE 
							WHEN ISNULL(LDCL.dblReceivedQty, 0) <> 0 THEN
								--dbo.fnCalculateQtyBetweenUOM(
								--	LD.intItemUOMId
								--	, COALESCE(LCUOM.intItemUOMId, LD.intWeightItemUOMId, CD.intNetWeightUOMId)
								--	, ISNULL(LDCL.dblQuantity, 0) - ISNULL(LDCL.dblReceivedQty, 0))
								NULL 
							ELSE 
								ISNULL(LDCL.dblLinkTareWt, 0)
						END
				,[dblNet] = CASE WHEN ISNULL(LDCL.dblReceivedQty, 0) <> 0 THEN
								dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, COALESCE(LCUOM.intItemUOMId, LD.intWeightItemUOMId, CD.intNetWeightUOMId),
									ISNULL(LDCL.dblQuantity, 0) - ISNULL(LDCL.dblReceivedQty, 0))
								ELSE 
									ISNULL(LDCL.dblLinkNetWt, 0)
								END
				,[dblCost] = ISNULL(AD.dblSeqPrice, ISNULL(LD.dblUnitPrice,0))
				,[intCostUOMId] = dbo.fnGetMatchingItemUOMId(LD.intItemId, ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId))
				,intCurrencyId = CASE WHEN AD.ysnValidFX = 1 THEN CD.intInvoiceCurrencyId ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) END
				,[intSubCurrencyCents] = CASE WHEN (AD.ysnValidFX = 1) THEN SC.intCent ELSE COALESCE(LSC.intCent, SC.intCent, 1) END
				,[dblExchangeRate] = 1
				,[intLotId] = NULL
				,[intSubLocationId] = ISNULL(LW.intSubLocationId, CD.intSubLocationId)
				,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, CD.intStorageLocationId)
				,[ysnIsStorage] = 0
				,[intSourceId] = LD.intLoadDetailId
				,[intSourceType] = 2
				,[strSourceId] = L.strLoadNumber
				,[strSourceScreenName] = 'Contract'
				,[ysnSubCurrency] = CASE WHEN (AD.ysnValidFX = 1) THEN AD.ysnSeqSubCurrency ELSE ISNULL(LSC.ysnSubCurrency, AD.ysnSeqSubCurrency) END
				,[intForexRateTypeId] = CASE --if contract FX tab is setup
										WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN CD.intRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use null
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN FX.intForexRateTypeId --foreign price to foreign FX, use master FX rate
											ELSE LD.intForexRateTypeId END
										ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, ''))) 
											THEN FX.intForexRateTypeId
											ELSE LD.intForexRateTypeId END
										END
				,[dblForexRate] = CASE --if contract FX tab is setup
										WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN dbo.fnDivide(1, CD.dblRate) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
										ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, ISNULL(SC.intCurrencyID,''))) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
										END
				,[intContainerId] = ISNULL(LC.intLoadContainerId, -1)
				,[intFreightTermId] = L.intFreightTermId
				,[intBookId] = L.intBookId
				,[intSubBookId] = L.intSubBookId
				,[intSort] = ISNULL(LC.intLoadContainerId,0)
				,[intLoadShipmentId] = L.intLoadId
				,[intLoadShipmentDetailId] = LD.intLoadDetailId
				,[intTaxGroupId] = LD.intTaxGroupId
				,[strTaxPoint] = L.strTaxPoint
				,[intTaxLocationId] = L.intTaxLocationId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND intUnitMeasureId = LC.intWeightUnitMeasureId) LCUOM
			OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> CD.intInvoiceCurrencyId
							AND ((ER.intFromCurrencyId = CD.intInvoiceCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = CD.intInvoiceCurrencyId))
						ORDER BY RD.dtmValidFromDate DESC) FX
			WHERE L.intLoadId = @intLoadId
				AND ISNULL(LC.ysnRejected, 0) <> 1
				AND NOT EXISTS (SELECT 1 FROM tblICInventoryReceiptItem IRI 
								INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
								WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intContainerId = LC.intLoadContainerId AND IR.intSourceType = 2)
			ORDER BY LDCL.intLoadDetailContainerLinkId
		END
		ELSE
		BEGIN
			INSERT INTO @ReceiptStagingTable (
				[strReceiptType]
				,[intEntityVendorId]
				,[intShipFromId]
				,[intLocationId]
				,[strBillOfLadding]
				,[intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[dtmDate]
				,[intShipViaId]
				,[dblQty]
				,[intGrossNetUOMId]
				,[dblGross]
				,[dblTare]
				,[dblNet]
				,[dblCost]
				,[intCostUOMId]
				,[intCurrencyId]
				,[intSubCurrencyCents]
				,[dblExchangeRate]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[ysnIsStorage]
				,[intSourceId]
				,[intSourceType]
				,[strSourceId]
				,[strSourceScreenName]
				,[ysnSubCurrency]
				,[intForexRateTypeId]
				,[dblForexRate]
				,[intContainerId]
				,[intFreightTermId]
				,[intBookId]
				,[intSubBookId]
				,[intSort]
				,[intLoadShipmentId]
				,[intLoadShipmentDetailId]
				,[intTaxGroupId]
				,[strTaxPoint]
				,[intTaxLocationId]
				)
			SELECT [strReceiptType] = 'Purchase Contract'
				,[intEntityVendorId] = LD.intVendorEntityId
				,[intShipFromId] = EL.intEntityLocationId
				,[intLocationId] = CD.intCompanyLocationId
				,[strBillOfLadding] = L.strBLNumber
				,[intItemId] = LD.intItemId
				,[intItemLocationId] = CD.intCompanyLocationId
				,[intItemUOMId] = LD.intItemUOMId
				,[intContractHeaderId] = CD.intContractHeaderId
				,[intContractDetailId] = LD.intPContractDetailId
				,[dtmDate] = GETDATE()
				,[intShipViaId] = CD.intShipViaId
				,[dblQty] = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0)
				,[intGrossNetUOMId] = ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId)
				,[dblGross] = LD.dblGross - ISNULL(LD.dblDeliveredGross,0)
				,[dblTare] = LD.dblTare - ISNULL(LD.dblDeliveredTare,0)
				,[dblNet] = LD.dblNet -ISNULL(LD.dblDeliveredNet,0)
				,[dblCost] = ISNULL(AD.dblSeqPrice, ISNULL(LD.dblUnitPrice,0))
				,[intCostUOMId] = dbo.fnGetMatchingItemUOMId(LD.intItemId, ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId))
				,intCurrencyId = CASE WHEN AD.ysnValidFX = 1 THEN CD.intInvoiceCurrencyId ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) END
				,[intSubCurrencyCents] = CASE WHEN (AD.ysnValidFX = 1) THEN SC.intCent ELSE COALESCE(LSC.intCent, SC.intCent, 1) END
				,[dblExchangeRate] = 1
				,[intLotId] = NULL
				,[intSubLocationId] = ISNULL(CD.intSubLocationId, LD.intPSubLocationId)
				,[intStorageLocationId] = CD.intStorageLocationId
				,[ysnIsStorage] = 0
				,[intSourceId] = LD.intLoadDetailId
				,[intSourceType] = 2
				,[strSourceId] = L.strLoadNumber
				,[strSourceScreenName] = 'Contract'
				,[ysnSubCurrency] = CASE WHEN (AD.ysnValidFX = 1) THEN AD.ysnSeqSubCurrency ELSE LSC.ysnSubCurrency END
				,[intForexRateTypeId] = CASE --if contract FX tab is setup
										WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN CD.intRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use null
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN FX.intForexRateTypeId --foreign price to foreign FX, use master FX rate
											ELSE LD.intForexRateTypeId END
										ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, 0))) 
											THEN FX.intForexRateTypeId
											ELSE LD.intForexRateTypeId END
										END
				,[dblForexRate] = CASE --if contract FX tab is setup
										WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN dbo.fnDivide(1, CD.dblRate) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(LSC.intMainCurrencyId, ISNULL(LSC.intCurrencyID, '')) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
										ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, ISNULL(SC.intCurrencyID,''))) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
										END
				,[intContainerId] = -1
				,[intFreightTermId] = L.intFreightTermId
				,[intBookId] = L.intBookId
				,[intSubBookId] = L.intSubBookId
				,[intSort] = NULL
				,[intLoadShipmentId] = L.intLoadId
				,[intLoadShipmentDetailId] = LD.intLoadDetailId
				,[intTaxGroupId] = LD.intTaxGroupId
				,[strTaxPoint] = L.strTaxPoint
				,[intTaxLocationId] = L.intTaxLocationId
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> CD.intInvoiceCurrencyId
							AND ((ER.intFromCurrencyId = CD.intInvoiceCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = CD.intInvoiceCurrencyId))
						ORDER BY RD.dtmValidFromDate DESC) FX
			WHERE L.intLoadId = @intLoadId
				AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink LDCL 
						INNER JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
						WHERE ISNULL(LC.ysnRejected, 0) = 0 AND LC.intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'Receipt already exists for all the containers in the inbound shipment.'
			END
			ELSE 
			BEGIN
				SET @strErrorMessage = 'Item has already been received.'			
			END
			RAISERROR (@strErrorMessage,16,1)
		END

		INSERT INTO @OtherCharges (
			[intOtherChargeEntityVendorId]
			,[intChargeId]
			,[strCostMethod]
			,[dblRate]
			,[dblAmount]
			,[dblQuantity]
			,[intCostUOMId]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[ysnAccrue]
			,[strReceiptType]
			,[intShipViaId]
			,[intCurrencyId]
			,[intEntityVendorId]
			,[intLocationId]
			,[ysnPrice]
			,[ysnSubCurrency]
			,[intCostCurrencyId]
			,[intShipFromId]
			,[strBillOfLadding]
			,[ysnInventoryCost]
			,[intLoadShipmentId]
			,[intLoadShipmentCostId]
			)
		SELECT 
			[intOtherChargeEntityVendorId] = CV.intEntityVendorId
			,[intChargeId] = CV.intItemId
			,[strCostMethod] = CV.strCostMethod
			,[dblRate] = CASE WHEN CV.strCostMethod = 'Amount' THEN 0
							ELSE (CV.[dblShipmentUnitPrice] / LOD.dblQuantityTotal) * LD.dblQuantity
							END
			,[dblAmount] = (CV.[dblTotal] / LOD.dblQuantityTotal) * LD.dblQuantity
			,[dblQuantity] = NULL
			,[intCostUOMId] = CV.intPriceItemUOMId
			,[intContractHeaderId] = CD.intContractHeaderId
			,[intContractDetailId] = LD.intPContractDetailId
			,[ysnAccrue] = 1
			,[strReceiptType] = 'Purchase Contract'
			,[intShipViaId] = NULL
			,[intCurrencyId] = CASE WHEN (AD.ysnValidFX = 1) THEN AD.intSeqCurrencyId ELSE COALESCE(LSC.intMainCurrencyId, LSC.intCurrencyID, SC.intMainCurrencyId, SC.intCurrencyID) END
			,[intEntityVendorId] = LD.intVendorEntityId
			,[intLocationId] = LD.intPCompanyLocationId
			,[ysnPrice] = CV.ysnPrice
			,[ysnSubCurrency] = CUR.ysnSubCurrency
			,[intCostCurrencyId] = CV.intCurrencyId
			,[intShipFromId] = EL.intEntityLocationId
			,[strBillOfLadding] = L.strBLNumber
			,[ysnInventoryCost] = I.ysnInventoryCost
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentCostId] = CV.intLoadCostId
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1
		LEFT JOIN tblAPBillDetail VP ON VP.intLoadId = L.intLoadId AND VP.intItemId = CV.intItemId
		LEFT JOIN tblAPBill AB ON AB.intBillId = VP.intBillId
		OUTER APPLY (SELECT dblQuantityTotal = SUM(LOD.dblQuantity) FROM tblLGLoadDetail LOD WHERE LOD.intLoadId = L.intLoadId) LOD
		OUTER APPLY (SELECT TOP 1 B.intBillId, B.ysnPosted FROM tblAPBill B JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId WHERE BD.intLoadShipmentCostId = CV.intLoadCostId) VCHR
		WHERE CV.intLoadId = @intLoadId AND ISNULL(AB.intTransactionType, 0) <> 3

		UNION ALL

		SELECT 
			[intOtherChargeEntityVendorId] = CLSL.intVendorId
			,[intChargeId] = LWS.intItemId
			,[strCostMethod] = CASE WHEN ISNULL(WRMD.intCalculateQty, 8) = 8 THEN 'Custom Unit' ELSE 'Per Unit' END -- If Calculate Qty is = 'Manual Entry', pass cost method 'Custom Unit' to the IR charges
			,[dblRate] = LWS.dblUnitRate
			,[dblAmount] = LWS.dblActualAmount
			,[dblQuantity] = CASE WHEN ISNULL(WRMD.intCalculateQty, 8) = 8 THEN LWS.dblQuantity ELSE NULL END
			,[intCostUOMId] = LWS.intItemUOMId
			,[intContractHeaderId] = CT.intContractHeaderId
			,[intContractDetailId] = CT.intContractDetailId
			,[ysnAccrue] = 1
			,[strReceiptType] = 'Purchase Contract'
			,[intShipViaId] = NULL
			,[intCurrencyId] = CT.intCurrencyId
			,[intEntityVendorId] = CT.intVendorEntityId
			,[intLocationId] = CT.intPCompanyLocationId
			,[ysnPrice] = 0
			,[ysnSubCurrency] = CUR.ysnSubCurrency
			,[intCostCurrencyId] = L.intCurrencyId
			,[intShipFromId] = CT.intEntityLocationId
			,[strBillOfLadding] = L.strBLNumber
			,[ysnInventoryCost] = I.ysnInventoryCost
			,[intLoadShipmentId] = L.intLoadId
			,[intLoadShipmentCostId] = NULL
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
		LEFT JOIN tblLGWarehouseRateMatrixDetail WRMD ON WRMD.intWarehouseRateMatrixDetailId = LWS.intWarehouseRateMatrixDetailId 
		OUTER APPLY (SELECT TOP 1 CD.intContractHeaderId, CD.intContractDetailId, 
						LD.intVendorEntityId, LD.intPCompanyLocationId, EL.intEntityLocationId
						,[intCurrencyId] = CASE WHEN (AD.ysnValidFX = 1) THEN AD.intSeqCurrencyId ELSE COALESCE(LSC.intMainCurrencyId, LSC.intCurrencyID, SC.intMainCurrencyId, SC.intCurrencyID) END
					FROM tblLGLoadDetail LD 
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId AND EL.ysnDefaultLocation = 1
					LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
					LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
					LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
					WHERE intLoadId = @intLoadId) CT
		WHERE L.intLoadId = @intLoadId
		
		INSERT INTO @LotEntries (
			[intLotId]
			,[strLotNumber]
			,[strLotAlias]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intContractHeaderId] 
			,[intContractDetailId]
			,[intItemUnitMeasureId]
			,[intItemId]
			,[dblQuantity]
			,[dblGrossWeight]
			,[dblTareWeight]
			,[strContainerNo]
			,[intSort]
			,[strMarkings]
			,[strCondition]
			,[intEntityVendorId]
			,[strReceiptType]
			,[intLocationId]
			,[intShipViaId]
			,[intShipFromId]
			,[intCurrencyId]
			,[intSourceType]
			,[strBillOfLadding]
			,[strCertificate]
			,[intProducerId]
			,[strCertificateId]
			,[strTrackingNumber]
			,[intSeasonCropYear]
			)
		SELECT DISTINCT [intLotId] = NULL
			,[strLotNumber] = NULL
			,[strLotAlias] = NULL
			,[intSubLocationId] = LW.intSubLocationId
			,[intStorageLocationId] = LW.intStorageLocationId
			,[intContractHeaderId] = CD.intContractHeaderId
			,[intContractDetailId] = CD.intContractDetailId
			,[intItemUnitMeasureId] = LD.intItemUOMId
			,[intItemId] = LD.intItemId
			,[dblQuantity] = ISNULL(LDCL.dblQuantity, ISNULL(LC.dblQuantity, LD.dblQuantity))
			,[dblGrossWeight] = ISNULL(LDCL.dblLinkGrossWt, ISNULL(LC.dblGrossWt, LD.dblGross))
			,[dblTareWeight] = ISNULL(LDCL.dblLinkTareWt, ISNULL(LC.dblTareWt, LD.dblTare))
			,[strContainerNo] = LC.strContainerNumber
			,[intSort] = ISNULL(LC.intLoadContainerId,0)
			,[strMarkings] = LC.strMarks
			,[strCondition] = @strLotCondition
			,[intEntityVendorId] = LD.intVendorEntityId
			,[strReceiptType] = 'Purchase Contract'
			,[intLocationId] = CD.intCompanyLocationId
			,[intShipViaId] = NULL
			,[intShipFromId] = EL.intEntityLocationId
			,[intCurrencyId] = ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
			,[intSourceType] = 2
			,[strBillOfLadding] = L.strBLNumber
			,[strCertificate] = CASE WHEN 
									(SELECT COUNT(1) FROM tblCTContractCertification WHERE intContractDetailId = CD.intContractDetailId) <= 1
									THEN CF.strCertificationName
									ELSE NULL
								END
			,[intProducerId] = CASE WHEN 
									(SELECT COUNT(1) FROM tblCTContractCertification WHERE intContractDetailId = CD.intContractDetailId) <= 1
									THEN CC.intProducerId
									ELSE NULL
								END
			,[strCertificateId] = CASE WHEN 
									(SELECT COUNT(1) FROM tblCTContractCertification WHERE intContractDetailId = CD.intContractDetailId) <= 1
									THEN CC.strCertificationId
									ELSE NULL
								END
			,[strTrackingNumber] = CASE WHEN 
									(SELECT COUNT(1) FROM tblCTContractCertification WHERE intContractDetailId = CD.intContractDetailId) <= 1
									THEN CC.strTrackingNumber
									ELSE NULL
								END
			,[intSeasonCropYear] = LD.intCropYearId
		FROM tblLGLoad L 
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId 
		JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1 
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblCTContractCertification CC ON CC.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblICCertification CF ON CF.intCertificationId = CC.intCertificationId
		LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LD.intLoadId = LW.intLoadId
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
		WHERE LD.intLoadId = @intLoadId

		INSERT INTO @ReceiptTradeFinance (
			[strTradeFinanceNumber]
			,[intBankId]
			,[intBankAccountId] 
			,[intBorrowingFacilityId] 
			,[strBankReferenceNo] 
			,[intLimitTypeId] 
			,[intSublimitTypeId] 
			,[ysnSubmittedToBank]
			,[dtmDateSubmitted] 
			,[strApprovalStatus] 
			,[dtmDateApproved] 
			,[strWarrantNo] 
			,[intWarrantStatus] 
			,[strReferenceNo] 
			,[intOverrideFacilityValuation] 
			,[strComments] 
			
			,[intEntityVendorId]
			,[strReceiptType]
			,[intLocationId]
			,[intShipViaId]
			,[intShipFromId]
			,[intCurrencyId]
			,[intSourceType]
			,[strBillOfLadding]
			)
		SELECT 
			[strTradeFinanceNumber] = L.strTradeFinanceNo
			,[intBankId] = ba.intBankId
			,[intBankAccountId] = L.intBankAccountId
			,[intBorrowingFacilityId] = L.intBorrowingFacilityId
			,[strBankReferenceNo] = L.strBankReferenceNo
			,[intLimitTypeId] = L.intBorrowingFacilityLimitId
			,[intSublimitTypeId] = L.intBorrowingFacilityLimitDetailId
			,[ysnSubmittedToBank] = L.ysnSubmittedToBank
			,[dtmDateSubmitted] = L.dtmDateSubmitted
			,[strApprovalStatus] = approvalStatus.strApprovalStatus
			,[dtmDateApproved] = L.dtmDateApproved
			,[strWarrantNo] = NULL
			,[intWarrantStatus] = NULL
			,[strReferenceNo] = L.strTradeFinanceReferenceNo
			,[intOverrideFacilityValuation] = L.intBankValuationRuleId
			,[strComments] = L.strTradeFinanceComments

			,[intEntityVendorId] = LD.intVendorEntityId
			,[strReceiptType] = 'Purchase Contract'
			,[intLocationId] = CD.intCompanyLocationId
			,[intShipViaId] = NULL
			,[intShipFromId] = EL.intEntityLocationId
			,[intCurrencyId] = ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
			,[intSourceType] = 2
			,[strBillOfLadding] = L.strBLNumber
		FROM tblLGLoad L  
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId 
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			LEFT JOIN tblCTContractCertification CC ON CC.intContractDetailId = CD.intContractDetailId
			LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblCMBankAccount ba ON ba.intBankAccountId = L.intBankAccountId
			LEFT JOIN tblCTApprovalStatusTF approvalStatus ON approvalStatus.intApprovalStatusId = L.intApprovalStatusId
		WHERE 
			L.intLoadId = @intLoadId
			AND ISNULL(L.strTradeFinanceNo, '') <> ''

		IF NOT EXISTS (
				SELECT 1
				FROM @ReceiptStagingTable
				)
		BEGIN
			RETURN
		END

		EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
									,@OtherCharges = @OtherCharges
									,@intUserId = @intEntityUserSecurityId
									,@LotEntries = @LotEntries
									,@ReceiptTradeFinance = @ReceiptTradeFinance

		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
		FROM #tmpAddItemReceiptResult
	END


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH