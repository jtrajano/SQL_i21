﻿CREATE PROCEDURE uspIPStageERPVendor @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @tblIPEntity TABLE (strAccountNo NVARCHAR(50))
	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Vendor'

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
				,strCompanyLocation
				,intActionId
				,dtmCreated
				,strCreatedUserName
				,strStatus
				,strAccountNo
				,strName
				,strTerm
				,strEntityType
				,strCurrency
				,strDefaultLocation
				,strTaxNo
				)
			OUTPUT INSERTED.strAccountNo
			INTO @tblIPEntity
			SELECT TrxSequenceNo
				,CompanyLocation
				,ActionId
				,CreatedDate
				,CreatedByUser
				,[Status]
				,VendorAccountNumber
				,VendorName
				,TermsCode
				,EntityType
				,Currency
				,DefaultLocation
				,TaxNo
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,ActionId INT
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					,[Status] NVARCHAR(50)
					,VendorAccountNumber NVARCHAR(50)
					,VendorName NVARCHAR(100)
					,TermsCode NVARCHAR(50)
					,EntityType NVARCHAR(50)
					,Currency NVARCHAR(50)
					,DefaultLocation NVARCHAR(50)
					,TaxNo NVARCHAR(50)
					) x

			SELECT @strInfo1 = @strInfo1 + ISNULL(strAccountNo, '') + ','
			FROM @tblIPEntity

			INSERT INTO tblIPEntityTermStage (
				intStageEntityId
				,strEntityName
				,intTrxSequenceNo
				,intParentTrxSequenceNo
				,intActionId
				,intLineType
				,strLocation
				,strAddress
				,strCity
				,strState
				,strZip
				,strCountry
				,strPhone
				,strFax
				,strTerm
				)
			SELECT (
					SELECT TOP 1 intStageEntityId
					FROM tblIPEntityStage
					WHERE intTrxSequenceNo = x.parentId
					)
				,VendorName
				,TrxSequenceNo
				,parentId
				,ActionId
				,LineType
				,LocationName
				,[Address]
				,City
				,[State]
				,Zip
				,Country
				,Phone
				,Fax
				,TermsCode
			FROM OPENXML(@idoc, 'root/data/header/line', 2) WITH (
					VendorName NVARCHAR(100) COLLATE Latin1_General_CI_AS '../VendorName'
					,TrxSequenceNo INT
					,parentId INT '@parentId'
					,ActionId INT
					,LineType INT
					,LocationName NVARCHAR(200)
					,[Address] NVARCHAR(MAX)
					,City NVARCHAR(100)
					,[State] NVARCHAR(100)
					,Zip NVARCHAR(100)
					,Country NVARCHAR(100)
					,Phone NVARCHAR(100)
					,Fax NVARCHAR(100)
					,TermsCode NVARCHAR(100)
					) x

			UPDATE ET
			SET ET.intStageEntityId = E.intStageEntityId
			FROM tblIPEntityStage E
			JOIN tblIPEntityTermStage ET ON ET.intParentTrxSequenceNo = E.intTrxSequenceNo

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,5
				,1
				,'Success'
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					)

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

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT TrxSequenceNo
				,CompanyLocation
				,CreatedDate
				,CreatedByUser
				,5
				,0
				,@ErrMsg
			FROM OPENXML(@idoc, 'root/data/header', 2) WITH (
					TrxSequenceNo INT
					,CompanyLocation NVARCHAR(6)
					,CreatedDate DATETIME
					,CreatedByUser NVARCHAR(50)
					)
			
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
