CREATE PROCEDURE uspIPProcessERPInitialAck
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
		,@TrxSequenceNo INT
		,@CompanyLocation NVARCHAR(6)
		,@CreatedDate DATETIME
		,@CreatedBy NVARCHAR(50)
		,@MessageTypeId INT
		,@ERPCONumber NVARCHAR(50)
		,@ERPReferenceNo NVARCHAR(50)
		,@ERPShopOrderNo NVARCHAR(50)
		,@ERPTransferOrderNo NVARCHAR(50)
		,@ERPVoucherNo NVARCHAR(50)
		,@StatusId INT
		,@StatusText NVARCHAR(2048)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intWorkOrderId INT
		,@strWorkOrderNo NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,TrxSequenceNo INT
		,CompanyLocation NVARCHAR(6)
		,CreatedDate DATETIME
		,CreatedBy NVARCHAR(50)
		,MessageTypeId INT
		,ERPCONumber NVARCHAR(50)
		,ERPReferenceNo NVARCHAR(50)
		,ERPShopOrderNo NVARCHAR(50)
		,ERPTransferOrderNo NVARCHAR(50)
		,ERPVoucherNo NVARCHAR(50)
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
	WHERE strType = 'InitialAck'

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
				,MessageTypeId
				,ERPCONumber
				,ERPReferenceNo
				,ERPShopOrderNo
				,ERPTransferOrderNo
				,ERPVoucherNo
				,StatusId
				,StatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedBy
				,MessageTypeId
				,ERPCONumber
				,ERPReferenceNo
				,ERPShopOrderNo
				,ERPTransferOrderNo
				,ERPVoucherNo
				,StatusId
				,StatusText
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedBy NVARCHAR(50)
					,MessageTypeId INT
					,ERPCONumber NVARCHAR(50)
					,ERPReferenceNo NVARCHAR(50)
					,ERPShopOrderNo NVARCHAR(50)
					,ERPTransferOrderNo NVARCHAR(50)
					,ERPVoucherNo NVARCHAR(50)
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
					,@MessageTypeId = NULL
					,@ERPCONumber = NULL
					,@ERPReferenceNo = NULL
					,@ERPShopOrderNo = NULL
					,@ERPTransferOrderNo = NULL
					,@ERPVoucherNo = NULL
					,@strWorkOrderNo = NULL
					,@StatusId = NULL
					,@StatusText = NULL

				SELECT @TrxSequenceNo = TrxSequenceNo
					,@CompanyLocation = CompanyLocation
					,@CreatedDate = CreatedDate
					,@CreatedBy = CreatedBy
					,@MessageTypeId = MessageTypeId
					,@ERPCONumber = ERPCONumber
					,@ERPReferenceNo = ERPReferenceNo
					,@ERPShopOrderNo = ERPShopOrderNo
					,@ERPTransferOrderNo = ERPTransferOrderNo
					,@ERPVoucherNo = ERPVoucherNo
					,@StatusId = StatusId
					,@StatusText = StatusText
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				/*  
    Not Processed: NULL  
    In-Progress: -1  
    Internal Error in i21: 1  
    Sent to AX: 2  
    AX 1st Level Failure: 3, AX 1st Level Success: 4  
    AX 2nd Level Failure: 5, AX 2nd Level Success: 6  
   */
				IF @MessageTypeId = 6 --Production Order
				BEGIN
					SELECT @intWorkOrderId = intWorkOrderId
						,@strWorkOrderNo = strWorkOrderNo
					FROM tblMFWorkOrderPreStage
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					UPDATE tblMFWorkOrderPreStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					UPDATE tblMFWorkOrder
					SET strERPOrderNo = @ERPShopOrderNo
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intWorkOrderId = @intWorkOrderId

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'InitialAck'
						,'Success'
						,@strWorkOrderNo
						,@ERPShopOrderNo
						)
				END
				ELSE IF @MessageTypeId = 7 --Service PO
				BEGIN
					SELECT @intWorkOrderId = intWorkOrderId
						,@strWorkOrderNo = strWorkOrderNo
						,@ERPShopOrderNo = strERPOrderNo
					FROM tblMFWorkOrderPreStage
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					UPDATE tblMFWorkOrderPreStage
					SET intServiceOrderStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intWorkOrderPreStageId = @TrxSequenceNo

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'InitialAck'
						,'Success'
						,@strWorkOrderNo
						,@ERPShopOrderNo
						)
				END
				ELSE IF @MessageTypeId = 8 --Production and Consumption
				BEGIN
					UPDATE tblMFProductionPreStage
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intProductionPreStageId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 10 --Lot Merge
				BEGIN
					UPDATE tblIPLotMergeFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotMergeFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 11 --Lot Split
				BEGIN
					UPDATE tblIPLotSplitFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotSplitFeedId = @TrxSequenceNo
				END
				ELSE IF @MessageTypeId = 13 --Lot Property Adj
				BEGIN
					UPDATE tblIPLotPropertyFeed
					SET intStatusId = (
							CASE 
								WHEN @StatusId = 1
									THEN 4
								ELSE 3
								END
							)
						,strMessage = @StatusText
					WHERE intLotPropertyFeedId = @TrxSequenceNo
				END

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
			AND strType = 'InitialAck'
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
