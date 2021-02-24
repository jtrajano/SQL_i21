CREATE PROCEDURE uspMFValidateAdditionalBasis @intLocationId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intAdditionalBasisImportId INT
		,@intConcurrencyId INT
		,@strItemNo NVARCHAR(50)
		,@dtmAdditionalBasisDate DATETIME
		,@strUnitMeasure NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
		,@intAdditionalBasisHeaderImportId INT
		,@intAdditionalBasisDetailImportId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@strErrorMessage NVARCHAR(MAX)
		,@strDetailErrorMessage NVARCHAR(MAX)
		,@strAdditionalBasisImportDateTimeFormat NVARCHAR(50)
		,@strComment NVARCHAR(MAX)
		,@strOtherChargeItemNo NVARCHAR(50)
		,@dblBasis NUMERIC(18, 6)
		,@strCurrency NVARCHAR(50)
		,@intConvertYear INT
		,@intCurrencyID INT
		,@intOtherChargeItemId INT
	DECLARE @tblMFAdditionalBasisHeaderImport TABLE (
		intAdditionalBasisHeaderImportId INT NOT NULL IDENTITY
		,dtmAdditionalBasisDate DATETIME
		,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,intCreatedUserId INT
		,dtmCreated DATETIME NULL
		)
	DECLARE @tblMFAdditionalBasisDetailImport TABLE (
		intAdditionalBasisDetailImportId INT NOT NULL IDENTITY
		,intAdditionalBasisImportId int
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOtherChargeItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblBasis NUMERIC(18, 6)
		,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	SELECT @strAdditionalBasisImportDateTimeFormat = IsNULL(strDemandImportDateTimeFormat, 'MM DD YYYY HH:MI')
	FROM tblMFCompanyPreference

	SELECT @intConvertYear = 101

	IF (
			@strAdditionalBasisImportDateTimeFormat = 'MM DD YYYY HH:MI'
			OR @strAdditionalBasisImportDateTimeFormat = 'YYYY MM DD HH:MI'
			)
		SELECT @intConvertYear = 101
	ELSE IF (
			@strAdditionalBasisImportDateTimeFormat = 'DD MM YYYY HH:MI'
			OR @strAdditionalBasisImportDateTimeFormat = 'YYYY DD MM HH:MI'
			)
		SELECT @intConvertYear = 103

	BEGIN TRANSACTION

	DELETE
	FROM tblMFAdditionalBasisImportError

	INSERT INTO @tblMFAdditionalBasisHeaderImport (
		dtmAdditionalBasisDate
		,strComment
		,intCreatedUserId
		,dtmCreated
		)
	SELECT DISTINCT dtmAdditionalBasisDate
		,strComment
		,intCreatedUserId
		,dtmCreated
	FROM tblMFAdditionalBasisImport
	ORDER BY dtmCreated

	SELECT @intAdditionalBasisHeaderImportId = MIN(intAdditionalBasisHeaderImportId)
	FROM @tblMFAdditionalBasisHeaderImport

	WHILE @intAdditionalBasisHeaderImportId IS NOT NULL
	BEGIN
		SELECT @dtmAdditionalBasisDate = NULL
			,@strComment = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL

		SELECT @strErrorMessage = ''

		SELECT @dtmAdditionalBasisDate = dtmAdditionalBasisDate
			,@strComment = strComment
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @tblMFAdditionalBasisHeaderImport
		WHERE intAdditionalBasisHeaderImportId = @intAdditionalBasisHeaderImportId

		IF @dtmAdditionalBasisDate IS NULL
			OR @dtmAdditionalBasisDate = '1900-01-01 00:00:00.000'
			OR @dtmAdditionalBasisDate = ''
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'Additional Basis Date cannot be empty. '
		END
		ELSE IF Isdate(@dtmAdditionalBasisDate) = 0
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + + 'Additional Basis Date ' + ltrim(@dtmAdditionalBasisDate) + ' is invalid. '
		END

		DELETE
		FROM @tblMFAdditionalBasisDetailImport

		INSERT INTO @tblMFAdditionalBasisDetailImport (
			intAdditionalBasisImportId
			,strItemNo
			,strOtherChargeItemNo
			,dblBasis
			,strCurrency
			,strUnitMeasure
			)
		SELECT
			intAdditionalBasisImportId 
			,strItemNo
			,strOtherChargeItemNo
			,dblBasis
			,strCurrency
			,strUnitMeasure
		FROM tblMFAdditionalBasisImport
		WHERE dtmAdditionalBasisDate = @dtmAdditionalBasisDate
		ORDER BY intAdditionalBasisImportId

		SELECT @intAdditionalBasisDetailImportId = NULL

		SELECT @intAdditionalBasisDetailImportId = MIN(intAdditionalBasisDetailImportId)
		FROM @tblMFAdditionalBasisDetailImport

		WHILE @intAdditionalBasisDetailImportId IS NOT NULL
		BEGIN
			SELECT @strItemNo = NULL
				,@strOtherChargeItemNo = NULL
				,@dblBasis = NULL
				,@strCurrency = NULL
				,@strUnitMeasure = NULL
				,@intItemId = NULL
				,@intOtherChargeItemId = NULL
				,@intCurrencyID = NULL
				,@intUnitMeasureId = NULL
				,@strDetailErrorMessage = ''
				,@intAdditionalBasisImportId=NULL

			SELECT @intAdditionalBasisImportId=intAdditionalBasisImportId 
				,@strItemNo = strItemNo
				,@strOtherChargeItemNo = strOtherChargeItemNo
				,@dblBasis = dblBasis
				,@strCurrency = strCurrency
				,@strUnitMeasure = strUnitMeasure
			FROM @tblMFAdditionalBasisDetailImport
			WHERE intAdditionalBasisDetailImportId = @intAdditionalBasisDetailImportId

			IF @strItemNo IS NULL
				OR @strItemNo = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Item cannot be empty. '
			END

			SELECT @intItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strItemNo

			IF @intItemId IS NULL
				AND @strItemNo <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Item ' + @strItemNo + ' is not available. '
			END

			IF @strOtherChargeItemNo IS NULL
				OR @strOtherChargeItemNo = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Other Charge Item cannot be empty. '
			END

			SELECT @intOtherChargeItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strOtherChargeItemNo

			IF @intOtherChargeItemId IS NULL
				AND @strOtherChargeItemNo <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Other Charge Item ' + @strOtherChargeItemNo + ' is not available. '
			END

			IF IsNumeric(@dblBasis) = 0
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Basis ' + ltrim(@dblBasis) + ' is invalid. '
			END

			IF @strCurrency IS NULL
				OR @strCurrency = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Currency cannot be empty. '
			END

			SELECT @intCurrencyID = intCurrencyID
			FROM tblSMCurrency U1
			WHERE U1.strCurrency = @strCurrency

			IF @intCurrencyID IS NULL
				AND @strCurrency <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Currency ' + @strCurrency + ' is not available. '
			END

			IF @strUnitMeasure IS NULL
				OR @strUnitMeasure = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure cannot be empty. '
			END

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM tblICUnitMeasure U1
			WHERE U1.strUnitMeasure = @strUnitMeasure

			IF @intUnitMeasureId IS NULL
				AND @strUnitMeasure <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not available. '
			END

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = @intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId

			IF @intItemUOMId IS NULL
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not configured for the other charge item ' + @strItemNo + '. '
			END

			--SELECT @intLocationId = intCompanyLocationId
			--FROM tblSMCompanyLocation
			--WHERE strLocationName = @strLocationName
			--IF @intLocationId IS NULL
			--	AND @strLocationName <> ''
			--BEGIN
			--	SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Location Name ' + @strLocationName + ' is not available. '
			--END
			SELECT @strDetailErrorMessage = @strErrorMessage + @strDetailErrorMessage

			IF @strDetailErrorMessage <> ''
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblMFAdditionalBasisImportError
						WHERE intAdditionalBasisImportId = @intAdditionalBasisImportId
						)
				BEGIN
					INSERT INTO tblMFAdditionalBasisImportError (
						intAdditionalBasisImportId
						,intConcurrencyId
						,dtmAdditionalBasisDate
						,strComment
						,strItemNo
						,strOtherChargeItemNo
						,dblBasis
						,strCurrency
						,strUnitMeasure
						,intCreatedUserId
						,dtmCreated
						,strErrorMessage
						)
					SELECT @intAdditionalBasisImportId
						,1 intConcurrencyId
						,@dtmAdditionalBasisDate
						,@strComment
						,@strItemNo
						,@strOtherChargeItemNo
						,@dblBasis
						,@strCurrency
						,@strUnitMeasure
						,@intCreatedUserId
						,@dtmCreated
						,@strDetailErrorMessage
				END
			END

			SELECT @intAdditionalBasisDetailImportId = MIN(intAdditionalBasisDetailImportId)
			FROM @tblMFAdditionalBasisDetailImport
			WHERE intAdditionalBasisDetailImportId > @intAdditionalBasisDetailImportId
		END

		DELETE
		FROM @tblMFAdditionalBasisHeaderImport
		WHERE dtmAdditionalBasisDate = @dtmAdditionalBasisDate

		SELECT @intAdditionalBasisHeaderImportId = MIN(intAdditionalBasisHeaderImportId)
		FROM @tblMFAdditionalBasisHeaderImport
		WHERE intAdditionalBasisHeaderImportId > @intAdditionalBasisHeaderImportId
	END

	SELECT intAdditionalBasisImportErrorId
		,intAdditionalBasisImportId
		,intConcurrencyId
		,dtmAdditionalBasisDate
		,strComment
		,strItemNo
		,strOtherChargeItemNo
		,dblBasis
		,strCurrency
		,strUnitMeasure
		,intCreatedUserId
		,dtmCreated
		,strErrorMessage
	FROM tblMFAdditionalBasisImportError
	ORDER BY intAdditionalBasisImportErrorId

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
