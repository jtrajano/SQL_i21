CREATE PROCEDURE uspIPStageERPVendor_EK @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @tblIPEntity TABLE (strAccountNo NVARCHAR(50))
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Vendor'
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
			FROM @tblIPEntity

			INSERT INTO tblIPEntityStage (
				intTrxSequenceNo
				,dtmCreated
				,strAccountNo
				,strStatus
				,strName
				,strContactName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				)
			OUTPUT INSERTED.strAccountNo
			INTO @tblIPEntity
			SELECT DocNo
				,@dtmCurrentDate
				,VendorAccountNo
				,[Status]
				,VendorName
				,ContactName
				,DefaultTermsCode
				,EntityType
				,Currency
				,DefaultLocation
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,VendorAccountNo NVARCHAR(50)
					,[Status] NVARCHAR(50)
					,VendorName NVARCHAR(100)
					,ContactName NVARCHAR(100)
					,DefaultTermsCode NVARCHAR(50)
					,EntityType NVARCHAR(50)
					,Currency NVARCHAR(40)
					,DefaultLocation NVARCHAR(100)
					) x

			SELECT @strInfo1 = @strInfo1 + ISNULL(strAccountNo, '') + ','
			FROM @tblIPEntity

			INSERT INTO tblIPEntityTermStage (
				intStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,strLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strContactName
				,strPhone
				,strMobile
				,strEmail
				,strTerm
				)
			SELECT (
					SELECT TOP 1 intStageEntityId
					FROM tblIPEntityStage
					WHERE strAccountNo = x.VendorAccountNo
					)
				,VendorName
				,DocNo
				,LineType
				,LocationName
				,[Address]
				,City
				,[State]
				,Zip
				,Country
				,Name
				,Phone
				,Mobile
				,Email
				,TermsCode
			FROM OPENXML(@idoc, 'root/Header/Line', 2) WITH (
					VendorName NVARCHAR(100) COLLATE Latin1_General_CI_AS '../VendorName'
					,DocNo BIGINT '../../DocNo'
					,LineType NVARCHAR(50)
					,LocationName NVARCHAR(100)
					,[Address] NVARCHAR(MAX)
					,City NVARCHAR(100)
					,[State] NVARCHAR(100)
					,Zip NVARCHAR(100)
					,Country NVARCHAR(100)
					,Name NVARCHAR(100)
					,Phone NVARCHAR(100)
					,Mobile NVARCHAR(100)
					,Email NVARCHAR(100)
					,TermsCode NVARCHAR(100)
					,VendorAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS '../VendorAccountNo'
					) x

			UPDATE ET
			SET ET.strCountry = C.strCountry
			FROM tblSMCountry C
			JOIN tblIPEntityTermStage ET ON ET.strCountry = C.strISOCode
				AND ISNULL(ET.strCountry, '') <> ''

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
