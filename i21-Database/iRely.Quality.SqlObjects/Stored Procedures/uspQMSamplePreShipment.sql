CREATE PROCEDURE uspQMSamplePreShipment @strXml NVARCHAR(MAX)
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
		,@strRepresentingUOM NVARCHAR(50)
		,@strRefNo NVARCHAR(100)
		,@strSampleStatus NVARCHAR(30)
		,@dtmSampleReceivedDate DATETIME
		,@strSampleNote NVARCHAR(512)
		,@intSampleUOMId INT
		,@intSampleStatusId INT
	DECLARE @intControlPointId INT = 2 -- Approval Sample
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
	DECLARE @dblOldRepresentingQty NUMERIC(18, 6)
		,@intOldRepresentingUOMId INT
		,@strOldRefNo NVARCHAR(100)
		,@intOldSampleStatusId INT
		,@strOldSampleNote NVARCHAR(512)
		,@dtmOldSampleReceivedDate DATETIME
	DECLARE @dblNewRepresentingQty NUMERIC(18, 6)
		,@intNewRepresentingUOMId INT
		,@strNewRefNo NVARCHAR(100)
		,@intNewSampleStatusId INT
		,@strNewSampleNote NVARCHAR(512)
		,@dtmNewSampleReceivedDate DATETIME
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

	-- Temporary taking first user 
	SELECT TOP 1 @intUserId = intEntityId
	FROM tblEMEntity

	SELECT @strSampleNumber = strSampleNumber
		,@intContractDetailId = intContractDetailId
		,@dblRepresentingQty = dblRepresentingQty
		,@strRepresentingUOM = strRepresentingUOM
		,@strRefNo = strRefNo
		,@strSampleStatus = strSampleStatus
		,@dtmSampleReceivedDate = dtmSampleReceivedDate
		,@strSampleNote = strSampleNote --Inspection Lot No
	FROM OPENXML(@idoc, 'root', 2) WITH (
			strSampleNumber NVARCHAR(30)
			,intContractDetailId INT
			,dblRepresentingQty NUMERIC(18, 6)
			,strRepresentingUOM NVARCHAR(50)
			,strRefNo NVARCHAR(100)
			,strSampleStatus NVARCHAR(30)
			,dtmSampleReceivedDate DATETIME
			,strSampleNote NVARCHAR(512)
			)

	-- Existing sample update
	IF (ISNULL(@strSampleNumber, '') <> '')
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM tblQMSample
				WHERE strSampleNumber = @strSampleNumber
				)
		BEGIN
			IF (ISNULL(@strSampleStatus, '') <> '')
			BEGIN
				SELECT @intSampleStatusId = intSampleStatusId
				FROM tblQMSampleStatus
				WHERE strStatus = @strSampleStatus

				IF @intSampleStatusId IS NULL
					RAISERROR (
							'Sample Status is not available. '
							,16
							,1
							)
			END

			IF (ISNULL(@strRepresentingUOM, '') <> '')
			BEGIN
				SELECT @intRepresentingUOMId = intUnitMeasureId
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = @strRepresentingUOM

				IF @intRepresentingUOMId IS NULL
					RAISERROR (
							'Representing UOM is not available. '
							,16
							,1
							)
			END

			SELECT @intSampleId = intSampleId
			FROM tblQMSample
			WHERE strSampleNumber = @strSampleNumber

			BEGIN TRAN

			SELECT @dblOldRepresentingQty = dblRepresentingQty
				,@intOldRepresentingUOMId = intRepresentingUOMId
				,@strOldRefNo = strRefNo
				,@intOldSampleStatusId = intSampleStatusId
				,@strOldSampleNote = strSampleNote
				,@dtmOldSampleReceivedDate = dtmSampleReceivedDate
			FROM tblQMSample
			WHERE intSampleId = @intSampleId

			UPDATE tblQMSample
			SET intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
				,dblRepresentingQty = CASE 
					WHEN @dblRepresentingQty IS NOT NULL
						THEN @dblRepresentingQty
					ELSE dblRepresentingQty
					END
				,intRepresentingUOMId = CASE 
					WHEN @intRepresentingUOMId IS NOT NULL
						THEN @intRepresentingUOMId
					ELSE intRepresentingUOMId
					END
				,strRefNo = CASE 
					WHEN @strRefNo IS NOT NULL
						THEN @strRefNo
					ELSE strRefNo
					END
				,intSampleStatusId = CASE 
					WHEN @intSampleStatusId IS NOT NULL
						THEN @intSampleStatusId
					ELSE intSampleStatusId
					END
				,strSampleNote = CASE 
					WHEN @strSampleNote IS NOT NULL
						THEN @strSampleNote
					ELSE strSampleNote
					END
				,dtmSampleReceivedDate = CASE 
					WHEN @dtmSampleReceivedDate IS NOT NULL
						THEN @dtmSampleReceivedDate
					ELSE dtmSampleReceivedDate
					END
				,dtmTestedOn = CASE 
					WHEN @dtmSampleReceivedDate IS NOT NULL
						THEN @dtmSampleReceivedDate
					ELSE dtmSampleReceivedDate
					END
				,dtmTestingStartDate = CASE 
					WHEN @dtmSampleReceivedDate IS NOT NULL
						THEN @dtmSampleReceivedDate
					ELSE dtmSampleReceivedDate
					END
				,dtmTestingEndDate = CASE 
					WHEN @dtmSampleReceivedDate IS NOT NULL
						THEN @dtmSampleReceivedDate
					ELSE dtmSampleReceivedDate
					END
				,dtmSamplingEndDate = CASE 
					WHEN @dtmSampleReceivedDate IS NOT NULL
						THEN @dtmSampleReceivedDate
					ELSE dtmSampleReceivedDate
					END
			FROM tblQMSample
			WHERE intSampleId = @intSampleId

			SELECT @dblNewRepresentingQty = dblRepresentingQty
				,@intNewRepresentingUOMId = intRepresentingUOMId
				,@strNewRefNo = strRefNo
				,@intNewSampleStatusId = intSampleStatusId
				,@strNewSampleNote = strSampleNote
				,@dtmNewSampleReceivedDate = dtmSampleReceivedDate
			FROM tblQMSample
			WHERE intSampleId = @intSampleId

			IF (@intSampleId > 0)
			BEGIN
				DECLARE @strDetails NVARCHAR(MAX) = ''

				IF (@dblOldRepresentingQty <> @dblNewRepresentingQty)
					SET @strDetails += '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblOldRepresentingQty) + '","to":"' + LTRIM(@dblNewRepresentingQty) + '","leaf":true},'

				IF (@intOldRepresentingUOMId <> @intNewRepresentingUOMId)
					SET @strDetails += '{"change":"intRepresentingUOMId","iconCls":"small-gear","from":"' + LTRIM(@intOldRepresentingUOMId) + '","to":"' + LTRIM(@intNewRepresentingUOMId) + '","leaf":true},'

				IF (@strOldRefNo <> @strNewRefNo)
					SET @strDetails += '{"change":"strRefNo","iconCls":"small-gear","from":"' + LTRIM(@strOldRefNo) + '","to":"' + LTRIM(@strNewRefNo) + '","leaf":true},'

				IF (@intOldSampleStatusId <> @intNewSampleStatusId)
					SET @strDetails += '{"change":"intSampleStatusId","iconCls":"small-gear","from":"' + LTRIM(@intOldSampleStatusId) + '","to":"' + LTRIM(@intNewSampleStatusId) + '","leaf":true},'

				IF (@strOldSampleNote <> @strNewSampleNote)
					SET @strDetails += '{"change":"strSampleNote","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleNote) + '","to":"' + LTRIM(@strNewSampleNote) + '","leaf":true},'

				IF (@dtmOldSampleReceivedDate <> @dtmNewSampleReceivedDate)
					SET @strDetails += '{"change":"dtmSampleReceivedDate","iconCls":"small-gear","from":"' + LTRIM(@dtmOldSampleReceivedDate) + '","to":"' + LTRIM(@dtmNewSampleReceivedDate) + '","leaf":true},'

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END
			END

			COMMIT TRAN

			RETURN;
		END
	END

	-- New Sample Create
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

	IF ISNULL(@strRepresentingUOM, '') = ''
	BEGIN
		SELECT TOP 1 @intRepresentingUOMId = UOM.intUnitMeasureId
			,@strRepresentingUOM = UOM.strUnitMeasure
		FROM tblCTContractDetail CD
		JOIN tblICItemUOM IUOM ON IUOM.intItemId = CD.intItemId
			AND IUOM.ysnStockUnit = 1
		JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		WHERE CD.intContractDetailId = @intContractDetailId
	END
	ELSE
	BEGIN
		SELECT @intRepresentingUOMId = intUnitMeasureId
		FROM tblICUnitMeasure
		WHERE strUnitMeasure = @strRepresentingUOM

		IF @intRepresentingUOMId IS NULL
			RAISERROR (
					'Representing UOM is not available. '
					,16
					,1
					)
	END

	IF @dblRepresentingQty IS NULL
		RAISERROR (
				'Representing Qty cannot be empty. '
				,16
				,1
				)

	SELECT @intProductTypeId = 8
		,@intProductValueId = CD.intContractDetailId
		,@intItemId = CD.intItemId
		,@intItemContractId = CD.intItemContractId
		,@intCountryID = ISNULL(IM.intOriginId, IC.intCountryId) --intCountryId
		,@intEntityId = CH.intEntityId
		--,@dblRepresentingQty = CD.dblQuantity
		--,@intRepresentingUOMId = CD.intUnitMeasureId
		,@strCountry = ISNULL(CA.strDescription, CG.strCountry) --strCountry
		,@intLocationId = CD.intCompanyLocationId
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem IM ON IM.intItemId = CD.intItemId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
	LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
	LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
	WHERE CD.intContractDetailId = @intContractDetailId

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

	IF ISNULL(@dtmSampleReceivedDate, '') = ''
		SET @dtmSampleReceivedDate = GETDATE()

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
		,NULL
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

	IF (@intSampleId > 0)
	BEGIN
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Sample Number'

		EXEC uspSMAuditLog @keyValue = @intSampleId
			,@screenName = 'Quality.view.QualitySample'
			,@entityId = @intUserId
			,@actionType = 'Created'
			,@actionIcon = 'small-new-plus'
			,@changeDescription = @StrDescription
			,@fromValue = ''
			,@toValue = @strSampleNumber
	END

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
