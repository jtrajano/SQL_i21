CREATE PROCEDURE uspMFImportAdditionalBasis @intLocationId INT = NULL
	,@intUserId INT = NULL
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
		,@intCurrencyId INT
		,@intOtherChargeItemId INT
		,@strOldComment NVARCHAR(MAX)
		,@intAdditionalBasisId INT
		,@strDetails NVARCHAR(MAX)
		,@strOtherChargeData NVARCHAR(MAX)
		,@strJson NVARCHAR(MAX)
		,@strOldAdditionalBasisNo NVARCHAR(50)
		,@dtmOldDate DATETIME
		,@intOldBookId INT
		,@intOldSubBookId INT
		,@strHeaderData NVARCHAR(MAX)
		,@strOldBook NVARCHAR(50)
		,@strOldSubBook NVARCHAR(50)
		,@strDetailData NVARCHAR(MAX)
		,@strJSONData NVARCHAR(MAX)
		,@intAdditionalBasisDetailId INT
		,@intAdditionalBasisOtherChargeImportId INT
		,@intAdditionalBasisOtherChargesId INT
	DECLARE @tblMFAdditionalBasisHeaderImport TABLE (
		intAdditionalBasisHeaderImportId INT NOT NULL IDENTITY
		,dtmAdditionalBasisDate DATETIME
		,strComment NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
		,intCreatedUserId INT
		,dtmCreated DATETIME NULL
		)
	DECLARE @tblMFAdditionalBasisDetailImport TABLE (
		intAdditionalBasisDetailImportId INT NOT NULL IDENTITY
		,dtmAdditionalBasisDate DATETIME
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOtherChargeItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblBasis NUMERIC(18, 6)
		,strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblMFAdditionalBasisOtherChargeImport TABLE (
		intAdditionalBasisOtherChargeImportId INT NOT NULL IDENTITY
		,strOtherChargeItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,dblBasis NUMERIC(18, 6)
		)
	DECLARE @tblMFAdditionalBasisDetailChanges TABLE (
		intOldCurrencyId INT
		,intOldItemUOMId INT
		,intNewCurrencyId INT
		,intNewItemUOMId INT
		,intAdditionalBasisDetailId INT
		)
	DECLARE @tblMFAdditionalBasisOtherChargeChanges TABLE (
		dblOldBasis NUMERIC(18, 6)
		,dblNewBasis NUMERIC(18, 6)
		,intAdditionalBasisOtherChargesId INT
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
			,@strOldComment = NULL
		,@intAdditionalBasisId = NULL

		SELECT @dtmAdditionalBasisDate = dtmAdditionalBasisDate
			,@strComment = strComment
			,@intCreatedUserId = intCreatedUserId
			,@dtmCreated = dtmCreated
		FROM @tblMFAdditionalBasisHeaderImport
		WHERE intAdditionalBasisHeaderImportId = @intAdditionalBasisHeaderImportId

		SELECT @intAdditionalBasisId = intAdditionalBasisId
			,@strOldComment = strComment
		FROM dbo.tblMFAdditionalBasis
		WHERE dtmAdditionalBasisDate = @dtmAdditionalBasisDate

		IF @intAdditionalBasisId IS NULL
		BEGIN
			INSERT INTO tblMFAdditionalBasis (
				dtmAdditionalBasisDate
				,strComment
				,intConcurrencyId
				,[dtmCreated]
				,[intCreatedUserId]
				,[dtmLastModified]
				,[intLastModifiedUserId]
				,[intLocationId]
				,ysnImported
				)
			SELECT @dtmAdditionalBasisDate
				,@strComment
				,1 AS intConcurrencyId
				,@dtmCreated AS [dtmCreated]
				,@intCreatedUserId [intCreatedUserId]
				,@dtmCreated [dtmLastModified]
				,@intCreatedUserId [intLastModifiedUserId]
				,@intLocationId
				,1 ysnImported

			SELECT @intAdditionalBasisId = SCOPE_IDENTITY()

			SET @strJson = '{"action":"Created","change":"Imported - Record: ' + CONVERT(VARCHAR, @intAdditionalBasisId) + '","keyValue":' + CONVERT(VARCHAR, @intAdditionalBasisId) + ',"iconCls":"small-new-plus","leaf":true}'

			EXEC uspSMAuditLog @keyValue = @intAdditionalBasisId
				,@screenName = 'Manufacturing.view.AdditionalBasisEntry'
				,@entityId = @intCreatedUserId
				,@actionType = 'Created'
				,@actionIcon = 'small-new-plus'
				,@details = @strJson
		END
		ELSE
		BEGIN
			UPDATE tblMFAdditionalBasis
			SET strComment = @strComment
				,intConcurrencyId = intConcurrencyId + 1
				,[dtmLastModified] = @dtmCreated
				,[intLastModifiedUserId] = @intCreatedUserId
				--,[intLocationId] = @intLocationId
				,ysnImported = 1
			WHERE intAdditionalBasisId = @intAdditionalBasisId

			SET @strHeaderData = ''

			IF @strOldComment <> @strComment
			BEGIN
				SET @strHeaderData = @strHeaderData + '{"change":"strComment","from":"' + Ltrim(@strOldComment) + '","to":"' + Ltrim(@strComment) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(@intAdditionalBasisId) + ',"changeDescription":"Comment","hidden":false},'
			END
		END

		DELETE
		FROM @tblMFAdditionalBasisDetailImport

		INSERT INTO @tblMFAdditionalBasisDetailImport (
			strItemNo
			,strCurrency
			,strUnitMeasure
			)
		SELECT DISTINCT strItemNo
			,strCurrency
			,strUnitMeasure
		FROM tblMFAdditionalBasisImport
		WHERE dtmAdditionalBasisDate = @dtmAdditionalBasisDate

		SELECT @intAdditionalBasisDetailImportId = NULL

		SELECT @strDetailData = ''

		SELECT @intAdditionalBasisDetailImportId = MIN(intAdditionalBasisDetailImportId)
		FROM @tblMFAdditionalBasisDetailImport

		WHILE @intAdditionalBasisDetailImportId IS NOT NULL
		BEGIN
			SELECT @strItemNo = NULL
				,@strCurrency = NULL
				,@strUnitMeasure = NULL
				,@intItemId = NULL
				,@intOtherChargeItemId = NULL
				,@intCurrencyId = NULL
				,@intUnitMeasureId = NULL
				,@strDetailErrorMessage = ''
				,@intAdditionalBasisDetailId = NULL

			SELECT @strItemNo = strItemNo
				,@strCurrency = strCurrency
				,@strUnitMeasure = strUnitMeasure
			FROM @tblMFAdditionalBasisDetailImport
			WHERE intAdditionalBasisDetailImportId = @intAdditionalBasisDetailImportId

			SELECT @intItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strItemNo

			SELECT @intOtherChargeItemId = intItemId
			FROM tblICItem I
			WHERE I.strItemNo = @strOtherChargeItemNo

			SELECT @intCurrencyId = intCurrencyID
			FROM tblSMCurrency
			WHERE strCurrency = @strCurrency

			SELECT @intUnitMeasureId = intUnitMeasureId
			FROM tblICUnitMeasure U1
			WHERE U1.strUnitMeasure = @strUnitMeasure

			SELECT @intItemUOMId = intItemUOMId
			FROM tblICItemUOM IU
			WHERE IU.intItemId = @intItemId
				AND IU.intUnitMeasureId = @intUnitMeasureId

			SELECT @intAdditionalBasisDetailId = intAdditionalBasisDetailId
			FROM tblMFAdditionalBasisDetail
			WHERE intAdditionalBasisId = @intAdditionalBasisId
				AND intItemId = @intItemId

			IF @intAdditionalBasisDetailId IS NULL
			BEGIN
				INSERT INTO tblMFAdditionalBasisDetail (
					intConcurrencyId
					,intAdditionalBasisId
					,intItemId
					,intCurrencyId
					,intItemUOMId
					)
				SELECT 1 AS intConcurrencyId
					,@intAdditionalBasisId
					,@intItemId
					,@intCurrencyId
					,@intItemUOMId

				SELECT @intAdditionalBasisDetailId = SCOPE_IDENTITY()
			END
			ELSE
			BEGIN
				DELETE
				FROM @tblMFAdditionalBasisDetailChanges

				UPDATE tblMFAdditionalBasisDetail
				SET intConcurrencyId = intConcurrencyId + 1
					,intCurrencyId = @intCurrencyId
					,intItemUOMId = @intItemUOMId
				OUTPUT deleted.intCurrencyId
					,deleted.intItemUOMId
					,inserted.intCurrencyId
					,inserted.intItemUOMId
					,inserted.intAdditionalBasisDetailId
				INTO @tblMFAdditionalBasisDetailChanges
				WHERE intAdditionalBasisDetailId = @intAdditionalBasisDetailId
			END

			SELECT @strDetailData += '{"action":"Updated","change":"Updated - Record: ' + ltrim(@strItemNo) + ' - ' + ltrim(@dtmAdditionalBasisDate) + '","keyValue":' + ltrim(intAdditionalBasisDetailId) + ',"iconCls":"small-tree-modified","children":['
			FROM @tblMFAdditionalBasisDetailChanges
			WHERE ISNULL(intOldCurrencyId, 0) <> ISNULL(intNewCurrencyId, 0)
				OR ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			IF EXISTS (
					SELECT *
					FROM @tblMFAdditionalBasisDetailChanges
					WHERE ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)
					)
			BEGIN
				SELECT @strDetailData += '{"change":"intCurrencyId","from":"' + C.strCurrency + '","to":"' + C1.strCurrency + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intAdditionalBasisDetailId) + ',"associationKey":"tblMFAdditionalBasisDetails","changeDescription":"Currency","hidden":false},'
				FROM @tblMFAdditionalBasisDetailChanges DC
				JOIN tblSMCurrency C ON C.intCurrencyID = DC.intOldCurrencyId
				JOIN tblSMCurrency C1 ON C1.intCurrencyID = DC.intNewCurrencyId
				WHERE ISNULL(intOldCurrencyId, 0) <> ISNULL(intNewCurrencyId, 0)
			END
			ELSE
			BEGIN
				SELECT @strDetailData += '{"change":"intCurrencyId","from":"' + C.strCurrency + '","to":"' + C1.strCurrency + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intAdditionalBasisDetailId) + ',"associationKey":"tblMFAdditionalBasisDetails","changeDescription":"Currency","hidden":false}'
				FROM @tblMFAdditionalBasisDetailChanges DC
				JOIN tblSMCurrency C ON C.intCurrencyID = DC.intOldCurrencyId
				JOIN tblSMCurrency C1 ON C1.intCurrencyID = DC.intNewCurrencyId
				WHERE ISNULL(intOldCurrencyId, 0) <> ISNULL(intNewCurrencyId, 0)
			END

			SELECT @strDetailData += '{"change":"strItemUOM","from":"' + UM.strUnitMeasure + '","to":"' + UM1.strUnitMeasure + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intAdditionalBasisDetailId) + ',"associationKey":"tblMFAdditionalBasisDetails","changeDescription":"Item UOM","hidden":false}'
			FROM @tblMFAdditionalBasisDetailChanges DD
			JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intOldItemUOMId
			JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			JOIN tblICItemUOM IU1 ON IU1.intItemUOMId = DD.intNewItemUOMId
			JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = IU1.intUnitMeasureId
			WHERE ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			SELECT @strDetailData += ']},'
			FROM @tblMFAdditionalBasisDetailChanges
			WHERE ISNULL(intOldCurrencyId, 0) <> ISNULL(intNewCurrencyId, 0)
				OR ISNULL(intOldItemUOMId, 0) <> ISNULL(intNewItemUOMId, 0)

			---******************* Other Charge
			DELETE
			FROM @tblMFAdditionalBasisOtherChargeImport

			INSERT INTO @tblMFAdditionalBasisOtherChargeImport (
				strOtherChargeItemNo
				,dblBasis
				)
			SELECT strOtherChargeItemNo
				,dblBasis
			FROM tblMFAdditionalBasisImport
			WHERE dtmAdditionalBasisDate = @dtmAdditionalBasisDate
				AND strItemNo = @strItemNo

			SELECT @intAdditionalBasisOtherChargeImportId = NULL

			SELECT @strDetailData = ''

			SELECT @intAdditionalBasisOtherChargeImportId = MIN(intAdditionalBasisOtherChargeImportId)
			FROM @tblMFAdditionalBasisOtherChargeImport

			WHILE @intAdditionalBasisOtherChargeImportId IS NOT NULL
			BEGIN
				SELECT @strOtherChargeItemNo = NULL
					,@dblBasis = NULL
					,@intOtherChargeItemId = NULL

				SELECT @intAdditionalBasisOtherChargesId =NULL

				SELECT @strOtherChargeItemNo = strOtherChargeItemNo
					,@dblBasis = dblBasis
				FROM @tblMFAdditionalBasisOtherChargeImport
				WHERE intAdditionalBasisOtherChargeImportId = @intAdditionalBasisOtherChargeImportId

				SELECT @intOtherChargeItemId = intItemId
				FROM dbo.tblICItem I
				WHERE I.strItemNo = @strOtherChargeItemNo

				SELECT @intAdditionalBasisOtherChargesId = intAdditionalBasisOtherChargesId
				FROM tblMFAdditionalBasisOtherCharges
				WHERE intAdditionalBasisDetailId = @intAdditionalBasisDetailId
					AND intItemId = @intOtherChargeItemId

				IF @intAdditionalBasisOtherChargesId IS NULL
				BEGIN
					INSERT INTO tblMFAdditionalBasisOtherCharges (
						intConcurrencyId
						,intAdditionalBasisDetailId
						,intItemId
						,dblBasis
						)
					SELECT 1 AS intConcurrencyId
						,@intAdditionalBasisDetailId
						,@intOtherChargeItemId
						,@dblBasis

					SELECT @intAdditionalBasisOtherChargesId = SCOPE_IDENTITY()
				END
				ELSE
				BEGIN
					DELETE
					FROM @tblMFAdditionalBasisDetailChanges

					UPDATE tblMFAdditionalBasisOtherCharges
					SET intConcurrencyId = intConcurrencyId + 1
						,dblBasis = @dblBasis
					OUTPUT deleted.dblBasis
						,inserted.dblBasis
						,inserted.intAdditionalBasisOtherChargesId
					INTO @tblMFAdditionalBasisOtherChargeChanges
					WHERE intAdditionalBasisOtherChargesId = @intAdditionalBasisOtherChargesId
				END

				SELECT @strOtherChargeData += '{"action":"Updated","change":"Updated - Record: ' + ltrim(@strItemNo) + ' - ' + ltrim(@dtmAdditionalBasisDate) + '","keyValue":' + ltrim(intAdditionalBasisOtherChargesId) + ',"iconCls":"small-tree-modified","children":['
				FROM @tblMFAdditionalBasisOtherChargeChanges
				WHERE ISNULL(dblOldBasis, 0) <> ISNULL(dblNewBasis, 0)

				SELECT @strOtherChargeData += '{"change":"dblBasis","from":"' + ltrim(dblOldBasis) + '","to":"' + Ltrim(dblNewBasis) + '","leaf":true,"iconCls":"small-gear","isField":true,"keyValue":' + ltrim(intAdditionalBasisOtherChargesId) + ',"associationKey":"tblMFAdditionalBasisOtherCharges","changeDescription":"Basis","hidden":false}'
				FROM @tblMFAdditionalBasisOtherChargeChanges
				WHERE ISNULL(dblOldBasis, 0) <> ISNULL(dblNewBasis, 0)

				SELECT @strOtherChargeData += ']},'
				FROM @tblMFAdditionalBasisOtherChargeChanges
				WHERE ISNULL(dblOldBasis, 0) <> ISNULL(dblNewBasis, 0)

				IF Len(@strDetailData) > 0
				BEGIN
					SELECT @strDetailData = Left(@strDetailData, Len(@strDetailData) - 1)

					SELECT @strDetailData = '{"change":"tblMFAdditionalBasisDetails","children":[' + @strDetailData + '],"iconCls":"small-tree-grid","changeDescription":"Details"}'
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
					EXEC uspSMAuditLog @keyValue = @intAdditionalBasisId
						,@screenName = 'Manufacturing.view.AdditionalBasisEntry'
						,@entityId = @intCreatedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strJSONData
				END

				SELECT @intAdditionalBasisOtherChargeImportId = MIN(intAdditionalBasisOtherChargeImportId)
				FROM @tblMFAdditionalBasisOtherChargeImport
				WHERE intAdditionalBasisOtherChargeImportId > @intAdditionalBasisOtherChargeImportId
			END

			---*******************
			SELECT @intAdditionalBasisDetailImportId = MIN(intAdditionalBasisDetailImportId)
			FROM @tblMFAdditionalBasisDetailImport
			WHERE intAdditionalBasisDetailImportId > @intAdditionalBasisDetailImportId
		END

		SELECT @intAdditionalBasisHeaderImportId = MIN(intAdditionalBasisHeaderImportId)
		FROM @tblMFAdditionalBasisHeaderImport
		WHERE intAdditionalBasisHeaderImportId > @intAdditionalBasisHeaderImportId
	END

	DELETE
	FROM tblMFAdditionalBasisImport

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
