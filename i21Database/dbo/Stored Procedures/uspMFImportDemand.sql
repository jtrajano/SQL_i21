CREATE PROCEDURE uspMFImportDemand @intLocationId INT = NULL
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
		,@strDemandImportDateTimeFormat NVARCHAR(50)
		,@intConvertYear INT
		,@dtmMinDemandDate DATETIME
		,@dtmMaxDemandDate DATETIME
		,@intMinMonth INT
		,@intMaxMonth INT
		,@intMinYear INT
		,@intMaxYear INT
		,@intMinimumDemandMonth INT
		,@intMaximumDemandMonth INT
		,@intMonthDiff int
		,@dblDemandGrowthPerc  NUMERIC(18,6)
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

	SELECT @strDemandImportDateTimeFormat = IsNULL(strDemandImportDateTimeFormat,'MM DD YYYY HH:MI')
		,@intMinimumDemandMonth = IsNULL(intMinimumDemandMonth,12)
		,@intMaximumDemandMonth = IsNULL(intMaximumDemandMonth,12)
		,@dblDemandGrowthPerc=IsNULL(dblDemandGrowthPerc,0)
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
			,@strUserName = NULL
			,@dtmCreated = NULL
			,@intBookId = NULL
			,@intSubBookId = NULL
			,@intDemandHeaderId = NULL

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

		SELECT @intSubBookId = intSubBookId
		FROM tblCTSubBook
		WHERE strSubBook = @strSubBook

		SELECT @intDemandHeaderId = intDemandHeaderId
		FROM tblMFDemandHeader
		WHERE strDemandName = @strDemandName

		IF @intDemandHeaderId IS NULL
		BEGIN
			IF @strDemandNo IS NULL
				OR @strDemandNo = ''
				EXEC uspCTGetStartingNumber 'Demand'
					,@strDemandNo OUTPUT

			INSERT INTO tblMFDemandHeader (
				intConcurrencyId
				,strDemandNo
				,strDemandName
				,dtmDate
				,intBookId
				,intSubBookId
				)
			SELECT 1 AS intConcurrencyId
				,@strDemandNo
				,@strDemandName
				,@dtmDate
				,@intBookId
				,@intSubBookId

			SELECT @intDemandHeaderId = SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			UPDATE tblMFDemandHeader
			SET intConcurrencyId = intConcurrencyId + 1
				,dtmDate = @dtmDate
				,intBookId = @intBookId
				,intSubBookId = @intSubBookId
			WHERE intDemandHeaderId = @intDemandHeaderId
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
			)
		SELECT strDemandName
			,strItemNo
			,strSubstituteItemNo
			,CONVERT(DATETIME, dtmDemandDate, @intConvertYear)
			,sum(dblQuantity)
			,strUnitMeasure
			,strLocationName
		FROM tblMFDemandImport
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
				,@intItemId = NULL
				,@intSubstituteItemId = NULL
				,@intUnitMeasureId = NULL
				,@intItemUOMId = NULL
				,@intLocationId = NULL
				,@intDemandDetailId = NULL

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

			SELECT @intSubstituteItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strSubstituteItemNo

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM tblICUnitMeasure U1
			WHERE U1.strUnitMeasure = @strUnitMeasure

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = @intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId

			SELECT @intLocationId = intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE strLocationName = @strLocationName

			SELECT @intDemandDetailId = intDemandDetailId
			FROM tblMFDemandDetail
			WHERE intDemandHeaderId = @intDemandHeaderId
				AND intItemId = @intItemId

			IF @intDemandDetailId IS NULL
			BEGIN
				INSERT INTO tblMFDemandDetail (
					intConcurrencyId
					,intDemandHeaderId
					,intItemId
					,intSubstituteItemId
					,dtmDemandDate
					,dblQuantity
					,intItemUOMId
					,intCompanyLocationId
					)
				SELECT 1 AS intConcurrencyId
					,@intDemandHeaderId
					,@intItemId
					,@intSubstituteItemId
					,@dtmDemandDate
					,@dblQuantity
					,@intItemUOMId
					,@intLocationId
			END
			ELSE
			BEGIN
				UPDATE tblMFDemandDetail
				SET intConcurrencyId = intConcurrencyId + 1
					,intItemId = @intItemId
					,intSubstituteItemId = @intSubstituteItemId
					,dtmDemandDate = @dtmDemandDate
					,dblQuantity = @dblQuantity
					,intItemUOMId = @intItemUOMId
					,intCompanyLocationId = @intLocationId
				WHERE intDemandDetailId = @intDemandDetailId
			END

			SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId > @intDemandDetailImportId
		END

		SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId > @intDemandHeaderImportId
	END

	INSERT INTO tblMFDemandDetail (
		intConcurrencyId
		,intDemandHeaderId
		,intItemId
		,intSubstituteItemId
		,dtmDemandDate
		,dblQuantity
		,intItemUOMId
		,intCompanyLocationId
		)
	SELECT 1 AS intConcurrencyId
		,@intDemandHeaderId
		,intItemId
		,intSubstituteItemId
		,dtmDemandDate
		,dblQuantity+(dblQuantity*@dblDemandGrowthPerc/100)
		,intItemUOMId
		,intLocationId
	FROM tblMFDemandDetail
	WHERE dtmDemandDate BETWEEN DATEADD(YY,-1,DATEADD(mm, DATEDIFF(mm, 0, @dtmMaxDemandDate) + 1, 0))
			AND DATEADD(YY,-1,DATEADD(MM, 12 - @intMonthDiff, @dtmMaxDemandDate))

	DELETE
	FROM tblMFDemandImport

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
