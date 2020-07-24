--EXEC uspQMSampleCreateBySystem 4356,38,4886,1,1
CREATE PROCEDURE uspQMSampleCreateBySystem @intWorkOrderId INT
	,@intItemId INT
	,@intOutputLotId INT
	,@intLocationId INT
	,@intUserId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intProductId INT
	DECLARE @intCategoryId INT
	DECLARE @intControlPointId INT = 7 -- Production Computed
	DECLARE @intSampleTypeId INT
	DECLARE @intProductTypeId INT
	DECLARE @intProductValueId INT
	DECLARE @strSampleNumber NVARCHAR(30)
	DECLARE @intSampleId INT
	DECLARE @intShiftId INT
	DECLARE @dtmBusinessDate DATETIME
	DECLARE @intLotStatusId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @ysnEnableParentLot BIT
	DECLARE @dtmCurrentDateTime DATETIME = GETDATE()
	DECLARE @dtmCurrentDate DATETIME = CONVERT(DATE, GETDATE())
		,@ysnAdjustInventoryQtyBySampleQty BIT
		,@strChildLotNumber NVARCHAR(50)
		,@dblRepresentingQty NUMERIC(18, 6)
		,@intRepresentingUOMId INT
		,@intEntityId INT

	-- If no output sample created
	IF NOT EXISTS (
			SELECT 1
			FROM tblICLot
			WHERE intLotId = @intOutputLotId
			)
		RETURN;

	SET @intProductId = (
			SELECT P.intProductId
			FROM tblQMProduct AS P
			JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
			WHERE P.intProductTypeId = 2 -- Item
				AND P.intProductValueId = @intItemId
				AND PC.intControlPointId = @intControlPointId
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
					AND PC.intControlPointId = @intControlPointId
					AND P.ysnActive = 1
				)
	END

	-- If no template for output item
	IF @intProductId IS NULL
		RETURN;

	SELECT @intSampleTypeId = ST.intSampleTypeId
		,@ysnAdjustInventoryQtyBySampleQty = ST.ysnAdjustInventoryQtyBySampleQty
	FROM tblQMProductControlPoint PC
	JOIN tblQMSampleType ST ON ST.intControlPointId = PC.intControlPointId
		AND PC.intProductId = @intProductId

	-- If no sample type created
	IF @intSampleTypeId IS NULL
		RETURN;

	SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0)
	FROM tblQMCompanyPreference

	IF @ysnEnableParentLot = 1
		SET @intProductTypeId = 11 -- Parent Lot
	ELSE
		SET @intProductTypeId = 6 -- Lot

	-- Input lot latest samples
	DECLARE @InputLotSample TABLE (
		intSeqNo INT IDENTITY(1, 1)
		,intLotId INT
		,dblQuantity NUMERIC(38, 20)
		,strLotNumber NVARCHAR(50)
		,intSampleId INT
		)

	IF @intProductTypeId = 6
	BEGIN
		INSERT INTO @InputLotSample
		SELECT intLotId
			,dblQuantity
			,strLotNumber
			,intSampleId
		FROM (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY L.strLotNumber ORDER BY intSampleId DESC
					) AS intRowNo
				,WIL.intLotId
				,WIL.dblQuantity
				,L.strLotNumber
				,S.intSampleId
			FROM tblMFWorkOrderConsumedLot WIL
			JOIN tblICLot L ON L.intLotId = WIL.intLotId
			JOIN tblQMSample S ON S.strLotNumber = L.strLotNumber
				AND S.intProductTypeId = @intProductTypeId
			WHERE WIL.intWorkOrderId = @intWorkOrderId
			) t
		WHERE t.intRowNo = 1
	END
	ELSE
	BEGIN
		INSERT INTO @InputLotSample
		SELECT intLotId
			,dblQuantity
			,strLotNumber
			,intSampleId
		FROM (
			SELECT ROW_NUMBER() OVER (
					PARTITION BY L.strLotNumber ORDER BY intSampleId DESC
					) AS intRowNo
				,WIL.intLotId
				,WIL.dblQuantity
				,L.strLotNumber
				,S.intSampleId
			FROM tblMFWorkOrderConsumedLot WIL
			JOIN tblICLot L ON L.intLotId = WIL.intLotId
			JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			JOIN tblQMSample S ON S.strLotNumber = PL.strParentLotNumber
				AND S.intProductTypeId = @intProductTypeId
			WHERE WIL.intWorkOrderId = @intWorkOrderId
			) t
		WHERE t.intRowNo = 1
	END

	-- Weighted average sample result
	DECLARE @SampleCalculatedResult TABLE (
		intSeqNo INT IDENTITY(1, 1)
		,intTestId INT
		,intPropertyId INT
		,dblPropertyValue NUMERIC(38, 20)
		)

	INSERT INTO @SampleCalculatedResult
	SELECT TR.intTestId
		,TR.intPropertyId
		,CONVERT(DECIMAL(38, 4), ISNULL(SUM(S.dblQuantity * ISNULL(TR.strPropertyValue, 0)) / SUM(S.dblQuantity), 0)) AS dblPropertyValue
	FROM @InputLotSample S
	JOIN tblQMTestResult TR ON TR.intSampleId = S.intSampleId
		AND ISNUMERIC(TR.strPropertyValue) = 1
	JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
	JOIN tblQMTest T ON T.intTestId = TR.intTestId
	GROUP BY TR.intTestId
		,TR.intPropertyId

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
		RAISERROR (
				'Sample number already exists. '
				,16
				,1
				)
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDateTime, @intLocationId)

	SELECT @intShiftId = intShiftId
	FROM tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCurrentDateTime BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	IF @intProductTypeId = 6
	BEGIN
		SELECT @intLotStatusId = L.intLotStatusId
			,@strLotNumber = strLotNumber
			,@intProductValueId = L.intLotId
			,@intEntityId = O.intOwnerId
		FROM tblICLot L
		LEFT JOIN tblICItemOwner O ON O.intItemId = L.intItemId
			AND O.ysnDefault = 1
		WHERE L.intLotId = @intOutputLotId

		SELECT @dblRepresentingQty = (
			CASE 
				WHEN IU.intItemUOMId = L.intWeightUOMId
					THEN ISNULL(L.dblWeight, L.dblQty)
				ELSE L.dblQty
				END
			)
			,@intRepresentingUOMId = IU.intUnitMeasureId
		FROM tblICLot L
		JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
			AND IU.ysnStockUnit = 1
		WHERE L.intLotId = @intProductValueId
	END
	ELSE
	BEGIN
		SELECT @intLotStatusId = L.intLotStatusId
			,@strLotNumber = PL.strParentLotNumber
			,@intProductValueId = L.intParentLotId
			,@strChildLotNumber = L.strLotNumber
			,@intEntityId = O.intOwnerId
		FROM tblICLot L
		JOIN tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
		LEFT JOIN tblICItemOwner O ON O.intItemId = L.intItemId
			AND O.ysnDefault = 1
		WHERE L.intLotId = @intOutputLotId

		SELECT @dblRepresentingQty = SUM(CASE 
					WHEN IU.intItemUOMId = L.intWeightUOMId
						THEN ISNULL(L.dblWeight, L.dblQty)
					ELSE L.dblQty
					END)
			,@intRepresentingUOMId = MAX(IU.intUnitMeasureId)
		FROM tblICLot L
		JOIN tblICItemUOM IU ON IU.intItemId = L.intItemId
			AND IU.ysnStockUnit = 1
		WHERE L.intParentLotId = @intProductValueId
	END

	INSERT INTO tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,intItemId
		,intLotStatusId
		,strLotNumber
		,strChildLotNumber
		,strSampleNote
		,dtmSampleReceivedDate
		,dtmTestedOn
		--,intTestedById
		,dblRepresentingQty
		,intRepresentingUOMId
		,intEntityId
		,dtmTestingStartDate
		,dtmTestingEndDate
		,dtmSamplingEndDate
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,intWorkOrderId
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,ysnAdjustInventoryQtyBySampleQty
		)
	SELECT 1
		,@intSampleTypeId
		,@strSampleNumber
		,@intProductTypeId
		,@intProductValueId
		,1
		,@intItemId
		,@intLotStatusId
		,@strLotNumber
		,@strChildLotNumber
		,'Auto populated by the system'
		,DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmCurrentDate)
		,@dtmCurrentDateTime
		--,@intUserId
		,@dblRepresentingQty
		,@intRepresentingUOMId
		,@intEntityId
		,DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmCurrentDate)
		,DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmCurrentDate)
		,DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), @dtmCurrentDate)
		,@dtmBusinessDate
		,@intShiftId
		,@intLocationId
		,@intWorkOrderId
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
		,@ysnAdjustInventoryQtyBySampleQty

	SELECT @intSampleId = SCOPE_IDENTITY()

	INSERT INTO tblQMTestResult (
		intConcurrencyId
		,intSampleId
		,intProductId
		,intProductTypeId
		,intProductValueId
		,intTestId
		,intPropertyId
		,strPropertyValue
		,dtmCreateDate
		,strResult
		,ysnFinal
		,intSequenceNo
		,dtmValidFrom
		,dtmValidTo
		,strPropertyRangeText
		,dblMinValue
		,dblMaxValue
		,dblLowValue
		,dblHighValue
		,intUnitMeasureId
		,intProductPropertyValidityPeriodId
		,intControlPointId
		,intRepNo
		,strIsMandatory
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT DISTINCT 1
		,@intSampleId
		,@intProductId AS intProductId
		,@intProductTypeId AS intProductTypeId
		,@intProductValueId AS intProductValueId
		,PP.intTestId
		,PP.intPropertyId
		,dbo.fnRemoveTrailingZeroes(SR.dblPropertyValue) AS strPropertyValue
		,@dtmCurrentDateTime
		,CASE 
			WHEN ISNUMERIC(SR.dblPropertyValue) = 1
				THEN CASE 
						WHEN ISNUMERIC(PPV.dblMinValue) = 1
							AND ISNUMERIC(PPV.dblMaxValue) = 1
							THEN CASE 
									WHEN (PPV.dblMaxValue - PPV.dblMinValue <= 1)
										THEN CASE 
												WHEN SR.dblPropertyValue >= PPV.dblMinValue
													OR SR.dblPropertyValue <= PPV.dblMaxValue
													THEN 'Passed'
												ELSE 'Failed'
												END
									ELSE CASE 
											WHEN SR.dblPropertyValue > PPV.dblMinValue
												AND SR.dblPropertyValue < PPV.dblMaxValue
												THEN 'Passed'
											WHEN SR.dblPropertyValue < PPV.dblMinValue
												OR SR.dblPropertyValue > PPV.dblMaxValue
												THEN 'Failed'
											WHEN SR.dblPropertyValue = PPV.dblMinValue
												OR SR.dblPropertyValue = PPV.dblMaxValue
												THEN 'Marginal'
											ELSE ''
											END
									END
						ELSE ''
						END
			ELSE ''
			END AS strResult
		,0
		,PP.intSequenceNo
		,PPV.dtmValidFrom
		,PPV.dtmValidTo
		,PPV.strPropertyRangeText
		,PPV.dblMinValue
		,PPV.dblMaxValue
		,PPV.dblLowValue
		,PPV.dblHighValue
		,PPV.intUnitMeasureId
		,PPV.intProductPropertyValidityPeriodId
		,PC.intControlPointId
		,0
		,PP.strIsMandatory
		,@intUserId
		,@dtmCurrentDateTime
		,@intUserId
		,@dtmCurrentDateTime
	FROM tblQMProduct AS PRD
	JOIN tblQMProductControlPoint PC ON PC.intProductId = PRD.intProductId
	JOIN tblQMProductProperty AS PP ON PP.intProductId = PRD.intProductId
	JOIN tblQMProductPropertyValidityPeriod AS PPV ON PPV.intProductPropertyId = PP.intProductPropertyId
	LEFT JOIN @SampleCalculatedResult SR ON SR.intPropertyId = PP.intPropertyId
		AND SR.intTestId = PP.intTestId
	WHERE PRD.intProductId = @intProductId
		AND PC.intControlPointId = @intControlPointId
	ORDER BY PP.intSequenceNo

	IF (@intSampleId > 0)
	BEGIN
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Auto Populate from Work Order to Quality'

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
