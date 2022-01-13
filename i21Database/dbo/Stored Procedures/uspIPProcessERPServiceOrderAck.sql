CREATE PROCEDURE uspIPProcessERPServiceOrderAck
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@OriginalTrxSequenceNo BIGINT
		,@TrxSequenceNo BIGINT
		,@CompanyLocation NVARCHAR(6)
		,@CreatedDate DATETIME
		,@CreatedBy NVARCHAR(50)
		,@WorkOrderNo NVARCHAR(50)
		,@ERPShopOrderNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intWorkOrderId INT
		,@ERPServicePONo NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,OriginalTrxSequenceNo BIGINT
		,TrxSequenceNo BIGINT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,WorkOrderNo NVARCHAR(50)
		,ERPShopOrderNo NVARCHAR(50)
		,ERPServicePONo NVARCHAR(50)
		,StatusId INT
		,StatusText NVARCHAR(2048)
		)
	DECLARE @tblMessage AS TABLE (
		strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		)
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Service PO Ack'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblAcknowledgement

			INSERT INTO @tblAcknowledgement (
				OriginalTrxSequenceNo
				,TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,WorkOrderNo
				,ERPShopOrderNo
				,ERPServicePONo
				,StatusId
				,StatusText
				)
			SELECT OriginalTrxSequenceNo
				,TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,WorkOrderNo
				,ERPShopOrderNo
				,ERPServicePONo
				,StatusId
				,StatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					OriginalTrxSequenceNo BIGINT
					,TrxSequenceNo BIGINT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,WorkOrderNo NVARCHAR(50)
					,ERPShopOrderNo NVARCHAR(50)
					,ERPServicePONo NVARCHAR(50)
					,StatusId INT
					,StatusText NVARCHAR(2048)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @OriginalTrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@WorkOrderNo = NULL
					,@ERPShopOrderNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@ERPServicePONo = NULL
					,@TrxSequenceNo = NULL

				SELECT @OriginalTrxSequenceNo = OriginalTrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@WorkOrderNo = WorkOrderNo
					,@ERPShopOrderNo = ERPShopOrderNo
					,@ERPServicePONo = ERPServicePONo
					,@StatusId = StatusId
					,@StatusText = StatusText
					,@TrxSequenceNo = TrxSequenceNo
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intWorkOrderId = intWorkOrderId
				FROM tblMFWorkOrderPreStage
				WHERE intWorkOrderPreStageId = @OriginalTrxSequenceNo

				UPDATE tblMFWorkOrderPreStage
				SET intStatusId = 6
					,strMessage = 'Success'
				WHERE intWorkOrderPreStageId = @OriginalTrxSequenceNo

				IF @ERPServicePONo IS NOT NULL
				BEGIN
					UPDATE tblMFWorkOrder
					SET strERPServicePONumber = @ERPServicePONo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intWorkOrderId = @intWorkOrderId
				END

				UPDATE tblMFWorkOrderWarehouseRateMatrixDetail
				SET strERPServicePOLineNo = x.ERPServicePOLineNo
				FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
						OriginalTrxSequenceNo BIGINT '../OriginalTrxSequenceNo'
						,ERPServicePOLineNo NVARCHAR(50)
						) x
				WHERE intWorkOrderId = @intWorkOrderId
					AND x.OriginalTrxSequenceNo = @OriginalTrxSequenceNo

				INSERT INTO tblIPInitialAck (
					intTrxSequenceNo
					,strCompanyLocation
					,dtmCreatedDate
					,strCreatedBy
					,intMessageTypeId
					,intStatusId
					,strStatusText
					)
				SELECT @TrxSequenceNo
					,@CompanyLocation
					,@CreatedDate
					,@CreatedBy
					,21
					,1
					,'Success'

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					'Service PO Ack'
					,'Success'
					,@WorkOrderNo
					,@ERPServicePONo
					)

				SELECT @intMinRowNo = MIN(intRowNo)
				FROM @tblAcknowledgement
				WHERE intRowNo > @intMinRowNo
			END

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

	SELECT strMessageType
		,strMessage
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
	FROM @tblMessage
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
