CREATE PROCEDURE uspQMSampleImport @intLoggedOnLocationId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @ImportHeader TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intSampleImportId INT
		,dtmSampleReceivedDate DATETIME
		,strSampleNumber NVARCHAR(30)
		,strItemNumber NVARCHAR(50)
		,strSampleTypeName NVARCHAR(50)
		,strVendorName NVARCHAR(100)
		,strWarehouse NVARCHAR(50)
		,strContractNumber NVARCHAR(50)
		,strContainerNumber NVARCHAR(100)
		,strMarks NVARCHAR(100)
		,strSampleNote NVARCHAR(512)
		,strHeaderComment NVARCHAR(MAX)
		,dblSequenceQuantity NUMERIC(18, 6)
		,strQuantityUOM NVARCHAR(50)
		,strSampleStatus NVARCHAR(30)
		,intCreatedUserId INT
		,dtmCreated DATETIME
		)
	DECLARE @intSampleImportId INT
		,@dtmSampleReceivedDate DATETIME
		,@strItemNumber NVARCHAR(50)
		,@strSampleTypeName NVARCHAR(50)
		,@strVendorName NVARCHAR(100)
		,@strWarehouse NVARCHAR(50)
		,@strContractNumber NVARCHAR(50)
		,@strContainerNumber NVARCHAR(100)
		,@strMarks NVARCHAR(100)
		,@strSampleNote NVARCHAR(512)
		,@strHeaderComment NVARCHAR(MAX)
		,@dblSequenceQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@strSampleStatus NVARCHAR(30)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
	DECLARE @strSampleRefNo NVARCHAR(30)
		,@intContractHeaderId INT
		,@intItemId INT
		,@intCategoryId INT
		,@intSampleTypeId INT
		,@intProductId INT
		,@intContractDetailId INT
		,@intSampleStatusId INT
		,@intEntityId INT
		,@intLocationId INT
		,@strSampleNumber NVARCHAR(30)
		,@intSampleId INT
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
		,@dtmCurrentDate DATETIME = GETDATE()
		,@intShipperEntityId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intValidDate INT
		,@intItemContractId INT
		,@intCountryID INT
		,@strCountry NVARCHAR(50)
		,@intRepresentingUOMId INT
		,@strItemNo NVARCHAR(50)
		,@strSampleImportDateTimeFormat NVARCHAR(50)
		,@intConvertYear INT
		,@intCompanyLocationSubLocationId INT
	DECLARE @FormulaProperty TABLE (
		intTestResultId INT
		,strFormula NVARCHAR(MAX)
		,strFormulaParser NVARCHAR(MAX)
		)
	DECLARE @intTestResultId INT
		,@strFormula NVARCHAR(MAX) = ''
		,@strFormulaParser NVARCHAR(MAX)
	DECLARE @strPropertyValue NVARCHAR(MAX) = ''

	SELECT @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT @strSampleImportDateTimeFormat = strSampleImportDateTimeFormat
	FROM tblQMCompanyPreference

	SELECT @intConvertYear = 101

	IF (
			@strSampleImportDateTimeFormat = 'MM DD YYYY HH:MI'
			OR @strSampleImportDateTimeFormat = 'YYYY MM DD HH:MI'
			)
		SELECT @intConvertYear = 101
	ELSE IF (
			@strSampleImportDateTimeFormat = 'DD MM YYYY HH:MI'
			OR @strSampleImportDateTimeFormat = 'YYYY DD MM HH:MI'
			)
		SELECT @intConvertYear = 103

	INSERT INTO @ImportHeader
	SELECT MIN(intSampleImportId) AS intSampleImportId
		,CONVERT(DATETIME, dtmSampleReceivedDate, @intConvertYear) dtmSampleReceivedDate
		,strSampleNumber
		,strItemNumber
		,strSampleTypeName
		,strVendorName
		,strWarehouse
		,strContractNumber
		,strContainerNumber
		,strMarks
		,strSampleNote
		,strHeaderComment
		,dblSequenceQuantity
		,strQuantityUOM
		,strSampleStatus
		,MIN(intCreatedUserId) AS intCreatedUserId
		,MIN(dtmCreated) AS dtmCreated
	FROM tblQMSampleImport
	GROUP BY CONVERT(DATETIME, dtmSampleReceivedDate, @intConvertYear)
		,strSampleNumber
		,strItemNumber
		,strSampleTypeName
		,strVendorName
		,strWarehouse
		,strContractNumber
		,strContainerNumber
		,strMarks
		,strSampleNote
		,strHeaderComment
		,dblSequenceQuantity
		,strQuantityUOM
		,strSampleStatus
	ORDER BY intSampleImportId

	SELECT @intSampleImportId = MIN(intSampleImportId)
	FROM @ImportHeader

	BEGIN TRANSACTION

	WHILE (ISNULL(@intSampleImportId, 0) > 0)
	BEGIN
		SELECT @dtmSampleReceivedDate = NULL
			,@strItemNumber = NULL
			,@strSampleTypeName = NULL
			,@strVendorName = NULL
			,@strWarehouse = NULL
			,@strContractNumber = NULL
			,@strContainerNumber = NULL
			,@strMarks = NULL
			,@strSampleNote = NULL
			,@strHeaderComment = NULL
			,@dblSequenceQuantity = NULL
			,@strQuantityUOM = NULL
			,@strSampleStatus = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@strSampleRefNo = NULL
			,@intContractHeaderId = NULL
			,@intItemId = NULL
			,@intCategoryId = NULL
			,@intSampleTypeId = NULL
			,@intProductId = NULL
			,@intContractDetailId = NULL
			,@intSampleStatusId = NULL
			,@intEntityId = NULL
			,@intLocationId = NULL
			,@strSampleNumber = NULL
			,@intSampleId = NULL
			,@intShiftId = NULL
			,@dtmBusinessDate = NULL
			,@intShipperEntityId = NULL
			,@intProductTypeId = NULL
			,@intProductValueId = NULL
			,@intItemContractId = NULL
			,@intCountryID = NULL
			,@strCountry = NULL
			,@intRepresentingUOMId = NULL
			,@strItemNo = NULL
			,@intCompanyLocationSubLocationId = NULL

		SELECT @dtmSampleReceivedDate = dtmSampleReceivedDate
			,@strSampleRefNo = strSampleNumber
			,@strItemNumber = strItemNumber
			,@strSampleTypeName = strSampleTypeName
			,@strVendorName = strVendorName
			,@strWarehouse = strWarehouse
			,@strContractNumber = strContractNumber
			,@strContainerNumber = strContainerNumber
			,@strMarks = strMarks
			,@strSampleNote = strSampleNote
			,@strHeaderComment = strHeaderComment
			,@dblSequenceQuantity = dblSequenceQuantity
			,@strQuantityUOM = strQuantityUOM
			,@strSampleStatus = strSampleStatus
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @ImportHeader
		WHERE intSampleImportId = @intSampleImportId

		SELECT @intItemId = intItemId
			,@intCategoryId = intCategoryId
			,@strItemNo = strItemNo
		FROM tblICItem
		WHERE strItemNo = @strItemNumber

		SELECT @intSampleTypeId = intSampleTypeId
		FROM tblQMSampleType
		WHERE strSampleTypeName = @strSampleTypeName

		SELECT @intSampleStatusId = intSampleStatusId
		FROM tblQMSampleStatus
		WHERE strStatus = @strSampleStatus

		IF ISNULL(@strContractNumber, '') <> ''
		BEGIN
			SELECT @intContractHeaderId = CH.intContractHeaderId
				,@intEntityId = CH.intEntityId
			FROM tblCTContractHeader CH
			WHERE CH.strContractNumber = @strContractNumber
		END

		IF ISNULL(@strWarehouse, '') <> ''
		BEGIN
			SELECT @intCompanyLocationSubLocationId = intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strWarehouse
		END

		-- Template
		IF (
				ISNULL(@intItemId, 0) > 0
				AND ISNULL(@intSampleTypeId, 0) > 0
				)
		BEGIN
			SELECT @intProductId = (
					SELECT P.intProductId
					FROM tblQMProduct AS P
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
					WHERE P.intProductTypeId = 2 -- Item
						AND P.intProductValueId = @intItemId
						AND PC.intSampleTypeId = @intSampleTypeId
						AND P.ysnActive = 1
					)

			IF (
					@intProductId IS NULL
					AND ISNULL(@intCategoryId, 0) > 0
					)
				SELECT @intProductId = (
						SELECT P.intProductId
						FROM tblQMProduct AS P
						JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
						WHERE P.intProductTypeId = 1 -- Item Category
							AND P.intProductValueId = @intCategoryId
							AND PC.intSampleTypeId = @intSampleTypeId
							AND P.ysnActive = 1
						)
		END

		-- Retrieving Contract Sequence
		IF ISNULL(@intContractHeaderId, 0) > 0
		BEGIN
			DECLARE @intCRowNo INT
				,@intCContractDetailId INT
				,@intCSampleTypeId INT
				,@intCSampleStatusId INT
			DECLARE @ContractDetail TABLE (
				intRowNo INT IDENTITY(1, 1)
				,intContractDetailId INT
				,dblQuantity NUMERIC(18, 6)
				)

			DELETE
			FROM @ContractDetail

			INSERT INTO @ContractDetail
			SELECT intContractDetailId
				,dblQuantity
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
			ORDER BY intContractSeq

			SELECT @intCRowNo = MIN(intRowNo)
			FROM @ContractDetail

			WHILE (ISNULL(@intCRowNo, 0) > 0)
			BEGIN
				SELECT @intCContractDetailId = NULL
					,@intCSampleTypeId = NULL
					,@intCSampleStatusId = NULL

				SELECT @intCContractDetailId = intContractDetailId
				FROM @ContractDetail
				WHERE intRowNo = @intCRowNo

				SELECT TOP 1 @intCSampleTypeId = S.intSampleTypeId
					,@intCSampleStatusId = S.intSampleStatusId
				FROM tblQMSample S
				JOIN tblQMSampleImportSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
				WHERE S.intContractDetailId = @intCContractDetailId
					AND S.intSampleStatusId = 3 -- Approved
				ORDER BY S.intSampleId DESC

				-- Sequence existing sample
				IF ISNULL(@intCSampleTypeId, 0) > 0
				BEGIN
					SELECT @intContractDetailId = NULL
				END
				ELSE
				BEGIN
					SELECT @intContractDetailId = @intCContractDetailId

					BREAK
				END

				SELECT @intCRowNo = MIN(intRowNo)
				FROM @ContractDetail
				WHERE intRowNo > @intCRowNo
			END
		END

		IF ISNULL(@intContractHeaderId, 0) > 0
		BEGIN
			IF ISNULL(@intContractDetailId, 0) = 0
			BEGIN
				SET @ErrMsg = 'Sample No(' + @strSampleRefNo + ') - Contract already contains Sample. '

				RAISERROR (
						@ErrMsg
						,16
						,1
						)
			END
			ELSE
			BEGIN
				DECLARE @dblCQuantity NUMERIC(18, 6)
				DECLARE @intSeqItemId INT
				DECLARE @strCItemNo NVARCHAR(50)

				SELECT @dblCQuantity = NULL
					,@intSeqItemId = NULL
					,@strCItemNo = NULL

				SELECT @dblCQuantity = CD.dblQuantity
					,@intSeqItemId = CD.intItemId
					,@strCItemNo = I.strItemNo
				FROM tblCTContractDetail CD
				JOIN tblICItem I ON I.intItemId = CD.intItemId
				WHERE CD.intContractDetailId = @intContractDetailId

				IF @intItemId <> @intSeqItemId
				BEGIN
					SET @ErrMsg = 'Sample No(' + @strSampleRefNo + ') - Item is not matching with Contract Sequence Item(' + @strCItemNo + '). '

					RAISERROR (
							@ErrMsg
							,16
							,1
							)
				END

				IF ISNUMERIC(@dblSequenceQuantity) = 1
				BEGIN
					IF @dblSequenceQuantity > @dblCQuantity
					BEGIN
						SET @ErrMsg = 'Sample No(' + @strSampleRefNo + ') - Quantity cannot be greater than Contract Sequence Quantity(' + LTRIM(@dblCQuantity) + '). '

						RAISERROR (
								@ErrMsg
								,16
								,1
								)
					END
				END
			END
		END

		-- Contract details
		IF ISNULL(@intContractDetailId, 0) > 0
		BEGIN
			IF ISNULL(@dblSequenceQuantity, 0) <= 0
			BEGIN
				SELECT @dblSequenceQuantity = CD.dblQuantity
				FROM tblCTContractDetail CD
				WHERE CD.intContractDetailId = @intContractDetailId
			END

			SELECT @intProductTypeId = 8 -- Contract Line Item
				,@intProductValueId = CD.intContractDetailId
				,@intItemContractId = CD.intItemContractId
				,@intCountryID = ISNULL(IM.intOriginId, IC.intCountryId)
				,@strCountry = ISNULL(CA.strDescription, CG.strCountry)
				,@intLocationId = CD.intCompanyLocationId
				,@intRepresentingUOMId = CD.intUnitMeasureId
			FROM tblCTContractDetail CD
			JOIN tblICItem IM ON IM.intItemId = CD.intItemId
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
			LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
			LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
			WHERE CD.intContractDetailId = @intContractDetailId
		END
		ELSE
		BEGIN
			SELECT @intProductTypeId = 2 -- Item
				,@intProductValueId = IM.intItemId
				,@intLocationId = @intLoggedOnLocationId
				,@intContractHeaderId = NULL
				,@intContractDetailId = NULL
				,@intItemContractId = NULL
				,@intCountryID = IM.intOriginId
				,@strCountry = CA.strDescription
			FROM tblICItem IM
			LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
			WHERE IM.intItemId = @intItemId

			SELECT @intEntityId = intEntityId
			FROM vyuCTEntity
			WHERE strEntityName = @strVendorName
				AND (
					strEntityType = 'Vendor'
					OR strEntityType = 'Customer'
					)

			IF ISNULL(@strQuantityUOM, '') = ''
			BEGIN
				-- Take the template UOM. If not avail, take stock UOM
				SELECT @intRepresentingUOMId = P.intUnitMeasureId
				FROM tblQMProduct P
				WHERE P.intProductId = @intProductId

				IF ISNULL(@intRepresentingUOMId, 0) = 0
				BEGIN
					SELECT @intRepresentingUOMId = IU.intUnitMeasureId
					FROM tblICItemUOM IU
					WHERE IU.intItemId = @intItemId
						AND IU.ysnStockUnit = 1
				END
			END
			ELSE
			BEGIN
				SELECT @intRepresentingUOMId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strQuantityUOM
			END
		END

		-- Business Date and Shift Id
		SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

		SELECT @intShiftId = intShiftId
		FROM tblMFShift
		WHERE intLocationId = @intLocationId
			AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
				AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

		-- Shipper Entity Id
		IF ISNULL(@strMarks, '') <> ''
		BEGIN
			DECLARE @strShipperCode NVARCHAR(MAX)
			DECLARE @intFirstIndex INT
			DECLARE @intSecondIndex INT

			SELECT @strShipperCode = NULL
				,@intFirstIndex = NULL
				,@intSecondIndex = NULL

			SELECT @intFirstIndex = ISNULL(CHARINDEX('/', @strMarks), 0)

			SELECT @intSecondIndex = ISNULL(CHARINDEX('/', @strMarks, @intFirstIndex + 1), 0)

			IF (
					@intFirstIndex > 0
					AND @intSecondIndex > 0
					)
			BEGIN
				SELECT @strShipperCode = SUBSTRING(@strMarks, @intFirstIndex + 1, (@intSecondIndex - @intFirstIndex - 1))

				SELECT TOP 1 @intShipperEntityId = intEntityId
				FROM tblEMEntity
				WHERE strEntityNo = @strShipperCode
			END
			ELSE
			BEGIN
				SELECT @intShipperEntityId = NULL
			END
		END

		--New Sample Creation
		EXEC uspMFGeneratePatternId @intCategoryId = NULL
			,@intItemId = NULL
			,@intManufacturingId = NULL
			,@intSubLocationId = NULL
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 62
			,@ysnProposed = 0
			,@strPatternString = @strSampleNumber OUTPUT

		IF EXISTS (
				SELECT 1
				FROM tblQMSample
				WHERE strSampleNumber = @strSampleNumber
				)
		BEGIN
			RAISERROR (
					'Sample number already exists. '
					,16
					,1
					)
		END

		INSERT INTO tblQMSample (
			intConcurrencyId
			,intSampleTypeId
			,strSampleNumber
			,strSampleRefNo
			,intProductTypeId
			,intProductValueId
			,intSampleStatusId
			,intItemId
			,intItemContractId
			,intContractHeaderId
			,intContractDetailId
			,intShipmentBLContainerId
			,intShipmentBLContainerContractId
			,intShipmentId
			,intShipmentContractQtyId
			,intCountryID
			,ysnIsContractCompleted
			,intLotStatusId
			,intEntityId
			,intShipperEntityId
			,strShipmentNumber
			,strLotNumber
			,strSampleNote
			,dtmSampleReceivedDate
			,dtmTestedOn
			,intTestedById
			,dblSampleQty
			,intSampleUOMId
			,dblRepresentingQty
			,intRepresentingUOMId
			,strRefNo
			,dtmTestingStartDate
			,dtmTestingEndDate
			,dtmSamplingEndDate
			,strSamplingMethod
			,strContainerNumber
			,strMarks
			,intCompanyLocationSubLocationId
			,strCountry
			,intItemBundleId
			,intLoadContainerId
			,intLoadDetailContainerLinkId
			,intLoadId
			,intLoadDetailId
			,dtmBusinessDate
			,intShiftId
			,intLocationId
			,intInventoryReceiptId
			,intWorkOrderId
			,strComment
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT 1
			,@intSampleTypeId
			,@strSampleNumber
			,@strSampleRefNo
			,@intProductTypeId
			,@intProductValueId
			,@intSampleStatusId
			,@intItemId
			,@intItemContractId
			,@intContractHeaderId
			,@intContractDetailId
			,NULL
			,NULL
			,NULL
			,NULL
			,@intCountryID
			,0
			,NULL
			,@intEntityId
			,@intShipperEntityId
			,NULL
			,NULL
			,@strSampleNote
			,@dtmSampleReceivedDate
			,@dtmCurrentDate
			,@intCreatedUserId
			,NULL
			,NULL
			,@dblSequenceQuantity
			,@intRepresentingUOMId
			,NULL
			,@dtmSampleReceivedDate
			,@dtmSampleReceivedDate
			,@dtmSampleReceivedDate
			,NULL
			,@strContainerNumber
			,@strMarks
			,@intCompanyLocationSubLocationId
			,@strCountry
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,@dtmBusinessDate
			,@intShiftId
			,@intLocationId
			,NULL
			,NULL
			,@strHeaderComment
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate

		SELECT @intSampleId = SCOPE_IDENTITY()

		INSERT INTO tblQMSampleDetail (
			intConcurrencyId
			,intSampleId
			,intAttributeId
			,strAttributeValue
			,intListItemId
			,ysnIsMandatory
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT 1
			,@intSampleId
			,A.intAttributeId
			,ISNULL(A.strAttributeValue, '') AS strAttributeValue
			,A.intListItemId
			,ST.ysnIsMandatory
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate
		FROM tblQMSampleTypeDetail ST
		JOIN tblQMAttribute A ON A.intAttributeId = ST.intAttributeId
		WHERE ST.intSampleTypeId = @intSampleTypeId

		INSERT INTO tblQMTestResult (
			intConcurrencyId
			,intSampleId
			,intProductId
			,intProductTypeId
			,intProductValueId
			,intTestId
			,intPropertyId
			,strPanelList
			,strPropertyValue
			,dtmCreateDate
			,strResult
			,ysnFinal
			,strComment
			,intSequenceNo
			,dtmValidFrom
			,dtmValidTo
			,strPropertyRangeText
			,dblMinValue
			,dblMaxValue
			,dblLowValue
			,dblHighValue
			,intUnitMeasureId
			,strFormulaParser
			,dblCrdrPrice
			,dblCrdrQty
			,intProductPropertyValidityPeriodId
			,intPropertyValidityPeriodId
			,intControlPointId
			,intParentPropertyId
			,intRepNo
			,strFormula
			,intListItemId
			,strIsMandatory
			,dtmPropertyValueCreated
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			)
		SELECT DISTINCT 1
			,@intSampleId
			,@intProductId
			,@intProductTypeId
			,@intProductValueId
			,PP.intTestId
			,PP.intPropertyId
			,''
			,''
			,@dtmCurrentDate
			,''
			,0
			,''
			,PP.intSequenceNo
			,PPV.dtmValidFrom
			,PPV.dtmValidTo
			,PPV.strPropertyRangeText
			,PPV.dblMinValue
			,PPV.dblMaxValue
			,PPV.dblLowValue
			,PPV.dblHighValue
			,PPV.intUnitMeasureId
			,PP.strFormulaParser
			,NULL
			,NULL
			,PPV.intProductPropertyValidityPeriodId
			,NULL
			,PC.intControlPointId
			,NULL
			,0
			,PP.strFormulaField
			,NULL
			,PP.strIsMandatory
			,NULL
			,@intCreatedUserId
			,@dtmCurrentDate
			,@intCreatedUserId
			,@dtmCurrentDate
		FROM tblQMProduct AS PRD
		JOIN tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
		JOIN tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
		JOIN tblQMProductTest AS PT ON PT.intProductId = PP.intProductId
			AND PT.intProductId = PRD.intProductId
		JOIN tblQMTest AS T ON T.intTestId = PP.intTestId
			AND T.intTestId = PT.intTestId
		JOIN tblQMTestProperty AS TP ON TP.intPropertyId = PP.intPropertyId
			AND TP.intTestId = PP.intTestId
			AND TP.intTestId = T.intTestId
			AND TP.intTestId = PT.intTestId
		JOIN tblQMProperty AS PRT ON PRT.intPropertyId = PP.intPropertyId
			AND PRT.intPropertyId = TP.intPropertyId
		JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
		WHERE PRD.intProductId = @intProductId
			AND PC.intSampleTypeId = @intSampleTypeId
			AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
				AND DATEPART(dy, PPV.dtmValidTo)
		ORDER BY PP.intSequenceNo

		-- Update Properties Value, Comment, Result for the available properties
		-- Setting Bit to lower case then only in sencha client, it is recogonizing
		UPDATE tblQMTestResult
		SET strPropertyValue = (
				CASE P.intDataTypeId
					WHEN 4
						THEN LOWER(SI.strPropertyValue)
					ELSE (
							CASE 
								WHEN ISNULL(TR.strFormula, '') <> ''
									THEN ''
								ELSE SI.strPropertyValue
								END
							)
					END
				)
			,strComment = SI.strComment
			,strResult = (
				CASE 
					WHEN ISNULL(TR.strFormula, '') <> ''
						THEN ''
					ELSE SI.strResult
					END
				)
			,dtmPropertyValueCreated = (
				CASE 
					WHEN SI.strPropertyValue <> ''
						THEN GETDATE()
					ELSE NULL
					END
				)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
		JOIN tblQMSampleImport SI ON SI.strPropertyName = P.strPropertyName
			AND SI.strSampleNumber = @strSampleRefNo

		-- Calculate and update formula property value
		DELETE
		FROM @FormulaProperty

		INSERT INTO @FormulaProperty
		SELECT intTestResultId
			,strFormula
			,strFormulaParser
		FROM tblQMTestResult
		WHERE intSampleId = @intSampleId
			AND ISNULL(strFormula, '') <> ''
			AND ISNULL(strFormulaParser, '') <> ''
		ORDER BY intTestResultId

		SELECT @intTestResultId = MIN(intTestResultId)
		FROM @FormulaProperty

		WHILE (ISNULL(@intTestResultId, 0) > 0)
		BEGIN
			SELECT @strFormula = NULL
				,@strFormulaParser = NULL
				,@strPropertyValue = ''

			SELECT @strFormula = strFormula
				,@strFormulaParser = strFormulaParser
			FROM @FormulaProperty
			WHERE intTestResultId = @intTestResultId

			SELECT @strFormula = REPLACE(REPLACE(REPLACE(@strFormula, @strFormulaParser, ''), '{', ''), '}', '')

			IF @strFormulaParser = 'MAX'
			BEGIN
				SELECT @strPropertyValue = MAX(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'MIN'
			BEGIN
				SELECT @strPropertyValue = MIN(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'AVG'
			BEGIN
				SELECT @strPropertyValue = AVG(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END
			ELSE IF @strFormulaParser = 'SUM'
			BEGIN
				SELECT @strPropertyValue = SUM(CONVERT(NUMERIC(18, 6), strPropertyValue))
				FROM tblQMTestResult
				WHERE intSampleId = @intSampleId
					AND ISNULL(strPropertyValue, '') <> ''
					AND intPropertyId IN (
						SELECT intPropertyId
						FROM tblQMProperty
						WHERE strPropertyName IN (
								SELECT Item COLLATE Latin1_General_CI_AS
								FROM dbo.fnSplitStringWithTrim(@strFormula, ',')
								)
						)
			END

			IF @strPropertyValue <> ''
			BEGIN
				UPDATE tblQMTestResult
				SET strPropertyValue = dbo.fnRemoveTrailingZeroes(@strPropertyValue)
				WHERE intTestResultId = @intTestResultId
			END

			SELECT @intTestResultId = MIN(intTestResultId)
			FROM @FormulaProperty
			WHERE intTestResultId > @intTestResultId
		END

		-- Setting result for formula properties and the result which is not sent in excel
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(TR.strResult, '') = ''

		-- Setting correct date format
		UPDATE tblQMTestResult
		SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
			AND P.intDataTypeId = 12

		SELECT @intSampleImportId = MIN(intSampleImportId)
		FROM @ImportHeader
		WHERE intSampleImportId > @intSampleImportId
	END

	DELETE
	FROM tblQMSampleImport

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
