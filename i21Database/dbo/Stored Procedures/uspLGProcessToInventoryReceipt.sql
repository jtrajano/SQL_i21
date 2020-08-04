CREATE PROCEDURE [dbo].[uspLGProcessToInventoryReceipt] 
	 @intLoadId INT
	,@intEntityUserSecurityId INT
	,@intInventoryReceiptId INT OUTPUT
AS
BEGIN TRY
	DECLARE @strErrorMessage NVARCHAR(MAX)
	DECLARE @ErrorSeverity INT
	DECLARE @ErrorState INT
	DECLARE @InventoryReceiptId INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSourceId INT
	DECLARE @intContractDetailId INT
	DECLARE @intLoadDetailId INT
	DECLARE @intMinRecordId INT
	DECLARE @dblLoadDetailQty NUMERIC(18, 6)
	DECLARE @intInventoryReceiptItemId INT
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @LotEntries ReceiptItemLotStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @intPContractDetailId INT
	DECLARE @intPEntityId INT
	DECLARE @intPItemId INT
	DECLARE @intLoadSourceType INT
	DECLARE @intMinInvRecItemId INT
	DECLARE @dblVoucherQty NUMERIC(18,6)
	DECLARE @dblBillQty NUMERIC(18, 6)
	DECLARE @dblPContractDetailQty NUMERIC(18, 6)
	DECLARE @strLotCondition NVARCHAR(50)
	DECLARE @DefaultCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @tblLoadDetail TABLE (
		intRecordId INT Identity(1, 1)
		,intLoadDetailId INT
		,intContractDetailId INT
		,dblLoadDetailQty NUMERIC(18, 6)
		)

	SELECT TOP 1 @strLotCondition = strLotCondition
	FROM tblICCompanyPreference

	INSERT INTO @tblLoadDetail
	SELECT intLoadDetailId
		,intPContractDetailId
		,dblQuantity
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId

	SELECT @intLoadSourceType = intSourceType
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult'))
	BEGIN
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
			)
	END

	IF ISNULL(@intLoadSourceType,0) = 1
	BEGIN
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

		IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
		BEGIN
			INSERT INTO @ReceiptStagingTable (
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,strBillOfLadding
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,intGrossNetUOMId
				,dblGross
				,dblNet
				,dblCost
				,intCostUOMId
				,intCurrencyId
				,intSubCurrencyCents
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intSourceId
				,intSourceType
				,strSourceId
				,strSourceScreenName
				,ysnSubCurrency
				,intForexRateTypeId
				,dblForexRate
				,intContainerId
				,intFreightTermId
				,intBookId
				,intSubBookId
				,intSort
				)
			SELECT strReceiptType = 'Direct'
				,intEntityVendorId = LD.intVendorEntityId
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = LD.intPCompanyLocationId
				,L.strBLNumber
				,intItemId = LD.intItemId
				,intItemLocationId = LD.intPCompanyLocationId
				,intItemUOMId = LD.intItemUOMId
				,intContractHeaderId = NULL
				,intContractDetailId = NULL
				,dtmDate = GETDATE()
				,intShipViaId = NULL
				,dblQty = ISNULL(LDCL.dblQuantity, LD.dblQuantity)
				,intGrossNetUOMId = LD.intWeightItemUOMId
				,dblGross = ISNULL(LDCL.dblLinkGrossWt, LD.dblGross)
				,dblNet = ISNULL(LDCL.dblLinkNetWt, LD.dblNet)
				,dblCost = ISNULL(LD.dblUnitPrice,0)
				,intCostUOMId = LD.intPriceUOMId
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = LW.intSubLocationId 
				,intStorageLocationId = LW.intStorageLocationId
				,ysnIsStorage = 0
				,intSourceId = NULL
				,intSourceType = 0
				,strSourceId = NULL
				,strSourceScreenName = NULL
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
				,ISNULL(LC.intLoadContainerId, - 1)
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
				,ISNULL(LC.intLoadContainerId, 0)
			FROM tblLGLoad L 
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId 
				AND IL.intLocationId = LD.intPCompanyLocationId 
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId 
				AND EL.ysnDefaultLocation = 1 
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId 
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN L.intCurrencyId
					ELSE NULL
					END 
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			WHERE CAST((
						CASE 
							WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0
								THEN 0
							ELSE 1
							END
						) AS BIT) = 0
				AND L.intLoadId = @intLoadId
				AND ISNULL(LC.ysnRejected, 0) <> 1 
				AND ISNULL(LDCL.dblReceivedQty,0) = 0
			ORDER BY LDCL.intLoadDetailContainerLinkId
		END
		ELSE
		BEGIN
			
			INSERT INTO @ReceiptStagingTable (
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,strBillOfLadding
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,intGrossNetUOMId
				,dblGross
				,dblNet
				,dblCost
				,intCostUOMId
				,intCurrencyId
				,intSubCurrencyCents
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intSourceId
				,intSourceType
				,strSourceId
				,strSourceScreenName
				,ysnSubCurrency
				,intForexRateTypeId
				,dblForexRate
				,intContainerId
				,intFreightTermId
				,intBookId
				,intSubBookId
				,intSort
				)
			SELECT strReceiptType = 'Direct'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = LD.intPCompanyLocationId
				,L.strBLNumber 
				,intItemId = LD.intItemId 
				,intItemLocationId = LD.intPCompanyLocationId
				,intItemUOMId = LD.intItemUOMId
				,intContractHeaderId = NULL 
				,intContractDetailId = NUll 
				,dtmDate = GETDATE()
				,intShipViaId = NULl
				,dblQty = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0)
				,intGrossNetUOMId = LD.intWeightItemUOMId
				,dblGross =  LD.dblGross - ISNULL(LD.dblDeliveredGross,0)
				,dblNet = LD.dblNet -ISNULL(LD.dblDeliveredNet,0)
				,dblCost = ISNULL(LD.dblUnitPrice,0)
				,intCostUOMId = LD.intPriceUOMId
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = LD.intPSubLocationId
				,intStorageLocationId = NULL
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId
				,intSourceType = 0
				,strSourceId = L.strLoadNumber 
				,strSourceScreenName = NULL
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = NULL
				,dblForexRate = NULL
				,- 1 --
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
				,NULL
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId
				AND IL.intLocationId = LD.intPCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN L.intCurrencyId
					ELSE NULL
					END
			WHERE L.intLoadId = @intLoadId
				AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0 
		END
	
		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'All the containers in the inbound shipment has already been received.'
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
			)
		SELECT CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CASE 
				WHEN CV.strCostMethod = 'Amount'
					THEN 0
				ELSE ROUND((
							CV.[dblShipmentUnitPrice] / (
								SELECT SUM(LOD.dblQuantity)
								FROM tblLGLoadDetail LOD
								WHERE LOD.intLoadId = L.intLoadId
								)
							) * CONVERT(NUMERIC(18, 6), LD.dblQuantity), 2)
				END
			,ROUND((
					CV.[dblTotal] / (
						SELECT SUM(LOD.dblQuantity)
						FROM tblLGLoadDetail LOD
						WHERE LOD.intLoadId = L.intLoadId
						)
					) * LD.dblQuantity, 2)
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,1 ysnAccrue
			,'Direct'
			,NULL
			,L.intCurrencyId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,0
			,CUR.ysnSubCurrency
			,CV.intCurrencyId
			,EL.intEntityLocationId
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = CASE 
				WHEN L.intSourceType <> 1
					THEN CASE 
							WHEN ISNULL(LD.intPContractDetailId, 0) = 0
								THEN LD.intCustomerEntityId
							ELSE LD.intVendorEntityId
							END
				ELSE LD.intVendorEntityId
				END
			AND EL.ysnDefaultLocation = 1
		WHERE CV.intLoadId = @intLoadId
		GROUP BY CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CV.[dblShipmentUnitPrice]
			,CV.[dblTotal]
			,CV.intItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,CV.intCurrencyId
			,LD.dblQuantity
			,L.strBLNumber
			,I.ysnInventoryCost
			,CV.intLoadId
			,L.intLoadId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,EL.intEntityLocationId
			,L.intCurrencyId
			,CUR.ysnSubCurrency

		UNION ALL

		SELECT CLSL.intVendorId
			,LWS.intItemId
			,'Per Unit'
			,LWS.dblUnitRate
			,LWS.dblActualAmount
			,LWS.intItemUOMId
			,(
				SELECT TOP 1 CD.intContractHeaderId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPContractDetailId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,1
			,'Direct'
			,NULL
			,L.intCurrencyId
			,(
				SELECT TOP 1 LOD.intVendorEntityId
				FROM tblLGLoadDetail LOD
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPCompanyLocationId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,0
			,CUR.ysnSubCurrency
			,L.intCurrencyId
			,(
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
					AND EL.ysnDefaultLocation = 1
				WHERE LD.intLoadId = @intLoadId
				)
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
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
			)
		SELECT NULL
			,NULL
			,NULL
			,ISNULL(LW.intSubLocationId,LD.intPSubLocationId)
			,LW.intStorageLocationId
			,NULL
			,NULL
			,LD.intItemUOMId
			,LD.intItemId
			,ISNULL(LDCL.dblQuantity, ISNULL(LC.dblQuantity, LD.dblQuantity))
			,ISNULL(LDCL.dblLinkGrossWt, ISNULL(LC.dblGrossWt, LD.dblGross))
			,ISNULL(LDCL.dblLinkTareWt, ISNULL(LC.dblTareWt, LD.dblTare))
			,LC.strContainerNumber
			,ISNULL(LC.intLoadContainerId,0)
			,LC.strMarks
			,@strLotCondition
			,LD.intVendorEntityId
			,'Direct'
			,LD.intPCompanyLocationId
			,NULL
			,EL.intEntityLocationId
			,ISNULL(SC.intMainCurrencyId, L.intCurrencyId)
			,0
			,L.strBLNumber
		FROM tblLGLoad L  
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId 
			AND IL.intLocationId = LD.intPCompanyLocationId 
		JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId 
			AND EL.ysnDefaultLocation = 1 
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId		
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = L.intCurrencyId
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
	BEGIN 
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
	
		IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
		BEGIN
			INSERT INTO @ReceiptStagingTable (
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,strBillOfLadding
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,intGrossNetUOMId
				,dblGross
				,dblNet
				,dblCost
				,intCostUOMId
				,intCurrencyId
				,intSubCurrencyCents
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intSourceId
				,intSourceType
				,strSourceId
				,strSourceScreenName
				,ysnSubCurrency
				,intForexRateTypeId
				,dblForexRate
				,intContainerId
				,intFreightTermId
				,intBookId
				,intSubBookId
				,intSort
				)
			SELECT strReceiptType = 'Purchase Contract'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = CD.intCompanyLocationId
				,L.strBLNumber --
				,intItemId = LD.intItemId --
				,intItemLocationId = CD.intCompanyLocationId
				,intItemUOMId = LD.intItemUOMId --
				,intContractHeaderId = CD.intContractHeaderId --
				,intContractDetailId = LD.intPContractDetailId --
				,dtmDate = GETDATE()
				,intShipViaId = CD.intShipViaId
				,dblQty = ISNULL(LDCL.dblQuantity, LD.dblQuantity) --
				,intGrossNetUOMId = COALESCE((SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intItemId = LD.intItemId AND intUnitMeasureId = LC.intWeightUnitMeasureId), 
											LD.intWeightItemUOMId, CD.intNetWeightUOMId)
				,dblGross = ISNULL(LDCL.dblLinkGrossWt, LD.dblGross) --
				,dblNet = ISNULL(LDCL.dblLinkNetWt, LD.dblNet) --
				,dblCost = ISNULL(AD.dblSeqPrice, ISNULL(LD.dblUnitPrice,0)) --
				,intCostUOMId = ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId)  --
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = ISNULL(LW.intSubLocationId, CD.intSubLocationId) --
				,intStorageLocationId = ISNULL(LW.intStorageLocationId, CD.intStorageLocationId) --
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId --
				,intSourceType = 2
				,strSourceId = L.strLoadNumber --
				,strSourceScreenName = 'Contract'
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN RCTFX.intForexRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use null
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN FX.intForexRateTypeId --foreign price to foreign FX, use master FX rate
											ELSE LD.intForexRateTypeId END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) 
											THEN FX.intForexRateTypeId
											ELSE LD.intForexRateTypeId END
									 END
				,dblForexRate = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN ISNULL(RCTFX.dblFXRate, 1) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SeqCUR.intMainCurrencyId, SeqCUR.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
									 END
				,ISNULL(LC.intLoadContainerId, - 1) --
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
				,ISNULL(LC.intLoadContainerId,0)
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId
				AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblSMCurrency LSubCurrency ON LSubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblSMCurrency SeqCUR ON SeqCUR.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
			LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
			OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)
							AND ((ER.intFromCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)))
						ORDER BY RD.dtmValidFromDate DESC) FX
			OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
								THEN 1/RD.[dblRate] 
								ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)
						AND ((ER.intFromCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)))
					ORDER BY RD.dtmValidFromDate DESC) CTFX
			OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
								THEN 1/RD.[dblRate] 
								ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> CD.intInvoiceCurrencyId AND AD.ysnValidFX = 1
						AND ((ER.intFromCurrencyId = CD.intInvoiceCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = CD.intInvoiceCurrencyId))
					ORDER BY RD.dtmValidFromDate DESC) RCTFX  --reverse contract FX if functional to foreign
			WHERE CAST((
						CASE 
							WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0
								THEN 0
							ELSE 1
							END
						) AS BIT) = 0
				AND L.intLoadId = @intLoadId
				AND ISNULL(LC.ysnRejected, 0) <> 1
				AND ISNULL(LDCL.dblReceivedQty,0) = 0
			ORDER BY LDCL.intLoadDetailContainerLinkId
		END
		ELSE
		BEGIN
			INSERT INTO @ReceiptStagingTable (
				strReceiptType
				,intEntityVendorId
				,intShipFromId
				,intLocationId
				,strBillOfLadding
				,intItemId
				,intItemLocationId
				,intItemUOMId
				,intContractHeaderId
				,intContractDetailId
				,dtmDate
				,intShipViaId
				,dblQty
				,intGrossNetUOMId
				,dblGross
				,dblNet
				,dblCost
				,intCostUOMId
				,intCurrencyId
				,intSubCurrencyCents
				,dblExchangeRate
				,intLotId
				,intSubLocationId
				,intStorageLocationId
				,ysnIsStorage
				,intSourceId
				,intSourceType
				,strSourceId
				,strSourceScreenName
				,ysnSubCurrency
				,intForexRateTypeId
				,dblForexRate
				,intContainerId
				,intFreightTermId
				,intBookId
				,intSubBookId
				,intSort
				)
			SELECT strReceiptType = 'Purchase Contract'
				,intEntityVendorId = LD.intVendorEntityId --
				,intShipFromId = EL.intEntityLocationId
				,intLocationId = CD.intCompanyLocationId
				,L.strBLNumber --
				,intItemId = LD.intItemId --
				,intItemLocationId = CD.intCompanyLocationId
				,intItemUOMId = LD.intItemUOMId --
				,intContractHeaderId = CD.intContractHeaderId --
				,intContractDetailId = LD.intPContractDetailId --
				,dtmDate = GETDATE()
				,intShipViaId = CD.intShipViaId
				,dblQty = LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) --
				,intGrossNetUOMId = ISNULL(LD.intWeightItemUOMId, CD.intNetWeightUOMId) --
				,dblGross =  LD.dblGross - ISNULL(LD.dblDeliveredGross,0) --
				,dblNet = LD.dblNet -ISNULL(LD.dblDeliveredNet,0) --
				,dblCost = ISNULL(LD.dblUnitPrice,0) --
				,intCostUOMId = ISNULL(AD.intSeqPriceUOMId,LD.intPriceUOMId)  --
				,intCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)
				,intSubCurrencyCents = ISNULL(SubCurrency.intCent, 1)
				,dblExchangeRate = 1
				,intLotId = NULL
				,intSubLocationId = ISNULL(CD.intSubLocationId, LD.intPSubLocationId) --
				,intStorageLocationId = CD.intStorageLocationId --
				,ysnIsStorage = 0
				,intSourceId = LD.intLoadDetailId --
				,intSourceType = 2
				,strSourceId = L.strLoadNumber --
				,strSourceScreenName = 'Contract'
				,ysnSubCurrency = SubCurrency.ysnSubCurrency
				,intForexRateTypeId = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN RCTFX.intForexRateTypeId --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN NULL --foreign price to functional FX, use null
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN FX.intForexRateTypeId --foreign price to foreign FX, use master FX rate
											ELSE LD.intForexRateTypeId END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN FX.intForexRateTypeId
											ELSE LD.intForexRateTypeId END
									 END
				,dblForexRate = CASE --if contract FX tab is setup
									 WHEN AD.ysnValidFX = 1 THEN 
										CASE WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) = @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId) 
												THEN ISNULL(RCTFX.dblFXRate, 1) --functional price to foreign FX, use inverted contract FX rate
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId = @DefaultCurrencyId)
												THEN 1 --foreign price to functional FX, use 1
											WHEN (ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) <> @DefaultCurrencyId AND CD.intInvoiceCurrencyId <> @DefaultCurrencyId)
												THEN ISNULL(FX.dblFXRate, 1) --foreign price to foreign FX, use master FX rate
											ELSE ISNULL(LD.dblForexRate,1) END
									 ELSE  --if contract FX tab is not setup
										CASE WHEN (@DefaultCurrencyId <> ISNULL(SC.intMainCurrencyId, SC.intCurrencyID)) 
											THEN ISNULL(FX.dblFXRate, 1)
											ELSE ISNULL(LD.dblForexRate,1) END
									 END
				,- 1 --
				,L.intFreightTermId
				,L.intBookId
				,L.intSubBookId
				,NULL
			FROM tblLGLoad L
			JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
			JOIN tblICItemLocation IL ON IL.intItemId = CD.intItemId
				AND IL.intLocationId = CD.intCompanyLocationId
			JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
				AND EL.ysnDefaultLocation = 1
			LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
			LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			LEFT JOIN tblSMCurrency LSC ON LSC.intCurrencyID = LD.intPriceCurrencyId
			LEFT JOIN tblSMCurrency LSubCurrency ON LSubCurrency.intCurrencyID = CASE 
					WHEN SC.intMainCurrencyId IS NOT NULL
						THEN CD.intCurrencyId
					ELSE NULL
					END
			OUTER APPLY (SELECT	TOP 1  
						intForexRateTypeId = RD.intRateTypeId
						,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
									THEN 1/RD.[dblRate] 
									ELSE RD.[dblRate] END 
						FROM tblSMCurrencyExchangeRate ER
						JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
						WHERE @DefaultCurrencyId <> ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)
							AND ((ER.intFromCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
								OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)))
						ORDER BY RD.dtmValidFromDate DESC) FX
			OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
								THEN 1/RD.[dblRate] 
								ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)
						AND ((ER.intFromCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID) AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = ISNULL(LSC.intMainCurrencyId, LSC.intCurrencyID)))
					ORDER BY RD.dtmValidFromDate DESC) CTFX
			OUTER APPLY (SELECT	TOP 1  
					intForexRateTypeId = RD.intRateTypeId
					,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
								THEN 1/RD.[dblRate] 
								ELSE RD.[dblRate] END 
					FROM tblSMCurrencyExchangeRate ER
					JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
					WHERE @DefaultCurrencyId <> CD.intInvoiceCurrencyId AND AD.ysnValidFX = 1
						AND ((ER.intFromCurrencyId = CD.intInvoiceCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
							OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = CD.intInvoiceCurrencyId))
					ORDER BY RD.dtmValidFromDate DESC) RCTFX  --reverse contract FX if functional to foreign
			WHERE L.intLoadId = @intLoadId
				AND LD.dblQuantity-ISNULL(LD.dblDeliveredQuantity,0) > 0
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM @ReceiptStagingTable)
		BEGIN
			IF EXISTS(SELECT 1 FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId)
			BEGIN
				SET @strErrorMessage = 'All the containers in the inbound shipment has already been received.'
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
			)
		SELECT CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CASE 
				WHEN CV.strCostMethod = 'Amount'
					THEN 0
				ELSE ROUND((
							CV.[dblShipmentUnitPrice] / (
								SELECT SUM(LOD.dblQuantity)
								FROM tblLGLoadDetail LOD
								WHERE LOD.intLoadId = L.intLoadId
								)
							) * CONVERT(NUMERIC(18, 6), LD.dblQuantity), 2)
				END
			,ROUND((
					CV.[dblTotal] / (
						SELECT SUM(LOD.dblQuantity)
						FROM tblLGLoadDetail LOD
						WHERE LOD.intLoadId = L.intLoadId
						)
					) * LD.dblQuantity, 2)
			,CV.intPriceItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,1 ysnAccrue
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,0
			,CUR.ysnSubCurrency
			,CV.intCurrencyId
			,EL.intEntityLocationId
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM vyuLGLoadCostForVendor CV
		JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = CV.intLoadDetailId
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		JOIN tblICItem I ON I.intItemId = CV.intItemId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
				WHEN ISNULL(LD.intPContractDetailId, 0) = 0
					THEN LD.intSContractDetailId
				ELSE LD.intPContractDetailId
				END
		LEFT JOIN tblEMEntityLocation EL ON EL.intEntityId = CASE 
				WHEN L.intSourceType <> 1
					THEN CASE 
							WHEN ISNULL(LD.intPContractDetailId, 0) = 0
								THEN LD.intCustomerEntityId
							ELSE LD.intVendorEntityId
							END
				ELSE LD.intVendorEntityId
				END
			AND EL.ysnDefaultLocation = 1
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CV.intCurrencyId
		WHERE CV.intLoadId = @intLoadId
		GROUP BY CV.intEntityVendorId
			,CV.intItemId
			,CV.strCostMethod
			,CV.[dblShipmentUnitPrice]
			,CV.[dblTotal]
			,CV.intPriceItemUOMId
			,CD.intContractHeaderId
			,LD.intPContractDetailId
			,CV.intCurrencyId
			,LD.dblQuantity
			,L.strBLNumber
			,I.ysnInventoryCost
			,CV.intLoadId
			,L.intLoadId
			,LD.intVendorEntityId
			,LD.intPCompanyLocationId
			,EL.intEntityLocationId
			,L.intCurrencyId
			,CUR.ysnSubCurrency

		UNION ALL

		SELECT CLSL.intVendorId
			,LWS.intItemId
			,'Per Unit'
			,LWS.dblUnitRate
			,LWS.dblActualAmount
			,LWS.intItemUOMId
			,(
				SELECT TOP 1 CD.intContractHeaderId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPContractDetailId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,1
			,'Purchase Contract'
			,NULL
			,L.intCurrencyId
			,(
				SELECT TOP 1 LOD.intVendorEntityId
				FROM tblLGLoadDetail LOD
				WHERE intLoadId = @intLoadId
				)
			,(
				SELECT TOP 1 intPCompanyLocationId
				FROM tblLGLoadDetail
				WHERE intLoadId = @intLoadId
				)
			,0
			,CUR.ysnSubCurrency
			,L.intCurrencyId
			,(
				SELECT TOP 1 EL.intEntityLocationId
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblEMEntityLocation EL ON EL.intEntityId = CH.intEntityId
					AND EL.ysnDefaultLocation = 1
				WHERE LD.intLoadId = @intLoadId
				)
			,L.strBLNumber
			,I.ysnInventoryCost
		FROM tblLGLoad L
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseServices LWS ON LW.intLoadWarehouseId = LWS.intLoadWarehouseId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		JOIN tblICItem I ON I.intItemId = LWS.intItemId
		JOIN tblSMCurrency CUR ON CUR.intCurrencyID = L.intCurrencyId
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
			)
		SELECT NULL
			,NULL
			,NULL
			,LW.intSubLocationId
			,LW.intStorageLocationId
			,CD.intContractHeaderId
			,CD.intContractDetailId
			,LD.intItemUOMId
			,LD.intItemId
			,ISNULL(LDCL.dblQuantity, ISNULL(LC.dblQuantity, LD.dblQuantity))
			,ISNULL(LDCL.dblLinkGrossWt, ISNULL(LC.dblGrossWt, LD.dblGross))
			,ISNULL(LDCL.dblLinkTareWt, ISNULL(LC.dblTareWt, LD.dblTare))
			,LC.strContainerNumber
			,ISNULL(LC.intLoadContainerId,0)
			,LC.strMarks
			,@strLotCondition
			,LD.intVendorEntityId
			,'Purchase Contract'
			,CD.intCompanyLocationId
			,NULL
			,EL.intEntityLocationId
			,ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
			,2
			,L.strBLNumber
		FROM tblLGLoad L  
		JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId 
			AND IL.intLocationId = LD.intPCompanyLocationId 
		JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId 
			AND EL.ysnDefaultLocation = 1 
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LD.intLoadId = LW.intLoadId
		LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
		LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
				WHEN SC.intMainCurrencyId IS NOT NULL
					THEN CD.intCurrencyId
				ELSE NULL
				END
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

		SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
		FROM #tmpAddItemReceiptResult

		--If IR is created, remove LS payables
		IF (@intInventoryReceiptId IS NOT NULL)
		BEGIN
			DELETE VP
			FROM tblAPVoucherPayable VP
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = VP.intLoadShipmentDetailId AND LD.intPContractDetailId = VP.intContractDetailId
			WHERE LD.intLoadId = @intLoadId
		END
	END


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH