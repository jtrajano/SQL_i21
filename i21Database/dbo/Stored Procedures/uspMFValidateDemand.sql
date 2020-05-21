CREATE PROCEDURE uspMFValidateDemand @intLocationId INT = NULL
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intDemandImportId INT
		,@intConcurrencyId INT
		,@strDemandNo NVARCHAR(50)
		,@strDemandName NVARCHAR(100)
		,@dtmDate DATETIME
		,@strBook NVARCHAR(100)
		,@strSubBook NVARCHAR(100)
		,@strItemNo NVARCHAR(50)
		,@strSubstituteItemNo NVARCHAR(50)
		,@dtmDemandDate NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strUnitMeasure NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@intCreatedUserId INT
		,@dtmCreated DATETIME
		,@intBookId INT
		,@intSubBookId INT
		,@intDemandHeaderImportId INT
		,@intDemandDetailImportId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intDemandDetailId INT
		,@intSubstituteItemId INT
		,@strErrorMessage NVARCHAR(MAX)
		,@strDetailErrorMessage NVARCHAR(MAX)
		,@dtmMinDemandDate DATETIME
		,@dtmMaxDemandDate DATETIME
		,@intMinMonth INT
		,@intMaxMonth INT
		,@intMinYear INT
		,@intMaxYear INT
		,@intMinimumDemandMonth INT
		,@intMaximumDemandMonth INT
		,@intMonthDiff INT
		,@strDemandImportDateTimeFormat NVARCHAR(50)
		,@intConvertYear INT
	DECLARE @tblMFDemandHeaderImport TABLE (
		intDemandHeaderImportId INT NOT NULL IDENTITY
		,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dtmDate DATETIME
		,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intCreatedUserId INT
		,dtmCreated DATETIME NULL
		)
	DECLARE @tblMFDemandDetailImport TABLE (
		intDemandDetailImportId INT NOT NULL IDENTITY
		,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strSubstituteItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmDemandDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblQuantity NUMERIC(18, 6)
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,intDemandImportId INT
		)

	SELECT @strDemandImportDateTimeFormat = IsNULL(strDemandImportDateTimeFormat, 'MM DD YYYY HH:MI')
		,@intMinimumDemandMonth = IsNULL(intMinimumDemandMonth, 12)
		,@intMaximumDemandMonth = IsNULL(intMaximumDemandMonth, 12)
	FROM tblMFCompanyPreference

	SELECT @intConvertYear = 101

	IF (
			@strDemandImportDateTimeFormat = 'MM DD YYYY HH:MI'
			OR @strDemandImportDateTimeFormat = 'YYYY MM DD HH:MI'
			)
		SELECT @intConvertYear = 101
	ELSE IF (
			@strDemandImportDateTimeFormat = 'DD MM YYYY HH:MI'
			OR @strDemandImportDateTimeFormat = 'YYYY DD MM HH:MI'
			)
		SELECT @intConvertYear = 103

	BEGIN TRANSACTION

	DELETE
	FROM tblMFDemandImportError

	INSERT INTO @tblMFDemandHeaderImport (
		strDemandName
		,dtmDate
		,strBook
		,strSubBook
		,intCreatedUserId
		,dtmCreated
		)
	SELECT DISTINCT strDemandName
		,CONVERT(NVARCHAR, GETDATE(), @intConvertYear)
		,strBook
		,strSubBook
		,intCreatedUserId
		,dtmCreated
	FROM tblMFDemandImport
	ORDER BY dtmCreated

	SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
	FROM @tblMFDemandHeaderImport

	WHILE @intDemandHeaderImportId IS NOT NULL
	BEGIN
		SELECT @strDemandName = NULL
			,@dtmDate = NULL
			,@strBook = NULL
			,@strSubBook = NULL
			,@strItemNo = NULL
			,@strSubstituteItemNo = NULL
			,@dtmDemandDate = NULL
			,@dblQuantity = NULL
			,@strUnitMeasure = NULL
			,@intCreatedUserId = NULL
			,@dtmCreated = NULL
			,@intBookId = NULL
			,@intSubBookId = NULL

		SELECT @strErrorMessage = ''

		SELECT @strDemandName = strDemandName
			,@dtmDate = dtmDate
			,@strBook = strBook
			,@strSubBook = strSubBook
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId = @intDemandHeaderImportId

		IF EXISTS (
				SELECT Count(*)
				FROM (
					SELECT DISTINCT strBook
						,strSubBook
					FROM @tblMFDemandHeaderImport
					WHERE strDemandName = @strDemandName
					) AS DT
				HAVING count(*) > 1
				)
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'All the book and sub book name should be same for the demand name ' + @strDemandName + '. '
		END

		IF @strDemandName IS NULL
			OR @strDemandName = ''
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'Demand Name cannot be empty. '
		END

		IF EXISTS (
				SELECT *
				FROM tblMFDemandHeader
				WHERE strDemandName = @strDemandName
				)
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'Demand Name already exists. '
		END

		SELECT @intBookId = intBookId
		FROM tblCTBook
		WHERE strBook = @strBook

		IF @intBookId IS NULL
			AND @strBook <> ''
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'Book ' + @strBook + ' is not available. '
		END

		SELECT @intSubBookId = intSubBookId
		FROM tblCTSubBook
		WHERE strSubBook = @strSubBook

		IF @intSubBookId IS NULL
			AND @strSubBook <> ''
		BEGIN
			SELECT @strErrorMessage = @strErrorMessage + 'Sub Book ' + @strSubBook + ' is not available. '
		END

		DELETE
		FROM @tblMFDemandDetailImport

		INSERT INTO @tblMFDemandDetailImport (
			strDemandName
			,strItemNo
			,strSubstituteItemNo
			,dtmDemandDate
			,dblQuantity
			,strUnitMeasure
			,strLocationName
			,intDemandImportId
			)
		SELECT strDemandName
			,strItemNo
			,strSubstituteItemNo
			,dtmDemandDate
			,dblQuantity
			,strUnitMeasure
			,strLocationName
			,intDemandImportId
		FROM tblMFDemandImport
		WHERE strDemandName = @strDemandName
		ORDER BY intDemandImportId

		SELECT @intDemandDetailImportId = NULL

		SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
		FROM @tblMFDemandDetailImport

		WHILE @intDemandDetailImportId IS NOT NULL
		BEGIN
			SELECT @strItemNo = NULL
				,@strSubstituteItemNo = NULL
				,@dtmDemandDate = NULL
				,@dblQuantity = NULL
				,@strUnitMeasure = NULL
				,@strLocationName = NULL
				,@intSubstituteItemId = NULL
				,@intItemId = NULL
				,@intUnitMeasureId = NULL
				,@intLocationId = NULL
				,@strDetailErrorMessage = ''
				,@intDemandImportId = NULL
				,@dtmMinDemandDate = NULL
				,@dtmMaxDemandDate = NULL
				,@intMinMonth = NULL
				,@intMaxMonth = NULL
				,@intMinYear = NULL
				,@intMaxYear = NULL

			SELECT @strItemNo = strItemNo
				,@strSubstituteItemNo = strSubstituteItemNo
				,@dtmDemandDate = dtmDemandDate
				,@dblQuantity = dblQuantity
				,@strUnitMeasure = strUnitMeasure
				,@strLocationName = strLocationName
				,@intDemandImportId = intDemandImportId
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId = @intDemandDetailImportId

			IF (
					SELECT Count(*)
					FROM @tblMFDemandDetailImport
					WHERE strItemNo = @strItemNo
						AND IsNULL(strSubstituteItemNo, '') = IsNULL(@strSubstituteItemNo, IsNULL(strSubstituteItemNo, ''))
						AND IsNULL(strLocationName, '') = IsNULL(@strLocationName, IsNULL(strLocationName, ''))
						AND Datepart(mm, Convert(datetime,dtmDemandDate,@intConvertYear)) = Datepart(mm, Convert(datetime,@dtmDemandDate,@intConvertYear))
					) > 1
			BEGIN
				IF @strSubstituteItemNo <> ''
				BEGIN
					SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'The item and substitute item ' + @strItemNo + ' and ' + @strSubstituteItemNo + ' is available multiple times for the same month. '
				END
				ELSE
				BEGIN
					SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'The item ' + @strItemNo + ' is available multiple times for the same month. '
				END
			END

			SELECT @dtmMinDemandDate = MIN(Convert(datetime,dtmDemandDate,@intConvertYear))
				,@dtmMaxDemandDate = MAX(Convert(datetime,dtmDemandDate,@intConvertYear))
			FROM @tblMFDemandDetailImport
			WHERE strItemNo = @strItemNo
				AND IsNULL(strSubstituteItemNo, '') = IsNULL(@strSubstituteItemNo, IsNULL(strSubstituteItemNo, ''))
				AND IsNULL(strLocationName, '') = IsNULL(@strLocationName, IsNULL(strLocationName, ''))

			SELECT @intMinMonth = Datepart(mm, @dtmMinDemandDate)
				,@intMaxMonth = Datepart(mm, @dtmMaxDemandDate)
				,@intMinYear = Datepart(yy, @dtmMinDemandDate)
				,@intMaxYear = Datepart(yy, @dtmMaxDemandDate)

			IF @intMinYear <> @intMaxYear
			BEGIN
				SELECT @intMaxMonth = @intMaxMonth + 12
			END

			SELECT @intMonthDiff = @intMaxMonth - @intMinMonth + 1

			IF (
					@intMonthDiff > @intMaximumDemandMonth
					OR @intMonthDiff < @intMinimumDemandMonth
					) and IsNULL(@strSubstituteItemNo,'')=''
			BEGIN
					SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand date is not between minimum and maximum month for the item ' + @strItemNo + ' '
			END

			IF IsNumeric(@dblQuantity) = 0
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Quantity ' + ltrim(@dblQuantity) + ' is invalid. '
			END

			IF @dblQuantity < 0
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Quantity cannot be negative. '
			END

			IF @dtmDemandDate IS NULL
				OR @dtmDemandDate = '1900-01-01 00:00:00.000'
				OR @dtmDemandDate = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand Date cannot be empty. '
			END
			ELSE IF Isdate(@dtmDemandDate) = 0
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand Date ' + ltrim(@dtmDemandDate) + ' is invalid. '
			END

			IF @strItemNo IS NULL
				OR @strItemNo = ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Item is not available. '
			END

			SELECT @intItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strItemNo

			IF @intItemId IS NULL
				AND @strItemNo <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Item ' + @strItemNo + ' is not available. '
			END

			SELECT @intSubstituteItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strSubstituteItemNo

			IF @intSubstituteItemId IS NULL
				AND @strSubstituteItemNo <> ''
				AND @intItemId IS NOT NULL
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Substitute Item ' + @strSubstituteItemNo + ' is not available. '
			END
			ELSE IF @intSubstituteItemId IS NOT NULL
				AND NOT EXISTS (
					SELECT *
					FROM vyuMFGetDemandSubstituteItem
					WHERE intMainItemId = @intItemId
						AND intItemId = @intSubstituteItemId
					)
				AND @intItemId IS NOT NULL
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Substitute item ' + @strSubstituteItemNo + ' is not configured for the item ' + @strItemNo + '. '
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
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not configured for the item ' + @strItemNo + '. '
			END

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationName

			IF @intLocationId IS NULL
				AND @strLocationName <> ''
			BEGIN
				SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Location Name ' + @strLocationName + ' is not available. '
			END

			SELECT @strDetailErrorMessage = @strErrorMessage + @strDetailErrorMessage

			IF @strDetailErrorMessage <> ''
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblMFDemandImportError
						WHERE intDemandImportId = @intDemandImportId
						)
				BEGIN
					INSERT INTO tblMFDemandImportError (
						intDemandImportId
						,intConcurrencyId
						,strDemandName
						,strBook
						,strSubBook
						,strItemNo
						,strSubstituteItemNo
						,dtmDemandDate
						,dblQuantity
						,strUnitMeasure
						,strLocationName
						,dtmCreated
						,strErrorMessage
						,intCreatedUserId
						)
					SELECT @intDemandImportId
						,1 intConcurrencyId
						,@strDemandName
						,@strBook
						,@strSubBook
						,@strItemNo
						,@strSubstituteItemNo
						,@dtmDemandDate
						,@dblQuantity
						,@strUnitMeasure
						,@strLocationName
						,@dtmCreated
						,@strDetailErrorMessage
						,@intCreatedUserId
				END
			END

			SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId > @intDemandDetailImportId
		END

		DELETE
		FROM @tblMFDemandHeaderImport
		WHERE strDemandName = @strDemandName

		SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId > @intDemandHeaderImportId
	END

	SELECT intDemandImportErrorId
		,intDemandImportId
		,intConcurrencyId
		,strDemandName
		,strBook
		,strSubBook
		,strItemNo
		,strSubstituteItemNo
		,dtmDemandDate
		,dblQuantity
		,strUnitMeasure
		,strLocationName
		,intCreatedUserId
		,dtmCreated
		,strErrorMessage
	FROM tblMFDemandImportError

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
