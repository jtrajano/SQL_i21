CREATE PROCEDURE uspIPProcessPOAcknowledgement_CA (
	@strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
	)
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
		,@strERPPONumber NVARCHAR(50)
		,@strCode NVARCHAR(50)
		,@strDescription NVARCHAR(MAX)
		,@strReference NVARCHAR(50)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@intMinRowNo INT
		,@strContractSeq NVARCHAR(50)
		,@intContractHeaderId INT
		,@strContractNumber NVARCHAR(50)
	DECLARE @tblAcknowledgement AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,strCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strDescription NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,strReference NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMessage AS TABLE (
		intRowNo INT identity(1, 1)
		,strMessageType NVARCHAR(50)
		,strMessage NVARCHAR(MAX)
		,strInfo1 NVARCHAR(50)
		,strInfo2 NVARCHAR(50)
		,strXml NVARCHAR(MAX)
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'POAcknowledgement'

	WHILE @intRowNo IS NOT NULL
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblAcknowledgement

			INSERT INTO @tblAcknowledgement (
				strCode
				,strDescription
				,strReference
				)
			SELECT code
				,description
				,reference
			FROM OPENXML(@idoc, 'Acknowledgement', 2) WITH (
					code NVARCHAR(50)
					,description NVARCHAR(MAX)
					,reference NVARCHAR(50)
					)

			SELECT @intMinRowNo = MIN(intRowNo)
			FROM @tblAcknowledgement

			WHILE @intMinRowNo IS NOT NULL
			BEGIN
				SELECT @strCode = NULL
					,@strDescription = NULL
					,@strReference = NULL
					,@strContractSeq = NULL
					,@intContractHeaderId = NULL
					,@strContractNumber = NULL

				SELECT @strCode = strCode
					,@strDescription = strDescription
					,@strReference = strReference
				FROM @tblAcknowledgement
				WHERE intRowNo = @intMinRowNo

				UPDATE tblIPThirdPartyContractFeed
				SET strThirdPartyFeedStatus = 'Ack Rcvd'
					,strThirdPartyMessage = CASE 
						WHEN @strCode = '200'
							THEN 'Success'
						ELSE @strDescription
						END
				WHERE strERPPONumber = @strReference
					AND strThirdPartyFeedStatus IN (
						'Awt Ack'
						,'Ack Rcvd'
						)

				SELECT TOP 1 @strContractSeq = CONVERT(VARCHAR, intContractSeq)
					,@intContractHeaderId = intContractHeaderId
				FROM tblCTContractDetail WITH (NOLOCK)
				WHERE strERPPONumber = @strReference

				SELECT @strContractNumber = strContractNumber
				FROM tblCTContractHeader WITH (NOLOCK)
				WHERE intContractHeaderId = @intContractHeaderId

				INSERT INTO @tblMessage (
					strMessageType
					,strMessage
					,strInfo1
					,strInfo2
					,strXml
					)
				VALUES (
					'Contract Create/Update'
					,CASE 
						WHEN @strCode = '200'
							THEN 'Success'
						ELSE @strDescription
						END
					,@strContractNumber + ' / ' + ISNULL(@strContractSeq, '')
					,@strReference
					,@strXml
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
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			EXEC sp_xml_removedocument @idoc

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
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage WITH (NOLOCK)
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'POAcknowledgement'
	END

	--SELECT intRowNo AS id
	--	,strXml AS strXml
	--	,ISNULL(strInfo1, '') AS strInfo1
	--	,ISNULL(strInfo2, '') AS strInfo2
	--	,'' AS strOnFailureCallbackSql
	--FROM @tblMessage
	--ORDER BY intRowNo
	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + IsNULL(strInfo1, '') + ','
		,@strInfo2 = @strInfo2 + ISNULL(strInfo2, '') + ','
	FROM @tblMessage

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF (ISNULL(@strInfo2, '')) <> ''
		SELECT @strInfo2 = LEFT(@strInfo2, LEN(@strInfo2) - 1)

	IF Len(@strInfo1) > 0
		OR Len(@strInfo2) > 0
	BEGIN
		SELECT @intNoOfRowsAffected = 1
	END
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
