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
		,@dtmDemandDate DATETIME
		,@dblQuantity NUMERIC(18, 6)
		,@strUnitMeasure NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@strUserName NVARCHAR(100)
		,@dtmCreated DATETIME
		,@intBookId INT
		,@intSubBookId INT
		,@intDemandHeaderImportId INT
		,@intDemandHeaderId INT
		,@intDemandDetailImportId INT
		,@intItemId INT
		,@intUnitMeasureId INT
		,@intItemUOMId INT
		,@intDemandDetailId INT
		,@intSubstituteItemId INT
		,@strErrorMessage NVARCHAR(MAX)
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
		,intConcurrencyId INT NULL
		,strDemandNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,dtmDate DATETIME NOT NULL
		,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strUserName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,dtmCreated DATETIME NULL
		)
	DECLARE @tblMFDemandDetailImport TABLE (
		intDemandDetailImportId INT NOT NULL IDENTITY
		,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strSubstituteItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dtmDemandDate DATETIME NOT NULL
		,dblQuantity NUMERIC(18, 6) NOT NULL
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		)

	SELECT @strDemandImportDateTimeFormat = IsNULL(strDemandImportDateTimeFormat, 'MM DD YYYY HH:MI')
		,@intMinimumDemandMonth = IsNULL(intMinimumDemandMonth, 12)
		,@intMaximumDemandMonth = IsNULL(intMaximumDemandMonth, 12)
	FROM tblMFCompanyPreference

	SELECT @dtmMinDemandDate = MIN(dtmDemandDate)
		,@dtmMaxDemandDate = Max(dtmDemandDate)
	FROM tblMFDemandImport

	SELECT @intMinMonth = Datepart(mm, @dtmMinDemandDate)
		,@intMaxMonth = Datepart(mm, @dtmMaxDemandDate)
		,@intMinYear = Datepart(yy, @dtmMinDemandDate)
		,@intMaxYear = Datepart(yy, @dtmMaxDemandDate)

	IF @intMinYear <> @intMaxYear
	BEGIN
		SELECT @intMaxMonth = @intMaxMonth + 12
	END

	SELECT @intMonthDiff = @intMaxMonth - @intMinMonth + 1

	IF NOT (
			@intMinimumDemandMonth <= @intMonthDiff
			AND @intMaximumDemandMonth >= @intMinimumDemandMonth
			)
	BEGIN
		RAISERROR (
				'Demand date is not between minimum and maximum month.'
				,16
				,1
				)

		RETURN
	END

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

	INSERT INTO @tblMFDemandHeaderImport (
		strDemandNo
		,strDemandName
		,dtmDate
		,strBook
		,strSubBook
		,strUserName
		,dtmCreated
		)
	SELECT DISTINCT strDemandNo
		,strDemandName
		,CONVERT(DATETIME, dtmDate, @intConvertYear)
		,strBook
		,strSubBook
		,strUserName
		,dtmCreated
	FROM tblMFDemandImport

	SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
	FROM @tblMFDemandHeaderImport

	WHILE @intDemandHeaderImportId IS NOT NULL
	BEGIN
		SELECT @strDemandNo = NULL
			,@strDemandName = NULL
			,@dtmDate = NULL
			,@strBook = NULL
			,@strSubBook = NULL
			,@strItemNo = NULL
			,@strSubstituteItemNo = NULL
			,@dtmDemandDate = NULL
			,@dblQuantity = NULL
			,@strUnitMeasure = NULL
			,@strUserName = NULL
			,@dtmCreated = NULL
			,@intBookId = NULL
			,@intSubBookId = NULL
			,@intDemandHeaderId = NULL

		SELECT @strErrorMessage = ''

		SELECT @strDemandNo = strDemandNo
			,@strDemandName = strDemandName
			,@dtmDate = dtmDate
			,@strBook = strBook
			,@strSubBook = strSubBook
			,@strUserName = strUserName
			,@dtmCreated = dtmCreated
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId = @intDemandHeaderImportId

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

		--SELECT @intUserId=intEntityId
		--FROM tblEMEntity CE
		--JOIN tblEMEntityType ET1 ON ET1.intEntityId = CE.intEntityId
		--WHERE ET1.strType = 'User'
		--	AND CE.strName = @dtmCreated
		--	AND CE.strEntityNo <> ''
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
			)
		SELECT strDemandName
			,strItemNo
			,strSubstituteItemNo
			,CONVERT(DATETIME, dtmDemandDate, @intConvertYear)
			,sum(dblQuantity)
			,strUnitMeasure
			,strLocationName
		FROM tblMFDemandImport
		WHERE strDemandName = @strDemandName
		GROUP BY strDemandName
			,strItemNo
			,strSubstituteItemNo
			,CONVERT(DATETIME, dtmDemandDate, @intConvertYear)
			,strUnitMeasure
			,strLocationName

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

			SELECT @strItemNo = strItemNo
				,@strSubstituteItemNo = strSubstituteItemNo
				,@dtmDemandDate = dtmDemandDate
				,@dblQuantity = dblQuantity
				,@strUnitMeasure = strUnitMeasure
				,@strLocationName = strLocationName
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId = @intDemandDetailImportId

			SELECT @intItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strItemNo

			IF @intItemId IS NULL
				AND @strItemNo <> ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Item ' + @strItemNo + ' is not available. '
			END

			SELECT @intSubstituteItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strSubstituteItemNo

			IF @intSubstituteItemId IS NULL
				AND @strSubstituteItemNo <> ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Substitute Item ' + @strSubstituteItemNo + ' is not available. '
			END

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM tblICUnitMeasure U1
			WHERE U1.strUnitMeasure = @strUnitMeasure

			IF @intUnitMeasureId IS NULL
				AND @strUnitMeasure <> ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not available. '
			END

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = @intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId

			IF @intItemUOMId IS NULL
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not configured for the item ' + @strItemNo + '. '
			END

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationName

			IF @intLocationId IS NULL
				AND @strLocationName <> ''
			BEGIN
				SELECT @strErrorMessage = @strErrorMessage + 'Location Name ' + @strLocationName + ' is not available. '
			END

			IF @strErrorMessage <> ''
			BEGIN
				SELECT @intDemandImportId = NULL

				SELECT @intDemandImportId = intDemandImportId
				FROM tblMFDemandImport
				WHERE strDemandName = @strDemandName
					AND strItemNo = @strItemNo

				IF NOT EXISTS (
						SELECT 1
						FROM tblMFDemandImportError
						WHERE intDemandImportId = @intDemandImportId
						)
				BEGIN
					INSERT INTO tblMFDemandImportError (
						intDemandImportId
						,intConcurrencyId
						,strDemandNo
						,strDemandName
						,dtmDate
						,strBook
						,strSubBook
						,strItemNo
						,strSubstituteItemNo
						,dtmDemandDate
						,dblQuantity
						,strUnitMeasure
						,strLocationName
						,strUserName
						,dtmCreated
						,strErrorMessage
						)
					SELECT @intDemandImportId
						,1 intConcurrencyId
						,@strDemandNo
						,@strDemandName
						,@dtmDate
						,@strBook
						,@strSubBook
						,@strItemNo
						,@strSubstituteItemNo
						,@dtmDemandDate
						,@dblQuantity
						,@strUnitMeasure
						,@strLocationName
						,@strUserName
						,@dtmCreated
						,@strErrorMessage
				END
			END

			SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId > @intDemandDetailImportId
		END

		SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId > @intDemandHeaderImportId
	END

	SELECT intDemandImportId
		,intConcurrencyId
		,strDemandNo
		,strDemandName
		,dtmDate
		,strBook
		,strSubBook
		,strItemNo
		,strSubstituteItemNo
		,dtmDemandDate
		,dblQuantity
		,strUnitMeasure
		,strLocationName
		,strUserName
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
