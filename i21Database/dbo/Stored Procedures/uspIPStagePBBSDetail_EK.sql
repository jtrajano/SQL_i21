CREATE PROCEDURE uspIPStagePBBSDetail_EK @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@dtmCurrentDate DATETIME
	DECLARE @tblIPPBBS TABLE (strBlendCode NVARCHAR(50))
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'PBBS Detail'
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

	SELECT @dtmCurrentDate = GETDATE()

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblIPPBBS

			INSERT INTO tblIPPBBSStage (
				intDocNo
				,strSender
				,intPBBSID
				,strBlendCode
				,strMaterialCode
				,dtmValidFrom
				,dtmValidTo
				,dblSieve1M
				,dblSieve1T1
				,dblSieve1T2
				,strPDFFileName
				,blbPDFContent
				)
			OUTPUT INSERTED.strBlendCode
			INTO @tblIPPBBS
			SELECT DocNo
				,Sender
				,PBBSID
				,BlendCode
				,MaterialCode
				,ValidFrom
				,ValidTo
				,Sieve1M
				,Sieve1T1
				,Sieve1T2
				,PDFFileName
				,PDFContent
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,Sender NVARCHAR(50) '../Sender'
					,PBBSID INT
					,BlendCode NVARCHAR(50)
					,MaterialCode NVARCHAR(50)
					,ValidFrom DATETIME
					,ValidTo DATETIME
					,Sieve1M NUMERIC(18, 6)
					,Sieve1T1 NUMERIC(18, 6)
					,Sieve1T2 NUMERIC(18, 6)
					,PDFFileName NVARCHAR(100)
					,PDFContent VARBINARY(MAX)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strBlendCode, '') + ','
			FROM @tblIPPBBS

			INSERT INTO tblIPPBBSDetailStage (
				intPBBSStageId
				,strBlendCode
				,intPBBSID
				,strSpecificationCode
				,dblMinValue
				,dblMaxValue
				,dblPinPoint
				)
			SELECT (
					SELECT TOP 1 intPBBSStageId
					FROM tblIPPBBSStage
					WHERE strBlendCode = x.BlendCode
					)
				,BlendCode
				,PBBSID
				,SpecificationCode
				,MinValue
				,MaxValue
				,PinPoint
			FROM OPENXML(@idoc, 'root/Header/Detail', 2) WITH (
					BlendCode NVARCHAR(50) COLLATE Latin1_General_CI_AS '../BlendCode'
					,PBBSID INT
					,SpecificationCode NVARCHAR(100)
					,MinValue NUMERIC(18, 6)
					,MaxValue NUMERIC(18, 6)
					,PinPoint NUMERIC(18, 6)
					) x

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
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

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

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
