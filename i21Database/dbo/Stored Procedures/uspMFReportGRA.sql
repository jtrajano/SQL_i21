CREATE PROCEDURE uspMFReportGRA @xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	DECLARE @idoc INT
		,@strErrMsg NVARCHAR(MAX)
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strContactName NVARCHAR(50)
		,@strCounty NVARCHAR(25)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
		,@strPhone NVARCHAR(50)
	DECLARE @strLotId NVARCHAR(MAX)
		,@strInventoryTransferDetailId NVARCHAR(MAX)
		,@intUserId INT
	DECLARE @strMoisture NVARCHAR(MAX)
		,@strCupScore NVARCHAR(MAX)
		,@strGradeScore NVARCHAR(MAX)
		,@strComment NVARCHAR(MAX)
		,@strSampleStatus NVARCHAR(32)
		,@strCupScoreResult NVARCHAR(50)
		,@strGradeScoreResult NVARCHAR(50)
		,@strToStorageLocation NVARCHAR(50)
		,@intInventoryTransferDetailId INT
		,@intSampleId INT
		,@strContainerNumber NVARCHAR(100)
		,@intLotId INT
		,@intParentLotId INT
	DECLARE @tblICInventoryTransferDetail TABLE (intInventoryTransferDetailId INT)
	DECLARE @tblSampleValues TABLE (
		intInventoryTransferDetailId INT
		,strComment NVARCHAR(MAX)
		,strMoisture NVARCHAR(MAX)
		,strCupScore NVARCHAR(MAX)
		,strGradeScore NVARCHAR(MAX)
		,strCupScoreResult NVARCHAR(50)
		,strGradeScoreResult NVARCHAR(50)
		)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@idoc, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @strLotId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intLotId'

	SELECT @strInventoryTransferDetailId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInventoryTransferDetailId'

	SELECT @intUserId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intUserId'

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strContactName = strContactName
		,@strCounty = strCounty
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
		,@strPhone = strPhone
	FROM tblSMCompanySetup

	IF ISNULL(@strInventoryTransferDetailId, '') <> ''
	BEGIN
		DELETE
		FROM @tblSampleValues

		DELETE
		FROM @tblICInventoryTransferDetail

		INSERT INTO @tblICInventoryTransferDetail (intInventoryTransferDetailId)
		SELECT intInventoryTransferDetailId
		FROM tblICInventoryTransferDetail
		WHERE intInventoryTransferDetailId IN (
				SELECT x.Item COLLATE DATABASE_DEFAULT
				FROM dbo.fnSplitString(@strInventoryTransferDetailId, '^') x
				)

		SELECT @intInventoryTransferDetailId = MIN(intInventoryTransferDetailId)
		FROM @tblICInventoryTransferDetail

		WHILE @intInventoryTransferDetailId IS NOT NULL
		BEGIN
			SELECT @intSampleId = NULL
				,@strContainerNumber = NULL
				,@strComment = NULL
				,@strSampleStatus = NULL
				,@strCupScoreResult = 'Cupping Required'
				,@strGradeScoreResult = 'Cupping Required'
				,@strToStorageLocation = NULL
				,@strMoisture = NULL
				,@strCupScore = NULL
				,@strGradeScore = NULL
				,@intLotId = NULL
				,@intParentLotId = NULL

			SELECT @strContainerNumber = L.strContainerNo
				,@intLotId = L.intLotId
				,@intParentLotId = L.intParentLotId
				,@strToStorageLocation = TSL.strName
			FROM tblICInventoryTransferDetail ITD
			JOIN tblICLot L ON L.intLotId = ITD.intLotId
			JOIN tblICStorageLocation TSL ON TSL.intStorageLocationId = ITD.intToStorageLocationId
			WHERE ITD.intInventoryTransferDetailId = @intInventoryTransferDetailId

			SELECT TOP 1 @intSampleId = S.intSampleId
				,@strComment = S.strComment
				,@strSampleStatus = SS.strSecondaryStatus
			FROM dbo.tblQMSample S
			JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
			WHERE S.strContainerNumber = @strContainerNumber
			ORDER BY S.intSampleId DESC

			IF ISNULL(@intSampleId, 0) = 0
			BEGIN
				SELECT TOP 1 @intSampleId = S.intSampleId
					,@strComment = S.strComment
					,@strSampleStatus = SS.strSecondaryStatus
				FROM dbo.tblQMSample S
				JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
				WHERE S.intProductTypeId = 11
					AND S.intProductValueId = @intParentLotId
				ORDER BY S.intSampleId DESC
			END

			IF ISNULL(@intSampleId, 0) > 0
			BEGIN
				SELECT @strMoisture = TR.strPropertyValue
				FROM dbo.tblQMTestResult TR
				JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND TR.intSampleId = @intSampleId
					AND P.strPropertyName = 'Moisture'

				SELECT @strCupScore = TR.strPropertyValue
				FROM dbo.tblQMTestResult TR
				JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND TR.intSampleId = @intSampleId
					AND P.strPropertyName = 'Cup Score'

				SELECT @strGradeScore = TR.strPropertyValue
				FROM dbo.tblQMTestResult TR
				JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND TR.intSampleId = @intSampleId
					AND P.strPropertyName = 'Grade Score'

				SELECT @strCupScoreResult = @strSampleStatus
					,@strGradeScoreResult = @strSampleStatus

				IF ISNULL(@strCupScore, '') = ''
					SELECT @strCupScore = NULL

				IF CAST(ISNULL(@strCupScore, 0) AS DECIMAL(18, 6)) <= 2.0
					AND ISNULL(@strToStorageLocation, '') = 'FMYARD'
				BEGIN
					SELECT @strCupScoreResult = 'Cupping Required'
				END
			END

			INSERT INTO @tblSampleValues (
				intInventoryTransferDetailId
				,strComment
				,strMoisture
				,strCupScore
				,strGradeScore
				,strCupScoreResult
				,strGradeScoreResult
				)
			SELECT @intInventoryTransferDetailId
				,@strComment
				,@strMoisture
				,@strCupScore
				,@strGradeScore
				,@strCupScoreResult
				,@strGradeScoreResult

			-- Update Printed detail in Lot Mapping table
			UPDATE tblMFLotInventory
			SET ysnPrinted = 1
				,dtmLastPrinted = GETDATE()
				,intPrintedById = @intUserId
			WHERE intLotId = @intLotId

			SELECT @intInventoryTransferDetailId = MIN(intInventoryTransferDetailId)
			FROM @tblICInventoryTransferDetail
			WHERE intInventoryTransferDetailId > @intInventoryTransferDetailId
		END

		SELECT ITD.intInventoryTransferDetailId
			,IT.strTransferNo
			,dbo.fnConvertDateToReportDateFormat(IT.dtmTransferDate, 0) dtmTransferDate
			,I.strItemNo
			,L.strLotNumber
			,PL.strParentLotNumber
			,L.strContainerNo
			,IT.strTrailerId
			,ISNULL(L.strContainerNo, '') + ' / ' + ISNULL(IT.strTrailerId, '') AS strContainerTrailer
			,ShipVia.strName AS strCarrier
			,I.strDescription
			,E.strName AS strVendor
			,L.strMarkings
			,L.strContractNo
			,CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), ITD.dblNet)) + ' ' + NUOM.strUnitMeasure AS strNetWeight
			,S.strComment
			,S.strMoisture
			,S.strCupScore
			,S.strGradeScore
			,S.strCupScoreResult
			,S.strGradeScoreResult
			,CONVERT(NVARCHAR, CONVERT(NUMERIC(38, 2), ITD.dblQuantity)) + ' ' + QUOM.strUnitMeasure AS strQuantityUOM
		FROM dbo.tblICInventoryTransferDetail ITD
		JOIN dbo.tblICInventoryTransfer IT ON IT.intInventoryTransferId = ITD.intInventoryTransferId
		JOIN @tblSampleValues S ON S.intInventoryTransferDetailId = ITD.intInventoryTransferDetailId
		JOIN dbo.tblICLot L ON L.intLotId = ITD.intLotId
		JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
		JOIN dbo.tblICItem I ON I.intItemId = L.intItemId
		JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		JOIN dbo.tblEMEntity ShipVia ON ShipVia.intEntityId = IT.intShipViaId
		LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = L.intEntityVendorId
		LEFT JOIN dbo.tblICItemUOM NetUOM ON NetUOM.intItemUOMId = ITD.intGrossNetUOMId
		LEFT JOIN dbo.tblICUnitMeasure NUOM ON NUOM.intUnitMeasureId = NetUOM.intUnitMeasureId
		LEFT JOIN dbo.tblICItemUOM QtyUOM ON QtyUOM.intItemUOMId = ITD.intItemUOMId
		LEFT JOIN dbo.tblICUnitMeasure QUOM ON QUOM.intUnitMeasureId = QtyUOM.intUnitMeasureId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = 'uspMFReportGRA - ' + ERROR_MESSAGE()

	RAISERROR (
			@strErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
