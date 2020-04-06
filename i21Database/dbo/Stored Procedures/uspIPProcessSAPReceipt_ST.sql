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
	DECLARE @strContractNumber NVARCHAR(50)
		,@intContractSeq INT
		,@strBLNumber NVARCHAR(100)
		,@strStatus NVARCHAR(100)
		,@dtmArrivedInPort DATETIME
		,@dtmCustomsReleased DATETIME
		,@dtmETA DATETIME
	DECLARE @strLoadNumber NVARCHAR(100)
		,@strDeliveryNo NVARCHAR(50)
		,@intLoadId INT
	DECLARE @strDescription AS NVARCHAR(MAX)
	DECLARE @intNewStageReceiptId INT

	SELECT @intMinRowNo = Min(intStageReceiptId)
	FROM tblIPInvReceiptStage WITH (NOLOCK)

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strContractNumber = NULL
				,@intContractSeq = NULL
				,@strBLNumber = NULL
				,@strStatus = NULL
				,@dtmArrivedInPort = NULL
				,@dtmCustomsReleased = NULL
				,@dtmETA = NULL

			SELECT @strLoadNumber = NULL
				,@strDeliveryNo = NULL
				,@intLoadId = NULL

			SELECT @strDescription = NULL

			SELECT @strContractNumber = strContractNumber
				,@intContractSeq = intContractSeq
				,@strBLNumber = strBLNumber
				,@strStatus = strStatus
				,@dtmArrivedInPort = dtmArrivedInPort
				,@dtmCustomsReleased = dtmCustomsReleased
				,@dtmETA = dtmETA
			FROM tblIPShipmentStatusStage WITH (NOLOCK)
			WHERE intStageShipmentStatusId = @intMinRowNo

			SELECT @strLoadNumber = L.strLoadNumber
				,@strDeliveryNo = L.strExternalShipmentNumber
				,@intLoadId = L.intLoadId
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND L.intShipmentType = 1
				AND L.strBLNumber = @strBLNumber
			JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
				AND CD.intContractSeq = @intContractSeq
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
				AND CH.strContractNumber = @strContractNumber

			SET @strInfo1 = ISNULL(@strLoadNumber, '') + ' / ' + ISNULL(@strDeliveryNo, '')
			SET @strInfo2 = ISNULL(CONVERT(VARCHAR(10), @dtmETA, 121), '')

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			IF @strStatus IS NULL
				AND @dtmETA IS NULL
			BEGIN
				RAISERROR (
						'Invalid Status and ETA. '
						,16
						,1
						)
			END

			IF ISNULL(@intLoadId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Load No. '
						,16
						,1
						)
			END

			BEGIN TRAN

			-- Shipment Status Update
			IF ISNULL(@strStatus, '') <> ''
			BEGIN
				-- Audit Log
				IF (@intLoadId > 0)
				BEGIN
					SELECT @strDescription = 'Receipt created from external system. '

					EXEC uspSMAuditLog @keyValue = @intLoadId
						,@screenName = 'Inventory.view.InventoryReceipt'
						,@entityId = @intEntityId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @strDescription
						,@fromValue = ''
						,@toValue = @strLoadNumber
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
