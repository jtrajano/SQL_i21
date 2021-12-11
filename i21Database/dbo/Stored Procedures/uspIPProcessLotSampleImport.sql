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
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intUserId INT
		,@dtmDateCreated DATETIME = GETDATE()
		,@strError NVARCHAR(MAX)
	DECLARE @intLotSampleImportId INT
		,@strSampleNumber NVARCHAR(30)
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
		,@strNewSampleNumber NVARCHAR(30)

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

			SELECT @strNewSampleNumber = NULL

			SELECT @strSampleNumber = strSampleNumber
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

			--SELECT @intItemId = intItemId
			--FROM dbo.tblICItem WITH (NOLOCK)
			--WHERE strItemNo = @strItemNo
			--IF @intCompanyLocationId IS NULL
			--BEGIN
			--	SELECT @strError = 'Company Location not found.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--IF ISNULL(@strItemNo, '') = ''
			--BEGIN
			--	SELECT @strError = 'Item No cannot be blank.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
			--IF ISNULL(@strOrigin, '') <> ''
			--	AND @intCountryID IS NULL
			--BEGIN
			--	SELECT @strError = 'Origin not found.'
			--	RAISERROR (
			--			@strError
			--			,16
			--			,1
			--			)
			--END
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
			--	,@strPatternString = @strNewSampleNumber OUTPUT
			IF EXISTS (
					SELECT 1
					FROM tblQMSample
					WHERE strSampleNumber = @strNewSampleNumber
					)
			BEGIN
				RAISERROR (
						'Sample number already exists. '
						,16
						,1
						)
			END

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
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

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
