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
		,[dblNet]
		,[dblCost]
		,[intCostUOMId]
		,[intCurrencyId]
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
		,[intLocationId] = ISNULL(CLSL.intCompanyLocationId, LD.intSCompanyLocationId)
		,[strBillOfLadding] = L.strBLNumber
		,[intItemId] = LD.intItemId
		,[intItemLocationId] = LD.intPCompanyLocationId
		,[intItemUOMId] = LD.intItemUOMId
		,[intContractHeaderId] = NULL
		,[intContractDetailId] = NULL
		,[dtmDate] = GETDATE()
		,[intShipViaId] = ISNULL(LW.intHaulerEntityId, L.intHaulerEntityId)
		,[dblQty] = COALESCE(LDCL.dblQuantity, LD.dblQuantity, 0)
		,[intGrossNetUOMId] = COALESCE(Lot.intWeightUOMId, LCUOM.intItemUOMId, LD.intWeightItemUOMId)
		,[dblGross] = COALESCE(LD.dblGross, LDCL.dblLinkGrossWt, 0)
		,[dblNet] = COALESCE(LD.dblNet, LDCL.dblLinkNetWt, 0)
		,[dblCost] = --COALESCE(Lot.dblLastCost, ItemPricing.dblLastCost)
			dbo.fnCalculateCostBetweenUOM(
				topValuation.intItemUOMId
				,ISNULL(Lot.intWeightUOMId, StkUOM.intItemUOMId) 
				,valuationCost.dblCost
			)
		,[intCostUOMId] = ISNULL(Lot.intWeightUOMId, StkUOM.intItemUOMId) --StkUOM.intItemUOMId
		,[intCurrencyId] = @DefaultCurrencyId
		,[dblExchangeRate] = 1
		,[intLotId] = NULL
		,[intSubLocationId] = ISNULL(LW.intSubLocationId, LD.intSSubLocationId)
		,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, LD.intSStorageLocationId)
		,[ysnIsStorage] = 0
		,[intSourceId] = LD.intLoadDetailId
		,[intSourceType] = 9 --TEMPORARY Source Type for Transfer Shipment
		,[strSourceId] = L.strLoadNumber
		,[strSourceScreenName] = 'Load Shipment/Schedule'
		,[intContainerId] = ISNULL(LC.intLoadContainerId, -1)
		,[intBookId] = L.intBookId
		,[intSubBookId] = L.intSubBookId
		,[intSort] = ISNULL(LC.intLoadContainerId,0)
		,[intLoadShipmentId] = L.intLoadId
		,[intLoadShipmentDetailId] = LD.intLoadDetailId
	FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId
		LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblICItemPricing ItemPricing ON ItemPricing.intItemId = LD.intItemId
			AND ItemPricing.intItemLocationId = dbo.fnICGetItemLocation(LD.intItemId, LD.intPCompanyLocationId)
		OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND intUnitMeasureId = LC.intWeightUnitMeasureId) LCUOM
		OUTER APPLY (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND ysnStockUOM = 1) StkUOM
		OUTER APPLY (
			SELECT 				
				dblCost = 
					dbo.fnDivide(
						SUM(dbo.fnMultiply(ISNULL(t.dblQty, 0), ISNULL(t.dblCost, 0)) + ISNULL(t.dblValue, 0))
						,SUM(t.dblQty) 
					)
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.strTransactionId = L.strLoadNumber
				AND t.intTransactionId = L.intLoadId
				AND t.intTransactionDetailId = LD.intLoadDetailId
				AND t.intItemId = LD.intItemId
				AND t.dblQty > 0
				AND t.ysnIsUnposted = 0 
		) valuationCost 
		OUTER APPLY (
			SELECT TOP 1 			
				t.* 
			FROM 
				tblICInventoryTransaction t 
			WHERE
				t.strTransactionId = L.strLoadNumber
				AND t.intTransactionId = L.intLoadId
				AND t.intTransactionDetailId = LD.intLoadDetailId
				AND t.intItemId = LD.intItemId
				AND t.dblQty > 0
				AND t.ysnIsUnposted = 0 
		) topValuation
	WHERE L.intLoadId = @intLoadId
		AND NOT EXISTS (SELECT 1 FROM tblICInventoryReceiptItem IRI 
						INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
						WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intContainerId = LC.intLoadContainerId AND IR.intSourceType = 9) --TEMPORARY Source Type for Transfer Shipment
	ORDER BY LDCL.intLoadDetailContainerLinkId

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
		,[strCertificate]
		,[intProducerId]
		,[strCertificateId]
		,[strTrackingNumber]
		)
	SELECT DISTINCT [intLotId] = LDL.intNewLotId
		,[strLotNumber] = CASE WHEN ISNULL(LDL.strNewLotNumber, '') <> '' THEN LDL.strNewLotNumber ELSE Lot.strLotNumber END
		,[strLotAlias] = Lot.strLotAlias
		,[intParentLotId] = Lot.intParentLotId
		,[strParentLotNumber] = PLot.strParentLotNumber
		,[intSubLocationId] = ISNULL(LW.intSubLocationId, LD.intSSubLocationId)
		,[intStorageLocationId] = ISNULL(LW.intStorageLocationId, LD.intSStorageLocationId)
		,[intContractHeaderId] = NULL
		,[intContractDetailId] = NULL
		,[intItemUnitMeasureId] = LD.intItemUOMId
		,[intItemId] = LD.intItemId
		,[dblQuantity] = LDL.dblLotQuantity
		,[dblGrossWeight] = LDL.dblGross
		,[dblTareWeight] = LDL.dblTare
		,[strContainerNo] = LC.strContainerNumber
		,[intSort] = ISNULL(LC.intLoadContainerId,0)
		,[strMarkings] = LC.strMarks
		,[strCondition] = Lot.strCondition
		,[intEntityVendorId] = NULL --LD.intVendorEntityId
		,[strReceiptType] = 'Transfer Order'
		,[intLocationId] = ISNULL(CLSL.intCompanyLocationId, LD.intSCompanyLocationId)
		,[intShipViaId] = ISNULL(LW.intHaulerEntityId, L.intHaulerEntityId)
		,[intShipFromId] = LD.intPCompanyLocationId
		,[intCurrencyId] = @DefaultCurrencyId
		,[intSourceType] =  9 --TEMPORARY Source Type for Transfer Shipment
		,[strBillOfLadding] = L.strBLNumber
		,[strCertificate] = Lot.strCertificate
		,[intProducerId] = Lot.intProducerId
		,[strCertificateId] = Lot.strCertificateId
		,[strTrackingNumber] = Lot.strTrackingNumber
	FROM tblLGLoadDetailLot LDL
		JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDL.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblICParentLot PLot ON PLot.intParentLotId = Lot.intParentLotId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LD.intLoadId = LW.intLoadId
		LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
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
