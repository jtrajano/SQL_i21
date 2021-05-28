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

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Service Order Ack'

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
				TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,WorkOrderNo
				,ERPShopOrderNo
				,ERPServicePONo
				,StatusId
				,StatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,WorkOrderNo
				,ERPShopOrderNo
				,ERPServicePONo
				,StatusId
				,StatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo BIGINT
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
				SELECT @TrxSequenceNo = NULL
					,@CompanyLocation = NULL
					,@CreatedDate = NULL
					,@CreatedBy = NULL
					,@WorkOrderNo = NULL
					,@ERPShopOrderNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL
					,@ERPServicePONo = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@WorkOrderNo = WorkOrderNo
					,@ERPShopOrderNo = ERPShopOrderNo
					,@ERPServicePONo = ERPServicePONo
					,@StatusId = StatusId
					,@StatusText = StatusText
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intWorkOrderId = intWorkOrderId
				FROM tblMFWorkOrderPreStage
				WHERE intWorkOrderPreStageId = @TrxSequenceNo

				UPDATE tblMFWorkOrderPreStage
				SET intStatusId = 6
					,strMessage='Success'
				WHERE intWorkOrderPreStageId = @TrxSequenceNo

				UPDATE tblMFWorkOrder
				SET strERPServicePONumber = @ERPServicePONo
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intWorkOrderId = @intWorkOrderId

				UPDATE RMD
				SET strERPServicePOLineNo = ERPServicePOlineNo
				FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
						TrxSequenceNo BIGINT
						,ERPServicePOlineNo NVARCHAR(50)
						,parentId BIGINT '@parentId'
						) x
				JOIN dbo.tblMFWorkOrderWarehouseRateMatrixDetail RMD ON RMD.intWorkOrderWarehouseRateMatrixDetailId = x.TrxSequenceNo
				WHERE RMD.intWorkOrderId = @intWorkOrderId and parentId=@TrxSequenceNo

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					)
				VALUES (
					'Service Order Ack'
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
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Service Order Ack'
	END

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
