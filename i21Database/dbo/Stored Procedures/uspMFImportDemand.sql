CREATE PROCEDURE uspMFImportDemand @intLocationId INT = NULL
	,@intUserId INT = NULL
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
		,@intCreatedUserId INT
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
		,@intMonthDiff INT
		,@dblDemandGrowthPerc NUMERIC(18, 6)
	DECLARE @tblMFDemandHeaderImport TABLE (
		intDemandHeaderImportId INT NOT NULL IDENTITY
		,strDemandName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,dtmDate DATETIME
		,strBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strSubBook NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intCreatedUserId INT
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
		,@dblDemandGrowthPerc = IsNULL(dblDemandGrowthPerc, 0)
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

	BEGIN TRANSACTION

	INSERT INTO @tblMFDemandHeaderImport (
		strDemandName
		,dtmDate
		,strBook
		,strSubBook
		,intCreatedUserId
		)
	SELECT DISTINCT strDemandName
		,CONVERT(DATETIME, GETDATE(), @intConvertYear)
		,strBook
		,strSubBook
		,intCreatedUserId
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
			,@dtmCreated = NULL
			,@intBookId = NULL
			,@intSubBookId = NULL
			,@intDemandHeaderId = NULL
			,@intCreatedUserId = NULL

		SELECT @strDemandName = strDemandName
			,@dtmDate = dtmDate
			,@strBook = strBook
			,@strSubBook = strSubBook
			,@intCreatedUserId = intCreatedUserId
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
			EXEC dbo.uspMFGeneratePatternId @intCategoryId = NULL
				,@intItemId = NULL
				,@intManufacturingId = NULL
				,@intSubLocationId = NULL
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = NULL
				,@intPatternCode = 145
				,@ysnProposed = 0
				,@strPatternString = @strDemandNo OUTPUT
				,@intShiftId = NULL
				,@dtmDate = @dtmDate

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
			,Convert(DATETIME, CONVERT(CHAR, dtmDemandDate, @intConvertYear))
			,sum(dblQuantity)
			,strUnitMeasure
			,strLocationName
		FROM tblMFDemandImport
		WHERE strDemandName = @strDemandName
		GROUP BY strDemandName
			,strItemNo
			,strSubstituteItemNo
			,Convert(DATETIME, CONVERT(CHAR, dtmDemandDate, @intConvertYear))
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
				AND dtmDemandDate = @dtmDemandDate
				AND IsNULL(intSubstituteItemId,0)=IsNULL(@intSubstituteItemId,IsNULL(intSubstituteItemId,0))

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

	IF @intMonthDiff <> 12
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
			,intItemId
			,intSubstituteItemId
			,DATEADD(YY, 1, dtmDemandDate)
			,dblQuantity + (dblQuantity * @dblDemandGrowthPerc / 100)
			,intItemUOMId
			,intCompanyLocationId
		FROM tblMFDemandDetail
		WHERE dtmDemandDate BETWEEN DATEADD(YY, - 1, DATEADD(mm, DATEDIFF(mm, 0, @dtmMaxDemandDate) + 1, 0))
				AND DATEADD(YY, - 1, DATEADD(MM, 12 - @intMonthDiff, @dtmMaxDemandDate))
	END

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
