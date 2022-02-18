CREATE PROCEDURE uspIPProcessSAPReceipt_ST @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intEntityId INT
	DECLARE @strCompCode NVARCHAR(20)
		,@strReceiptNumber NVARCHAR(50)
		,@dtmReceiptDate DATETIME
		,@strBLNumber NVARCHAR(100)
		,@strLocationName NVARCHAR(50)
		,@strCreatedBy NVARCHAR(50)
		,@dtmCreated DATETIME
		,@strTrackingNo INT
		,@strTransactionType NVARCHAR(50)
	DECLARE @intInventoryReceiptId INT
		,@strReceiptNo NVARCHAR(50)
	DECLARE @strERPPONumber NVARCHAR(100)
		,@strERPItemNumber NVARCHAR(100)
		,@intContractSeq INT
		,@strItemNo NVARCHAR(50)
		,@strLocationName1 NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@dblGrossWeight NUMERIC(18, 6)
		,@dblTareWeight NUMERIC(18, 6)
		,@dblNetWeight NUMERIC(18, 6)
		,@strNetWeightUOM NVARCHAR(50)
		,@dblCost NUMERIC(18, 6)
		,@strCostUOM NVARCHAR(50)
		,@strCostCurrency NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strTrackingNo1 INT
	DECLARE @intStageReceiptItemId INT
		,@intContractDetailId INT
		,@intLoadId INT
		,@intLoadDetailId INT
		,@intItemId INT
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intQtyUnitMeasureId INT
		,@intQtyItemUOMId INT
		,@intNetWeightUnitMeasureId INT
		,@intNetWeightItemUOMId INT
		,@intCostUnitMeasureId INT
		,@intCostItemUOMId INT
		,@intDefaultCurrencyId INT
		,@intCostCurrencyId INT
		,@dblNewCost NUMERIC(38, 20)
		,@intStockItemUOMId INT
		,@intMainCurrencyId INT
		,@ysnSubCurrency BIT
		,@intLocationId INT
		,@intLoadContainerId INT
		,@dblReceivedQty NUMERIC(18, 6)
		,@ysnPosted BIT
	DECLARE @intNewStageReceiptId INT
	DECLARE @ReceiptStagingTable ReceiptStagingTable
	DECLARE @OtherCharges ReceiptOtherChargesTableType
	DECLARE @LotEntries ReceiptItemLotStagingTable

	SELECT @intMinRowNo = Min(intStageReceiptId)
	FROM tblIPInvReceiptStage WITH (NOLOCK)

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strCompCode = NULL
				,@strReceiptNumber = NULL
				,@dtmReceiptDate = NULL
				,@strBLNumber = NULL
				,@strLocationName = NULL
				,@strCreatedBy = NULL
				,@dtmCreated = NULL
				,@strTrackingNo = NULL
				,@strTransactionType = NULL

			SELECT @intInventoryReceiptId = NULL
				,@strReceiptNo = NULL

			SELECT @strCompCode = strCompCode
				,@strReceiptNumber = strReceiptNumber
				,@dtmReceiptDate = dtmReceiptDate
				,@strBLNumber = strBLNumber
				,@strLocationName = strLocationName
				,@strCreatedBy = strCreatedBy
				,@dtmCreated = dtmCreated
				,@strTrackingNo = strTrackingNo
				,@strTransactionType = strTransactionType
			FROM tblIPInvReceiptStage WITH (NOLOCK)
			WHERE intStageReceiptId = @intMinRowNo

			IF ISNULL(@strReceiptNumber, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Goods Receipt No. '
						,16
						,1
						)
			END

			IF @dtmReceiptDate IS NULL
			BEGIN
				RAISERROR (
						'Invalid Receipt Date. '
						,16
						,1
						)
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblIPInvReceiptItemStage
					WHERE intStageReceiptId = @intMinRowNo
					)
			BEGIN
				RAISERROR (
						'Receipt Item is required. '
						,16
						,1
						)
			END

			SET @strInfo1 = ISNULL(@strReceiptNumber, '')
			SET @strInfo2 = ISNULL(CONVERT(VARCHAR(10), @dtmReceiptDate, 121), '')

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			BEGIN TRAN

			DELETE
			FROM @ReceiptStagingTable

			DELETE
			FROM @LotEntries

			SELECT @intStageReceiptItemId = MIN(intStageReceiptItemId)
			FROM tblIPInvReceiptItemStage WITH (NOLOCK)
			WHERE intStageReceiptId = @intMinRowNo

			WHILE @intStageReceiptItemId IS NOT NULL
			BEGIN
				SELECT @strERPPONumber = NULL
					,@strERPItemNumber = NULL
					,@intContractSeq = NULL
					,@strItemNo = NULL
					,@strLocationName1 = NULL
					,@strSubLocationName = NULL
					,@strStorageLocationName = NULL
					,@dblQuantity = NULL
					,@strQuantityUOM = NULL
					,@dblGrossWeight = NULL
					,@dblTareWeight = NULL
					,@dblNetWeight = NULL
					,@strNetWeightUOM = NULL
					,@dblCost = NULL
					,@strCostUOM = NULL
					,@strCostCurrency = NULL
					,@strContainerNumber = NULL
					,@strTrackingNo1 = NULL

				SELECT @intContractDetailId = NULL
					,@intLoadId = NULL
					,@intLoadDetailId = NULL
					,@intItemId = NULL
					,@intSubLocationId = NULL
					,@intStorageLocationId = NULL
					,@intQtyUnitMeasureId = NULL
					,@intQtyItemUOMId = NULL
					,@intNetWeightUnitMeasureId = NULL
					,@intNetWeightItemUOMId = NULL
					,@intCostUnitMeasureId = NULL
					,@intCostItemUOMId = NULL
					,@intDefaultCurrencyId = NULL
					,@intCostCurrencyId = NULL
					,@dblNewCost = NULL
					,@intStockItemUOMId = NULL
					,@intMainCurrencyId = NULL
					,@ysnSubCurrency = 0
					,@intLocationId = NULL
					,@intLoadContainerId = NULL
					,@dblReceivedQty = NULL
					,@ysnPosted = 0

				SELECT @strERPPONumber = strERPPONumber
					,@strERPItemNumber = strERPItemNumber
					,@intContractSeq = intContractSeq
					,@strItemNo = strItemNo
					,@strLocationName1 = strLocationName
					,@strSubLocationName = strSubLocationName
					,@strStorageLocationName = strStorageLocationName
					,@dblQuantity = ISNULL(dblQuantity, 0)
					,@strQuantityUOM = strQuantityUOM
					,@dblGrossWeight = ISNULL(dblGrossWeight, 0)
					,@dblTareWeight = ISNULL(dblTareWeight, 0)
					,@dblNetWeight = ISNULL(dblNetWeight, 0)
					,@strNetWeightUOM = strNetWeightUOM
					,@dblCost = ISNULL(dblCost, 0)
					,@strCostUOM = strCostUOM
					,@strCostCurrency = strCostCurrency
					,@strContainerNumber = strContainerNumber
					,@strTrackingNo1 = strTrackingNo
				FROM tblIPInvReceiptItemStage WITH (NOLOCK)
				WHERE intStageReceiptItemId = @intStageReceiptItemId

				IF ISNULL(@strERPPONumber, '') = ''
				BEGIN
					RAISERROR (
							'Invalid ERP PO No. '
							,16
							,1
							)
				END

				--IF ISNULL(@strERPItemNumber, '') = ''
				--BEGIN
				--	RAISERROR (
				--			'Invalid ERP Item No. '
				--			,16
				--			,1
				--			)
				--END
				SELECT @intItemId = t.intItemId
				FROM tblICItem t WITH (NOLOCK)
				WHERE t.strItemNo = @strItemNo

				IF ISNULL(@intItemId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Item No. '
							,16
							,1
							)
				END

				SELECT @intStockItemUOMId = t.intItemUOMId
				FROM tblICItemUOM t WITH (NOLOCK)
				WHERE t.intItemId = @intItemId
					AND t.ysnStockUnit = 1

				SELECT @intContractDetailId = intContractDetailId
					,@intLocationId = intCompanyLocationId
				FROM tblCTContractDetail WITH (NOLOCK)
				WHERE intContractSeq = @intContractSeq
					AND strERPPONumber = @strERPPONumber
					--AND strERPItemNumber = @strERPItemNumber

				IF ISNULL(@intContractDetailId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Contract. '
							,16
							,1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblCTContractDetail t WITH (NOLOCK)
						WHERE t.intContractDetailId = @intContractDetailId
							AND t.intItemId = @intItemId
						)
				BEGIN
					RAISERROR (
							'Item No is not matching with Contract Sequence Item. '
							,16
							,1
							)
				END

				SELECT @intSubLocationId = t.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
				WHERE t.strSubLocationName = @strSubLocationName
					AND t.intCompanyLocationId = @intLocationId

				IF ISNULL(@intSubLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Sub Location. '
							,16
							,1
							)
				END

				SELECT @intStorageLocationId = t.intStorageLocationId
				FROM tblICStorageLocation t WITH (NOLOCK)
				WHERE t.strName = @strStorageLocationName
					AND t.intSubLocationId = @intSubLocationId

				IF ISNULL(@intStorageLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Storage Location. '
							,16
							,1
							)
				END

				IF @dblQuantity <= 0
				BEGIN
					RAISERROR (
							'Invalid Quantity. '
							,16
							,1
							)
				END

				SELECT @intQtyUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strQuantityUOM

				IF ISNULL(@intQtyUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Quantity UOM. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					SELECT @intQtyItemUOMId = intItemUOMId
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intUnitMeasureId = @intQtyUnitMeasureId

					IF ISNULL(@intQtyItemUOMId, 0) = 0
					BEGIN
						RAISERROR (
								'Quantity UOM does not belongs to the Item. '
								,16
								,1
								)
					END
				END

				IF @dblNetWeight <= 0
				BEGIN
					RAISERROR (
							'Invalid Net Weight. '
							,16
							,1
							)
				END

				SELECT @intNetWeightUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strNetWeightUOM

				IF ISNULL(@intNetWeightUnitMeasureId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Net Weight UOM. '
							,16
							,1
							)
				END
				ELSE
				BEGIN
					SELECT @intNetWeightItemUOMId = intItemUOMId
					FROM tblICItemUOM t WITH (NOLOCK)
					WHERE t.intItemId = @intItemId
						AND t.intUnitMeasureId = @intNetWeightUnitMeasureId

					IF ISNULL(@intNetWeightItemUOMId, 0) = 0
					BEGIN
						RAISERROR (
								'Net Weight UOM does not belongs to the Item. '
								,16
								,1
								)
					END
				END

				--IF @dblGrossWeight = 0
				--	SELECT @dblGrossWeight = @dblNetWeight
				--IF @dblGrossWeight > 0
				--	AND @dblGrossWeight <> @dblNetWeight
				--BEGIN
				--	SELECT @dblTareWeight = @dblGrossWeight - @dblNetWeight
				--END
				IF @dblCost >= 0
					AND ISNULL(@strCostUOM, '') <> ''
					AND ISNULL(@strCostCurrency, '') <> ''
				BEGIN
					SELECT @intCostUnitMeasureId = t.intUnitMeasureId
					FROM tblICUnitMeasure t WITH (NOLOCK)
					WHERE t.strUnitMeasure = @strCostUOM

					IF ISNULL(@intCostUnitMeasureId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Cost UOM. '
								,16
								,1
								)
					END
					ELSE
					BEGIN
						SELECT @intCostItemUOMId = intItemUOMId
						FROM tblICItemUOM t WITH (NOLOCK)
						WHERE t.intItemId = @intItemId
							AND t.intUnitMeasureId = @intCostUnitMeasureId

						IF ISNULL(@intCostItemUOMId, 0) = 0
						BEGIN
							RAISERROR (
									'Cost UOM does not belongs to the Item. '
									,16
									,1
									)
						END
					END

					SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId
					FROM tblSMCompanyPreference t WITH (NOLOCK)

					SELECT @intCostCurrencyId = t.intCurrencyID
						,@intMainCurrencyId = t.intMainCurrencyId
						,@ysnSubCurrency = t.ysnSubCurrency
					FROM tblSMCurrency t WITH (NOLOCK)
					WHERE t.strCurrency = @strCostCurrency

					IF @ysnSubCurrency = 1
						SELECT @intCostCurrencyId = @intMainCurrencyId

					IF @intDefaultCurrencyId <> @intCostCurrencyId
					BEGIN
						RAISERROR (
								'Invalid Currency. '
								,16
								,1
								)
					END
							-- Cost UOM Conversion
							--SELECT @dblNewCost = dbo.fnCTConvertQtyToTargetItemUOM(@intCostItemUOMId, @intStockItemUOMId, @dblCost)
				END
				ELSE
				BEGIN
					SELECT @dblCost = dblCashPrice
						,@intCostItemUOMId = intPriceItemUOMId
						,@intCostCurrencyId = intCurrencyId
					FROM tblCTContractDetail WITH (NOLOCK)
					WHERE intContractDetailId = @intContractDetailId

					SELECT @intMainCurrencyId = t.intMainCurrencyId
						,@ysnSubCurrency = t.ysnSubCurrency
					FROM tblSMCurrency t WITH (NOLOCK)
					WHERE t.intCurrencyID = @intCostCurrencyId

					IF @ysnSubCurrency = 1
						SELECT @intCostCurrencyId = @intMainCurrencyId
							-- Cost UOM Conversion
							--SELECT @dblNewCost = dbo.fnCTConvertQtyToTargetItemUOM(@intCostItemUOMId, @intStockItemUOMId, @dblCost)
				END

				SELECT @intLoadContainerId = intLoadContainerId
				FROM tblLGLoadContainer t WITH (NOLOCK)
				WHERE t.strContainerNumber = @strContainerNumber

				IF ISNULL(@intLoadContainerId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Container No. '
							,16
							,1
							)
				END

				SELECT @intLoadId = L.intLoadId
					,@intLoadDetailId = LD.intLoadDetailId
					,@intLoadContainerId = LC.intLoadContainerId
					,@dblReceivedQty = LDCL.dblReceivedQty
					,@ysnPosted = L.ysnPosted
				FROM tblLGLoad L WITH (NOLOCK)
				JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
					AND L.intShipmentType = 1
					AND LD.intPContractDetailId = @intContractDetailId
					AND L.intShipmentStatus <> 10
				JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
				JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
					AND LC.strContainerNumber = @strContainerNumber

				IF ISNULL(@intLoadId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Load. '
							,16
							,1
							)
				END

				IF ISNULL(@ysnPosted, 0) = 0
				BEGIN
					RAISERROR (
							'Load is not yet posted. '
							,16
							,1
							)
				END

				IF ISNULL(@dblReceivedQty, 0) > 0
				BEGIN
					RAISERROR (
							'Container is already received. '
							,16
							,1
							)
				END

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
					,intLoadShipmentId
					,intLoadShipmentDetailId
					,strVendorRefNo
					,dblUnitRetail
					)
				SELECT TOP 1 strReceiptType = 'Purchase Contract'
					,intEntityVendorId = LD.intVendorEntityId
					,intShipFromId = EL.intEntityLocationId
					,intLocationId = CD.intCompanyLocationId
					,strBillOfLadding = ISNULL(@strBLNumber, L.strBLNumber)
					,intItemId = LD.intItemId
					,intItemLocationId = CD.intCompanyLocationId
					,intItemUOMId = CL.intItemUOMId
					,intContractHeaderId = CD.intContractHeaderId
					,intContractDetailId = LD.intPContractDetailId
					,dtmDate = @dtmReceiptDate
					,intShipViaId = CD.intShipViaId
					,dblQty = CL.dblQuantity
					,intGrossNetUOMId = IU.intItemUOMId
					,dblGross = RI.dblNetWeight + ISNULL(C.dblTareWt, 0)
					,dblNet = RI.dblNetWeight
					,dblCost = @dblCost
					,intCostUOMId = @intCostItemUOMId
					,intCurrencyId = L.intCurrencyId
					,intSubCurrencyCents = (
						CASE 
							WHEN ISNULL(@ysnSubCurrency, 0) = 1
								THEN 100
							ELSE 1
							END
						)
					,dblExchangeRate = 1
					,intLotId = NULL
					,intSubLocationId = CSL.intCompanyLocationSubLocationId
					,intStorageLocationId = SL.intStorageLocationId
					,ysnIsStorage = 0
					,intSourceId = LD.intLoadDetailId
					,intSourceType = 2
					,strSourceId = L.strLoadNumber
					,strSourceScreenName = 'External System'
					,ysnSubCurrency = (
						CASE 
							WHEN ISNULL(@ysnSubCurrency, 0) = 1
								THEN 1
							ELSE 0
							END
						)
					,intForexRateTypeId = NULL
					,dblForexRate = NULL
					,intContainerId = CL.intLoadContainerId
					,intFreightTermId = L.intFreightTermId
					,intBookId = L.intBookId
					,intSubBookId = L.intSubBookId
					,intSort = NULL
					,intLoadShipmentId = L.intLoadId
					,intLoadShipmentDetailId = LD.intLoadDetailId
					,strVendorRefNo = @strReceiptNumber
					,dblUnitRetail = @dblCost
				FROM tblIPInvReceiptItemStage RI
				JOIN tblICItem I ON I.strItemNo = RI.strItemNo
					AND RI.intStageReceiptItemId = @intStageReceiptItemId
				JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
					AND IL.intLocationId = @intLocationId
				JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
				JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
					AND UM.strUnitMeasure = RI.strQuantityUOM
				JOIN tblSMCompanyLocationSubLocation CSL ON CSL.strSubLocationName = RI.strSubLocationName
					AND CSL.intCompanyLocationId = @intLocationId
				JOIN tblICStorageLocation SL ON SL.strName = RI.strStorageLocationName
					AND SL.intSubLocationId = CSL.intCompanyLocationSubLocationId
				JOIN tblLGLoadDetail LD ON LD.intItemId = I.intItemId
					AND LD.intLoadDetailId = @intLoadDetailId
				JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId
				JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
					AND L.intLoadId = @intLoadId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblLGLoadDetailContainerLink CL ON CL.intLoadDetailId = LD.intLoadDetailId
					AND CL.intLoadContainerId = @intLoadContainerId
				JOIN tblLGLoadContainer C ON C.intLoadContainerId = CL.intLoadContainerId

				IF NOT EXISTS (
						SELECT 1
						FROM @ReceiptStagingTable
						)
				BEGIN
					RAISERROR (
							'Receipt Staging Table entries not inserted. '
							,16
							,1
							)
				END

				INSERT INTO @LotEntries (
					intLotId
					,strLotNumber
					,strLotAlias
					,intSubLocationId
					,intStorageLocationId
					,intContractHeaderId
					,intContractDetailId
					,intItemUnitMeasureId
					,intItemId
					,dblQuantity
					,dblGrossWeight
					,dblTareWeight
					,dblCost
					,strContainerNo
					,intSort
					,strMarkings
					,strCondition
					,intEntityVendorId
					,strReceiptType
					,intLocationId
					,intShipViaId
					,intShipFromId
					,intCurrencyId
					,intSourceType
					,strBillOfLadding
					)
				SELECT intLotId = NULL
					,strLotNumber = C.strContainerNumber
					,strLotAlias = NULL
					,intSubLocationId = RI.intSubLocationId
					,intStorageLocationId = RI.intStorageLocationId
					,intContractHeaderId = RI.intContractHeaderId
					,intContractDetailId = RI.intContractDetailId
					,intItemUnitMeasureId = RI.intItemUOMId
					,intItemId = RI.intItemId
					,dblQuantity = RI.dblQty
					,dblGrossWeight = RI.dblGross
					,dblTareWeight = ISNULL(C.dblTareWt, 0)
					,dblCost = RI.dblCost
					,strContainerNo = C.strContainerNumber
					,intSort = NULL
					,strMarkings = C.strMarks
					,strCondition = (
						CASE 
							WHEN RI.dblNet > C.dblNetWt
								THEN 'Clean Wgt'
							ELSE NULL
							END
						)
					,intEntityVendorId = RI.intEntityVendorId
					,strReceiptType = RI.strReceiptType
					,intLocationId = RI.intLocationId
					,intShipViaId = RI.intShipViaId
					,intShipFromId = RI.intShipFromId
					,intCurrencyId = RI.intCurrencyId
					,intSourceType = RI.intSourceType
					,strBillOfLadding = RI.strBillOfLadding
				FROM @ReceiptStagingTable RI
				JOIN tblLGLoadContainer C ON C.intLoadContainerId = RI.intContainerId
					AND RI.intContainerId = @intLoadContainerId

				SELECT @intStageReceiptItemId = MIN(intStageReceiptItemId)
				FROM tblIPInvReceiptItemStage WITH (NOLOCK)
				WHERE intStageReceiptId = @intMinRowNo
					AND intStageReceiptItemId > @intStageReceiptItemId
			END

			IF EXISTS (
					SELECT 1
					FROM @ReceiptStagingTable
					)
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tempdb..sysobjects
						WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')
						)
				BEGIN
					CREATE TABLE #tmpAddItemReceiptResult (
						intSourceId INT
						,intInventoryReceiptId INT
						)
				END

				-- Create IR with lots
				EXEC dbo.uspICAddItemReceipt @ReceiptEntries = @ReceiptStagingTable
					,@OtherCharges = @OtherCharges
					,@intUserId = @intEntityId
					,@LotEntries = @LotEntries

				SELECT TOP 1 @intInventoryReceiptId = intInventoryReceiptId
				FROM #tmpAddItemReceiptResult

				-- If IR is created, Post the Receipt
				IF (@intInventoryReceiptId IS NOT NULL)
				BEGIN
					SELECT @strReceiptNo = strReceiptNumber
					FROM tblICInventoryReceipt
					WHERE intInventoryReceiptId = @intInventoryReceiptId

					SET @strInfo1 = ISNULL(@strReceiptNo, '') + ' / ' + ISNULL(@strReceiptNumber, '')

					--Post Receipt
					EXEC uspICPostInventoryReceipt 1
						,0
						,@strReceiptNo
						,@intEntityId

					DELETE
					FROM #tmpAddItemReceiptResult
					WHERE intInventoryReceiptId = @intInventoryReceiptId
				END
			END

			--Move to Archive
			INSERT INTO tblIPInvReceiptArchive (
				strCompCode
				,strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strTrackingNo
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strCompCode
				,strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strTrackingNo
				,strTransactionType
				,''
				,'Success'
				,strSessionId
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intMinRowNo

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemArchive (
				intStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,strTrackingNo
				)
			SELECT @intNewStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,strTrackingNo
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intMinRowNo

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPInvReceiptError (
				strCompCode
				,strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strTrackingNo
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strCompCode
				,strReceiptNumber
				,dtmReceiptDate
				,strBLNumber
				,strLocationName
				,strCreatedBy
				,dtmCreated
				,strTrackingNo
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intMinRowNo

			SELECT @intNewStageReceiptId = SCOPE_IDENTITY()

			INSERT INTO tblIPInvReceiptItemError (
				intStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,strTrackingNo
				)
			SELECT @intNewStageReceiptId
				,strReceiptNumber
				,strERPPONumber
				,strERPItemNumber
				,intContractSeq
				,strItemNo
				,strLocationName
				,strSubLocationName
				,strStorageLocationName
				,dblQuantity
				,strQuantityUOM
				,dblGrossWeight
				,dblTareWeight
				,dblNetWeight
				,strNetWeightUOM
				,dblCost
				,strCostUOM
				,strCostCurrency
				,strContainerNumber
				,strTrackingNo
			FROM tblIPInvReceiptItemStage
			WHERE intStageReceiptId = @intMinRowNo

			DELETE
			FROM tblIPInvReceiptStage
			WHERE intStageReceiptId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageReceiptId)
		FROM tblIPInvReceiptStage WITH (NOLOCK)
		WHERE intStageReceiptId > @intMinRowNo
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
