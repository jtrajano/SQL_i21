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

	--DECLARE @dtmNewArrivedInPort DATETIME
	--	,@dtmNewCustomsReleased DATETIME
	--	,@ysnNewArrivedInPort BIT
	--	,@ysnNewCustomsReleased BIT
	--	,@dtmOldArrivedInPort DATETIME
	--	,@dtmOldCustomsReleased DATETIME
	--	,@ysnOldArrivedInPort BIT
	--	,@ysnOldCustomsReleased BIT
	--	,@dtmOldETA DATETIME
	--	,@strDetails NVARCHAR(MAX)
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

			--SELECT @dtmNewArrivedInPort = NULL
			--	,@dtmNewCustomsReleased = NULL
			--	,@ysnNewArrivedInPort = NULL
			--	,@ysnNewCustomsReleased = NULL
			--	,@dtmOldArrivedInPort = NULL
			--	,@dtmOldCustomsReleased = NULL
			--	,@ysnOldArrivedInPort = NULL
			--	,@ysnOldCustomsReleased = NULL
			--	,@dtmOldETA = NULL
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

			IF ISNULL(@strSampleNumber, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Sample No. '
						,16
						,1
						)
			END

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
				,@intProductTypeId = 8
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

			IF ISNULL(@strVendor, '') <> ''
			BEGIN
				SELECT @intEntityId = t.intEntityId
				FROM tblEMEntity t
				JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
				WHERE ET.strType IN (
						'Vendor'
						,'Customer'
						)
					AND t.strName = @strVendor
					AND t.strEntityNo <> ''
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

				IF NOT EXISTS (
						SELECT 1
						FROM tblICItemUOM t WITH (NOLOCK)
						WHERE t.intUnitMeasureId = @intRepresentingUOMId
						)
				BEGIN
					RAISERROR (
							'Invalid Item UOM. '
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

				IF ISNULL(@intCreatedUserId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Created User. '
							,16
							,1
							)
				END
						--IF @intCreatedUserId IS NULL
						--BEGIN
						--	IF EXISTS (
						--			SELECT 1
						--			FROM tblSMUserSecurity WITH (NOLOCK)
						--			WHERE strUserName = 'irelyadmin'
						--			)
						--		SELECT TOP 1 @intCreatedUserId = intEntityId
						--		FROM tblSMUserSecurity WITH (NOLOCK)
						--		WHERE strUserName = 'irelyadmin'
						--	ELSE
						--		SELECT TOP 1 @intCreatedUserId = intEntityId
						--		FROM tblSMUserSecurity WITH (NOLOCK)
						--END
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

				-- Inter Company for Quality
				EXEC uspQMInterCompanyPreStageSample @intSampleId
					,'Added'
					--SELECT @dtmNewArrivedInPort = L.dtmArrivedInPort
					--	,@dtmNewCustomsReleased = L.dtmCustomsReleased
					--	,@ysnNewArrivedInPort = L.ysnArrivedInPort
					--	,@ysnNewCustomsReleased = L.ysnCustomsReleased
					--FROM tblLGLoad L WITH (NOLOCK)
					--WHERE L.intLoadId = @intLoadId
					-- Audit Log
					--SELECT @strDetails = ''
					--IF (@dtmOldArrivedInPort <> @dtmNewArrivedInPort)
					--	SET @strDetails += '{"change":"dtmArrivedInPort","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldArrivedInPort, '')) + '","to":"' + LTRIM(ISNULL(@dtmNewArrivedInPort, '')) + '","leaf":true,"changeDescription":"Arrived in Port Date"},'
					--IF (@dtmOldCustomsReleased <> @dtmNewCustomsReleased)
					--	SET @strDetails += '{"change":"dtmCustomsReleased","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldCustomsReleased, '')) + '","to":"' + LTRIM(ISNULL(@dtmNewCustomsReleased, '')) + '","leaf":true,"changeDescription":"Customs Released Date"},'
					--IF (@ysnOldArrivedInPort <> @ysnNewArrivedInPort)
					--	SET @strDetails += '{"change":"ysnArrivedInPort","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@ysnOldArrivedInPort, '')) + '","to":"' + LTRIM(ISNULL(@ysnNewArrivedInPort, '')) + '","leaf":true,"changeDescription":"Arrived In Port"},'
					--IF (@ysnOldCustomsReleased <> @ysnNewCustomsReleased)
					--	SET @strDetails += '{"change":"ysnCustomsReleased","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@ysnOldCustomsReleased, '')) + '","to":"' + LTRIM(ISNULL(@ysnNewCustomsReleased, '')) + '","leaf":true,"changeDescription":"Customs Released"},'
					--IF (LEN(@strDetails) > 1)
					--BEGIN
					--	SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))
					--	EXEC uspSMAuditLog @keyValue = @intLoadId
					--		,@screenName = 'Quality.view.QualitySample'
					--		,@entityId = @intUserId
					--		,@actionType = 'Updated'
					--		,@actionIcon = 'small-tree-modified'
					--		,@details = @strDetails
					--END
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

				-- Inter Company for Quality
				EXEC uspQMInterCompanyPreStageSample @intSampleId
					,'Modified'
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
