CREATE PROCEDURE uspIPProcessLotSampleImport @strSampleTypeName NVARCHAR(50) = ''
	,@strSampleStatus NVARCHAR(30) = ''
	,@strQuantityUOM NVARCHAR(50) = ''
	,@strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	--SET ANSI_WARNINGS OFF
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strPreviousErrMsg NVARCHAR(MAX)
	DECLARE @intLotSampleImportId INT
		,@strSampleNumber NVARCHAR(30)
		,@strSampleRefNo NVARCHAR(30)
		,@dtmSampleReceivedDate DATETIME
		,@strLotNumber NVARCHAR(50)
		,@strStorageUnit NVARCHAR(50)
		,@dblRepresentingQty NUMERIC(18, 6)
		,@strComment NVARCHAR(MAX)
		,@strProperty1 NVARCHAR(MAX)
		,@strProperty2 NVARCHAR(MAX)
		,@strProperty3 NVARCHAR(MAX)
		,@strProperty4 NVARCHAR(MAX)
		,@strProperty5 NVARCHAR(MAX)
		,@strProperty6 NVARCHAR(MAX)
		,@strProperty7 NVARCHAR(MAX)
		,@strProperty8 NVARCHAR(MAX)
		,@strProperty9 NVARCHAR(MAX)
		,@strProperty10 NVARCHAR(MAX)
		,@strProperty11 NVARCHAR(MAX)
		,@strProperty12 NVARCHAR(MAX)
		,@strProperty13 NVARCHAR(MAX)
		,@strProperty14 NVARCHAR(MAX)
		,@strProperty15 NVARCHAR(MAX)
		,@strProperty16 NVARCHAR(MAX)
		,@strProperty17 NVARCHAR(MAX)
		,@strProperty18 NVARCHAR(MAX)
		,@strProperty19 NVARCHAR(MAX)
		,@strProperty20 NVARCHAR(MAX)
	DECLARE @intValidDate INT
		,@strSampleImportDateTimeFormat NVARCHAR(50)
		,@intConvertYear INT
		,@intShiftId INT
		,@dtmBusinessDate DATETIME
		,@dtmCurrentDate DATETIME = GETDATE()
	DECLARE @intLotId INT
		,@intItemId INT
		,@intCategoryId INT
		,@intLocationId INT
		,@intSampleTypeId INT
		,@intSampleStatusId INT
		,@intRepresentingUOMId INT
		,@intStorageLocationId INT
		,@intCompanyLocationSubLocationId INT
		,@intProductId INT
		,@intLotStatusId INT
		,@strParentLotNumber NVARCHAR(50)
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intContractHeaderId INT
		,@intEntityId INT
		,@intContractDetailId INT
		,@intItemContractId INT
		,@intCountryID INT
		,@strCountry NVARCHAR(100)
		,@intInventoryReceiptId INT
		,@strContainerNumber NVARCHAR(100)
		,@intLoadId INT
		,@intLoadDetailId INT
		,@intLoadContainerId INT
		,@intLoadDetailContainerLinkId INT

	IF ISNULL(@strSampleTypeName, '') = ''
		SELECT @strSampleTypeName = 'Quality Sample'

	IF ISNULL(@strSampleStatus, '') = ''
		SELECT @strSampleStatus = 'Approved'

	IF ISNULL(@strQuantityUOM, '') = ''
		SELECT @strQuantityUOM = 'KG'

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

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @intLotSampleImportId = MIN(intLotSampleImportId)
	FROM tblQMLotSampleImport

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(strSampleNumber, '') + ', '
	FROM tblQMLotSampleImport

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	SELECT @strInfo2 = @strInfo2 + ISNULL(strLotNumber, '') + ', '
	FROM (
		SELECT DISTINCT strLotNumber
		FROM tblQMLotSampleImport
		) AS DT

	IF Len(@strInfo2) > 0
	BEGIN
		SELECT @strInfo2 = Left(@strInfo2, Len(@strInfo2) - 1)
	END

	WHILE (@intLotSampleImportId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @strSampleNumber = NULL
				,@strSampleRefNo = NULL
				,@dtmSampleReceivedDate = NULL
				,@strLotNumber = NULL
				,@strStorageUnit = NULL
				,@dblRepresentingQty = NULL
				,@strComment = NULL
				,@strProperty1 = NULL
				,@strProperty2 = NULL
				,@strProperty3 = NULL
				,@strProperty4 = NULL
				,@strProperty5 = NULL
				,@strProperty6 = NULL
				,@strProperty7 = NULL
				,@strProperty8 = NULL
				,@strProperty9 = NULL
				,@strProperty10 = NULL
				,@strProperty11 = NULL
				,@strProperty12 = NULL
				,@strProperty13 = NULL
				,@strProperty14 = NULL
				,@strProperty15 = NULL
				,@strProperty16 = NULL
				,@strProperty17 = NULL
				,@strProperty18 = NULL
				,@strProperty19 = NULL
				,@strProperty20 = NULL

			SELECT @intShiftId = NULL
				,@dtmBusinessDate = NULL
				,@dtmCurrentDate = NULL
				,@strPreviousErrMsg = ''

			SELECT @intLotId = NULL
				,@intItemId = NULL
				,@intCategoryId = NULL
				,@intLocationId = NULL
				,@intSampleTypeId = NULL
				,@intSampleStatusId = NULL
				,@intRepresentingUOMId = NULL
				,@intStorageLocationId = NULL
				,@intCompanyLocationSubLocationId = NULL
				,@intProductId = NULL
				,@intLotStatusId = NULL
				,@strParentLotNumber = NULL
				,@intProductTypeId = NULL
				,@intProductValueId = NULL
				,@intContractHeaderId = NULL
				,@intEntityId = NULL
				,@intContractDetailId = NULL
				,@intItemContractId = NULL
				,@intCountryID = NULL
				,@strCountry = NULL
				,@intInventoryReceiptId = NULL
				,@strContainerNumber = NULL
				,@intLoadId = NULL
				,@intLoadDetailId = NULL
				,@intLoadContainerId = NULL
				,@intLoadDetailContainerLinkId = NULL

			SELECT @strSampleRefNo = strSampleNumber
				,@dtmSampleReceivedDate = CONVERT(DATETIME, dtmSampleReceivedDate, @intConvertYear)
				,@strLotNumber = strLotNumber
				,@strStorageUnit = strStorageUnit
				,@dblRepresentingQty = dblRepresentingQty
				,@strComment = strComment
				,@strProperty1 = strProperty1
				,@strProperty2 = strProperty2
				,@strProperty3 = strProperty3
				,@strProperty4 = strProperty4
				,@strProperty5 = strProperty5
				,@strProperty6 = strProperty6
				,@strProperty7 = strProperty7
				,@strProperty8 = strProperty8
				,@strProperty9 = strProperty9
				,@strProperty10 = strProperty10
				,@strProperty11 = strProperty11
				,@strProperty12 = strProperty12
				,@strProperty13 = strProperty13
				,@strProperty14 = strProperty14
				,@strProperty15 = strProperty15
				,@strProperty16 = strProperty16
				,@strProperty17 = strProperty17
				,@strProperty18 = strProperty18
				,@strProperty19 = strProperty19
				,@strProperty20 = strProperty20
			FROM tblQMLotSampleImport
			WHERE intLotSampleImportId = @intLotSampleImportId

			-- Sample No
			IF ISNULL(@strSampleRefNo, '') = ''
				SELECT @strPreviousErrMsg += 'Invalid Sample No. '
			ELSE
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblQMSample WITH (NOLOCK)
						WHERE strSampleRefNo = @strSampleRefNo
						)
					SELECT @strPreviousErrMsg += 'Sample No already exists. '
			END

			-- Sample Date
			IF ISNULL(@dtmSampleReceivedDate, '') = ''
				SELECT @strPreviousErrMsg += 'Invalid Sample Date. '
			ELSE
			BEGIN
				IF ISDATE(@dtmSampleReceivedDate) = 0
					SELECT @strPreviousErrMsg += 'Invalid Sample Date. '
				ELSE
				BEGIN
					IF CONVERT(DATE, @dtmSampleReceivedDate) > CONVERT(DATE, GETDATE())
						SELECT @strPreviousErrMsg += 'Sample Date cannot be Future Date. '
				END
			END

			-- Sample Type
			SELECT @intSampleTypeId = intSampleTypeId
			FROM tblQMSampleType WITH (NOLOCK)
			WHERE strSampleTypeName = @strSampleTypeName

			IF @intSampleTypeId IS NULL
				SELECT @strPreviousErrMsg += 'Invalid Sample Type. '

			-- Quantity
			IF ISNULL(@dblRepresentingQty, 0) = 0
				SELECT @strPreviousErrMsg += 'Invalid Quantity. '
			ELSE
			BEGIN
				IF ISNUMERIC(@dblRepresentingQty) = 0
					SELECT @strPreviousErrMsg += 'Invalid Quantity. '
				ELSE
				BEGIN
					IF @dblRepresentingQty <= 0
						SELECT @strPreviousErrMsg += 'Quantity should be greater than 0. '
				END
			END

			-- Sample Status
			SELECT @intSampleStatusId = intSampleStatusId
			FROM tblQMSampleStatus WITH (NOLOCK)
			WHERE strStatus = @strSampleStatus

			IF @intSampleStatusId IS NULL
				SELECT @strPreviousErrMsg += 'Invalid Sample Status. '

			-- Quantity UOM
			SELECT @intRepresentingUOMId = intUnitMeasureId
			FROM tblICUnitMeasure WITH (NOLOCK)
			WHERE strUnitMeasure = @strQuantityUOM

			IF @intRepresentingUOMId IS NULL
				SELECT @strPreviousErrMsg += 'Invalid Quantity UOM. '
			ELSE
			BEGIN
				IF ISNULL(@intItemId, 0) > 0
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICItemUOM IUOM WITH (NOLOCK)
							JOIN tblICUnitMeasure UOM WITH (NOLOCK) ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
							WHERE IUOM.intItemId = @intItemId
								AND UOM.strUnitMeasure = @strQuantityUOM
							)
						SELECT @strPreviousErrMsg += 'Quantity UOM is not available in the configured Item UOM. '
				END
			END

			-- Storage Unit
			IF ISNULL(@strStorageUnit, '') <> ''
			BEGIN
				SELECT @intStorageLocationId = intStorageLocationId
				FROM tblICStorageLocation WITH (NOLOCK)
				WHERE strName = @strStorageUnit

				IF @intStorageLocationId IS NULL
					SELECT @strPreviousErrMsg += 'Invalid Storage Unit. '
			END

			-- Lot Number
			IF ISNULL(@strLotNumber, '') = ''
				SELECT @strPreviousErrMsg += 'Invalid Lot Number. '
			ELSE
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblICLot WITH (NOLOCK)
						WHERE strLotNumber = @strLotNumber
							AND dblQty > 0
						)
					SELECT @strPreviousErrMsg += 'Invalid Lot Number. '
				ELSE
				BEGIN
					SELECT TOP 1 @intLotId = L.intLotId
						,@intLocationId = L.intLocationId
						,@intItemId = L.intItemId
						,@intCategoryId = I.intCategoryId
						,@intCompanyLocationSubLocationId = L.intSubLocationId
						,@intStorageLocationId = L.intStorageLocationId
						,@intLotStatusId = L.intLotStatusId
						,@strParentLotNumber = PL.strParentLotNumber
						,@intProductTypeId = 6
						,@intProductValueId = L.intLotId
					FROM tblICLot L WITH (NOLOCK)
					JOIN tblICParentLot PL WITH (NOLOCK) ON PL.intParentLotId = L.intParentLotId
					JOIN tblICItem I WITH (NOLOCK) ON I.intItemId = L.intItemId
					WHERE L.strLotNumber = @strLotNumber
						AND L.dblQty > 0
					ORDER BY L.intLotId DESC

					SELECT @intContractHeaderId = CH.intContractHeaderId
						,@intEntityId = CH.intEntityId
						,@intContractDetailId = CD.intContractDetailId
						,@intItemContractId = CD.intItemContractId
						,@intCountryID = ISNULL(CA.intCountryID, IC.intCountryId)
						,@strCountry = ISNULL(CA.strDescription, CG.strCountry)
						,@intInventoryReceiptId = RI.intInventoryReceiptId
						,@strContainerNumber = LC.strContainerNumber
						,@intLoadId = LD.intLoadId
						,@intLoadDetailId = LD.intLoadDetailId
						,@intLoadContainerId = LC.intLoadContainerId
						,@intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					FROM tblICInventoryReceiptItemLot RIL
					JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptItemId = RIL.intInventoryReceiptItemId
						AND RIL.intLotId = @intLotId
					JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = RI.intContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICItem IM ON IM.intItemId = CD.intItemId
					LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
					LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
					LEFT JOIN tblSMCountry CG ON CG.intCountryID = IC.intCountryId
					LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = RI.intContainerId
					LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
					LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId

					IF @intContractDetailId IS NULL
						SELECT @strPreviousErrMsg += 'Contract is not available. '
				END
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

				IF @intProductId IS NULL
					SELECT @strPreviousErrMsg += 'Quality Template is not configured for the Item and Sample Type. '
			END

			-- Business Date and Shift Id
			SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmCurrentDate, @intLocationId)

			SELECT @intShiftId = intShiftId
			FROM tblMFShift
			WHERE intLocationId = @intLocationId
				AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
					AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

			-- Property Validation - Pending
			-- After all validation, insert / update the error
			IF ISNULL(@strPreviousErrMsg, '') <> ''
			BEGIN
				RAISERROR (
						@strPreviousErrMsg
						,16
						,1
						)
			END

			BEGIN TRAN

			--New Sample Creation
			--EXEC uspMFGeneratePatternId @intCategoryId = NULL
			--	,@intItemId = NULL
			--	,@intManufacturingId = NULL
			--	,@intSubLocationId = NULL
			--	,@intLocationId = @intLocationId
			--	,@intOrderTypeId = NULL
			--	,@intBlendRequirementId = NULL
			--	,@intPatternCode = 62
			--	,@ysnProposed = 0
			--	,@strPatternString = @strSampleNumber OUTPUT
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

			-- Sample Insertion - Pending
			MOVE_TO_ARCHIVE:

			INSERT INTO tblQMLotSampleImportArchive (
				intLotSampleImportId
				,intConcurrencyId
				,strSampleNumber
				,dtmSampleReceivedDate
				,strLotNumber
				,strStorageUnit
				,dblRepresentingQty
				,strComment
				,strProperty1
				,strProperty2
				,strProperty3
				,strProperty4
				,strProperty5
				,strProperty6
				,strProperty7
				,strProperty8
				,strProperty9
				,strProperty10
				,strProperty11
				,strProperty12
				,strProperty13
				,strProperty14
				,strProperty15
				,strProperty16
				,strProperty17
				,strProperty18
				,strProperty19
				,strProperty20
				,ysnError
				,strErrorMsg
				)
			SELECT intLotSampleImportId
				,intConcurrencyId
				,strSampleNumber
				,dtmSampleReceivedDate
				,strLotNumber
				,strStorageUnit
				,dblRepresentingQty
				,strComment
				,strProperty1
				,strProperty2
				,strProperty3
				,strProperty4
				,strProperty5
				,strProperty6
				,strProperty7
				,strProperty8
				,strProperty9
				,strProperty10
				,strProperty11
				,strProperty12
				,strProperty13
				,strProperty14
				,strProperty15
				,strProperty16
				,strProperty17
				,strProperty18
				,strProperty19
				,strProperty20
				,0
				,'Success'
			FROM tblQMLotSampleImport
			WHERE intLotSampleImportId = @intLotSampleImportId

			DELETE
			FROM tblQMLotSampleImport
			WHERE intLotSampleImportId = @intLotSampleImportId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()

			INSERT INTO tblQMLotSampleImportArchive (
				intLotSampleImportId
				,intConcurrencyId
				,strSampleNumber
				,dtmSampleReceivedDate
				,strLotNumber
				,strStorageUnit
				,dblRepresentingQty
				,strComment
				,strProperty1
				,strProperty2
				,strProperty3
				,strProperty4
				,strProperty5
				,strProperty6
				,strProperty7
				,strProperty8
				,strProperty9
				,strProperty10
				,strProperty11
				,strProperty12
				,strProperty13
				,strProperty14
				,strProperty15
				,strProperty16
				,strProperty17
				,strProperty18
				,strProperty19
				,strProperty20
				,ysnError
				,strErrorMsg
				)
			SELECT intLotSampleImportId
				,intConcurrencyId
				,strSampleNumber
				,dtmSampleReceivedDate
				,strLotNumber
				,strStorageUnit
				,dblRepresentingQty
				,strComment
				,strProperty1
				,strProperty2
				,strProperty3
				,strProperty4
				,strProperty5
				,strProperty6
				,strProperty7
				,strProperty8
				,strProperty9
				,strProperty10
				,strProperty11
				,strProperty12
				,strProperty13
				,strProperty14
				,strProperty15
				,strProperty16
				,strProperty17
				,strProperty18
				,strProperty19
				,strProperty20
				,1
				,@ErrMsg
			FROM tblQMLotSampleImport
			WHERE intLotSampleImportId = @intLotSampleImportId

			DELETE
			FROM tblQMLotSampleImport
			WHERE intLotSampleImportId = @intLotSampleImportId
		END CATCH

		SELECT @intLotSampleImportId = MIN(intLotSampleImportId)
		FROM tblQMLotSampleImport
		WHERE intLotSampleImportId > @intLotSampleImportId
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
