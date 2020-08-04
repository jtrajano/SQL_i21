CREATE PROCEDURE uspIPProcessSAPLSICancel_CA @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@strRowState NVARCHAR(50)
	DECLARE @strCustomerReference NVARCHAR(100)
		,@strCancelStatus NVARCHAR(50)
		,@dtmCancelDate DATETIME
	DECLARE @strLoadNumber NVARCHAR(100)
		,@intLoadId INT
		,@intContractDetailId INT
		,@dblQuantityToUpdate NUMERIC(18, 6)
		,@intShipmentStatus INT
	DECLARE @strDescription NVARCHAR(MAX)

	SELECT @intMinRowNo = Min(intStageLoadId)
	FROM tblIPLoadStage WITH (NOLOCK)
	WHERE ISNULL(strTransactionType, '') = 'LSI_Cancel'

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strCustomerReference = NULL
				,@strCancelStatus = NULL
				,@dtmCancelDate = NULL

			SELECT @strLoadNumber = NULL
				,@intLoadId = NULL
				,@intContractDetailId = NULL
				,@dblQuantityToUpdate = NULL
				,@intShipmentStatus = NULL

			SELECT @strDescription = NULL

			SELECT @strRowState = 'Cancel'

			UPDATE tblIPLoadStage
			SET strAction = @strRowState
			WHERE intStageLoadId = @intMinRowNo

			SELECT @strCustomerReference = strCustomerReference
				,@strCancelStatus = strCancelStatus
				,@dtmCancelDate = dtmCancelDate
			FROM tblIPLoadStage WITH (NOLOCK)
			WHERE intStageLoadId = @intMinRowNo

			UPDATE tblIPLoadError
			SET ysnDeadlockError = 0
			WHERE ysnDeadlockError = 1
				AND strCustomerReference = @strCustomerReference

			IF ISNULL(@strCustomerReference, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Customer Reference. '
						,16
						,1
						)
			END

			IF ISNULL(@strCancelStatus, '') <> '240'
			BEGIN
				RAISERROR (
						'Invalid Status Code. '
						,16
						,1
						)
			END

			SELECT TOP 1 @strLoadNumber = L.strLoadNumber
				,@intLoadId = L.intLoadId
				,@intContractDetailId = CD.intContractDetailId
				,@dblQuantityToUpdate = - LD.dblQuantity
				,@intShipmentStatus = L.intShipmentStatus
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND L.strCustomerReference = @strCustomerReference
				AND L.intShipmentType = 2
				--AND L.intShipmentStatus <> 10
			JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId

			-- Contract Unslice - LSI will get deleted. so will not have LSI No.
			IF ISNULL(@intLoadId, 0) = 0
				SELECT @intLoadId = 0

			-- If LSI is already cancelled, we should not do the process again.
			IF ISNULL(@intShipmentStatus, 0) = 10
				SELECT @intLoadId = 0

			IF EXISTS (
					SELECT 1
					FROM tblLGLoad
					WHERE intLoadShippingInstructionId = @intLoadId
						AND intShipmentStatus <> 10
					)
			BEGIN
				RAISERROR (
						'Shipment has already been created for the shipping instruction. Cannot cancel.'
						,11
						,1
						)
			END

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			SET @strInfo1 = ISNULL(@strCustomerReference, '') + ' / ' + 'Cancel'
			SET @strInfo2 = ISNULL(@strLoadNumber, '')

			UPDATE tblIPLoadStage
			SET strLoadNumber = @strLoadNumber
			WHERE intStageLoadId = @intMinRowNo

			BEGIN TRAN

			-- Shipment Instruction Cancel
			IF ISNULL(@intLoadId, 0) > 0
			BEGIN
				IF (ISNULL(@intContractDetailId, 0) > 0)
				BEGIN
					EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityId
				END

				UPDATE tblLGLoad
				SET intShipmentStatus = 10
					,ysnCancelled = 1
				WHERE intLoadId = @intLoadId

				--EXEC uspLGCreateLoadIntegrationLog @intLoadId = @intLoadId
				--	,@strRowState = 'Delete'
				--	,@intShipmentType = 2 -- LSI

				-- Audit Log
				EXEC uspSMAuditLog @keyValue = @intLoadId
					,@screenName = 'Logistics.view.ShipmentSchedule'
					,@entityId = @intEntityId
					,@actionType = 'Cancel'
					,@actionIcon = 'small-tree-modified'
					,@details = ''
			END

			--Move to Archive
			INSERT INTO tblIPLoadArchive (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strBLNumber
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				,ysnDeadlockError
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strBLNumber
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,''
				,'Success'
				,strSessionId
				,ysnDeadlockError
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			DELETE
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPLoadError (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strBLNumber
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strBLNumber
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			DELETE
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageLoadId)
		FROM tblIPLoadStage WITH (NOLOCK)
		WHERE intStageLoadId > @intMinRowNo
			AND ISNULL(strTransactionType, '') = 'LSI_Cancel'
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
