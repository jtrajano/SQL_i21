﻿CREATE PROCEDURE uspQMSamplePreShipment @strXml NVARCHAR(MAX)
	,@strSampleNumber NVARCHAR(30) OUTPUT
	,@intSampleId INT OUTPUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @intContractDetailId INT
		,@dblSampleQty NUMERIC(18, 6)
		,@strSampleUOM NVARCHAR(50)
		,@strRefNo NVARCHAR(100)
		,@strSampleStatus NVARCHAR(30)
		,@dtmSampleReceivedDate DATETIME
		,@strSampleNote NVARCHAR(512)
		,@intSampleUOMId INT
		,@intSampleStatusId INT
	DECLARE @intControlPointId INT = 5 -- Inbound Sample
		,@intProductId INT
		,@intCategoryId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intSampleTypeId INT
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
		,@dtmCreated DATETIME = GETDATE()
		,@intUserId INT
		,@intValidDate INT
	DECLARE @intItemId INT
		,@intItemContractId INT
		,@intCountryID INT
		,@intEntityId INT
		,@dblRepresentingQty NUMERIC(18, 6)
		,@intRepresentingUOMId INT
		,@strCountry NVARCHAR(50)
		,@intLocationId INT

	SET @intValidDate = (
			SELECT DATEPART(dy, GETDATE())
			)

	SELECT @strSampleNumber = strSampleNumber
		,@intContractDetailId = intContractDetailId
		,@dblSampleQty = dblSampleQty
		,@strSampleUOM = strSampleUOM
		,@strRefNo = strRefNo
		,@strSampleStatus = strSampleStatus
		,@dtmSampleReceivedDate = dtmSampleReceivedDate
		,@strSampleNote = strSampleNote --Inspection Lot No
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strSampleNumber NVARCHAR(30)
			,intContractDetailId INT
			,dblSampleQty NUMERIC(18, 6)
			,strSampleUOM NVARCHAR(50)
			,strRefNo NVARCHAR(100)
			,strSampleStatus NVARCHAR(30)
			,dtmSampleReceivedDate DATETIME
			,strSampleNote NVARCHAR(512)
			)

	IF ISNULL(@strSampleStatus, '') = ''
		RAISERROR (
				'Sample Status cannot be empty. '
				,16
				,1
				)

	SELECT @intSampleStatusId = intSampleStatusId
	FROM tblQMSampleStatus
	WHERE strStatus = @strSampleStatus

	IF @intSampleStatusId IS NULL
		RAISERROR (
				'Sample Status is not available. '
				,16
				,1
				)

	IF ISNULL(@strSampleUOM, '') = ''
		RAISERROR (
				'Sample UOM cannot be empty. '
				,16
				,1
				)

	SELECT @intSampleUOMId = intUnitMeasureId
	FROM tblICUnitMeasure
	WHERE strUnitMeasure = @strSampleUOM

	IF @intSampleUOMId IS NULL
		RAISERROR (
				'Sample UOM is not available. '
				,16
				,1
				)

	IF @dblSampleQty IS NULL
		RAISERROR (
				'Sample Qty cannot be empty. '
				,16
				,1
				)

	IF NOT EXISTS (
			SELECT 1
			FROM tblCTContractDetail
			WHERE intContractDetailId = @intContractDetailId
			)
		RAISERROR (
				'Contract Sequence is not available. '
				,16
				,1
				)

	SELECT @intProductTypeId = 8
		,@intProductValueId = CD.intContractDetailId
		,@intItemId = CD.intItemId
		,@intItemContractId = CD.intItemContractId
		,@intCountryID = ISNULL(IM.intOriginId, IC.intCountryId) --intCountryId
		,@intEntityId = CH.intEntityId
		,@dblRepresentingQty = CD.dblQuantity
		,@intRepresentingUOMId = CD.intUnitMeasureId
		,@strCountry = ISNULL(CA.strDescription, CG.strCountry) --strCountry
		,@intLocationId = CD.intCompanyLocationId
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
	LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
	LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
	WHERE CD.intContractDetailId = @intContractDetailId

	-- Temporary taking first user 
	SELECT TOP 1 @intUserId = intEntityId
	FROM tblEMEntity

	SELECT @intProductId = (
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
		SELECT @intCategoryId = (
				SELECT intCategoryId
				FROM tblICItem
				WHERE intItemId = @intItemId
				)

		SELECT @intProductId = (
				SELECT P.intProductId
				FROM tblQMProduct AS P
				JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
				WHERE P.intProductTypeId = 1 -- Item Category
					AND P.intProductValueId = @intCategoryId
					AND PC.intControlPointId = @intControlPointId
					AND P.ysnActive = 1
				)
	END

	-- If no template for item
	IF @intProductId IS NULL
		RAISERROR (
				'Quality Template is not configured. '
				,16
				,1
				)

	SELECT @intSampleTypeId = ST.intSampleTypeId
	FROM tblQMProductControlPoint PC
	JOIN tblQMSampleType ST ON ST.intControlPointId = PC.intControlPointId
		AND PC.intProductId = @intProductId
		AND PC.intControlPointId = @intControlPointId

	-- If no sample type created
	IF @intSampleTypeId IS NULL
		RAISERROR (
				'Quality Sample Type is not configured. '
				,16
				,1
				)

	IF (
			@strSampleNumber = ''
			OR @strSampleNumber IS NULL
			)
	BEGIN
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
	END

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

	IF (
			SELECT CASE 
					WHEN @strSampleNumber LIKE '%[@~$\`^&*()%?:<>!|\+;",{}'']%'
						THEN 0
					ELSE 1
					END
			) = 0
	BEGIN
		RAISERROR (
				'Special characters are not allowed for Sample Number. '
				,16
				,1
				)
	END

	SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCreated, @intLocationId)

	SELECT @intShiftId = intShiftId
	FROM tblMFShift
	WHERE intLocationId = @intLocationId
		AND @dtmCreated BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
			AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

	BEGIN TRAN

	INSERT INTO tblQMSample (
		intConcurrencyId
		,intSampleTypeId
		,strSampleNumber
		,intProductTypeId
		,intProductValueId
		,intSampleStatusId
		,intItemId
		,intItemContractId
		,intContractDetailId
		,intCountryID
		,intEntityId
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
		,strCountry
		,dtmBusinessDate
		,intShiftId
		,intLocationId
		,strComment
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		)
	SELECT 1
		,@intSampleTypeId
		,@strSampleNumber
		,@intProductTypeId
		,@intProductValueId
		,@intSampleStatusId
		,@intItemId
		,@intItemContractId
		,@intContractDetailId
		,@intCountryID
		,@intEntityId
		,@strSampleNote
		,@dtmSampleReceivedDate
		,@dtmSampleReceivedDate
		,@intUserId
		,@dblSampleQty
		,@intSampleUOMId
		,@dblRepresentingQty
		,@intRepresentingUOMId
		,@strRefNo
		,@dtmSampleReceivedDate
		,@dtmSampleReceivedDate
		,@dtmSampleReceivedDate
		,@strCountry
		,@dtmBusinessDate
		,@intShiftId
		,@intLocationId
		,'Auto created by the system'
		,@intUserId
		,@dtmCreated
		,@intUserId
		,@dtmCreated

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
		,@dtmCreated
		,@intUserId
		,@dtmCreated
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
		,@dtmCreated
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
		,@intUserId
		,@dtmCreated
		,@intUserId
		,@dtmCreated
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

	SELECT @strSampleNumber AS strSampleNumber

	EXEC sp_xml_removedocument @idoc

	COMMIT TRAN
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

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
