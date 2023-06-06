CREATE PROCEDURE [dbo].[uspIPProcessERPInboundDelivery_EK] @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS ON

	DECLARE @intInboundDeliveryStageId INT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @dtmDate DATETIME
	DECLARE @intUserId INT
	DECLARE @strUserName NVARCHAR(100)
	DECLARE @strFinalErrMsg NVARCHAR(MAX) = ''
		,@strCompanyLocation NVARCHAR(50)
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
		,@strPONumber NVARCHAR(50)
		,@strPOLineItemNo NVARCHAR(50)
		,@strPOStatus NVARCHAR(50)
		,@strBatchId NVARCHAR(50)
		,@strContainerNo NVARCHAR(50)
		,@strBOLNo NVARCHAR(50)
		,@dtmStockDate DATETIME
		,@strFreightAgent NVARCHAR(50)
		,@strSealNo NVARCHAR(50)
		,@strContainerType NVARCHAR(50)
		,@strVoyage NVARCHAR(50)
		,@strVessel NVARCHAR(50)
		,@intCompanyLocationId INT
		,@strError NVARCHAR(MAX)
		,@strIBDNo NVARCHAR(50)

	SELECT @dtmDate = GETDATE()

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	DECLARE @tblIPInboundDeliveryStage TABLE (intInboundDeliveryStageId INT)

	INSERT INTO @tblIPInboundDeliveryStage
	SELECT intInboundDeliveryStageId
	FROM tblIPInboundDeliveryStage
	WHERE intStatusId IS NULL

	UPDATE tblIPInboundDeliveryStage
	SET intStatusId = - 1
	WHERE intInboundDeliveryStageId IN (
			SELECT intInboundDeliveryStageId
			FROM @tblIPInboundDeliveryStage
			)

	SELECT @intInboundDeliveryStageId = MIN(intInboundDeliveryStageId)
	FROM @tblIPInboundDeliveryStage

	SELECT @strInfo1 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strBatchId, '') + ', '
	FROM @tblIPInboundDeliveryStage a
	JOIN tblIPInboundDeliveryStage b ON a.intInboundDeliveryStageId = b.intInboundDeliveryStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	WHILE @intInboundDeliveryStageId IS NOT NULL
	BEGIN
		BEGIN TRY
			SELECT @strCompanyLocation = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL
				,@strPONumber = NULL
				,@strPOLineItemNo = NULL
				,@strPOStatus = NULL
				,@strBatchId = NULL
				,@strContainerNo = NULL
				,@strBOLNo = NULL
				,@dtmStockDate = NULL
				,@strFreightAgent = NULL
				,@strSealNo = NULL
				,@strContainerType = NULL
				,@strVoyage = NULL
				,@strVessel = NULL
				,@strIBDNo	= NULL

			SELECT @strCompanyLocation = strCompanyLocation
				,@dtmCreatedDate = dtmCreatedDate
				,@strPONumber = strPONumber
				,@strPOLineItemNo = strPOLineItemNo
				,@strPOStatus = strPOStatus
				,@strBatchId = strBatchId
				,@strContainerNo = strContainerNo
				,@strBOLNo = strBOLNo
				,@dtmStockDate = dtmStockDate
				,@strFreightAgent = strFreightAgent
				,@strSealNo = strSealNo
				,@strContainerType = strContainerType
				,@strVoyage = strVoyage
				,@strVessel = strVessel
				,@strIBDNo = strIBDNo
			FROM tblIPInboundDeliveryStage
			WHERE intInboundDeliveryStageId = @intInboundDeliveryStageId

			SELECT @intCompanyLocationId = NULL

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLocationNumber = @strCompanyLocation

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location ' + @strCompanyLocation + 'is not available.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			UPDATE tblMFBatch
			SET strPOStatus = (
					CASE 
						WHEN @strPOStatus = 'A'
							THEN 'PO Open'
						ELSE 'Completed'
						END
					)
				,strContainerNumber = @strContainerNo
				,strBOLNo = @strBOLNo
				,dtmStock = @dtmStockDate
				,strFreightAgent = @strFreightAgent
				,strSealNumber = @strSealNo
				,strContainerType = @strContainerType
				,strVoyage = @strVoyage
				,strVessel = @strVessel
				,strIBDNo = @strIBDNo
			WHERE strBatchId = @strBatchId

			MOVE_TO_ARCHIVE:

			--Move to Ack
			INSERT INTO tblIPInboundDeliveryArchive (
				intInboundDeliveryArchiveId
				,intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strPONumber
				,strPOLineItemNo
				,strPOStatus
				,strBatchId
				,strContainerNo
				,strBOLNo
				,dtmStockDate
				,strFreightAgent
				,strSealNo
				,strContainerType
				,strVoyage
				,strVessel
				,strIBDNo
				)
			SELECT intInboundDeliveryStageId
				,intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strPONumber
				,strPOLineItemNo
				,strPOStatus
				,strBatchId
				,strContainerNo
				,strBOLNo
				,dtmStockDate
				,strFreightAgent
				,strSealNo
				,strContainerType
				,strVoyage
				,strVessel
				,strIBDNo
			FROM tblIPInboundDeliveryStage
			WHERE intInboundDeliveryStageId = @intInboundDeliveryStageId

			DELETE
			FROM tblIPInboundDeliveryStage
			WHERE intInboundDeliveryStageId = @intInboundDeliveryStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = NULL
			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPInboundDeliveryError (
				intInboundDeliveryErrorId
				,intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strPONumber
				,strPOLineItemNo
				,strPOStatus
				,strBatchId
				,strContainerNo
				,strBOLNo
				,dtmStockDate
				,strFreightAgent
				,strSealNo
				,strContainerType
				,strVoyage
				,strVessel
				,strMessage
				,strIBDNo
				)
			SELECT intInboundDeliveryStageId
				,intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strPONumber
				,strPOLineItemNo
				,strPOStatus
				,strBatchId
				,strContainerNo
				,strBOLNo
				,dtmStockDate
				,strFreightAgent
				,strSealNo
				,strContainerType
				,strVoyage
				,strVessel
				,@ErrMsg AS strStatusText
				,strIBDNo
			FROM tblIPInboundDeliveryStage
			WHERE intInboundDeliveryStageId = @intInboundDeliveryStageId

			DELETE
			FROM tblIPInboundDeliveryStage
			WHERE intInboundDeliveryStageId = @intInboundDeliveryStageId
		END CATCH

		SELECT @intInboundDeliveryStageId = MIN(intInboundDeliveryStageId)
		FROM @tblIPInboundDeliveryStage
		WHERE intInboundDeliveryStageId > @intInboundDeliveryStageId
	END

	UPDATE tblIPInboundDeliveryStage
	SET intStatusId = NULL
	WHERE intInboundDeliveryStageId IN (
			SELECT intInboundDeliveryStageId
			FROM @tblIPInboundDeliveryStage
			)
		AND intStatusId = - 1

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
