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
		,@dtmDemandDate NVARCHAR(50)
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
		,@strDetails NVARCHAR(MAX)
		,@strJson NVARCHAR(MAX)
		,@strOldDemandNo NVARCHAR(50)
		,@dtmOldDate DATETIME
		,@intOldBookId INT
		,@intOldSubBookId INT
		,@strHeaderData NVARCHAR(MAX)
		,@strOldBook NVARCHAR(50)
		,@strOldSubBook NVARCHAR(50)
		,@strDetailData NVARCHAR(MAX)
		,@strJSONData NVARCHAR(MAX)
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
		,dtmDemandDate NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,dblQuantity NUMERIC(18, 6) NOT NULL
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		,strLocationName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
		)
	DECLARE @tblMFDemandDetailChanges TABLE (
		dblOldQuantity NUMERIC(18, 6)
		,intOldItemUOMId INT
		,dblNewQuantity NUMERIC(18, 6)
		,intNewItemUOMId INT
		,intDemandDetailId INT
		)
	DECLARE @tblMFItem TABLE (
		intItemId INT
		,intSubstituteItemId INT
		,intLocationId INT
		)

	SELECT @strDemandImportDateTimeFormat = IsNULL(strDemandImportDateTimeFormat, 'MM DD YYYY HH:MI')
		,@intMinimumDemandMonth = IsNULL(intMinimumDemandMonth, 12)
		,@intMaximumDemandMonth = IsNULL(intMaximumDemandMonth, 12)
		,@dblDemandGrowthPerc = IsNULL(dblDemandGrowthPerc, 0)
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

	INSERT INTO @tblMFDemandHeaderImport (
		strDemandName
		,dtmDate
		,strBook
		,strSubBook
		,intCreatedUserId
		)
	SELECT DISTINCT strDemandName
		,CONVERT(NVARCHAR, GETDATE(), 101)
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

		--Update Audit Trail Record
		SELECT @strDetails = ''
			,@strOldDemandNo = NULL
			,@dtmOldDate = NULL
			,@intOldBookId = NULL
			,@intOldSubBookId = NULL

		SELECT @strOldBook = NULL
			,@strOldSubBook = NULL

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
			,@strOldDemandNo = strDemandNo
			,@dtmOldDate = dtmDate
			,@intOldBookId = intBookId
			,@intOldSubBookId = intSubBookId
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
				,ysnImported
				)
			SELECT 1 AS intConcurrencyId
				,@strDemandNo
				,@strDemandName
				,@dtmDate
				,@intBookId
				,@intSubBookId
				,1

			SELECT @intDemandHeaderId = SCOPE_IDENTITY()

			SET @strJson = '{"action":"Created","change":"Imported - Record: ' + CONVERT(VARCHAR, @intDemandHeaderId) + '","keyValue":' + CONVERT(VARCHAR, @intDemandHeaderId) + ',"iconCls":"small-new-plus","leaf":true}'

			EXEC uspSMAuditLog @keyValue = @intDemandHeaderId
				,@screenName = 'Manufacturing.view.DemandEntry'
				,@entityId = @intCreatedUserId
				,@actionType = 'Created'
				,@actionIcon = 'small-new-plus'
				,@details = @strJson

			BEGIN TRY
				DECLARE @SingleAuditLogParam SingleAuditLogParam
				INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
						SELECT 1, '', 'Created', 'Created - Record: ' + CAST(@intDemandHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
						UNION ALL
						SELECT 2, CONVERT(VARCHAR, @intDemandHeaderId), 'Created', 'Imported - Record: ' + CONVERT(VARCHAR, @intDemandHeaderId), NULL, NULL, NULL, NULL, NULL, 1

				EXEC uspSMSingleAuditLog 
					@screenName     = 'Manufacturing.view.DemandEntry',
					@recordId       = @intDemandHeaderId,
					@entityId       = @intCreatedUserId,
					@AuditLogParam  = @SingleAuditLogParam
			END TRY
			BEGIN CATCH
			END CATCH
		END
		ELSE
		BEGIN
			UPDATE tblMFDemandHeader
			SET intConcurrencyId = intConcurrencyId + 1
				,dtmDate = @dtmDate
				,intBookId = @intBookId
				,intSubBookId = @intSubBookId
				,strDemandName = @strDemandName
			WHERE intDemandHeaderId = @intDemandHeaderId

			SET @strHeaderData = ''

			IF @intOldBookId <> @intBookId
			BEGIN
				SELECT @strOldBook = strBook
				FROM tblCTBook
				WHERE intBookId = @intOldBookId

				SET @strHeaderData = @strHeaderData + '{"change":"strBook","from":"' + Ltrim(@strOldBook) + '","to":"' + Ltrim(@strBook) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(@intDemandHeaderId) + ',"changeDescription":"Book","hidden":false},'
			END

			IF @intOldSubBookId <> @intSubBookId
			BEGIN
				SELECT @strOldSubBook = strSubBook
				FROM tblCTSubBook
				WHERE intSubBookId = @intOldSubBookId

				SET @strHeaderData = @strHeaderData + '{"change":"strSubBook","from":"' + Ltrim(@strOldSubBook) + '","to":"' + Ltrim(@strSubBook) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(@intDemandHeaderId) + ',"changeDescription":"Sub Book","hidden":false},'
			END
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
			,CONVERT(datetime, CONVERT(datetime, dtmDemandDate, @intConvertYear))
			,dblQuantity
			,strUnitMeasure
			,strLocationName
		FROM tblMFDemandImport
		WHERE strDemandName = @strDemandName
		ORDER BY intDemandImportId

		DELETE
		FROM @tblMFItem

		SELECT @intDemandDetailImportId = NULL

		SELECT @strDetailData = ''

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
				,@dtmMinDemandDate = NULL
				,@dtmMaxDemandDate = NULL
				,@intMinMonth = NULL
				,@intMaxMonth = NULL
				,@intMinYear = NULL
				,@intMaxYear = NULL
				,@intMonthDiff = NULL

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
				AND IsNULL(intSubstituteItemId, 0) = IsNULL(@intSubstituteItemId, IsNULL(intSubstituteItemId, 0))
				AND IsNULL(intCompanyLocationId, 0) = IsNULL(@intLocationId, IsNULL(intCompanyLocationId, 0))

			SELECT @dtmMinDemandDate = MIN(Convert(DATETIME, dtmDemandDate))
				,@dtmMaxDemandDate = Max(Convert(DATETIME, dtmDemandDate))
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
				DELETE
				FROM @tblMFDemandDetailChanges

				UPDATE tblMFDemandDetail
				SET intConcurrencyId = intConcurrencyId + 1
					,dblQuantity = @dblQuantity
					,intItemUOMId = @intItemUOMId
				OUTPUT deleted.dblQuantity
					,deleted.intItemUOMId
					,inserted.dblQuantity
					,inserted.intItemUOMId
					,inserted.intDemandDetailId
				INTO @tblMFDemandDetailChanges
				WHERE intDemandDetailId = @intDemandDetailId
			END

			SELECT @strDetailData += '{"action":"Updated","change":"Updated - Record: ' + ltrim(@strItemNo) + ' - ' + ltrim(@dtmDemandDate) + '","keyValue":' + ltrim(intDemandDetailId) + ',"iconCls":"small-tree-modified","children":['
			FROM @tblMFDemandDetailChanges
			WHERE ISNULL(dblOldQuantity, 0) <> ISNULL(dblNewQuantity, 0)
				OR ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			IF EXISTS (
					SELECT *
					FROM @tblMFDemandDetailChanges
					WHERE ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)
					)
			BEGIN
				SELECT @strDetailData += '{"change":"dblQuantity","from":"' + LTRIM(ISNULL(dblOldQuantity, 0)) + '","to":"' + LTRIM(ISNULL(dblNewQuantity, 0)) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intDemandDetailId) + ',"associationKey":"tblMFDemandDetails","changeDescription":"Quantity","hidden":false},'
				FROM @tblMFDemandDetailChanges
				WHERE ISNULL(dblOldQuantity, 0) <> ISNULL(dblNewQuantity, 0)
			END
			ELSE
			BEGIN
				SELECT @strDetailData += '{"change":"dblQuantity","from":"' + LTRIM(ISNULL(dblOldQuantity, 0)) + '","to":"' + LTRIM(ISNULL(dblNewQuantity, 0)) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intDemandDetailId) + ',"associationKey":"tblMFDemandDetails","changeDescription":"Quantity","hidden":false}'
				FROM @tblMFDemandDetailChanges
				WHERE ISNULL(dblOldQuantity, 0) <> ISNULL(dblNewQuantity, 0)
			END

			SELECT @strDetailData += '{"change":"strItemUOM","from":"' + UM.strUnitMeasure + '","to":"' + UM1.strUnitMeasure + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intDemandDetailId) + ',"associationKey":"tblMFDemandDetails","changeDescription":"Item UOM","hidden":false}'
			FROM @tblMFDemandDetailChanges DD
			JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intOldItemUOMId
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = DD.intNewItemUOMId
			JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
			WHERE ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			SELECT @strDetailData += ']},'
			FROM @tblMFDemandDetailChanges
			WHERE ISNULL(dblOldQuantity, 0) <> ISNULL(dblNewQuantity, 0)
				OR ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			IF @intMonthDiff <> 12
				AND NOT EXISTS (
					SELECT *
					FROM @tblMFItem
					WHERE intItemId = @intItemId
						AND IsNULL(intSubstituteItemId, 0) = IsNULL(@intSubstituteItemId, IsNULL(intSubstituteItemId, 0))
						AND IsNULL(intLocationId, 0) = IsNULL(@intLocationId, IsNULL(intLocationId, 0))
					)
				AND NOT EXISTS (
					SELECT 1
					FROM @tblMFDemandDetailImport
					WHERE intDemandDetailImportId > @intDemandDetailImportId
						AND strItemNo = @strItemNo
						AND IsNULL(strSubstituteItemNo, '') = IsNULL(@strSubstituteItemNo, IsNULL(strSubstituteItemNo, ''))
						AND IsNULL(strLocationName, '') = IsNULL(@strLocationName, IsNULL(strLocationName, ''))
					)
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
					,ysnPopulatedBySystem
					)
				SELECT 1 AS intConcurrencyId
					,@intDemandHeaderId
					,DD.intItemId
					,DD.intSubstituteItemId
					,DATEADD(YY, 1, DD.dtmDemandDate)
					,DD.dblQuantity + (DD.dblQuantity * @dblDemandGrowthPerc / 100)
					,DD.intItemUOMId
					,DD.intCompanyLocationId
					,1 AS ysnPopulatedBySystem
				FROM tblMFDemandDetail DD
				WHERE dtmDemandDate BETWEEN DATEADD(YY, - 1, DATEADD(mm, DATEDIFF(mm, 0, @dtmMaxDemandDate) + 1, 0))
						AND DATEADD(YY, - 1, DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, 12 - @intMonthDiff, @dtmMaxDemandDate)) + 1, 0))) --eomonth(DATEADD(YY, - 1, DATEADD(MM, 12 - @intMonthDiff, @dtmMaxDemandDate)))
					AND intItemId = @intItemId
					AND IsNULL(intSubstituteItemId, 0) = IsNULL(@intSubstituteItemId, IsNULL(intSubstituteItemId, 0))
					AND IsNULL(intCompanyLocationId, 0) = IsNULL(@intLocationId, IsNULL(intCompanyLocationId, 0))
					AND DD.intDemandDetailId IN (
						SELECT MIN(DD2.intDemandDetailId)
						FROM tblMFDemandDetail DD2
						WHERE DD2.intItemId = DD.intItemId
							AND IsNULL(DD2.intSubstituteItemId, 0) = IsNULL(DD.intSubstituteItemId, 0)
							AND IsNULL(DD2.intCompanyLocationId, 0) = IsNULL(DD.intCompanyLocationId, 0)
							AND Datepart(mm, DD2.dtmDemandDate) = Datepart(mm, DD.dtmDemandDate)
							AND Datepart(YY, DD2.dtmDemandDate) = Datepart(YY, DD.dtmDemandDate)
						)

				INSERT INTO @tblMFItem
				SELECT @intItemId
					,@intSubstituteItemId
					,@intLocationId
			END

			SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
			FROM @tblMFDemandDetailImport
			WHERE intDemandDetailImportId > @intDemandDetailImportId
		END

		IF Len(@strDetailData) > 0
		BEGIN
			SELECT @strDetailData = Left(@strDetailData, Len(@strDetailData) - 1)

			SELECT @strDetailData = '{"change":"tblMFDemandDetails","children":[' + @strDetailData + '],"iconCls":"small-tree-grid","changeDescription":"Details"}'
		END

		IF Len(@strDetailData) > 0
			AND Len(@strHeaderData) > 0
			SELECT @strJSONData = @strHeaderData + @strDetailData
		ELSE IF Len(@strHeaderData) > 0
			SELECT @strJSONData = Left(@strHeaderData, Len(@strHeaderData) - 1)
		ELSE IF Len(@strDetailData) > 0
			SELECT @strJSONData = @strDetailData
		ELSE
			SELECT @strJSONData = ''

		IF LEN(@strJSONData) > 1
		BEGIN
			EXEC uspSMAuditLog @keyValue = @intDemandHeaderId
				,@screenName = 'Manufacturing.view.DemandEntry'
				,@entityId = @intCreatedUserId
				,@actionType = 'Updated'
				,@actionIcon = 'small-tree-modified'
				,@details = @strJSONData
		END

		SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
		FROM @tblMFDemandHeaderImport
		WHERE intDemandHeaderImportId > @intDemandHeaderImportId
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
