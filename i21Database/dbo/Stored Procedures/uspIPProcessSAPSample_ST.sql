CREATE PROCEDURE uspIPProcessSAPSample_ST @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
	DECLARE @strERPPONumber NVARCHAR(100)
		,@strERPItemNumber NVARCHAR(100)
		,@strSampleNumber NVARCHAR(30)
		,@strSampleTypeName NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strVendor NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@strSampleRefNo NVARCHAR(30)
		,@strSampleNote NVARCHAR(512)
		,@strSampleStatus NVARCHAR(30)
		,@strRefNo NVARCHAR(100)
		,@strMarks NVARCHAR(100)
		,@strSamplingMethod NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strCourier NVARCHAR(50)
		,@strCourierRef NVARCHAR(50)
		,@strComment NVARCHAR(MAX)
		,@strCreatedBy NVARCHAR(50)
		,@dtmCreated DATETIME
		,@strTransactionType NVARCHAR(50)
	DECLARE @intContractDetailId INT
		,@intSampleTypeId INT
		,@intItemId INT
		,@intEntityId INT -- Vendor
		,@intRepresentingUOMId INT
		,@intSampleStatusId INT
		,@intCompanyLocationSubLocationId INT
		,@intCreatedUserId INT
		,@intProductId INT
		,@intCategoryId INT
		,@intLocationId INT
		,@dtmBusinessDate DATETIME
		,@intShiftId INT
		,@intSampleId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intItemContractId INT
		,@intCountryID INT
		,@strCountry NVARCHAR(50)
		,@intBookId INT
		,@intSubBookId INT
		,@dtmCurrentUTCDate DATETIME
		,@dtmCurrentDate DATETIME
		,@intPreviousSampleStatusId INT
	DECLARE @intNewStageSampleId INT
	DECLARE @intValidDate INT
	DECLARE @strDescription AS NVARCHAR(MAX)
	DECLARE @strOldSampleTypeName NVARCHAR(50)
		,@strOldContractNumber NVARCHAR(50)
		,@strOldItemNo NVARCHAR(50)
		,@intOldProductValueId INT
		,@strOldCountry NVARCHAR(50)
		,@strOldVendor NVARCHAR(50)
		,@dblOldQuantity NUMERIC(18, 6)
		,@strOldQuantityUOM NVARCHAR(50)
		,@strOldSampleRefNo NVARCHAR(30)
		,@strOldSampleNote NVARCHAR(512)
		,@strOldSampleStatus NVARCHAR(30)
		,@strOldRefNo NVARCHAR(100)
		,@strOldMarks NVARCHAR(100)
		,@strOldSamplingMethod NVARCHAR(50)
		,@strOldSubLocationName NVARCHAR(50)
		,@strOldCourier NVARCHAR(50)
		,@strOldCourierRef NVARCHAR(50)
		,@strOldComment NVARCHAR(MAX)
		,@strNewContractNumber NVARCHAR(50)
	DECLARE @tblQMTestResultChanges TABLE (
		strOldPropertyValue NVARCHAR(MAX)
		,strOldComment NVARCHAR(MAX)
		,strOldResult NVARCHAR(20)
		,strNewPropertyValue NVARCHAR(MAX)
		,strNewComment NVARCHAR(MAX)
		,strNewResult NVARCHAR(20)
		,intTestResultId INT
		,strPropertyName NVARCHAR(100)
		)
	DECLARE @strOldPropertyValue NVARCHAR(MAX)
		,@strOldTestComment NVARCHAR(MAX)
		,@strOldResult NVARCHAR(20)
		,@strNewPropertyValue NVARCHAR(MAX)
		,@strNewTestComment NVARCHAR(MAX)
		,@strNewResult NVARCHAR(20)
		,@intTestResultId INT
		,@strPropertyName NVARCHAR(100)

	SELECT @intMinRowNo = Min(intStageSampleId)
	FROM tblIPSampleStage WITH (NOLOCK)

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strERPPONumber = NULL
				,@strERPItemNumber = NULL
				,@strSampleNumber = NULL
				,@strSampleTypeName = NULL
				,@strItemNo = NULL
				,@strVendor = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@strSampleRefNo = NULL
				,@strSampleNote = NULL
				,@strSampleStatus = NULL
				,@strRefNo = NULL
				,@strMarks = NULL
				,@strSamplingMethod = NULL
				,@strSubLocationName = NULL
				,@strCourier = NULL
				,@strCourierRef = NULL
				,@strComment = NULL
				,@strCreatedBy = NULL
				,@dtmCreated = NULL
				,@strTransactionType = NULL

			SELECT @intContractDetailId = NULL
				,@intSampleTypeId = NULL
				,@intItemId = NULL
				,@intEntityId = NULL
				,@intRepresentingUOMId = NULL
				,@intSampleStatusId = NULL
				,@intCompanyLocationSubLocationId = NULL
				,@intCreatedUserId = NULL
				,@intProductId = NULL
				,@intCategoryId = NULL
				,@intLocationId = NULL
				,@dtmBusinessDate = NULL
				,@intShiftId = NULL
				,@intSampleId = NULL
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@intItemContractId = NULL
				,@intCountryID = NULL
				,@strCountry = NULL
				,@intBookId = NULL
				,@intSubBookId = NULL
				,@dtmCurrentUTCDate = NULL
				,@dtmCurrentDate = NULL
				,@intPreviousSampleStatusId = NULL

			SELECT @strDescription = NULL

			SELECT @strOldSampleTypeName = NULL
				,@strOldContractNumber = NULL
				,@strOldItemNo = NULL
				,@intOldProductValueId = NULL
				,@strOldCountry = NULL
				,@strOldVendor = NULL
				,@dblOldQuantity = NULL
				,@strOldQuantityUOM = NULL
				,@strOldSampleRefNo = NULL
				,@strOldSampleNote = NULL
				,@strOldSampleStatus = NULL
				,@strOldRefNo = NULL
				,@strOldMarks = NULL
				,@strOldSamplingMethod = NULL
				,@strOldSubLocationName = NULL
				,@strOldCourier = NULL
				,@strOldCourierRef = NULL
				,@strOldComment = NULL
				,@strNewContractNumber = NULL

			SELECT @strERPPONumber = strERPPONumber
				,@strERPItemNumber = strERPItemNumber
				,@strSampleNumber = strSampleNumber
				,@strSampleTypeName = strSampleTypeName
				,@strItemNo = strItemNo
				,@strVendor = strVendor
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@strSampleRefNo = strSampleRefNo
				,@strSampleNote = strSampleNote
				,@strSampleStatus = strSampleStatus
				,@strRefNo = strRefNo
				,@strMarks = strMarks
				,@strSamplingMethod = strSamplingMethod
				,@strSubLocationName = strSubLocationName
				,@strCourier = strCourier
				,@strCourierRef = strCourierRef
				,@strComment = strComment
				,@strCreatedBy = strCreatedBy
				,@dtmCreated = dtmCreated
				,@strTransactionType = strTransactionType
			FROM tblIPSampleStage WITH (NOLOCK)
			WHERE intStageSampleId = @intMinRowNo

			SELECT @dtmCurrentUTCDate = DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), GETDATE())
				,@dtmCurrentDate = GETDATE()

			SELECT @intValidDate = (
					SELECT DATEPART(dy, GETDATE())
					)

			IF ISNULL(@strSampleNumber, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Sample No. '
						,16
						,1
						)
			END

			SELECT @intSampleTypeId = t.intSampleTypeId
			FROM tblQMSampleType t WITH (NOLOCK)
			WHERE t.strSampleTypeName = @strSampleTypeName

			IF ISNULL(@intSampleTypeId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sample Type. '
						,16
						,1
						)
			END

			SELECT @intItemId = t.intItemId
			FROM tblICItem t WITH (NOLOCK)
			WHERE t.strItemNo = @strItemNo

			IF ISNULL(@intItemId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Item No. '
						,16
						,1
						)
			END

			IF LOWER(@strSampleTypeName) = LOWER('Offer Sample')
			BEGIN
				SELECT @intContractDetailId = NULL
					,@intLocationId = NULL
					,@intProductTypeId = 2 -- Item
					,@intProductValueId = IM.intItemId
					,@intItemContractId = NULL
					,@intCountryID = CA.intCountryID
					,@strCountry = CA.strDescription
					,@intBookId = NULL
					,@intSubBookId = NULL
				FROM tblICItem IM WITH (NOLOCK)
				LEFT JOIN tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = IM.intOriginId
				WHERE IM.intItemId = @intItemId
			END
			ELSE
			BEGIN
				IF ISNULL(@strERPPONumber, '') = ''
				BEGIN
					RAISERROR (
							'Invalid ERP PO No. '
							,16
							,1
							)
				END

				IF ISNULL(@strERPItemNumber, '') = ''
				BEGIN
					RAISERROR (
							'Invalid ERP Item No. '
							,16
							,1
							)
				END

				SELECT @intContractDetailId = CD.intContractDetailId
					,@intLocationId = CD.intCompanyLocationId
					,@intProductTypeId = 8 -- Contract Line Item
					,@intProductValueId = CD.intContractDetailId
					,@intItemContractId = CD.intItemContractId
					,@intCountryID = ISNULL(CA.intCountryID, IC.intCountryId)
					,@strCountry = ISNULL(CA.strDescription, CG.strCountry)
					,@intBookId = CD.intBookId
					,@intSubBookId = CD.intSubBookId
				FROM tblCTContractDetail CD WITH (NOLOCK)
				JOIN tblICItem IM WITH (NOLOCK) ON IM.intItemId = CD.intItemId
				LEFT JOIN tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = IM.intOriginId
				LEFT JOIN tblICItemContract IC WITH (NOLOCK) ON IC.intItemContractId = CD.intItemContractId
				LEFT JOIN tblSMCountry CG WITH (NOLOCK) ON CG.intCountryID = IC.intCountryId
				WHERE CD.strERPPONumber = @strERPPONumber
					AND CD.strERPItemNumber = @strERPItemNumber

				IF ISNULL(@intContractDetailId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Contract. '
							,16
							,1
							)
				END
				
				IF NOT EXISTS (
						SELECT 1
						FROM tblCTContractDetail t WITH (NOLOCK)
						WHERE t.intContractDetailId = @intContractDetailId
							AND t.intItemId = @intItemId
						)
				BEGIN
					RAISERROR (
							'Item No is not matching with Contract Sequence Item. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strVendor, '') <> ''
			BEGIN
				SELECT @intEntityId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				JOIN tblAPVendor V WITH (NOLOCK) ON V.intEntityId = t.intEntityId
				WHERE ET.strType IN (
						'Vendor'
						,'Customer'
						)
					AND V.strVendorAccountNum = @strVendor
					AND t.strEntityNo <> ''
			END

			IF ISNULL(@intEntityId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Vendor. '
						,16
						,1
						)
			END

			IF ISNULL(@strQuantityUOM, '') <> ''
			BEGIN
				SELECT @intRepresentingUOMId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strQuantityUOM

				IF ISNULL(@intRepresentingUOMId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid UOM. '
							,16
							,1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblICItemUOM t WITH (NOLOCK)
						WHERE t.intUnitMeasureId = @intRepresentingUOMId
							AND t.intItemId = @intItemId
						)
				BEGIN
					RAISERROR (
							'Invalid Item UOM. '
							,16
							,1
							)
				END
			END

			SELECT @intSampleStatusId = t.intSampleStatusId
			FROM tblQMSampleStatus t WITH (NOLOCK)
			WHERE t.strSecondaryStatus = @strSampleStatus

			IF ISNULL(@intSampleStatusId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Sample Status. '
						,16
						,1
						)
			END

			IF ISNULL(@strSubLocationName, '') <> ''
			BEGIN
				SELECT @intCompanyLocationSubLocationId = t.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
				WHERE t.strSubLocationName = @strSubLocationName

				IF ISNULL(@intCompanyLocationSubLocationId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Sub Location. '
							,16
							,1
							)
				END
			END

			IF ISNULL(@strCreatedBy, '') <> ''
			BEGIN
				SELECT @intCreatedUserId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strCreatedBy
					AND t.strEntityNo <> ''

				--IF ISNULL(@intCreatedUserId, 0) = 0
				--BEGIN
				--	RAISERROR (
				--			'Invalid Created User. '
				--			,16
				--			,1
				--			)
				--END
			END

			IF ISNULL(@intCreatedUserId, 0) = 0
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intCreatedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intCreatedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
			END

			IF @strTransactionType NOT IN (
					'SAMPLE_CREATE'
					,'SAMPLE_UPDATE'
					,'SAMPLE_DELETE'
					)
			BEGIN
				RAISERROR (
						'Invalid Message Type. '
						,16
						,1
						)
			END

			SET @intProductId = (
					SELECT P.intProductId
					FROM tblQMProduct AS P WITH (NOLOCK)
					JOIN tblQMProductControlPoint PC WITH (NOLOCK) ON PC.intProductId = P.intProductId
					WHERE P.intProductTypeId = 2 -- Item
						AND P.intProductValueId = @intItemId
						AND PC.intSampleTypeId = @intSampleTypeId
						AND P.ysnActive = 1
					)

			IF @intProductId IS NULL
			BEGIN
				SET @intCategoryId = (
						SELECT intCategoryId
						FROM tblICItem WITH (NOLOCK)
						WHERE intItemId = @intItemId
						)
				SET @intProductId = (
						SELECT P.intProductId
						FROM tblQMProduct AS P WITH (NOLOCK)
						JOIN tblQMProductControlPoint PC WITH (NOLOCK) ON PC.intProductId = P.intProductId
						WHERE P.intProductTypeId = 1 -- Item Category
							AND P.intProductValueId = @intCategoryId
							AND PC.intSampleTypeId = @intSampleTypeId
							AND P.ysnActive = 1
						)
			END

			IF ISNULL(@intProductId, 0) = 0
			BEGIN
				RAISERROR (
						'Quality Template is not configured. '
						,16
						,1
						)
			END

			SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

			SELECT @intShiftId = intShiftId
			FROM tblMFShift WITH (NOLOCK)
			WHERE intLocationId = @intLocationId
				AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
					AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

			SET @strInfo1 = ISNULL(@strSampleNumber, '') + ' / ' + ISNULL(@strERPPONumber, '')
			SET @strInfo2 = ISNULL(@strItemNo, '')

			SELECT @intUserId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			BEGIN TRAN

			-- Sample Create
			IF ISNULL(@strTransactionType, '') = 'SAMPLE_CREATE'
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblQMSample WITH (NOLOCK)
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
					,intPreviousSampleStatusId
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
					,strSamplingMethod
					,strMarks
					,intCompanyLocationSubLocationId
					,strCountry
					,dtmBusinessDate
					,intShiftId
					,intLocationId
					,strComment
					,intBookId
					,intSubBookId
					,strCourier
					,strCourierRef
					,ysnParent
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
					,@intSampleStatusId
					,@intItemId
					,@intItemContractId
					,@intContractDetailId
					,@intCountryID
					,@intEntityId
					,@strSampleNote
					,@dtmCurrentUTCDate
					,@dtmCurrentDate
					,@intCreatedUserId
					,NULL
					,NULL
					,@dblQuantity
					,@intRepresentingUOMId
					,@strRefNo
					,@dtmCurrentUTCDate
					,@dtmCurrentUTCDate
					,@dtmCurrentUTCDate
					,@strSamplingMethod
					,@strMarks
					,@intCompanyLocationSubLocationId
					,@strCountry
					,@dtmBusinessDate
					,@intShiftId
					,@intLocationId
					,@strComment
					,@intBookId
					,@intSubBookId
					,@strCourier
					,@strCourierRef
					,0
					,@intCreatedUserId
					,@dtmCurrentDate
					,@intCreatedUserId
					,@dtmCurrentDate

				SELECT @intSampleId = SCOPE_IDENTITY()

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
				FROM tblQMProduct AS PRD WITH (NOLOCK)
				JOIN tblQMProductControlPoint PC WITH (NOLOCK) ON PC.intProductId = PRD.intProductId
				JOIN tblQMProductProperty AS PP WITH (NOLOCK) ON PP.intProductId = PRD.intProductId
				JOIN tblQMProductTest AS PT WITH (NOLOCK) ON PT.intProductId = PP.intProductId
					AND PT.intProductId = PRD.intProductId
				JOIN tblQMTest AS T WITH (NOLOCK) ON T.intTestId = PP.intTestId
					AND T.intTestId = PT.intTestId
				JOIN tblQMTestProperty AS TP WITH (NOLOCK) ON TP.intPropertyId = PP.intPropertyId
					AND TP.intTestId = PP.intTestId
					AND TP.intTestId = T.intTestId
					AND TP.intTestId = PT.intTestId
				JOIN tblQMProperty AS PRT WITH (NOLOCK) ON PRT.intPropertyId = PP.intPropertyId
					AND PRT.intPropertyId = TP.intPropertyId
				JOIN tblQMProductPropertyValidityPeriod AS PPV WITH (NOLOCK) ON PPV.intProductPropertyId = PP.intProductPropertyId
				WHERE PRD.intProductId = @intProductId
					AND PC.intSampleTypeId = @intSampleTypeId
					AND @intValidDate BETWEEN DATEPART(dy, PPV.dtmValidFrom)
						AND DATEPART(dy, PPV.dtmValidTo)
				ORDER BY PP.intSequenceNo
			END

			IF ISNULL(@strTransactionType, '') = 'SAMPLE_UPDATE'
			BEGIN
				SELECT @intSampleId = intSampleId
					,@intPreviousSampleStatusId = intSampleStatusId
				FROM tblQMSample WITH (NOLOCK)
				WHERE strSampleNumber = @strSampleNumber

				IF ISNULL(@intSampleId, 0) = 0
				BEGIN
					RAISERROR (
							'Sample No is not available. '
							,16
							,1
							)
				END

				SELECT @intOldProductValueId = S.intProductValueId
					,@strOldCountry = S.strCountry
					,@dblOldQuantity = S.dblRepresentingQty
					,@strOldSampleRefNo = S.strSampleRefNo
					,@strOldSampleNote = S.strSampleNote
					,@strOldRefNo = S.strRefNo
					,@strOldMarks = S.strMarks
					,@strOldSamplingMethod = S.strSamplingMethod
					,@strOldCourier = S.strCourier
					,@strOldCourierRef = S.strCourierRef
					,@strOldComment = S.strComment
				FROM tblQMSample S WITH (NOLOCK)
				WHERE S.intSampleId = @intSampleId

				SELECT @strOldSampleTypeName = S.strSampleTypeName
					,@strOldContractNumber = S.strSequenceNumber
					,@strOldItemNo = S.strItemNo
					,@strOldVendor = S.strPartyName
					,@strOldQuantityUOM = S.strRepresentingUOM
					,@strOldSampleStatus = S.strSampleStatus
					,@strOldSubLocationName = S.strSubLocationName
				FROM vyuQMSampleNotMapped S WITH (NOLOCK)
				WHERE S.intSampleId = @intSampleId

				UPDATE tblQMSample
				SET intConcurrencyId = intConcurrencyId + 1
					,intSampleTypeId = @intSampleTypeId
					,strSampleRefNo = @strSampleRefNo
					,intProductValueId = @intProductValueId
					,intSampleStatusId = @intSampleStatusId
					,intPreviousSampleStatusId = @intPreviousSampleStatusId
					,intItemContractId = @intItemContractId
					,intContractDetailId = @intContractDetailId
					,intCountryID = @intCountryID
					,intEntityId = @intEntityId
					,strSampleNote = @strSampleNote
					,dblRepresentingQty = @dblQuantity
					,intRepresentingUOMId = @intRepresentingUOMId
					,strRefNo = @strRefNo
					,strSamplingMethod = @strSamplingMethod
					,strMarks = @strMarks
					,intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
					,strCountry = @strCountry
					,dtmBusinessDate = @dtmBusinessDate
					,intShiftId = @intShiftId
					,intLocationId = @intLocationId
					,strComment = @strComment
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,strCourier = @strCourier
					,strCourierRef = @strCourierRef
					,intLastModifiedUserId = @intCreatedUserId
					,dtmLastModified = @dtmCurrentDate
				WHERE intSampleId = @intSampleId

				SELECT @strNewContractNumber = CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)
				FROM tblQMSample S WITH (NOLOCK)
				LEFT JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = S.intContractDetailId
				LEFT JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
				WHERE S.intSampleId = @intSampleId
			END

			IF ISNULL(@strTransactionType, '') = 'SAMPLE_CREATE'
				OR ISNULL(@strTransactionType, '') = 'SAMPLE_UPDATE'
			BEGIN
				DELETE
				FROM @tblQMTestResultChanges

				INSERT INTO @tblQMTestResultChanges (
					strOldPropertyValue
					,strOldComment
					,strOldResult
					,intTestResultId
					,strPropertyName
					)
				SELECT TR.strPropertyValue
					,TR.strComment
					,TR.strResult
					,TR.intTestResultId
					,P.strPropertyName
				FROM tblQMTestResult TR WITH (NOLOCK)
				JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = TR.intPropertyId
					AND intSampleId = @intSampleId

				-- Update Properties Value, Comment
				-- Setting Bit to lower case then only in sencha client, it is recogonizing
				UPDATE tblQMTestResult
				SET strPropertyValue = (
						CASE P.intDataTypeId
							WHEN 4
								THEN LOWER(SR.strActualValue)
							ELSE SR.strActualValue
							END
						)
					,strComment = SR.strTestComment
					,dtmPropertyValueCreated = (
						CASE 
							WHEN SR.strActualValue <> ''
								THEN GETDATE()
							ELSE NULL
							END
						)
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND TR.intSampleId = @intSampleId
				JOIN tblIPSampleTestResultStage SR ON SR.strPropertyName = P.strPropertyName
					AND SR.intStageSampleId = @intMinRowNo

				-- Setting result for properties
				UPDATE tblQMTestResult
				SET strResult = dbo.fnQMGetPropertyTestResult(TR.intTestResultId)
				FROM tblQMTestResult TR
				WHERE TR.intSampleId = @intSampleId

				-- Setting correct date format
				UPDATE tblQMTestResult
				SET strPropertyValue = CONVERT(DATETIME, TR.strPropertyValue, 120)
				FROM tblQMTestResult TR
				JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					AND TR.intSampleId = @intSampleId
					AND ISNULL(TR.strPropertyValue, '') <> ''
					AND P.intDataTypeId = 12

				UPDATE @tblQMTestResultChanges
				SET strNewPropertyValue = TR.strPropertyValue
					,strNewComment = TR.strComment
					,strNewResult = TR.strResult
				FROM @tblQMTestResultChanges OLD
				JOIN tblQMTestResult TR ON TR.intTestResultId = OLD.intTestResultId

				IF ISNULL(@strTransactionType, '') = 'SAMPLE_CREATE'
				BEGIN
					-- Audit Log
					IF (@intSampleId > 0)
					BEGIN
						SELECT @strDescription = 'Sample created from external system. '

						EXEC uspSMAuditLog @keyValue = @intSampleId
							,@screenName = 'Quality.view.QualitySample'
							,@entityId = @intUserId
							,@actionType = 'Created'
							,@actionIcon = 'small-new-plus'
							,@changeDescription = @strDescription
							,@fromValue = ''
							,@toValue = @strSampleNumber
					END

					-- Inter Company for Quality
					EXEC uspQMInterCompanyPreStageSample @intSampleId
						,'Added'
				END
				ELSE
				BEGIN
					-- Audit Log
					IF (@intSampleId > 0)
					BEGIN
						DECLARE @strDetails NVARCHAR(MAX) = ''

						IF (@strOldSampleTypeName <> @strSampleTypeName)
							SET @strDetails += '{"change":"strSampleTypeName","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleTypeName) + '","to":"' + LTRIM(@strSampleTypeName) + '","leaf":true,"changeDescription":"Sample Type"},'

						IF (@strOldContractNumber <> @strNewContractNumber)
							SET @strDetails += '{"change":"strSequenceNumber","iconCls":"small-gear","from":"' + LTRIM(@strOldContractNumber) + '","to":"' + LTRIM(@strNewContractNumber) + '","leaf":true,"changeDescription":"Contract Number"},'

						IF (@strOldItemNo <> @strItemNo)
							SET @strDetails += '{"change":"strItemNo","iconCls":"small-gear","from":"' + LTRIM(@strOldItemNo) + '","to":"' + LTRIM(@strItemNo) + '","leaf":true,"changeDescription":"Item No"},'

						IF (@intOldProductValueId <> @intProductValueId)
							SET @strDetails += '{"change":"intProductValueId","iconCls":"small-gear","from":"' + LTRIM(@intOldProductValueId) + '","to":"' + LTRIM(@intProductValueId) + '","leaf":true,"changeDescription":"Product Value"},'

						IF (@strOldCountry <> @strCountry)
							SET @strDetails += '{"change":"strCountry","iconCls":"small-gear","from":"' + LTRIM(@strOldCountry) + '","to":"' + LTRIM(@strCountry) + '","leaf":true,"changeDescription":"Origin"},'

						IF (@strOldVendor <> @strVendor)
							SET @strDetails += '{"change":"strPartyName","iconCls":"small-gear","from":"' + LTRIM(@strOldVendor) + '","to":"' + LTRIM(@strVendor) + '","leaf":true,"changeDescription":"Party Name"},'

						IF (@dblOldQuantity <> @dblQuantity)
							SET @strDetails += '{"change":"dblRepresentingQty","iconCls":"small-gear","from":"' + LTRIM(@dblOldQuantity) + '","to":"' + LTRIM(@dblQuantity) + '","leaf":true,"changeDescription":"Representing Qty"},'

						IF (@strOldQuantityUOM <> @strQuantityUOM)
							SET @strDetails += '{"change":"strRepresentingUOM","iconCls":"small-gear","from":"' + LTRIM(@strOldQuantityUOM) + '","to":"' + LTRIM(@strQuantityUOM) + '","leaf":true,"changeDescription":"Representing Qty UOM"},'

						IF (@strOldSampleRefNo <> @strSampleRefNo)
							SET @strDetails += '{"change":"strSampleRefNo","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleRefNo) + '","to":"' + LTRIM(@strSampleRefNo) + '","leaf":true,"changeDescription":"Sample Ref No"},'

						IF (@strOldSampleNote <> @strSampleNote)
							SET @strDetails += '{"change":"strSampleNote","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleNote) + '","to":"' + LTRIM(@strSampleNote) + '","leaf":true,"changeDescription":"Sample Note"},'

						IF (@strOldSampleStatus <> @strSampleStatus)
							SET @strDetails += '{"change":"strSampleStatus","iconCls":"small-gear","from":"' + LTRIM(@strOldSampleStatus) + '","to":"' + LTRIM(@strSampleStatus) + '","leaf":true,"changeDescription":"Sample Status"},'

						IF (@strOldRefNo <> @strRefNo)
							SET @strDetails += '{"change":"strRefNo","iconCls":"small-gear","from":"' + LTRIM(@strOldRefNo) + '","to":"' + LTRIM(@strRefNo) + '","leaf":true,"changeDescription":"Reference No"},'

						IF (@strOldMarks <> @strMarks)
							SET @strDetails += '{"change":"strMarks","iconCls":"small-gear","from":"' + LTRIM(@strOldMarks) + '","to":"' + LTRIM(@strMarks) + '","leaf":true,"changeDescription":"Marks"},'

						IF (@strOldSamplingMethod <> @strSamplingMethod)
							SET @strDetails += '{"change":"strSamplingMethod","iconCls":"small-gear","from":"' + LTRIM(@strOldSamplingMethod) + '","to":"' + LTRIM(@strSamplingMethod) + '","leaf":true,"changeDescription":"Sampling Method"},'

						IF (@strOldSubLocationName <> @strSubLocationName)
							SET @strDetails += '{"change":"strSubLocationName","iconCls":"small-gear","from":"' + LTRIM(@strOldSubLocationName) + '","to":"' + LTRIM(@strSubLocationName) + '","leaf":true,"changeDescription":"Warehouse"},'

						IF (@strOldCourier <> @strCourier)
							SET @strDetails += '{"change":"strCourier","iconCls":"small-gear","from":"' + LTRIM(@strOldCourier) + '","to":"' + LTRIM(@strCourier) + '","leaf":true,"changeDescription":"Courier"},'

						IF (@strOldCourierRef <> @strCourierRef)
							SET @strDetails += '{"change":"strCourierRef","iconCls":"small-gear","from":"' + LTRIM(@strOldCourierRef) + '","to":"' + LTRIM(@strCourierRef) + '","leaf":true,"changeDescription":"Courier Ref"},'

						IF (@strOldComment <> @strComment)
							SET @strDetails += '{"change":"strComment","iconCls":"small-gear","from":"' + LTRIM(@strOldComment) + '","to":"' + LTRIM(@strComment) + '","leaf":true,"changeDescription":"Comments"},'

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

						-- Test Result Audit Log
						DECLARE @details NVARCHAR(MAX) = ''

						WHILE EXISTS (
								SELECT TOP 1 NULL
								FROM @tblQMTestResultChanges
								)
						BEGIN
							SELECT @strOldPropertyValue = NULL
								,@strOldTestComment = NULL
								,@strOldResult = NULL
								,@strNewPropertyValue = NULL
								,@strNewTestComment = NULL
								,@strNewResult = NULL
								,@intTestResultId = NULL
								,@strPropertyName = NULL

							SELECT TOP 1 @strOldPropertyValue = strOldPropertyValue
								,@strOldTestComment = strOldComment
								,@strOldResult = strOldResult
								,@strNewPropertyValue = strNewPropertyValue
								,@strNewTestComment = strNewComment
								,@strNewResult = strNewResult
								,@intTestResultId = intTestResultId
								,@strPropertyName = strPropertyName
							FROM @tblQMTestResultChanges

							SET @details = '{  
								 "action":"Updated",
								 "change":"Updated - Record: ' + LTRIM(@intSampleId) + '",
								 "keyValue":' + LTRIM(@intSampleId) + ',
								 "iconCls":"small-tree-modified",
								 "children":[  
									 {  
											"change":"tblQMTestResults",
											"children":[  
											 {  
												"action":"Updated",
												"change":"Updated - Record: ' + LTRIM(@strPropertyName) + '",
												"keyValue":' + LTRIM(@intTestResultId) + ',
												"iconCls":"small-tree-modified",
												"children":
												 [   
													 '

							IF @strOldPropertyValue <> @strNewPropertyValue
								SET @details = @details + '
													 {  
												        "change":"strPropertyValue",
												        "from":"' + LTRIM(@strOldPropertyValue) + '",
												        "to":"' + LTRIM(@strNewPropertyValue) + '",
												        "leaf":true,
												        "iconCls":"small-gear",
												        "isField":true,
												        "keyValue":' + LTRIM(@intTestResultId) + ',
												        "associationKey":"tblQMTestResults",
												        "changeDescription":"Actual Value",
														"hidden":false
												     },'

							IF @strOldTestComment <> @strNewTestComment
								SET @details = @details + '
													 {  
												      "change":"strComment",
												      "from":"' + LTRIM(@strOldTestComment) + '",
												      "to":"' + LTRIM(@strNewTestComment) + '",
												      "leaf":true,
												      "iconCls":"small-gear",
												      "isField":true,
												      "keyValue":' + LTRIM(@intTestResultId) + ',
												      "associationKey":"tblQMTestResults",
												      "changeDescription":"Comments",
												      "hidden":false
												     },'

							IF @strOldResult <> @strNewResult
								SET @details = @details + '
												     {  
												        "change":"strResult",
												        "from":"' + LTRIM(@strOldResult) + '",
												        "to":"' + LTRIM(@strNewResult) + '",
												        "leaf":true,
												        "iconCls":"small-gear",
												        "isField":true,
												        "keyValue":' + LTRIM(@intTestResultId) + ',
												        "associationKey":"tblQMTestResults",
												        "changeDescription":"Result",
												        "hidden":false
												     },'

							IF RIGHT(@details, 1) = ','
								SET @details = SUBSTRING(@details, 0, LEN(@details))
							SET @details = @details + '
												]
										  }
									   ],
										"iconCls":"small-tree-grid",
										"changeDescription":"Test Detail"
									  }
									]
								 }'

							IF @strOldPropertyValue <> @strNewPropertyValue
								OR @strOldTestComment <> @strNewTestComment
								OR @strOldResult <> @strNewResult
							BEGIN
								EXEC uspSMAuditLog @keyValue = @intSampleId
									,@screenName = 'Quality.view.QualitySample'
									,@entityId = @intUserId
									,@actionType = 'Updated'
									,@actionIcon = 'small-tree-modified'
									,@details = @details
							END

							DELETE
							FROM @tblQMTestResultChanges
							WHERE intTestResultId = @intTestResultId
						END
					END

					-- Inter Company for Quality
					EXEC uspQMInterCompanyPreStageSample @intSampleId
						,'Modified'
				END
			END

			IF ISNULL(@strTransactionType, '') = 'SAMPLE_DELETE'
			BEGIN
				SELECT @intSampleId = intSampleId
				FROM tblQMSample WITH (NOLOCK)
				WHERE strSampleNumber = @strSampleNumber

				IF ISNULL(@intSampleId, 0) = 0
				BEGIN
					RAISERROR (
							'Sample No is not available. '
							,16
							,1
							)
				END

				DELETE
				FROM tblQMSample
				WHERE intSampleId = @intSampleId

				-- Audit Log
				IF (@intSampleId > 0)
				BEGIN
					SELECT @strDescription = 'Sample deleted from external system. '

					EXEC uspSMAuditLog @keyValue = @intSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intUserId
						,@actionType = 'Deleted'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @strDescription
						,@fromValue = ''
						,@toValue = @strSampleNumber
				END

				-- Inter Company for Quality
				EXEC uspQMInterCompanyPreStageSample @intSampleId
					,'Delete'
			END

			--Move to Archive
			INSERT INTO tblIPSampleArchive (
				strERPPONumber
				,strERPItemNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strERPPONumber
				,strERPItemNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strTransactionType
				,''
				,'Success'
				,strSessionId
			FROM tblIPSampleStage
			WHERE intStageSampleId = @intMinRowNo

			SELECT @intNewStageSampleId = SCOPE_IDENTITY()

			INSERT INTO tblIPSampleTestResultArchive (
				intStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
				)
			SELECT @intNewStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
			FROM tblIPSampleTestResultStage
			WHERE intStageSampleId = @intMinRowNo

			DELETE
			FROM tblIPSampleStage
			WHERE intStageSampleId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPSampleError (
				strERPPONumber
				,strERPItemNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strERPPONumber
				,strERPItemNumber
				,strSampleNumber
				,strSampleTypeName
				,strItemNo
				,strVendor
				,dblQuantity
				,strQuantityUOM
				,strSampleRefNo
				,strSampleNote
				,strSampleStatus
				,strRefNo
				,strMarks
				,strSamplingMethod
				,strSubLocationName
				,strCourier
				,strCourierRef
				,strComment
				,strCreatedBy
				,dtmCreated
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPSampleStage
			WHERE intStageSampleId = @intMinRowNo

			SELECT @intNewStageSampleId = SCOPE_IDENTITY()

			INSERT INTO tblIPSampleTestResultError (
				intStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
				)
			SELECT @intNewStageSampleId
				,strSampleNumber
				,strTestName
				,strPropertyName
				,strActualValue
				,strTestComment
			FROM tblIPSampleTestResultStage
			WHERE intStageSampleId = @intMinRowNo

			DELETE
			FROM tblIPSampleStage
			WHERE intStageSampleId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageSampleId)
		FROM tblIPSampleStage WITH (NOLOCK)
		WHERE intStageSampleId > @intMinRowNo
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
