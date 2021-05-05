CREATE PROCEDURE [dbo].[uspIPProcessFinalSAPStock] @strSessionId NVARCHAR(50) = ''
	,@strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@ysnProcessDeadLockEntry BIT = 0
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@intItemId INT
		,@intSubLocationId INT
		,@strItemNo NVARCHAR(100)
		,@strSubLocation NVARCHAR(100)
		,@dblInspectionQuantity NUMERIC(38, 20)
		,@dblBlockedQuantity NUMERIC(38, 20)
		,@dblUnrestrictedQuantity NUMERIC(38, 20)
		,@dblInTransitQuantity NUMERIC(38, 20)
		,@dblQuantity NUMERIC(38, 20)
		,@intLocationId INT
		,@intEntityUserId INT
		,@intSourceId INT = 1
		,@ErrMsg NVARCHAR(MAX)
		,@intMinRowNo1 INT
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@strStockType NVARCHAR(50)
	DECLARE @tblStock TABLE (
		[intRowNo] INT IDENTITY(1, 1)
		,[strItemNo] NVARCHAR(100)
		,[strSubLocation] NVARCHAR(100)
		,[dblQuantity] NUMERIC(38, 20)
		,[strSessionId] NVARCHAR(50)
		)

	IF @ysnProcessDeadLockEntry = 1
	BEGIN
		EXEC dbo.uspIPReprocessFailedSAPStock

		INSERT INTO tblIPStockStage (
			strItemNo
			,strSubLocation
			,strStockType
			,dblInspectionQuantity
			,dblBlockedQuantity
			,dblUnrestrictedQuantity
			,dblInTransitQuantity
			,dblQuantity
			,strSessionId
			,ysnDeadlockError
			)
		SELECT strItemNo
			,strSubLocation
			,strStockType
			,dblInspectionQuantity
			,dblBlockedQuantity
			,dblUnrestrictedQuantity
			,dblInTransitQuantity
			,dblQuantity
			,strSessionId
			,ysnDeadlockError
		FROM tblIPStockError
		WHERE isNULL(ysnDeadlockError, 0) = 1

		DELETE
		FROM tblIPStockError
		WHERE isNULL(ysnDeadlockError, 0) = 1
	END

	SELECT @intLocationId = dbo.[fnIPGetSAPIDOCTagValue]('STOCK', 'LOCATION_ID')

	SELECT @intEntityUserId = intEntityId
	FROM tblSMUserSecurity WITH (NOLOCK)
	WHERE strUserName = 'IRELYADMIN'

	IF ISNULL(@strSessionId, '') = ''
		INSERT INTO @tblStock (
			strItemNo
			,strSubLocation
			,dblQuantity
			,strSessionId
			)
		SELECT strItemNo
			,strSubLocation
			,SUM(ISNULL(dblQuantity, 0))
			,strSessionId
		FROM tblIPStockStage
		WHERE strStockType = 'WB'
		GROUP BY strItemNo
			,strSubLocation
			,strSessionId
	ELSE
		INSERT INTO @tblStock (
			strItemNo
			,strSubLocation
			,dblQuantity
			,strSessionId
			)
		SELECT strItemNo
			,strSubLocation
			,SUM(ISNULL(dblQuantity, 0))
			,strSessionId
		FROM tblIPStockStage
		WHERE strSessionId = @strSessionId
			AND strStockType = 'WB'
		GROUP BY strItemNo
			,strSubLocation
			,strSessionId

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblStock

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intItemId = NULL
			SET @intSubLocationId = NULL

			SELECT @strItemNo = strItemNo
				,@strSubLocation = strSubLocation
				,@dblQuantity = dblQuantity
				,@strSessionId = strSessionId
			FROM @tblStock
			WHERE intRowNo = @intMinRowNo

			SELECT TOP 1 @dblInspectionQuantity = ISNULL(dblInspectionQuantity, 0)
				,@dblUnrestrictedQuantity = ISNULL(dblUnrestrictedQuantity, 0)
				,@dblInTransitQuantity = ISNULL(dblInTransitQuantity, 0)
				,@strStockType = strStockType
				,@dblBlockedQuantity = ISNULL(dblBlockedQuantity, 0)
			FROM tblIPStockStage
			WHERE strItemNo = @strItemNo
				AND strSubLocation = @strSubLocation
				AND strSessionId = @strSessionId

			IF @strStockType = 'WB'
				AND @dblUnrestrictedQuantity = @dblQuantity
			BEGIN
				SET @dblQuantity = @dblQuantity + @dblInspectionQuantity
			END

			IF @strStockType = 'WB'
				SET @dblQuantity = @dblQuantity + @dblInTransitQuantity + @dblBlockedQuantity

			--Add Qty from LK,KB
			SELECT @dblQuantity = @dblQuantity + SUM(ISNULL(dblQuantity, 0))
			FROM tblIPStockStage
			WHERE strSessionId = @strSessionId
				AND strStockType <> 'WB'
			GROUP BY strItemNo
				,strSubLocation
				,strSessionId

			SELECT @intItemId = intItemId
			FROM tblICItem
			WHERE strItemNo = @strItemNo

			SELECT @intSubLocationId = intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation
			WHERE strSubLocationName = @strSubLocation
				AND intCompanyLocationId = @intLocationId

			SET @strInfo1 = @strItemNo
			SET @strInfo2 = @strSubLocation + ' / ' + ISNULL(CONVERT(VARCHAR, dbo.fnRemoveTrailingZeroes(@dblQuantity)), '')

			BEGIN TRAN

			EXEC [uspICAdjustStockFromSAP] @dtmQtyChange = NULL
				,@intItemId = @intItemId
				,@strLotNumber = 'FIFO'
				,@intLocationId = @intLocationId
				,@intSubLocationId = @intSubLocationId
				,@intStorageLocationId = NULL
				,@intItemUOMId = NULL
				,@dblNewQty = @dblQuantity
				,@dblCost = NULL
				,@intEntityUserId = @intEntityUserId
				,@intSourceId = @intSourceId

			--Adjust Qty in SubLocation in other Location as 0
			SELECT @intMinRowNo1 = MIN(intCompanyLocationId)
			FROM tblSMCompanyLocation
			WHERE intCompanyLocationId <> @intLocationId

			WHILE (@intMinRowNo1 IS NOT NULL)
			BEGIN
				SET @intSubLocationId = NULL

				SELECT @intSubLocationId = intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation
				WHERE strSubLocationName = @strSubLocation
					AND intCompanyLocationId = @intMinRowNo1

				IF EXISTS (
						SELECT 1
						FROM tblICItemStock s
						JOIN tblICItemLocation il ON s.intItemLocationId = il.intItemLocationId
						WHERE s.intItemId = @intItemId
							AND il.intLocationId = @intMinRowNo1
						)
				BEGIN
					EXEC [uspICAdjustStockFromSAP] @dtmQtyChange = NULL
						,@intItemId = @intItemId
						,@strLotNumber = 'FIFO'
						,@intLocationId = @intMinRowNo1
						,@intSubLocationId = @intSubLocationId
						,@intStorageLocationId = NULL
						,@intItemUOMId = NULL
						,@dblNewQty = 0
						,@dblCost = NULL
						,@intEntityUserId = @intEntityUserId
						,@intSourceId = @intSourceId
				END

				SELECT @intMinRowNo1 = MIN(intCompanyLocationId)
				FROM tblSMCompanyLocation
				WHERE intCompanyLocationId <> @intLocationId
					AND intCompanyLocationId > @intMinRowNo1
			END

			--Move to Archive
			INSERT INTO tblIPStockArchive (
				strItemNo
				,strSubLocation
				,strStockType
				,dblInspectionQuantity
				,dblBlockedQuantity
				,dblUnrestrictedQuantity
				,dblInTransitQuantity
				,dblQuantity
				,strSessionId
				,strImportStatus
				,strErrorMessage
				,ysnDeadlockError
				)
			SELECT strItemNo
				,strSubLocation
				,strStockType
				,dblInspectionQuantity
				,dblBlockedQuantity
				,dblUnrestrictedQuantity
				,dblInTransitQuantity
				,dblQuantity
				,strSessionId
				,'Success'
				,''
				,ysnDeadlockError
			FROM tblIPStockStage
			WHERE strItemNo = @strItemNo
				AND strSubLocation = @strSubLocation
				AND strSessionId = @strSessionId

			DELETE
			FROM tblIPStockStage
			WHERE strItemNo = @strItemNo
				AND strSubLocation = @strSubLocation
				AND strSessionId = @strSessionId

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPStockError (
				strItemNo
				,strSubLocation
				,strStockType
				,dblInspectionQuantity
				,dblBlockedQuantity
				,dblUnrestrictedQuantity
				,dblInTransitQuantity
				,dblQuantity
				,strSessionId
				,strImportStatus
				,strErrorMessage
				,ysnDeadlockError
				)
			SELECT strItemNo
				,strSubLocation
				,strStockType
				,dblInspectionQuantity
				,dblBlockedQuantity
				,dblUnrestrictedQuantity
				,dblInTransitQuantity
				,dblQuantity
				,strSessionId
				,'Failed'
				,@ErrMsg
				,(
					CASE 
						WHEN ERROR_NUMBER() = 1205
							AND IsNULL(ysnDeadlockError, 0) = 0
							THEN 1
						ELSE 0
						END
					)
			FROM tblIPStockStage
			WHERE strItemNo = @strItemNo
				AND strSubLocation = @strSubLocation
				AND strSessionId = @strSessionId

			DELETE
			FROM tblIPStockStage
			WHERE strItemNo = @strItemNo
				AND strSubLocation = @strSubLocation
				AND strSessionId = @strSessionId
		END CATCH

		SELECT @intMinRowNo = Min(intRowNo)
		FROM @tblStock
		WHERE intRowNo > @intMinRowNo
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

