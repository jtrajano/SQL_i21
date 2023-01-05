CREATE PROCEDURE uspIPProcessSAPPriceAck_EK
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
		,@RefNo INT
		,@dblLandedPrice NUMERIC(18, 6)
		,@dblPurchasePrice NUMERIC(18, 6)
		,@dblSalePrice NUMERIC(18, 6)
		,@intContractDetailId INT
		,@intSampleId INT
		,@intPriceFeedId INT
		,@intUserId INT
		,@strContractNumber NVARCHAR(50)
		,@intContractSeq INT
		,@intPriceItemUOMId INT
		,@intCurrencyId INT
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,DocNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,MsgType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Sender NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,Receiver NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,RefNo INT
		,dblLandedPrice NUMERIC(18, 6)
		,dblPurchasePrice NUMERIC(18, 6)
		,dblSalePrice NUMERIC(18, 6)
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
	WHERE strType = 'Price Simulation Ack'
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
				,RefNo
				,dblLandedPrice
				,dblPurchasePrice
				,dblSalePrice
				)
			SELECT DocNo
				,MsgType
				,Sender
				,Receiver
				,ReferenceNo
				,LandedPrice
				,PurchasePrice
				,SalePrice
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,MsgType NVARCHAR(50) '../MsgType'
					,Sender NVARCHAR(50) '../Sender'
					,Receiver NVARCHAR(50) '../Receiver'
					,ReferenceNo INT
					,LandedPrice NUMERIC(18, 6)
					,PurchasePrice NUMERIC(18, 6)
					,SalePrice NUMERIC(18, 6)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE (@intMinRowNo IS NOT NULL)
			BEGIN
				SELECT @DocNo = NULL
					,@MsgType = NULL
					,@Sender = NULL
					,@Receiver = NULL
					,@RefNo = NULL
					,@dblLandedPrice = NULL
					,@dblPurchasePrice = NULL
					,@dblSalePrice = NULL

				SELECT @intContractDetailId = NULL
					,@intSampleId = NULL
					,@intPriceFeedId = NULL
					,@strContractNumber = NULL
					,@intContractSeq = NULL
					,@intPriceItemUOMId = NULL
					,@intCurrencyId = NULL

				SELECT @DocNo = DocNo
					,@MsgType = MsgType
					,@Sender = Sender
					,@Receiver = Receiver
					,@RefNo = RefNo
					,@dblLandedPrice = dblLandedPrice
					,@dblPurchasePrice = dblPurchasePrice
					,@dblSalePrice = dblSalePrice
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				--BEGIN TRAN

				IF @MsgType = 'Price_Simulation_Ack'
				BEGIN
					SELECT @intPriceFeedId = intPriceFeedId
						,@intContractDetailId = intContractDetailId
						,@intSampleId = intSampleId
					FROM dbo.tblIPPriceFeed
					WHERE intPriceFeedId = @RefNo

					IF ISNULL(@intPriceFeedId, 0) > 0
					BEGIN
						UPDATE tblIPPriceFeed
						SET strFeedStatus = 'Ack Rcvd'
							,strMessage = 'Success'
							,intStatusId = 4
							,dblLandedPrice = @dblLandedPrice
							,dblPurchasePrice = @dblPurchasePrice
							,dblSalePrice = @dblSalePrice
						WHERE intPriceFeedId = @intPriceFeedId
							AND ISNULL(strFeedStatus, '') = 'Awt Ack'

						SELECT @intUserId = intEntityId
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'IRELYADMIN'

						IF @intContractDetailId IS NOT NULL
						BEGIN
							SELECT @strContractNumber = CH.strContractNumber
								,@intContractSeq = CD.intContractSeq
								,@intPriceItemUOMId = CD.intPriceItemUOMId
								,@intCurrencyId = CD.intCurrencyId
							FROM dbo.tblCTContractDetail CD WITH (NOLOCK)
							JOIN dbo.tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
								AND CD.intContractDetailId = @intContractDetailId

							BEGIN TRY
								EXEC uspCTUpdateIntegrationPrice @strContractNumber = @strContractNumber
									,@intContractSeq = @intContractSeq
									,@dblPurchasePrice = @dblPurchasePrice
									,@dblLandedPrice = @dblLandedPrice
									,@dblSalesPrice = @dblSalePrice
									,@intUserId = @intUserId
									,@intFeedPriceItemUOMId = @intPriceItemUOMId
									,@intFeedPriceCurrencyId = @intCurrencyId
							END TRY

							BEGIN CATCH
							END CATCH
						END
						ELSE IF @intSampleId IS NOT NULL
						BEGIN
							UPDATE tblMFBatch
							SET dblLandedPrice = @dblLandedPrice
								,dblBoughtPrice = @dblPurchasePrice
								,dblSellingPrice = @dblSalePrice
								,intConcurrencyId = intConcurrencyId + 1
							WHERE intSampleId = @intSampleId
						END
					END

					INSERT INTO @tblMessage (
						strMessageType
						,strMessage
						,strInfo1
						,strInfo2
						)
					VALUES (
						'Price Simulation Ack'
						,'Success'
						,@RefNo
						,ISNULL(LTRIM(@dblLandedPrice), '')
						)
				END

				--COMMIT TRAN

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
		END TRY

		BEGIN CATCH
			--IF XACT_STATE() != 0
			--	AND @@TRANCOUNT > 0
			--	ROLLBACK TRANSACTION

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
