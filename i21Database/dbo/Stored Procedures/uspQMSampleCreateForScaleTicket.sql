--EXEC uspQMSampleCreateForScaleTicket 323,'Inbound Scale Sample',610,1,TableData
CREATE PROCEDURE uspQMSampleCreateForScaleTicket @intItemId INT
	,@strSampleTypeName NVARCHAR(50) -- (Inbound Scale Sample)
	,@intLotId INT
	,@intUserId INT
	,@QualityPropertyValueTable QualityPropertyValueTable READONLY
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intControlPointId INT
		,@intProductTypeId INT = 6
		,@intProductId INT
		,@intCategoryId INT
		,@intSampleTypeId INT
		,@ysnAdjustInventoryQtyBySampleQty BIT
		,@strSampleNumber NVARCHAR(30)
		,@intSampleId INT
		,@intTestResultId INT
	DECLARE @intLotStatusId INT
		,@strLotNumber NVARCHAR(50)
		,@dblRepresentingQty NUMERIC(18, 6)
		,@intRepresentingUOMId INT
		,@intCountryId INT
		,@strCountry NVARCHAR(50)
		,@intStorageLocationId INT
		,@intCompanyLocationSubLocationId INT
		,@intLocationId INT
		,@intInventoryReceiptId INT
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
	DECLARE @dtmCurrentDateTime DATETIME = GETDATE()
		,@dtmCurrentDate DATETIME = CONVERT(DATE, GETDATE())
	DECLARE @intValidDate INT

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	-- Property Count check
	IF (
			(
				SELECT COUNT(1)
				FROM @QualityPropertyValueTable
				) = 0
			)
		RETURN;

	-- Sample Type check
	IF NOT EXISTS (
			SELECT 1
			FROM tblQMSampleType
			WHERE strSampleTypeName = @strSampleTypeName
			)
		RETURN;

	SELECT @intSampleTypeId = intSampleTypeId
		,@intControlPointId = intControlPointId
		,@ysnAdjustInventoryQtyBySampleQty = ysnAdjustInventoryQtyBySampleQty
	FROM tblQMSampleType
	WHERE strSampleTypeName = @strSampleTypeName

	-- Lot check
	IF NOT EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE intLotId = @intLotId
				AND intItemId = @intItemId
			)
		RETURN;

	SELECT @intLotStatusId = L.intLotStatusId
		,@strLotNumber = L.strLotNumber
		,@dblRepresentingQty = (
			CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END
			)
		,@intRepresentingUOMId = IU.intUnitMeasureId
		,@intCountryId = I.intOriginId
		,@strCountry = CA.strDescription
		,@intStorageLocationId = L.intStorageLocationId
		,@intCompanyLocationSubLocationId = L.intSubLocationId
		,@intLocationId = L.intLocationId
	FROM tblICLot L
	JOIN tblICItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemId = I.intItemId
		AND IU.ysnStockUnit = 1
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	WHERE L.intLotId = @intLotId

	-- Quantity check
	IF (@dblRepresentingQty <= 0)
		RETURN;

	SET @intProductId = (
			SELECT P.intProductId
			FROM tblQMProduct AS P
			JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
			WHERE P.intProductTypeId = 2 -- Item
				AND P.intProductValueId = @intItemId
				AND PC.intSampleTypeId = @intSampleTypeId
				AND P.ysnActive = 1
			)

	IF @intProductId IS NULL
	BEGIN
		SET @intCategoryId = (
				SELECT intCategoryId
				FROM tblICItem
				WHERE intItemId = @intItemId
				)
		SET @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = 1 -- Item Category
					AND P.intProductValueId = @intCategoryId
					AND PC.intSampleTypeId = @intSampleTypeId
					AND P.ysnActive = 1
				)
	END

	-- Template check
	IF @intProductId IS NULL
		RETURN;

	-- New Sample
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
		RETURN;
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intShiftId = intShiftId
	FROM tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	-- Inventory Receipt No
	SELECT TOP 1 @intInventoryReceiptId = RI.intInventoryReceiptId
	FROM tblICInventoryReceiptItemLot RIL
	JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
	JOIN tblICLot L ON L.intLotId = RIL.intLotId
		AND L.strLotNumber = @strLotNumber
	ORDER BY RI.intInventoryReceiptId DESC

	INSERT INTO tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intParentSampleId
		,strSampleRefNo
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractHeaderId
		,intContractDetailId
		,intLoadContainerId
		,intLoadDetailContainerLinkId
		,intLoadId
		,intLoadDetailId
		,intCountryID
		,ysnIsContractCompleted
		,intLotStatusId
		,intStorageLocationId
		,ysnAdjustInventoryQtyBySampleQty
		,intEntityId
		,intBookId
		,intSubBookId
		,intShipperEntityId
		,strShipmentNumber
		,strLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		,dtmTestedOn
		--,intTestedById
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
		,strComment
		,intItemBundleId
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intInventoryReceiptId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleTypeId
		,@strSampleNumber
		,NULL
		,''
		,@intProductTypeId
		,@intLotId
		,3
		,@intItemId
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,@intCountryId
		,0
		,@intLotStatusId
		,@intStorageLocationId
		,@ysnAdjustInventoryQtyBySampleQty
		,NULL
		,NULL
		,NULL
		,NULL
		,''
		,@strLotNumber
		,'Auto created from scale ticket'
		,@dtmCurrentDate
		,@dtmCurrentDateTime
		--,@intUserId
		,NULL
		,NULL
		,@dblRepresentingQty
		,@intRepresentingUOMId
		,''
		,@dtmCurrentDateTime
		,@dtmCurrentDateTime
		,@dtmCurrentDateTime
		,''
		,''
		,''
		,@intCompanyLocationSubLocationId
		,@strCountry
		,''
		,NULL
		,@dtmBusinessDate
		,@intShiftId
		,@intLocationId
		,@intInventoryReceiptId
		,NULL
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime

	SELECT @intSampleId = SCOPE_IDENTITY()

	INSERT INTO tblQMSampleDetail (
		intConcurrencyId
		,intSampleId
		,intAttributeId
		,strAttributeValue
		,ysnIsMandatory
		,intListItemId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleId
		,ST.intAttributeId
		,ISNULL(A.strAttributeValue, '')
		,ST.ysnIsMandatory
		,A.intListItemId
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
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
		,intPropertyItemId
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
		,@intLotId
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
		,''
		,NULL
		,NULL
		,PPV.intProductPropertyValidityPeriodId
		,NULL
		,@intControlPointId
		,NULL
		,0
		,''
		,NULL
		,PP.strIsMandatory
		,PRT.intItemId
		,NULL
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
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
		AND PC.intControlPointId = @intControlPointId
		AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
			AND DATEPART(dy, PPV.dtmValidTo)
	ORDER BY PP.intSequenceNo

	SELECT TOP 1 @intTestResultId = TR.intTestResultId
	FROM tblQMTestResult TR
	WHERE TR.intSampleId = @intSampleId

	-- Update Properties Value, Comment, Result for the available properties
	-- Setting Bit to lower case then only in sencha client, it is recogonizing
	IF @intTestResultId <> 0
	BEGIN
		UPDATE tblQMTestResult
		SET strPropertyValue = (
				CASE P.intDataTypeId
					WHEN 4
						THEN LOWER(QPV.strPropertyValue)
					WHEN 1
						THEN dbo.fnRemoveTrailingZeroes(QPV.strPropertyValue)
					WHEN 2
						THEN dbo.fnRemoveTrailingZeroes(QPV.strPropertyValue)
					ELSE QPV.strPropertyValue
					END
				)
			,strComment = ISNULL(QPV.strComment, '')
			,dtmPropertyValueCreated = (
				CASE 
					WHEN QPV.strPropertyValue <> ''
						THEN GETDATE()
					ELSE NULL
					END
				)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
		JOIN @QualityPropertyValueTable QPV ON LOWER(QPV.strPropertyName) = LOWER(P.strPropertyName)
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(QPV.strPropertyValue, '') <> ''

		-- Setting correct date format
		UPDATE tblQMTestResult
		SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
		FROM tblQMTestResult TR
		JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			AND TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
			AND P.intDataTypeId = 12

		-- Setting result for the properties
		UPDATE tblQMTestResult
		SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
		FROM tblQMTestResult TR
		WHERE TR.intSampleId = @intSampleId
			AND ISNULL(TR.strPropertyValue, '') <> ''
	END

	IF (@intSampleId > 0)
	BEGIN
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Auto Created from Scale Ticket'

		EXEC uspSMAuditLog @keyValue = @intSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intUserId
			,@actionType = 'Created'
			,@actionIcon = 'small-new-plus'
			,@changeDescription = @StrDescription
			,@fromValue = ''
			,@toValue = @strSampleNumber
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
