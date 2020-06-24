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
	DECLARE @strDescription AS NVARCHAR(MAX)
	DECLARE @intNewStageReceiptId INT

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

			SELECT @strDescription = NULL

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

			SET @strInfo1 = ISNULL(@strReceiptNumber, '')
			SET @strInfo2 = ISNULL(CONVERT(VARCHAR(10), @dtmReceiptDate, 121), '')

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			BEGIN TRAN

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

				IF ISNULL(@strERPItemNumber, '') = ''
				BEGIN
					RAISERROR (
							'Invalid ERP Item No. '
							,16
							,1
							)
				END

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
					AND strERPItemNumber = @strERPItemNumber

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

				IF ISNULL(@intStorageLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Storage Location. '
							,16
							,1
							)
				END

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

				SELECT @intLoadId = L.intLoadId
					,@intLoadDetailId = LD.intLoadDetailId
				FROM tblLGLoad L WITH (NOLOCK)
				JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
					AND L.intShipmentType = 1
					AND LD.intPContractDetailId = @intContractDetailId
					AND L.intShipmentStatus <> 10

				IF ISNULL(@intLoadId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Load. '
							,16
							,1
							)
				END

				IF ISNULL(@strContainerNumber, '') = ''
				BEGIN
					RAISERROR (
							'Invalid Container No. '
							,16
							,1
							)
				END

				SELECT @intLoadContainerId = intLoadContainerId
				FROM tblLGLoadContainer t WITH (NOLOCK)
				WHERE t.intLoadId = @intLoadId
					AND t.strContainerNumber = @strContainerNumber

				IF ISNULL(@intLoadContainerId, 0) = 0
				BEGIN
					RAISERROR (
							'Container No is not matching with Load Shipment Container. '
							,16
							,1
							)
				END

				IF @intInventoryReceiptId IS NULL
				BEGIN
					EXEC dbo.uspSMGetStartingNumber 23
						,@strReceiptNo OUTPUT

					--Re-check if the receipt no is already used. If yes, then regenerate the receipt no. 
					IF EXISTS (
							SELECT TOP 1 1
							FROM tblICInventoryReceipt WITH (NOLOCK)
							WHERE strReceiptNumber = @strReceiptNo
							)
						EXEC dbo.uspSMGetStartingNumber 23
							,@strReceiptNo OUTPUT

					--Receipt
					INSERT INTO tblICInventoryReceipt (
						strReceiptType
						,intSourceType
						,intEntityVendorId
						,intLocationId
						,strReceiptNumber
						,dtmReceiptDate
						,intCurrencyId
						,intReceiverId
						,dblInvoiceAmount
						,ysnPrepaid
						,ysnInvoicePaid
						,intShipFromId
						,strBillOfLading
						,intCreatedUserId
						,intEntityId
						,intBookId
						,intSubBookId
						)
					SELECT TOP 1 'Purchase Contract'
						,2
						,LD.intVendorEntityId
						,@intLocationId
						,@strReceiptNo
						,@dtmReceiptDate
						,L.intCurrencyId
						,@intEntityId
						,0.0
						,0
						,0
						,EL.intEntityLocationId
						,ISNULL(@strBLNumber, L.strBLNumber)
						,@intEntityId
						,@intEntityId
						,L.intBookId
						,L.intSubBookId
					FROM tblIPInvReceiptItemStage RI
					JOIN tblICItem I ON RI.strItemNo = I.strItemNo
						AND RI.intStageReceiptItemId = @intStageReceiptItemId
					JOIN tblLGLoadDetail LD ON LD.intItemId = I.intItemId
						AND LD.intLoadDetailId = @intLoadDetailId
					JOIN tblEMEntityLocation EL ON EL.intEntityId = LD.intVendorEntityId
					JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
						AND L.intLoadId = @intLoadId

					SET @intInventoryReceiptId = SCOPE_IDENTITY();
				END

				--Receipt Items
				INSERT INTO tblICInventoryReceiptItem (
					intInventoryReceiptId
					,intLineNo
					,intOrderId
					,intSourceId
					,intItemId
					,intContainerId
					,intSubLocationId
					,dblOrderQty
					,dblOpenReceive
					,intStorageLocationId
					,intOwnershipType
					,intUnitMeasureId
					,intWeightUOMId
					,dblUnitCost
					,dblGross
					,dblNet
					,intConcurrencyId
					,dblLineTotal
					,dblUnitRetail
					,intCostUOMId
					,ysnSubCurrency
					,intContractHeaderId
					,intContractDetailId
					)
				SELECT @intInventoryReceiptId
					,CT.intContractDetailId
					,CT.intContractHeaderId
					,LD.intLoadDetailId
					,I.intItemId
					,CL.intLoadContainerId
					,CSL.intCompanyLocationSubLocationId
					,CL.dblQuantity
					,CL.dblQuantity
					,SL.intStorageLocationId
					,1
					,CL.intItemUOMId
					,IU.intItemUOMId
					,@dblCost
					,RI.dblNetWeight + ISNULL(C.dblTareWt, 0)
					,RI.dblNetWeight
					,1
					,(dbo.[fnCTConvertQtyToTargetItemUOM](IU.intItemUOMId, @intCostItemUOMId, RI.dblNetWeight)) * (
						@dblCost / CASE 
							WHEN ISNULL(@ysnSubCurrency, 0) = 1
								THEN 100
							ELSE 1
							END
						)
					,@dblCost
					,@intCostItemUOMId
					,CASE 
						WHEN ISNULL(@ysnSubCurrency, 0) = 1
							THEN 1
						ELSE 0
						END
					,CT.intContractHeaderId
					,CT.intContractDetailId
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
				JOIN tblCTContractDetail CT ON CT.intContractDetailId = LD.intPContractDetailId
				JOIN tblLGLoadDetailContainerLink CL ON CL.intLoadDetailId = LD.intLoadDetailId
					AND CL.intLoadContainerId = @intLoadContainerId
				JOIN tblLGLoadContainer C ON C.intLoadContainerId = CL.intLoadContainerId
				--Join tblSMCurrency cr on ct.intCurrencyId=cr.intCurrencyID
				WHERE RI.intStageReceiptItemId = @intStageReceiptItemId

				UPDATE RH
				SET RH.intSubCurrencyCents = (
						CASE 
							WHEN ISNULL(RI.ysnSubCurrency, 0) = 1
								THEN 100
							ELSE 1
							END
						)
				FROM tblICInventoryReceipt RH
				JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = RH.intInventoryReceiptId
				WHERE RH.intInventoryReceiptId = @intInventoryReceiptId

				--Lots
				INSERT INTO tblICInventoryReceiptItemLot (
					intInventoryReceiptItemId
					,strLotNumber
					,intSubLocationId
					,intStorageLocationId
					,dblQuantity
					,intItemUnitMeasureId
					,dblCost
					,dblGrossWeight
					,dblTareWeight
					,intConcurrencyId
					,strContainerNo
					,dtmDateCreated
					,intCreatedByUserId
					)
				SELECT RI.intInventoryReceiptItemId
					,C.strContainerNumber
					,RI.intSubLocationId
					,RI.intStorageLocationId
					,RI.dblOrderQty
					,RI.intUnitMeasureId
					,RI.dblUnitCost
					,RI.dblGross
					,ISNULL(C.dblTareWt, 0)
					,1
					,C.strContainerNumber
					,GETUTCDATE()
					,@intEntityId
				FROM tblICInventoryReceiptItem RI
				JOIN tblLGLoadContainer C ON C.intLoadContainerId = RI.intContainerId
					AND RI.intContainerId = @intLoadContainerId
				WHERE RI.intInventoryReceiptId = @intInventoryReceiptId

				SELECT @intStageReceiptItemId = MIN(intStageReceiptItemId)
				FROM tblIPInvReceiptItemStage WITH (NOLOCK)
				WHERE intStageReceiptId = @intMinRowNo
					AND intStageReceiptItemId > @intStageReceiptItemId
			END

			SET @strInfo1 = ISNULL(@strReceiptNo, '') + ' / ' + ISNULL(@strReceiptNumber, '')

			-- Audit Log
			IF (@intInventoryReceiptId > 0)
			BEGIN
				SELECT @strDescription = 'Receipt created from external system. '

				EXEC uspSMAuditLog @keyValue = @intInventoryReceiptId
					,@screenName = 'Inventory.view.InventoryReceipt'
					,@entityId = @intEntityId
					,@actionType = 'Created'
					,@actionIcon = 'small-new-plus'
					,@changeDescription = @strDescription
					,@fromValue = ''
					,@toValue = @strReceiptNo
			END

			--Post Receipt
			EXEC uspICPostInventoryReceipt 1
				,0
				,@strReceiptNo
				,@intEntityId

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
