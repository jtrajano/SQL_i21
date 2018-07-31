CREATE PROCEDURE uspIPStageSAPVendors_HE @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@dtmCreatedDate DATETIME
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblVendor TABLE (
		strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strAddress NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strState NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCountry NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strZipCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmCreated DATETIME NULL DEFAULT((getdate()))
		,strMarkForDeletion NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		)
	DECLARE @tblVendorContact TABLE (
		strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strLastName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Vendor'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@dtmCreatedDate = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			DELETE
			FROM @tblVendor

			DELETE
			FROM @tblVendorContact

			SELECT @strXml = strXml
				,@dtmCreatedDate = dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			INSERT INTO @tblVendor (
				strName
				,strAddress
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strAccountNo
				,dtmCreated
				,strMarkForDeletion
				,strTerm
				,strCurrency
				)
			SELECT NAME1
				,STRAS
				,ORT01
				,REGIO
				,LAND1
				,PSTLZ
				,LIFNR
				,@dtmCreatedDate
				,LOEVM
				,ZTERM
				,WAERS
			FROM OPENXML(@idoc, 'CREMAS/IDOC/E1LFA1M', 2) WITH (
					NAME1 NVARCHAR(100)
					,STRAS NVARCHAR(MAX)
					,ORT01 NVARCHAR(MAX)
					,REGIO NVARCHAR(MAX)
					,LAND1 NVARCHAR(MAX)
					,PSTLZ NVARCHAR(MAX)
					,LIFNR NVARCHAR(50)
					,LOEVM NVARCHAR(50)
					,ZTERM NVARCHAR(100) 'E1LFM1M/ZTERM'
					,WAERS NVARCHAR(50) 'E1LFM1M/WAERS'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strAccountNo, '') + ','
			FROM @tblVendor

			IF NOT EXISTS (
					SELECT 1
					FROM @tblVendor
					)
				RAISERROR (
						'Xml tag (CREMAS/IDOC/E1LFA1M) not found.'
						,16
						,1
						)

			INSERT INTO @tblVendorContact (
				strAccountNo
				,strLastName
				)
			SELECT LIFNR
				,NAME1
			FROM OPENXML(@idoc, 'CREMAS/IDOC/E1LFA1M', 2) WITH (
					LIFNR NVARCHAR(50)
					,NAME1 NVARCHAR(100)
					) x
			WHERE ISNULL(x.NAME1, '') <> ''

			-- Vendor Name data manipulation
			UPDATE @tblVendor
			SET strName = strAccountNo + ' - ' + strName

			--Add to Staging tables
			INSERT INTO tblIPEntityStage (
				strName
				,strAddress
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strAccountNo
				,dtmCreated
				,strEntityType
				,strCurrency
				,strTerm
				,ysnDeleted
				)
			SELECT strName
				,strAddress
				,strCity
				,strState
				,strCountry
				,strZipCode
				,strAccountNo
				,dtmCreated
				,'Vendor'
				,strCurrency
				,strTerm
				,CASE 
					WHEN ISNULL(strMarkForDeletion, '') = 'X'
						THEN 1
					ELSE 0
					END
			FROM @tblVendor

			INSERT INTO tblIPEntityContactStage (
				intStageEntityId
				,strEntityName
				,strLastName
				)
			SELECT MAX(s.intStageEntityId)
				,vc.strAccountNo
				,vc.strLastName
			FROM @tblVendorContact vc
			JOIN tblIPEntityStage s ON s.strAccountNo = vc.strAccountNo
			GROUP BY vc.strAccountNo
				,vc.strLastName

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
		FROM tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'Vendor'
	END

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
