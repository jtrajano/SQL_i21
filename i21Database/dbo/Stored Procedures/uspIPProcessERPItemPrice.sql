CREATE PROCEDURE uspIPProcessERPItemPrice @strInfo1 NVARCHAR(MAX) = '' OUT
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
	DECLARE @intTrxSequenceNo BIGINT
		,@strCompanyLocation NVARCHAR(6)
		,@intActionId INT
		,@dtmCreatedDate DATETIME
		,@strCreatedBy NVARCHAR(50)
	DECLARE @intItemPriceStageId INT
		,@strItemNo NVARCHAR(100)
		,@dblStandardCost NUMERIC(18, 6)
		,@strCurrency NVARCHAR(50)
	DECLARE @intCompanyLocationId INT
		,@intItemId INT
		,@intCurrencyID INT
		,@intNewItemPriceStageId INT
	DECLARE @tblICItemPricing TABLE (
		intItemPricingId INT
		,intItemLocationId INT
		,strLocationName NVARCHAR(50)
		,strRowState NVARCHAR(10)
		,dblOldStandardCost NUMERIC(18, 6)
		,dblNewStandardCost NUMERIC(18, 6)
		,dtmOldDateChanged DATETIME
		,dtmNewDateChanged DATETIME
		)
	DECLARE @intItemPricingId INT
		,@strLocationName NVARCHAR(50)
		,@dblOldStandardCost NUMERIC(18, 6)
		,@dblNewStandardCost NUMERIC(18, 6)
		,@dtmOldDateChanged DATETIME
		,@dtmNewDateChanged DATETIME
	DECLARE @tblIPItemPriceStage TABLE (intItemPriceStageId INT)

	INSERT INTO @tblIPItemPriceStage (intItemPriceStageId)
	SELECT intItemPriceStageId
	FROM tblIPItemPriceStage
	WHERE intStatusId IS NULL

	SELECT @intItemPriceStageId = MIN(intItemPriceStageId)
	FROM @tblIPItemPriceStage

	IF @intItemPriceStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPItemPriceStage S
	JOIN @tblIPItemPriceStage TS ON TS.intItemPriceStageId = S.intItemPriceStageId

	SELECT @intUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	SELECT @strInfo1 = ''
		,@strInfo2 = ''

	SELECT @strInfo1 = @strInfo1 + ISNULL(b.strItemNo, '') + ', '
	FROM @tblIPItemPriceStage a
	JOIN tblIPItemPriceStage b ON a.intItemPriceStageId = b.intItemPriceStageId

	IF Len(@strInfo1) > 0
	BEGIN
		SELECT @strInfo1 = Left(@strInfo1, Len(@strInfo1) - 1)
	END

	WHILE (@intItemPriceStageId IS NOT NULL)
	BEGIN
		BEGIN TRY
			SELECT @intTrxSequenceNo = NULL
				,@strCompanyLocation = NULL
				,@intActionId = NULL
				,@dtmCreatedDate = NULL
				,@strCreatedBy = NULL

			SELECT @strItemNo = NULL
				,@dblStandardCost = NULL
				,@strCurrency = NULL

			SELECT @intCompanyLocationId = NULL
				,@intItemId = NULL
				,@intCurrencyID = NULL
				,@intNewItemPriceStageId = NULL

			SELECT @intTrxSequenceNo = intTrxSequenceNo
				,@strCompanyLocation = strCompanyLocation
				,@intActionId = intActionId
				,@dtmCreatedDate = dtmCreatedDate
				,@strCreatedBy = strCreatedBy
				,@strItemNo = strItemNo
				,@dblStandardCost = dblStandardCost
				,@strCurrency = strCurrency
			FROM tblIPItemPriceStage
			WHERE intItemPriceStageId = @intItemPriceStageId

			IF EXISTS (
					SELECT 1
					FROM tblIPItemPriceArchive
					WHERE intTrxSequenceNo = @intTrxSequenceNo
					)
			BEGIN
				SELECT @strError = 'TrxSequenceNo ' + LTRIM(@intTrxSequenceNo) + ' is already processed in i21.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			SELECT @intCompanyLocationId = intCompanyLocationId
			FROM dbo.tblSMCompanyLocation
			WHERE strLotOrigin = @strCompanyLocation

			SELECT @intItemId = intItemId
			FROM dbo.tblICItem WITH (NOLOCK)
			WHERE strItemNo = @strItemNo

			SELECT @intCurrencyID = intCurrencyID
			FROM dbo.tblSMCurrency WITH (NOLOCK)
			WHERE strCurrency = @strCurrency

			IF @intCompanyLocationId IS NULL
			BEGIN
				SELECT @strError = 'Company Location not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intItemId IS NULL
			BEGIN
				SELECT @strError = 'Item not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @intCurrencyID IS NULL
			BEGIN
				SELECT @strError = 'Currency not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			IF @dblStandardCost IS NULL
			BEGIN
				SELECT @strError = 'Price not found.'

				RAISERROR (
						@strError
						,16
						,1
						)
			END

			BEGIN TRAN

			IF NOT EXISTS (
					SELECT 1
					FROM tblICItem I
					JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						AND IL.intLocationId = @intCompanyLocationId
						AND I.intItemId = @intItemId
					)
			BEGIN
				INSERT INTO tblICItemLocation (
					intConcurrencyId
					,intItemId
					,intLocationId
					,intCostingMethod
					,intAllowNegativeInventory
					,intAllowZeroCostTypeId
					)
				SELECT 1
					,@intItemId
					,@intCompanyLocationId
					,2
					,3
					,2
			END

			DELETE
			FROM @tblICItemPricing

			IF NOT EXISTS (
					SELECT 1
					FROM tblICItem I
					JOIN tblICItemLocation IL ON IL.intItemId = I.intItemId
						AND IL.intLocationId = @intCompanyLocationId
						AND I.intItemId = @intItemId
					JOIN tblICItemPricing IP ON IP.intItemId = I.intItemId
						AND IP.intItemLocationId = IL.intItemLocationId
					)
			BEGIN
				INSERT INTO tblICItemPricing (
					intConcurrencyId
					,intItemId
					,intItemLocationId
					,strPricingMethod
					,dblStandardCost
					,dtmDateChanged
					)
				OUTPUT inserted.intItemPricingId
					,inserted.intItemLocationId
					,NULL
					,'Added'
					,NULL
					,inserted.dblStandardCost
					,NULL
					,inserted.dtmDateChanged
				INTO @tblICItemPricing
				SELECT 1
					,@intItemId
					,IL.intItemLocationId
					,'None'
					,dbo.fnCTCalculateAmountBetweenCurrency(@intCurrencyID, NULL, @dblStandardCost, 1)
					,GETDATE()
				FROM tblICItemLocation IL
				WHERE IL.intLocationId = @intCompanyLocationId
					AND IL.intItemId = @intItemId

				UPDATE IP
				SET strLocationName = L.strLocationName
				FROM @tblICItemPricing IP
				JOIN tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId
				JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
			END
			ELSE
			BEGIN
				UPDATE IP
				SET intConcurrencyId = IP.intConcurrencyId + 1
					,dblStandardCost = dbo.fnCTCalculateAmountBetweenCurrency(@intCurrencyID, NULL, @dblStandardCost, 1)
					,dtmDateChanged = GETDATE()
				OUTPUT inserted.intItemPricingId
					,inserted.intItemLocationId
					,L.strLocationName
					,'Updated'
					,deleted.dblStandardCost
					,inserted.dblStandardCost
					,deleted.dtmDateChanged
					,inserted.dtmDateChanged
				INTO @tblICItemPricing
				FROM tblICItemPricing IP
				JOIN tblICItemLocation IL ON IL.intItemLocationId = IP.intItemLocationId
					AND IL.intItemId = @intItemId
					AND IL.intLocationId = @intCompanyLocationId
				JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = IL.intLocationId
			END

			DECLARE @strDetails NVARCHAR(MAX) = ''

			IF EXISTS (
					SELECT 1
					FROM @tblICItemPricing
					WHERE strRowState = 'Added'
					)
			BEGIN
				SELECT @strDetails += '{"change":"tblICItemPricings","children":['

				SELECT @strDetails += '{"action":"Created","change":"Created - Record: ' + strLocationName + '","keyValue":' + ltrim(intItemPricingId) + ',"iconCls":"small-new-plus","leaf":true},'
				FROM @tblICItemPricing
				WHERE strRowState = 'Added'

				SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

				SELECT @strDetails += '],"iconCls":"small-tree-grid","changeDescription":"Standard Cost/Price"},'

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END
			END

			WHILE EXISTS (
					SELECT TOP 1 NULL
					FROM @tblICItemPricing
					WHERE strRowState = 'Updated'
					)
			BEGIN
				SELECT @intItemPricingId = NULL
					,@strLocationName = NULL
					,@dblOldStandardCost = NULL
					,@dblNewStandardCost = NULL
					,@dtmOldDateChanged = NULL
					,@dtmNewDateChanged = NULL
					,@strDetails = NULL

				SELECT TOP 1 @intItemPricingId = intItemPricingId
					,@strLocationName = strLocationName
					,@dblOldStandardCost = dblOldStandardCost
					,@dblNewStandardCost = dblNewStandardCost
					,@dtmOldDateChanged = dtmOldDateChanged
					,@dtmNewDateChanged = dtmNewDateChanged
				FROM @tblICItemPricing
				WHERE strRowState = 'Updated'

				SET @strDetails = '{  
						"action":"Updated",
						"change":"Updated - Record: ' + LTRIM(@strItemNo) + '",
						"keyValue":' + LTRIM(@intItemId) + ',
						"iconCls":"small-tree-modified",
						"children":[  
							{  
								"change":"tblICItemPricings",
								"children":[  
									{  
									"action":"Updated",
									"change":"Updated - Record: ' + LTRIM(@strLocationName) + '",
									"keyValue":' + LTRIM(@intItemPricingId) + ',
									"iconCls":"small-tree-modified",
									"children":
										[   
											'

				IF @dtmOldDateChanged <> @dtmNewDateChanged
					SET @strDetails = @strDetails + '
											{  
											"change":"dtmDateChanged",
											"from":"' + LTRIM(@dtmOldDateChanged) + '",
											"to":"' + LTRIM(@dtmNewDateChanged) + '",
											"leaf":true,
											"iconCls":"small-gear",
											"isField":true,
											"keyValue":' + LTRIM(@intItemPricingId) + ',
											"associationKey":"tblICItemPricings",
											"changeDescription":"Date Changed",
											"hidden":false
											},'

				IF @dblOldStandardCost <> @dblNewStandardCost
					SET @strDetails = @strDetails + '
											{  
											"change":"dblStandardCost",
											"from":"' + LTRIM(@dblOldStandardCost) + '",
											"to":"' + LTRIM(@dblNewStandardCost) + '",
											"leaf":true,
											"iconCls":"small-gear",
											"isField":true,
											"keyValue":' + LTRIM(@intItemPricingId) + ',
											"associationKey":"tblICItemPricings",
											"changeDescription":"Standard Cost",
											"hidden":false
											},'

				IF RIGHT(@strDetails, 1) = ','
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))
				SET @strDetails = @strDetails + '
									]
								}
							],
							"iconCls":"small-tree-grid",
							"changeDescription":"Standard Cost/Price"
							}
						]
						}'

				IF @dtmOldDateChanged <> @dtmNewDateChanged
					OR @dblOldStandardCost <> @dblNewStandardCost
				BEGIN
					EXEC uspSMAuditLog @keyValue = @intItemId
						,@screenName = 'Inventory.view.Item'
						,@entityId = @intUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails
				END

				DELETE
				FROM @tblICItemPricing
				WHERE intItemPricingId = @intItemPricingId
			END

			MOVE_TO_ARCHIVE:

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,2 AS intMessageTypeId
				,1 AS intStatusId
				,'Success' AS strStatusText

			INSERT INTO tblIPItemPriceArchive (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,dblStandardCost
				,strCurrency
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,dblStandardCost
				,strCurrency
			FROM tblIPItemPriceStage
			WHERE intItemPriceStageId = @intItemPriceStageId

			SELECT @intNewItemPriceStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPItemPriceStage
			WHERE intItemPriceStageId = @intItemPriceStageId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			INSERT INTO tblIPInitialAck (
				intTrxSequenceNo
				,strCompanyLocation
				,dtmCreatedDate
				,strCreatedBy
				,intMessageTypeId
				,intStatusId
				,strStatusText
				)
			SELECT @intTrxSequenceNo
				,@strCompanyLocation
				,@dtmCreatedDate
				,@strCreatedBy
				,2 AS intMessageTypeId
				,0 AS intStatusId
				,@ErrMsg AS strStatusText

			INSERT INTO tblIPItemPriceError (
				intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,dblStandardCost
				,strCurrency
				,strErrorMessage
				)
			SELECT intTrxSequenceNo
				,strCompanyLocation
				,intActionId
				,dtmCreatedDate
				,strCreatedBy
				,strItemNo
				,dblStandardCost
				,strCurrency
				,@ErrMsg
			FROM tblIPItemPriceStage
			WHERE intItemPriceStageId = @intItemPriceStageId

			SELECT @intNewItemPriceStageId = SCOPE_IDENTITY()

			DELETE
			FROM tblIPItemPriceStage
			WHERE intItemPriceStageId = @intItemPriceStageId
		END CATCH

		SELECT @intItemPriceStageId = MIN(intItemPriceStageId)
		FROM @tblIPItemPriceStage
		WHERE intItemPriceStageId > @intItemPriceStageId
	END

	UPDATE S
	SET intStatusId = NULL
	FROM tblIPItemPriceStage S
	JOIN @tblIPItemPriceStage TS ON TS.intItemPriceStageId = S.intItemPriceStageId
	WHERE S.intStatusId = - 1

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
