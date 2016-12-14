﻿CREATE PROCEDURE uspMFGenerateTask @intOrderHeaderId INT
	,@intEntityUserSecurityId INT
AS
BEGIN TRY
	DECLARE @AllowablePickDayRange INT = 60
	DECLARE @RequiredQty NUMERIC(18, 6)
	DECLARE @strOrderNo NVARCHAR(100)
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @strOrderDirection NVARCHAR(50)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intTransactionCount INT
	DECLARE @dtmCurrentDateTime DATETIME
	DECLARE @dtmCurrentDate DATETIME
	DECLARE @intDayOfYear INT
	DECLARE @intLotRecordId INT
	DECLARE @intItemRecordId INT
	DECLARE @intOrderDetailId INT
	DECLARE @intItemId INT
	DECLARE @dblRequiredQty NUMERIC(18, 6)
	DECLARE @dblRequiredWeight NUMERIC(18, 6)
	DECLARE @ysnStrictTracking BIT
	DECLARE @intUserSecurityId INT
	DECLARE @intTaskTypeId INT
	DECLARE @intLineItemLotId INT
	DECLARE @dblPutbackQty NUMERIC(18, 6)
	DECLARE @dblPutbackWeight NUMERIC(18, 6)
	DECLARE @dblQty NUMERIC(18, 6)
	DECLARE @dblRemainingLotQty NUMERIC(18, 6)
	DECLARE @dblWeght NUMERIC(18, 6)
	DECLARE @dblRemainingLotWeight NUMERIC(18, 6)
	DECLARE @intLotId INT
	DECLARE @intTaskCount INT

	DECLARE @ysnPickByLotCode BIT,@intLotCodeStartingPosition int,@intLotCodeNoOfDigits int


	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	
	SELECT @ysnPickByLotCode  = ysnPickByLotCode,@intLotCodeStartingPosition=intLotCodeStartingPosition,@intLotCodeNoOfDigits=intLotCodeNoOfDigits FROM tblMFCompanyPreference

	If @intLotCodeStartingPosition is null
	Select @intLotCodeStartingPosition=2

	If @intLotCodeNoOfDigits is null
	Select @intLotCodeNoOfDigits=5


	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @strOrderType = OT.strOrderType
		,@strOrderNo = OH.strOrderNo
		,@strOrderDirection = OD.strOrderDirection
	FROM tblMFOrderHeader OH
	JOIN tblMFOrderType OT ON OT.intOrderTypeId = OH.intOrderTypeId
	JOIN tblMFOrderDirection OD ON OD.intOrderDirectionId = OH.intOrderDirectionId
	WHERE OH.intOrderHeaderId = @intOrderHeaderId

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	IF (@strOrderDirection = 'OUTBOUND')
	BEGIN
		DECLARE @tblLineItem TABLE (
			intItemRecordId INT Identity(1, 1)
			,intOrderHeaderId INT
			,intOrderDetailId INT
			,intItemId INT
			,dblRequiredQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblRequiredWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,ysnStrictTracking BIT
			,intLotId INT
			)
		DECLARE @tblLot TABLE (
			intLotRecordId INT Identity(1, 1)
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			,intItemUOMId INT
			,dblWeight NUMERIC(18, 6)
			,intWeightUOMId INT
			,dblRemainingLotQty NUMERIC(18, 6)
			,dblRemainingLotWeight NUMERIC(18, 6)
			,dtmProductionDate DATETIME
			,intGroupId INT
			)

		IF EXISTS (
				SELECT *
				FROM tblWHTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND ISNULL(intAssigneeId, 0) = 0
					AND (intTaskTypeId IN (2,7,13))
				)
		BEGIN
			DELETE
			FROM tblWHTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND ISNULL(intAssigneeId, 0) = 0
				AND (intTaskTypeId IN (2,7,13))
		END

		INSERT INTO @tblLineItem (
			intOrderHeaderId
			,intOrderDetailId
			,intItemId
			,dblRequiredQty
			,intItemUOMId
			,dblRequiredWeight
			,intWeightUOMId
			,ysnStrictTracking
			,intLotId
			)
		SELECT DISTINCT oh.intOrderHeaderId
			,oli.intOrderDetailId
			,i.intItemId
			,oli.dblQty - ISNULL((
					SELECT SUM(CASE 
								WHEN t.intTaskTypeId = 13
									THEN s.dblQty - t.dblQty
								ELSE t.dblQty
								END)
					FROM tblWHTask t
					JOIN tblWHSKU s ON s.intSKUId = t.intSKUId
					WHERE t.intOrderHeaderId = oh.intOrderHeaderId
						AND t.intItemId = oli.intItemId
					), 0) dblRemainingLineItemQty
			,oli.intItemUOMId
			,oli.dblWeight
			,oli.intWeightUOMId
			,i.ysnStrictFIFO
			,oli.intLotId
		FROM tblMFOrderHeader oh
		JOIN tblMFOrderDetail oli ON oh.intOrderHeaderId = oli.intOrderHeaderId
		JOIN tblICItem i ON i.intItemId = oli.intItemId
		WHERE oh.intOrderHeaderId = @intOrderHeaderId

		SELECT @intItemRecordId = MIN(intItemRecordId)
		FROM @tblLineItem

		WHILE (@intItemRecordId IS NOT NULL)
		BEGIN
			SET @intLotRecordId = NULL
			SET @intItemId = NULL
			SET @dblRequiredQty = NULL
			SET @dblRequiredWeight = NULL
			SET @dblPutbackQty = NULL
			SET @dblPutbackWeight = NULL
			SET @ysnStrictTracking = NULL
			SET @dblQty = NULL
			SET @intLineItemLotId = NULL

			DELETE
			FROM @tblLot

			SELECT @intOrderDetailId = intOrderDetailId
				,@intItemId = intItemId
				,@dblRequiredQty = dblRequiredQty
				,@dblRequiredWeight = dblRequiredWeight
				,@ysnStrictTracking = ysnStrictTracking
				,@intLineItemLotId = intLotId
			FROM @tblLineItem
			WHERE intItemRecordId = @intItemRecordId

			--- INSERT ALL THE LOTS WITHIN THE ALLOWABLE PICK DAY RANGE
			INSERT INTO @tblLot (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,dblWeight
				,intWeightUOMId
				,dblRemainingLotQty
				,dblRemainingLotWeight
				,dtmProductionDate
				,intGroupId
				)
			SELECT L.intLotId
				,L.intItemId
				,L.dblQty
				,L.intItemUOMId
				,L.dblWeight
				,L.intWeightUOMId
				,L.dblQty - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN L.dblQty - T.dblQty
								ELSE T.dblQty
								END, 0))
					) AS dblRemainingLotQty
				,L.dblWeight - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN L.dblWeight - T.dblWeight
								ELSE T.dblWeight
								END, 0))
					) AS dblRemainingLotWeight
				,L.dtmDateCreated
				,1
			FROM tblICLot L
			Join tblICStorageLocation SL on SL.intStorageLocationId =L.intStorageLocationId 
			Join tblICStorageUnitType UT on UT.intStorageUnitTypeId =SL.intStorageUnitTypeId and UT.ysnAllowPick =1
			LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				AND T.intTaskTypeId NOT IN (5,6,8,9,10,11)
			WHERE L.intItemId = @intItemId
				AND L.intLotStatusId IN (1)
				AND L.dtmDateCreated BETWEEN (
							SELECT MIN(dtmDateCreated)
							FROM tblICLot
							WHERE intItemId = @intItemId
								AND dblQty > 0
							)
					AND (
							SELECT MIN(dtmDateCreated) + @AllowablePickDayRange
							FROM tblICLot
							WHERE intItemId = @intItemId
								AND dblQty > 0
							)
				AND ISNULL(L.intParentLotId, 0) = ISNULL((
						CASE 
							WHEN @intLineItemLotId IS NULL
								THEN L.intParentLotId
							ELSE @intLineItemLotId
							END
						), 0)
			GROUP BY L.intLotId
				,L.intItemId
				,L.dblQty
				,L.intItemUOMId
				,L.dblWeight
				,L.intWeightUOMId
				,L.dtmDateCreated
				,L.dtmManufacturedDate
				,L.strLotNumber
			HAVING (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - T.dblWeight
								ELSE T.dblWeight
								END, 0))
					) > 0
			ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate,L.dtmDateCreated) ELSE CONVERT(INT,Substring(L.strLotNumber,@intLotCodeStartingPosition,@intLotCodeNoOfDigits  )) END ASC
,ABS((
						(Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - (
							SUM(ISNULL(CASE 
										WHEN T.intTaskTypeId = 13
											THEN (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - T.dblWeight
										ELSE T.dblWeight
										END, 0))
							)
						) - @dblRequiredWeight)
				,L.dtmDateCreated ASC


			--- INSERT ALL THE LOTS OUTSIDE ALLOWABLE PICK DAY RANGE
			INSERT INTO @tblLot (
				intLotId
				,intItemId
				,dblQty
				,intItemUOMId
				,dblWeight
				,intWeightUOMId
				,dblRemainingLotQty
				,dblRemainingLotWeight
				,dtmProductionDate
				,intGroupId
				)
			SELECT L.intLotId
				,L.intItemId
				,L.dblQty
				,L.intItemUOMId
				,L.dblWeight
				,L.intWeightUOMId
				,L.dblQty - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN L.dblQty - T.dblQty
								ELSE T.dblQty
								END, 0))
					) AS dblRemainingLotQty
				,L.dblWeight - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN L.dblWeight - T.dblWeight
								ELSE T.dblWeight
								END, 0))
					) AS dblRemainingLotWeight
				,L.dtmDateCreated
				,2
			FROM tblICLot L
			Join tblICStorageLocation SL on SL.intStorageLocationId =L.intStorageLocationId 
			Join tblICStorageUnitType UT on UT.intStorageUnitTypeId =SL.intStorageUnitTypeId and UT.ysnAllowPick =1
			LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				AND T.intTaskTypeId NOT IN (5,6,8,9,10,11)
			WHERE L.intItemId = @intItemId
				AND L.intLotStatusId = 1
				AND NOT EXISTS (
					SELECT *
					FROM @tblLot
					WHERE intLotId = L.intLotId
					)
				AND ISNULL(L.intParentLotId, 0) = ISNULL((
						CASE 
							WHEN @intLineItemLotId IS NULL
								THEN L.intParentLotId
							ELSE @intLineItemLotId
							END
						), 0)
			GROUP BY L.intLotId
					,L.intItemId
					,L.dblQty
					,L.intItemUOMId
					,L.dblWeight
					,L.intWeightUOMId
					,L.dtmDateCreated
					,L.dtmManufacturedDate
					,L.strLotNumber
			HAVING (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - L.dblWeight
								ELSE T.dblWeight
								END, 0))
					) > 0
			ORDER BY CASE WHEN @ysnPickByLotCode = 0 THEN ISNULL(L.dtmManufacturedDate,L.dtmDateCreated) ELSE Substring(L.strLotNumber,@intLotCodeStartingPosition,@intLotCodeNoOfDigits  ) END ASC,ABS((
						(Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End)- (
							SUM(ISNULL(CASE 
										WHEN T.intTaskTypeId = 13
											THEN (Case When L.intWeightUOMId is NULL Then L.dblQty Else L.dblWeight End) - T.dblWeight
										ELSE T.dblWeight
										END, 0))
							)
						) - @dblRequiredWeight)

				,L.dtmDateCreated ASC


			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblLot

			WHILE (@intLotRecordId IS NOT NULL)
			BEGIN
				SELECT @dblQty = dblQty
					,@intLotId = intLotId
					,@dblRemainingLotQty = dblRemainingLotQty
					,@dblWeght = (Case When intWeightUOMId is NULL Then dblQty Else dblWeight End)--dblWeight
					,@dblRemainingLotWeight = (Case When intWeightUOMId is NULL Then dblRemainingLotQty Else dblRemainingLotWeight End)--dblRemainingLotWeight
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF (@dblRemainingLotWeight > @dblRequiredWeight)
					AND (@dblRequiredWeight > (@dblRemainingLotWeight / 2))
				BEGIN
					SET @dblPutbackQty = @dblRemainingLotQty - @dblRequiredQty
					SET @dblPutbackWeight = @dblRemainingLotWeight - @dblRequiredWeight

					EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@dblSplitAndPickWeight = @dblRequiredWeight
						,@intTaskTypeId = 2

					SET @dblRequiredWeight = @dblRequiredWeight - @dblRemainingLotWeight

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE IF (@dblRemainingLotWeight <= @dblRequiredWeight)
					AND @dblWeght = @dblRemainingLotWeight
				BEGIN
					EXEC [uspMFCreatePickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId

					SET @dblRequiredWeight = @dblRequiredWeight - @dblWeght

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE
				BEGIN
					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END

					IF (@dblRemainingLotWeight <= @dblRequiredWeight)
					BEGIN
						EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
							,@intLotId = @intLotId
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@dblSplitAndPickWeight = @dblRemainingLotWeight
							,@intTaskTypeId = 2
					END
					ELSE
					BEGIN
						EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
							,@intLotId = @intLotId
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@dblSplitAndPickWeight = @dblRequiredWeight
							,@intTaskTypeId = 2
					END

					SET @dblRequiredWeight = @dblRequiredWeight - @dblWeght

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END

				DELETE
				FROM @tblLot
				WHERE intLotId = @intLotId

				SET @intLotRecordId = NULL

				SELECT TOP 1 @intLotRecordId = intLotRecordId
				FROM @tblLot s
				WHERE intGroupId = 1
				ORDER BY ABS(s.dblQty - @dblRequiredQty) ASC

				IF @intLotRecordId IS NULL
				BEGIN
					SELECT TOP 1 @intLotRecordId = @intLotRecordId
					FROM @tblLot s
					WHERE intGroupId = 2
					ORDER BY ABS(s.dblQty - @dblRequiredQty) ASC
				END
			END

			SELECT @intItemRecordId = MIN(intItemRecordId)
			FROM @tblLineItem
			WHERE intItemRecordId > @intItemRecordId
		END

		SELECT @intTaskCount = COUNT(*)
		FROM tblMFTask
		WHERE intOrderHeaderId = @intOrderHeaderId

		IF @intTaskCount <= 0
		BEGIN
			RAISERROR ('System was unable to generate task for one or more item(s).',16,1)
		END
	END
	ELSE
	BEGIN
		DECLARE @tblPutAwayLot TABLE (
			intLotRecordId INT Identity(1, 1)
			,intLotId INT
			,intItemId INT
			,dblQty NUMERIC(18, 6)
			)

		INSERT INTO @tblPutAwayLot
		SELECT OM.intLotId
			,L.intItemId
			,L.dblQty
		FROM tblMFOrderManifest OM
		JOIN tblICLot L ON L.intLotId = OM.intLotId
		WHERE intOrderHeaderId = @intOrderHeaderId

		SELECT @intLotRecordId = MIN(intLotRecordId)
		FROM @tblPutAwayLot

		WHILE (@intLotRecordId IS NOT NULL)
		BEGIN
			SET @intLotId = NULL

			SELECT @intLotId = intLotId
			FROM @tblPutAwayLot
			WHERE intLotRecordId = @intLotRecordId

			EXEC uspMFGeneratePutAwayTask @intOrderHeaderId = @intOrderHeaderId
										 ,@intLotId = @intLotId
										 ,@intEntityUserSecurityId = @intEntityUserSecurityId
										 ,@intAssigneeId = 0

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblPutAwayLot
			WHERE intLotRecordId > @intLotRecordId
		END
	END

	IF @intTransactionCount = 0
		COMMIT TRANSACTION
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH