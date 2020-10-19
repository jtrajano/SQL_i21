﻿CREATE PROCEDURE uspIPStageSAPShippingInstruction @strInfo1 NVARCHAR(MAX) = '' OUTPUT
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
		,@strFileName NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblLoad TABLE (
		strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strERPPONumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strOriginPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strDestinationPort NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmETAPOD DATETIME
		,dtmETAPOL DATETIME
		,dtmETSPOL DATETIME
		,dtmDeadlineCargo DATETIME
		,strBookingReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strServiceContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strBLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strShippingLine NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strMVessel NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strMVoyageNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strShippingMode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intNumberOfContainers INT
		,strContainerType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strPartyAlias NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPartyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPartyType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblLoadDetail TABLE (
		strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strContractItemName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(18, 6)
		,dblGrossWeight NUMERIC(18, 6)
		,strPackageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblLoadNotifyParties TABLE (
		strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPartyType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strPartyName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strPartyLocation NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblLoadDocuments TABLE (
		strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strTypeCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intOriginal INT
		,intCopies INT
		)
	DECLARE @intStageLoadId INT

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM tblIPIDOCXMLStage WITH (NOLOCK)
	WHERE strType = 'ShippingInstruction'

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@strFileName = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
				,@strFileName = strFileName
			FROM tblIPIDOCXMLStage WITH (NOLOCK)
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblLoad

			DELETE
			FROM @tblLoadDetail

			DELETE
			FROM @tblLoadNotifyParties

			DELETE
			FROM @tblLoadDocuments

			INSERT INTO @tblLoad (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strTransactionType
				)
			SELECT CargooReference
				,OrderReference
				,Pol
				,Pod
				,CASE 
					WHEN ISDATE(Ata) = 0
						OR Ata = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CONVERT(DATETIME, CONVERT(NVARCHAR, CONVERT(DATETIME, Ata), 101))
					END
				,CASE 
					WHEN ISDATE(Atd) = 0
						OR Atd = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CONVERT(DATETIME, CONVERT(NVARCHAR, CONVERT(DATETIME, Atd), 101))
					END
				,CASE 
					WHEN ISDATE(Etd) = 0
						OR Etd = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CONVERT(DATETIME, CONVERT(NVARCHAR, CONVERT(DATETIME, Etd), 101))
					END
				,CASE 
					WHEN ISDATE(Eta) = 0
						OR Eta = '1900-01-01 00:00:00.000'
						THEN NULL
					ELSE CONVERT(DATETIME, CONVERT(NVARCHAR, CONVERT(DATETIME, Eta), 101))
					END
				,BookingNumber
				,ContractReference
				,BLNumber
				,CarrierCode
				,Vessel
				,Voyage
				,LoadingType
				,CASE 
					WHEN ISNUMERIC([Count]) = 0
						THEN NULL
					ELSE [Count]
					END
				,[Type]
				,Alias
				,Name
				,[PartyType]
				,'ShippingInstruction'
			FROM OPENXML(@idoc, 'Shipment', 2) WITH (
					CargooReference NVARCHAR(100)
					,OrderReference NVARCHAR(100)
					,Pol NVARCHAR(200)
					,Pod NVARCHAR(200)
					,Ata NVARCHAR(50)
					,Atd NVARCHAR(50)
					,Etd NVARCHAR(50)
					,Eta NVARCHAR(50)
					,BookingNumber NVARCHAR(100)
					,ContractReference NVARCHAR(100)
					,BLNumber NVARCHAR(100)
					,CarrierCode NVARCHAR(100)
					,Vessel NVARCHAR(200)
					,Voyage NVARCHAR(100)
					,LoadingType NVARCHAR(100)
					,[Count] INT 'PlannedContainers/PlannedContainer/Count'
					,[Type] NVARCHAR(50) 'PlannedContainers/PlannedContainer/Type'
					,Alias NVARCHAR(100) 'Party/Alias'
					,Name NVARCHAR(100) 'Party/Name'
					,[PartyType] NVARCHAR(50) 'Party/Type'
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strCustomerReference, '') + ','
			FROM @tblLoad

			SELECT @strInfo2 = @strInfo2 + ISNULL(strERPPONumber, '') + ','
			FROM @tblLoad

			INSERT INTO @tblLoadDetail (
				strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
				)
			SELECT CargooReference
				,CommodityCode
				,ArticleCode
				,ArticleDescription
				,CASE 
					WHEN ISNUMERIC(Packages) = 0
						THEN NULL
					ELSE Packages
					END
				,CASE 
					WHEN ISNUMERIC(GrossWeight) = 0
						THEN NULL
					ELSE GrossWeight
					END
				,PackageType
			FROM OPENXML(@idoc, 'Shipment/CommodityItems/CommodityItem', 2) WITH (
					CargooReference NVARCHAR(100) COLLATE Latin1_General_CI_AS '../../CargooReference'
					,CommodityCode NVARCHAR(50)
					,ArticleCode NVARCHAR(50)
					,ArticleDescription NVARCHAR(100)
					,Packages NVARCHAR(50)
					,GrossWeight NVARCHAR(50)
					,PackageType NVARCHAR(50)
					) x
			WHERE ISNULL(x.CommodityCode, '') <> ''

			INSERT INTO @tblLoadNotifyParties (
				strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
				)
			SELECT CargooReference
				,[Type]
				,[Name]
				,[Location]
			FROM OPENXML(@idoc, 'Shipment/Parties/Party', 2) WITH (
					CargooReference NVARCHAR(100) COLLATE Latin1_General_CI_AS '../../CargooReference'
					,[Type] NVARCHAR(50)
					,[Name] NVARCHAR(100)
					,[Location] NVARCHAR(100)
					) x
			WHERE ISNULL(x.[Type], '') <> ''

			INSERT INTO @tblLoadDocuments (
				strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
				)
			SELECT CargooReference
				,TypeCode
				,[Name]
				,CASE 
					WHEN ISNUMERIC(Original) = 0
						THEN 0
					ELSE Original
					END
				,CASE 
					WHEN ISNUMERIC(Copies) = 0
						THEN 0
					ELSE Copies
					END
			FROM OPENXML(@idoc, 'Shipment/Documents/Document', 2) WITH (
					CargooReference NVARCHAR(100) COLLATE Latin1_General_CI_AS '../../CargooReference'
					,TypeCode NVARCHAR(50)
					,[Name] NVARCHAR(50)
					,Original INT
					,Copies INT
					) x
			WHERE ISNULL(x.[Name], '') <> ''

			--Add to Staging tables
			INSERT INTO tblIPLoadStage (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strFileName
				,strTransactionType
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmETSPOL
				,dtmDeadlineCargo
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,@strFileName
				,strTransactionType
			FROM @tblLoad

			SELECT @intStageLoadId = SCOPE_IDENTITY()

			INSERT INTO tblIPLoadDetailStage (
				intStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
				)
			SELECT @intStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
			FROM @tblLoadDetail

			INSERT INTO tblIPLoadNotifyPartiesStage (
				intStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
				)
			SELECT @intStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
			FROM @tblLoadNotifyParties

			INSERT INTO tblIPLoadDocumentsStage (
				intStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
				)
			SELECT @intStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
			FROM @tblLoadDocuments

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,strFileName
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
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
				,strFileName
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,strFileName
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM tblIPIDOCXMLStage WITH (NOLOCK)
		WHERE intIDOCXMLStageId > @intRowNo
			AND strType = 'ShippingInstruction'
	END

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF (ISNULL(@strInfo2, '')) <> ''
		SELECT @strInfo2 = LEFT(@strInfo2, LEN(@strInfo2) - 1)

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
