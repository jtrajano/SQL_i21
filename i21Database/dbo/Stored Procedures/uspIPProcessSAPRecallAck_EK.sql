CREATE PROCEDURE uspIPProcessSAPRecallAck_EK
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@strMessage NVARCHAR(MAX)
		,@intMinRowNo INT
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@DocNo NVARCHAR(50)
		,@MsgType NVARCHAR(50)
		,@Sender NVARCHAR(50)
		,@Receiver NVARCHAR(50)
		,@StatusText NVARCHAR(MAX)
		,@Plant NVARCHAR(50)
		,@OrderNo NVARCHAR(50)
		,@RecallAllowed INT
		,@intWorkOrderId INT
		,@ItemsToReserve AS dbo.ItemReservationTableType
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,DocNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,MsgType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Sender NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Receiver NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Plant NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,OrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,RecallAllowed INT
		,StatusText NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
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
	WHERE strType = 'Recall BlendSheet Ack'
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
				DocNo
				,MsgType
				,Sender
				,Receiver
				,Plant
				,OrderNo
				,RecallAllowed
				,StatusText
				)
			SELECT DocNo
				,MsgType
				,Sender
				,Receiver
				,Plant
				,OrderNo
				,RecallAllowed
				,StatusText
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,MsgType NVARCHAR(50) '../MsgType'
					,Sender NVARCHAR(50) '../Sender'
					,Receiver NVARCHAR(50) '../Receiver'
					,Plant NVARCHAR(50)
					,OrderNo NVARCHAR(50)
					,RecallAllowed INT
					,StatusText NVARCHAR(MAX)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @DocNo = NULL
					,@MsgType = NULL
					,@Sender = NULL
					,@Receiver = NULL
					,@Plant = NULL
					,@OrderNo = NULL
					,@RecallAllowed = NULL
					,@StatusText = NULL

				SELECT @DocNo = DocNo
					,@MsgType = MsgType
					,@Sender = Sender
					,@Receiver = Receiver
					,@Plant = Plant
					,@OrderNo = OrderNo
					,@RecallAllowed = RecallAllowed
					,@StatusText = StatusText
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				SELECT @intWorkOrderId = intWorkOrderId
				FROM tblMFWorkOrder
				WHERE strERPOrderNo = @OrderNo

				IF @MsgType = 'Recall_BlendSheet_Ack'
				BEGIN
					IF @RecallAllowed = 1 --Success
					BEGIN
						UPDATE tblMFRecallPreStage
						SET intStatusId = 4
							,ysnRecallAllowed = 1
						WHERE intWorkOrderId = @intWorkOrderId
							AND intStatusId = 2

						SELECT @intWorkOrderId

						UPDATE tblMFWorkOrder
						SET intStatusId = 19
							,intTrialBlendSheetStatusId	= NULL
							,intApprovedBy				= NULL
						   ,dtmApprovedDate				= NULL
						WHERE intWorkOrderId = @intWorkOrderId

						EXEC dbo.uspICCreateStockReservation @ItemsToReserve
							,@intWorkOrderId
							,8

						UPDATE tblMFWorkOrderInputLot
						SET ysnTBSReserved = 1
						WHERE intWorkOrderId = @intWorkOrderId

						EXEC [dbo].[uspMFUpdateTrialBlendSheetReservation] @intWorkOrderId

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							'Recall Ack'
							,'Success'
							,@Plant
							,@OrderNo
							)
					END

					IF @RecallAllowed = 0
					BEGIN
						UPDATE tblMFRecallPreStage
						SET strMessage = @StatusText
							,intStatusId = 3
							,ysnRecallAllowed = 0
						WHERE intWorkOrderId = @intWorkOrderId
							AND intStatusId = 2

						UPDATE tblMFWorkOrder
						SET intStatusId = 20,strERPComment =@StatusText
						WHERE intWorkOrderId = @intWorkOrderId

						INSERT INTO @tblMessage (
							strMessageType
							,strMessage
							,strInfo1
							,strInfo2
							)
						VALUES (
							'Recall Ack'
							,@StatusText
							,@Plant
							,@OrderNo
							)
					END
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
