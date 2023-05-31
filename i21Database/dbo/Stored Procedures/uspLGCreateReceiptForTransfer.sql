CREATE PROCEDURE [dbo].[uspLGCreateReceiptForTransfer] 
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
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')

	/* Validate "To" Company Location */
	IF EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadId = @intLoadId AND intSCompanyLocationId IS NULL)
	BEGIN
		SET @strErrorMessage = 'To Company Location is not specified.'
		RAISERROR (@strErrorMessage,16,1)
	END

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult'))
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END 
	
	/* Auto-correct Load Detail and Container Link UOM */
	IF EXISTS (SELECT LD.intItemId FROM tblLGLoadDetail LD JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
				WHERE LD.intLoadId = @intLoadId AND LD.intItemId <> U.intItemId)
	BEGIN
		UPDATE LD SET intItemUOMId = IU.intItemUOMId
		FROM tblLGLoad L JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId JOIN tblICItemUOM U ON U.intItemUOMId = LD.intItemUOMId
		JOIN tblICItemUOM IU ON IU.intUnitMeasureId = U.intUnitMeasureId AND IU.intItemId = LD.intItemId
		WHERE LD.intLoadId = @intLoadId AND LD.intItemId <> U.intItemId

		UPDATE LDCL SET intItemUOMId = LD.intItemUOMId FROM tblLGLoadDetail LD
		JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		WHERE LD.intItemUOMId <> LDCL.intItemUOMId AND LD.intLoadId = @intLoadId
	END

	/* Auto-correct Storage Location and Storage Unit */
	DECLARE @intCompanyLocationId INT
	SELECT TOP 1 @intCompanyLocationId = ISNULL(intSCompanyLocationId, intPCompanyLocationId) FROM tblLGLoadDetail WHERE intLoadId = @intLoadId
	IF (@intCompanyLocationId IS NOT NULL)
	BEGIN
		UPDATE LW
		SET intSubLocationId = (SELECT TOP 1 intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation 
								WHERE intCompanyLocationId = @intCompanyLocationId AND strSubLocationName = CLSL.strSubLocationName)
		FROM tblLGLoadWarehouse LW
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
		WHERE intLoadId = @intLoadId
			AND LW.intSubLocationId NOT IN (SELECT intCompanyLocationSubLocationId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationId = @intCompanyLocationId)
		
		UPDATE LW
		SET intStorageLocationId = (SELECT TOP 1 intStorageLocationId FROM tblICStorageLocation 
								WHERE intLocationId = @intCompanyLocationId AND intSubLocationId = LW.intSubLocationId AND strName = SL.strName)
		FROM tblLGLoadWarehouse LW
		LEFT JOIN tblICStorageLocation SL ON LW.intStorageLocationId = SL.intStorageLocationId
		WHERE intLoadId = @intLoadId
			AND LW.intStorageLocationId NOT IN (SELECT intStorageLocationId FROM tblICStorageLocation 
								WHERE intLocationId = @intCompanyLocationId AND intSubLocationId = LW.intSubLocationId)
	END
	
	/* Construct Receipt Staging Parameter */
	INSERT INTO @ReceiptStagingTable (
		[strReceiptType]
		,[intTransferorId]
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
		,[ysnSubCurrency]
		,[dblExchangeRate]
		,[intLotId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[ysnIsStorage]
		,[intSourceId]
		,[intSourceType]
		,[strSourceId]
		,[strSourceScreenName]
		,[intContainerId]
		,[intBookId]
		,[intSubBookId]
		,[intSort]
		,[intLoadShipmentId]
		,[intLoadShipmentDetailId]
		)
	SELECT [strReceiptType] = 'Transfer Order'
		,[intTransferorId] = LD.intPCompanyLocationId
		,[intEntityVendorId] = NULL --LD.intVendorEntityId
		,[intShipFromId] = LD.intPCompanyLocationId
		,[intLocationId] = LD.intSCompanyLocationId
		,[strBillOfLadding] = L.strBLNumber
		,[intItemId] = LD.intItemId
		,[intItemLocationId] = LD.intPCompanyLocationId
		,[intItemUOMId] = LD.intItemUOMId
		,[intContractHeaderId] = CD.intContractHeaderId
		,[intContractDetailId] = CD.intContractDetailId
		,[dtmDate] = GETDATE()
		,[intShipViaId] = CD.intShipViaId
		,[dblQty] = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0)
		,[intGrossNetUOMId] = ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId)
		,[dblGross] = LD.dblGross - ISNULL(LD.dblDeliveredGross,0)
		,[dblTare] = LD.dblTare - ISNULL(LD.dblDeliveredTare,0)
		,[dblNet] = LD.dblNet -ISNULL(LD.dblDeliveredNet,0)
		,[dblCost] = ISNULL(AD.dblSeqPrice, ISNULL(LD.dblUnitPrice,0))
		,[intCostUOMId] = dbo.fnGetMatchingItemUOMId(LD.intItemId, ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId))
		,[intCurrencyId] = CASE WHEN AD.ysnValidFX = 1 THEN CD.intInvoiceCurrencyId ELSE ISNULL(SC.intMainCurrencyId, SC.intCurrencyID) END
		,[intSubCurrencyCents] = CASE WHEN (AD.ysnValidFX = 1) THEN SC.intCent ELSE COALESCE(LSC.intCent, SC.intCent, 1) END
		,[ysnSubCurrency] = CASE WHEN (AD.ysnValidFX = 1) THEN AD.ysnSeqSubCurrency ELSE ISNULL(LSC.ysnSubCurrency, AD.ysnSeqSubCurrency) END
		,[dblExchangeRate] = 1
		,[intLotId] = NULL
		,[intSubLocationId] = LD.intSSubLocationId
		,[intStorageLocationId] = LD.intSStorageLocationId
		,[ysnIsStorage] = 0
		,[intSourceId] = LD.intLoadDetailId
		,[intSourceType] = 9 --TEMPORARY Source Type for Transfer Shipment
		,[strSourceId] = L.strLoadNumber
		,[strSourceScreenName] = 'Load Shipment/Schedule'
		,[intContainerId] = ISNULL(LC.intLoadContainerId, -1)
		,[intBookId] = L.intBookId
		,[intSubBookId] = L.intSubBookId
		,[intSort] = LD.intLoadDetailId
		,[intLoadShipmentId] = L.intLoadId
		,[intLoadShipmentDetailId] = LD.intLoadDetailId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN vyuLGAdditionalColumnForContractDetailView AD ON CD.intContractDetailId = AD.intContractDetailId
	JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId AND IL.intLocationId = CD.intCompanyLocationId
	JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId AND EL.ysnDefaultLocation = 1
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
	LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
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
	OUTER APPLY (SELECT	TOP 1 intBillId FROM tblAPBillDetail WHERE intLoadDetailId = LD.intLoadDetailId) VCHR
	WHERE L.intLoadId = @intLoadId
		AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0
		AND NOT EXISTS (SELECT 1 FROM tblICInventoryReceiptItem IRI 
						INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
						WHERE IRI.intSourceId = LD.intLoadDetailId AND IR.intSourceType = 9) --TEMPORARY Source Type for Transfer Shipment

	IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
	BEGIN
		IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink LDCL 
					INNER JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
					WHERE ISNULL(LC.ysnRejected, 0) = 0 AND LC.intLoadId = @intLoadId)
		BEGIN
			SET @strErrorMessage = 'Receipt already exists for all the containers in the transfer shipment.'
		END
		ELSE 
		BEGIN
			SET @strErrorMessage = 'Item has already been received.'			
		END
		RAISERROR (@strErrorMessage,16,1)
	END

	/* Construct Other Charges Staging Parameter */
	INSERT INTO @OtherCharges (
		[intOtherChargeEntityVendorId]
		,[intChargeId]
		,[strCostMethod]
		,[dblRate]
		,[dblAmount]
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
						ELSE ROUND((CV.[dblShipmentUnitPrice] / LOD.dblQuantityTotal) * CONVERT(NUMERIC(18, 6), LD.dblQuantity), 2)
						END
		,[dblAmount] = ROUND((CV.[dblTotal] / LOD.dblQuantityTotal) * LD.dblQuantity, 2)
		,[intCostUOMId] = CV.intItemUOMId
		,[intContractHeaderId] = NULL
		,[intContractDetailId] = LD.intPContractDetailId
		,[ysnAccrue] = 1
		,[strReceiptType] = 'Transfer Order'
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
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId AND EL.ysnDefaultLocation = 1
		OUTER APPLY (SELECT dblQuantityTotal = SUM(LOD.dblQuantity) FROM tblLGLoadDetail LOD WHERE LOD.intLoadId = L.intLoadId) LOD
	WHERE CV.intLoadId = @intLoadId
	UNION ALL
	SELECT 
		[intOtherChargeEntityVendorId] = CLSL.intVendorId
		,[intChargeId] = LWS.intItemId
		,[strCostMethod] = 'Per Unit'
		,[dblRate] = LWS.dblUnitRate
		,[dblAmount] = LWS.dblActualAmount
		,[intCostUOMId] = LWS.intItemUOMId
		,[intContractHeaderId] = NULL
		,[intContractDetailId] = NULL
		,[ysnAccrue] = 1
		,[strReceiptType] = 'Transfer Order'
		,[intShipViaId] = NULL
		,[intCurrencyId] = L.intCurrencyId
		,[intEntityVendorId] = LD.intVendorEntityId
		,[intLocationId] = ISNULL(CLSL.intCompanyLocationId, LD.intSCompanyLocationId)
		,[ysnPrice] = 0
		,[ysnSubCurrency] = CUR.ysnSubCurrency
		,[intCostCurrencyId] = L.intCurrencyId
		,[intShipFromId] = NULL
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
		OUTER APPLY (SELECT TOP 1 LD.intVendorEntityId, LD.intSCompanyLocationId FROM tblLGLoadDetail LD WHERE intLoadId = @intLoadId) LD
	WHERE L.intLoadId = @intLoadId
		
	/* Construct Lots Staging Parameter */
	INSERT INTO @LotEntries (
		[intLotId]
		,[strLotNumber]
		,[strLotAlias]
		,[intParentLotId]
		,[strParentLotNumber]
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
		,[strTrackingNumber]
		)
	SELECT DISTINCT [intLotId] = ISNULL(LDL.intNewLotId, Lot.intLotId)
		,[strLotNumber] = CASE WHEN ISNULL(LDL.strNewLotNumber, '') <> '' THEN LDL.strNewLotNumber ELSE Lot.strLotNumber END
		,[strLotAlias] = Lot.strLotAlias
		,[intParentLotId] = Lot.intParentLotId
		,[strParentLotNumber] = PLot.strParentLotNumber
		,[intSubLocationId] = LD.intSSubLocationId
		,[intStorageLocationId] = LD.intSStorageLocationId
		,[intContractHeaderId] = CD.intContractHeaderId
		,[intContractDetailId] = CD.intContractDetailId
		,[intItemUnitMeasureId] = LD.intItemUOMId
		,[intItemId] = LD.intItemId
		,[dblQuantity] = LDL.dblLotQuantity
		,[dblGrossWeight] = LDL.dblGross
		,[dblTareWeight] = LDL.dblTare
		,[strContainerNo] = LC.strContainerNumber
		,[intSort] = LD.intLoadDetailId
		,[strMarkings] = LC.strMarks
		,[strCondition] = Lot.strCondition
		,[intEntityVendorId] = NULL --LD.intVendorEntityId
		,[strReceiptType] = 'Transfer Order'
		,[intLocationId] = LD.intSCompanyLocationId
		,[intShipViaId] = L.intHaulerEntityId
		,[intShipFromId] = LD.intPCompanyLocationId
		,[intCurrencyId] = @DefaultCurrencyId
		,[intSourceType] =  9 --TEMPORARY Source Type for Transfer Shipment
		,[strBillOfLadding] = L.strBLNumber
		,[strTrackingNumber] = Lot.strTrackingNumber
	FROM tblLGLoadDetailLot LDL
		JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblICParentLot PLot ON PLot.intParentLotId = Lot.intParentLotId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
	WHERE LD.intLoadId = @intLoadId

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

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
