CREATE PROCEDURE uspMFGenerateTask 
	 @intOrderHeaderId INT
	,@intEntityUserSecurityId INT
	,@ysnAllTasksNotGenerated BIT = 0 OUTPUT
AS
BEGIN TRY
	DECLARE @intAllowablePickDayRange INT
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
	DECLARE @ysnPickByLotCode BIT
	DECLARE @intLotCodeStartingPosition INT
	DECLARE @intLotCodeNoOfDigits INT
	DECLARE @intTaskRecordId INT
	DECLARE @dblTotalTaskWeight NUMERIC(18, 6)
	DECLARE @dblLineItemWeight NUMERIC(18, 6)
		,@intCategoryId INT
	DECLARE @tblTaskGenerated TABLE (
		intTaskRecordId INT Identity(1, 1)
		,intItemId INT
		,dblTotalTaskWeight NUMERIC(18, 6)
		,dblLineItemWeight NUMERIC(18, 6)
		)
	DECLARE @intReceivedLife INT
		,@strReferenceNo NVARCHAR(50)
		,@intEntityCustomerId INT
		,@intItemOwnerId INT
		,@ysnPickByItemOwner BIT
		,@intPackagingCategoryId INT
		,@strPackagingCategory NVARCHAR(50)
		,@intPMCategoryId INT
		,@strPickByFullPallet NVARCHAR(50)

	SELECT @intPackagingCategoryId = intAttributeId
	FROM tblMFAttribute
	WHERE strAttributeName = 'Packaging Category'

	SELECT @strPackagingCategory = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = @intPackagingCategoryId

	SELECT @intPMCategoryId = intCategoryId
	FROM tblICCategory
	WHERE strCategoryCode = @strPackagingCategory

	SELECT @strPickByFullPallet = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intAttributeId = 92
		AND strAttributeValue <> ''

	IF @strPickByFullPallet IS NULL
		OR @strPickByFullPallet = ''
		SELECT @strPickByFullPallet = 'False'

	SELECT @intReceivedLife = 0
		,@ysnPickByItemOwner = 0
		,@intItemOwnerId = 0

	SELECT @intTransactionCount = @@TRANCOUNT

	SELECT @dtmCurrentDateTime = GETDATE()

	SELECT @ysnPickByLotCode = ysnPickByLotCode
		,@intLotCodeStartingPosition = intLotCodeStartingPosition
		,@intLotCodeNoOfDigits = intLotCodeNoOfDigits
		,@ysnPickByItemOwner = ysnPickByItemOwner
	FROM tblMFCompanyPreference

	SELECT @intAllowablePickDayRange = intAllowablePickDayRange
	FROM tblWHCompanyPreference

	IF @intAllowablePickDayRange IS NULL
		SELECT @intAllowablePickDayRange = 60

	IF @intLotCodeStartingPosition IS NULL
		SELECT @intLotCodeStartingPosition = 2

	IF @intLotCodeNoOfDigits IS NULL
		SELECT @intLotCodeNoOfDigits = 5

	SELECT @dtmCurrentDate = CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))

	SELECT @intDayOfYear = DATEPART(dy, @dtmCurrentDateTime)

	SELECT @strOrderType = OT.strOrderType
		,@strOrderNo = OH.strOrderNo
		,@strOrderDirection = OD.strOrderDirection
		,@strReferenceNo = OH.strReferenceNo
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
			,intCategoryId INT
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
				SELECT 1
				FROM tblMFTask
				WHERE intOrderHeaderId = @intOrderHeaderId
					AND intTaskStateId NOT IN (3,4)
				)
		BEGIN
			DELETE
			FROM tblMFTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND intTaskStateId  NOT IN (3,4)
		END

		Update tblMFOrderDetail Set dblWeight=dblQty Where dblQty>0 and (dblWeight=0 or dblWeight is null)

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
			,intCategoryId
			)
		SELECT DISTINCT oh.intOrderHeaderId
			,oli.intOrderDetailId
			,i.intItemId
			,oli.dblQty - ISNULL((
					SELECT SUM(CASE 
								WHEN t.intTaskTypeId = 13
									THEN l.dblQty - t.dblQty
								ELSE t.dblQty
								END)
					FROM tblMFTask t
					JOIN tblICLot l ON l.intLotId = t.intLotId
					WHERE t.intOrderHeaderId = oh.intOrderHeaderId
						AND t.intItemId = oli.intItemId
					), 0) dblRemainingLineItemQty
			,oli.intItemUOMId
			,oli.dblWeight- ISNULL((
					SELECT SUM(CASE 
								WHEN t.intTaskTypeId = 13
									THEN l.dblWeight - t.dblWeight
								ELSE t.dblWeight
								END)
					FROM tblMFTask t
					JOIN tblICLot l ON l.intLotId = t.intLotId
					WHERE t.intOrderHeaderId = oh.intOrderHeaderId
						AND t.intItemId = oli.intItemId
					), 0)
			,oli.intWeightUOMId
			,i.ysnStrictFIFO
			,oli.intLotId
			,i.intCategoryId
		FROM tblMFOrderHeader oh
		JOIN tblMFOrderDetail oli ON oh.intOrderHeaderId = oli.intOrderHeaderId
		JOIN tblICItem i ON i.intItemId = oli.intItemId
		WHERE oh.intOrderHeaderId = @intOrderHeaderId and oli.dblQty >0

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

			SELECT @intCategoryId = NULL

			DELETE
			FROM @tblLot

			SELECT @intOrderDetailId = intOrderDetailId
				,@intItemId = intItemId
				,@dblRequiredQty = dblRequiredQty
				,@dblRequiredWeight = dblRequiredWeight
				,@ysnStrictTracking = ysnStrictTracking
				,@intLineItemLotId = intLotId
				,@intCategoryId = intCategoryId
			FROM @tblLineItem I
			WHERE intItemRecordId = @intItemRecordId

			IF @strOrderType = 'INVENTORY SHIPMENT STAGING'
			BEGIN
				SELECT @intEntityCustomerId = intEntityCustomerId
				FROM tblICInventoryShipment
				WHERE strShipmentNumber = @strReferenceNo

				SELECT @intReceivedLife = intReceivedLife
				FROM tblMFItemOwner
				WHERE intOwnerId = @intEntityCustomerId
					AND intItemId = @intItemId

				IF @intReceivedLife = 0
					OR @intReceivedLife IS NULL
				BEGIN
					SELECT @intReceivedLife = intReceivedLife
					FROM tblMFItemOwner
					WHERE intOwnerId = @intEntityCustomerId
				END

				IF @intReceivedLife = 0
					OR @intReceivedLife IS NULL
				BEGIN
					SELECT @intReceivedLife = intReceiveLife
					FROM tblICItem
					WHERE intItemId = @intItemId
				END

				IF @intReceivedLife IS NULL
				BEGIN
					SELECT @intReceivedLife = 0
				END

				SELECT @intItemOwnerId = intItemOwnerId
				FROM tblICItemOwner
				WHERE intOwnerId = @intEntityCustomerId
					AND intItemId = @intItemId
			END

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
			JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
				AND UT.ysnAllowPick = 1
			LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				AND T.intTaskTypeId NOT IN (
					5
					,6
					,8
					,9
					,10
					,11
					)
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
				AND BS.strPrimaryStatus = 'Active'
			JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			WHERE L.intItemId = @intItemId
				AND LS.strPrimaryStatus = 'Active'
				AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
				AND L.dtmDateCreated BETWEEN (
							SELECT MIN(dtmDateCreated)
							FROM tblICLot
							WHERE intItemId = @intItemId
								AND dblQty > 0
							)
					AND (
							SELECT MIN(dtmDateCreated) + @intAllowablePickDayRange
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
				AND IsNULL(LI.intItemOwnerId, 0) = (
					CASE 
						WHEN @ysnPickByItemOwner = 1
							THEN @intItemOwnerId
						ELSE IsNULL(LI.intItemOwnerId, 0)
						END
					)
			GROUP BY L.intLotId
				,L.intItemId
				,L.dblQty
				,L.intItemUOMId
				,L.dblWeight
				,L.intWeightUOMId
				,L.dtmDateCreated
				,L.dtmManufacturedDate
				,PL.strParentLotNumber
			HAVING (
					CASE 
						WHEN L.intWeightUOMId IS NULL
							THEN L.dblQty
						ELSE L.dblWeight
						END
					) - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN (
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN L.dblQty
												ELSE L.dblWeight
												END
											) - T.dblWeight
								ELSE T.dblWeight
								END, 0))
					) > 0
			ORDER BY CASE 
					WHEN @ysnPickByLotCode = 0
						THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					ELSE '1900-01-01'
					END ASC
				,CASE 
					WHEN @ysnPickByLotCode = 1
						THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
					ELSE '1'
					END ASC
				,ABS((
						(
							CASE 
								WHEN L.intWeightUOMId IS NULL
									THEN L.dblQty
								ELSE L.dblWeight
								END
							) - (
							SUM(ISNULL(CASE 
										WHEN T.intTaskTypeId = 13
											THEN (
													CASE 
														WHEN L.intWeightUOMId IS NULL
															THEN L.dblQty
														ELSE L.dblWeight
														END
													) - T.dblWeight
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
			JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
			JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
				AND UT.ysnAllowPick = 1
			JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
				AND R.strInternalCode = 'STOCK'
			LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
				AND T.intTaskTypeId NOT IN (
					5
					,6
					,8
					,9
					,10
					,11
					)
			LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
			JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
				AND BS.strPrimaryStatus = 'Active'
			JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
			JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
			WHERE L.intItemId = @intItemId
				AND LS.strPrimaryStatus = 'Active'
				AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
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
				AND IsNULL(LI.intItemOwnerId, 0) = (
					CASE 
						WHEN @ysnPickByItemOwner = 1
							THEN @intItemOwnerId
						ELSE IsNULL(LI.intItemOwnerId, 0)
						END
					)
			GROUP BY L.intLotId
				,L.intItemId
				,L.dblQty
				,L.intItemUOMId
				,L.dblWeight
				,L.intWeightUOMId
				,L.dtmDateCreated
				,L.dtmManufacturedDate
				,PL.strParentLotNumber
			HAVING (
					CASE 
						WHEN L.intWeightUOMId IS NULL
							THEN L.dblQty
						ELSE L.dblWeight
						END
					) - (
					SUM(ISNULL(CASE 
								WHEN T.intTaskTypeId = 13
									THEN (
											CASE 
												WHEN L.intWeightUOMId IS NULL
													THEN L.dblQty
												ELSE L.dblWeight
												END
											) - L.dblWeight
								ELSE T.dblWeight
								END, 0))
					) > 0
			ORDER BY CASE 
					WHEN @ysnPickByLotCode = 0
						THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
					ELSE '1900-01-01'
					END ASC
				,CASE 
					WHEN @ysnPickByLotCode = 1
						THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
					ELSE '1'
					END ASC
				,ABS((
						(
							CASE 
								WHEN L.intWeightUOMId IS NULL
									THEN L.dblQty
								ELSE L.dblWeight
								END
							) - (
							SUM(ISNULL(CASE 
										WHEN T.intTaskTypeId = 13
											THEN (
													CASE 
														WHEN L.intWeightUOMId IS NULL
															THEN L.dblQty
														ELSE L.dblWeight
														END
													) - T.dblWeight
										ELSE T.dblWeight
										END, 0))
							)
						) - @dblRequiredWeight)
				,L.dtmDateCreated ASC

			IF @ysnPickByItemOwner = 1
				AND NOT EXISTS (
					SELECT *
					FROM @tblLot
					)
			BEGIN
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
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
					AND T.intTaskTypeId NOT IN (
						5
						,6
						,8
						,9
						,10
						,11
						)
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intItemId = @intItemId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
					AND L.dtmDateCreated BETWEEN (
								SELECT MIN(dtmDateCreated)
								FROM tblICLot
								WHERE intItemId = @intItemId
									AND dblQty > 0
								)
						AND (
								SELECT MIN(dtmDateCreated) + @intAllowablePickDayRange
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
					,PL.strParentLotNumber
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (
						SUM(ISNULL(CASE 
									WHEN T.intTaskTypeId = 13
										THEN (
												CASE 
													WHEN L.intWeightUOMId IS NULL
														THEN L.dblQty
													ELSE L.dblWeight
													END
												) - T.dblWeight
									ELSE T.dblWeight
									END, 0))
						) > 0
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE '1900-01-01'
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 1
							THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
						ELSE '1'
						END ASC
					,ABS((
							(
								CASE 
									WHEN L.intWeightUOMId IS NULL
										THEN L.dblQty
									ELSE L.dblWeight
									END
								) - (
								SUM(ISNULL(CASE 
											WHEN T.intTaskTypeId = 13
												THEN (
														CASE 
															WHEN L.intWeightUOMId IS NULL
																THEN L.dblQty
															ELSE L.dblWeight
															END
														) - T.dblWeight
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
				JOIN tblICStorageLocation SL ON SL.intStorageLocationId = L.intStorageLocationId
				JOIN tblICStorageUnitType UT ON UT.intStorageUnitTypeId = SL.intStorageUnitTypeId
					AND UT.ysnAllowPick = 1
				JOIN dbo.tblICRestriction R ON R.intRestrictionId = SL.intRestrictionId
					AND R.strInternalCode = 'STOCK'
				LEFT JOIN tblMFTask T ON T.intLotId = L.intLotId
					AND T.intTaskTypeId NOT IN (
						5
						,6
						,8
						,9
						,10
						,11
						)
				LEFT JOIN dbo.tblMFLotInventory LI ON LI.intLotId = L.intLotId
				JOIN dbo.tblICLotStatus BS ON BS.intLotStatusId = ISNULL(LI.intBondStatusId, 1)
					AND BS.strPrimaryStatus = 'Active'
				JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
				JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = L.intLotStatusId
				WHERE L.intItemId = @intItemId
					AND LS.strPrimaryStatus = 'Active'
					AND ISNULL(L.dtmExpiryDate - @intReceivedLife, @dtmCurrentDateTime) >= @dtmCurrentDateTime
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
					,PL.strParentLotNumber
				HAVING (
						CASE 
							WHEN L.intWeightUOMId IS NULL
								THEN L.dblQty
							ELSE L.dblWeight
							END
						) - (
						SUM(ISNULL(CASE 
									WHEN T.intTaskTypeId = 13
										THEN (
												CASE 
													WHEN L.intWeightUOMId IS NULL
														THEN L.dblQty
													ELSE L.dblWeight
													END
												) - L.dblWeight
									ELSE T.dblWeight
									END, 0))
						) > 0
				ORDER BY CASE 
						WHEN @ysnPickByLotCode = 0
							THEN ISNULL(L.dtmManufacturedDate, L.dtmDateCreated)
						ELSE '1900-01-01'
						END ASC
					,CASE 
						WHEN @ysnPickByLotCode = 1
							THEN Substring(PL.strParentLotNumber, @intLotCodeStartingPosition, @intLotCodeNoOfDigits)
						ELSE '1'
						END ASC
					,ABS((
							(
								CASE 
									WHEN L.intWeightUOMId IS NULL
										THEN L.dblQty
									ELSE L.dblWeight
									END
								) - (
								SUM(ISNULL(CASE 
											WHEN T.intTaskTypeId = 13
												THEN (
														CASE 
															WHEN L.intWeightUOMId IS NULL
																THEN L.dblQty
															ELSE L.dblWeight
															END
														) - T.dblWeight
											ELSE T.dblWeight
											END, 0))
								)
							) - @dblRequiredWeight)
					,L.dtmDateCreated ASC
			END

			SELECT @intLotRecordId = MIN(intLotRecordId)
			FROM @tblLot

			WHILE (@intLotRecordId IS NOT NULL)
			BEGIN
				SELECT @dblQty = dblQty
					,@intLotId = intLotId
					,@dblRemainingLotQty = dblRemainingLotQty
					,@dblWeght = (
						CASE 
							WHEN intWeightUOMId IS NULL
								THEN dblQty
							ELSE dblWeight
							END
						) --dblWeight
					,@dblRemainingLotWeight = (
						CASE 
							WHEN intWeightUOMId IS NULL
								THEN dblRemainingLotQty
							ELSE dblRemainingLotWeight
							END
						) --dblRemainingLotWeight
				FROM @tblLot
				WHERE intLotRecordId = @intLotRecordId

				IF @strPickByFullPallet = 'True'
					AND @strOrderType = 'WO PROD STAGING'
				BEGIN
					EXEC [uspMFCreatePickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@intItemId = @intItemId

					SET @dblRequiredWeight = @dblRequiredWeight - @dblWeght

					IF @dblRequiredWeight <= 0
					BEGIN
						BREAK;
					END
				END
				ELSE IF (@dblRemainingLotWeight > @dblRequiredWeight)
					AND (@dblRequiredWeight > (@dblRemainingLotWeight / 2))
				BEGIN
					SET @dblPutbackQty = @dblRemainingLotQty - @dblRequiredQty
					SET @dblPutbackWeight = @dblRemainingLotWeight - @dblRequiredWeight

					EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
						,@intLotId = @intLotId
						,@intEntityUserSecurityId = @intEntityUserSecurityId
						,@dblSplitAndPickWeight = @dblRequiredWeight
						,@intTaskTypeId = 2
						,@intItemId = @intItemId

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
						,@intItemId = @intItemId

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
							,@intItemId = @intItemId

						SET @dblRequiredWeight = @dblRequiredWeight - @dblRemainingLotWeight
					END
					ELSE
					BEGIN
						EXEC [uspMFCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId
							,@intLotId = @intLotId
							,@intEntityUserSecurityId = @intEntityUserSecurityId
							,@dblSplitAndPickWeight = @dblRequiredWeight
							,@intTaskTypeId = 2
							,@intItemId = @intItemId

						SET @dblRequiredWeight = @dblRequiredWeight - @dblWeght
					END

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
				ORDER BY intLotRecordId ASC

				IF @intLotRecordId IS NULL
				BEGIN
					SELECT TOP 1 @intLotRecordId = intLotRecordId
					FROM @tblLot s
					WHERE intGroupId = 2
					ORDER BY intLotRecordId ASC
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

	INSERT INTO @tblTaskGenerated
	SELECT OD.intItemId
		,ISNULL(SUM(dbo.fnMFConvertQuantityToTargetItemUOM(T.intWeightUOMId, OD.intWeightUOMId, T.dblWeight)), 0) dblTotalTaskWeight
		,OD.dblWeight
	FROM tblMFOrderDetail OD
	LEFT JOIN tblMFTask T ON OD.intItemId = T.intItemId
		AND OD.intOrderHeaderId = T.intOrderHeaderId
	WHERE OD.intOrderHeaderId = @intOrderHeaderId and OD.dblQty >0
	GROUP BY OD.intItemId
		,OD.dblWeight

	SELECT @intTaskRecordId = MIN(intTaskRecordId)
	FROM @tblTaskGenerated

	WHILE (ISNULL(@intTaskRecordId, 0) <> 0)
	BEGIN
		SET @dblTotalTaskWeight = NULL
		SET @dblLineItemWeight = NULL
		SET @ysnAllTasksNotGenerated = 0

		SELECT @dblTotalTaskWeight = dblTotalTaskWeight
			,@dblLineItemWeight = dblLineItemWeight
		FROM @tblTaskGenerated
		WHERE intTaskRecordId = @intTaskRecordId

		IF (@dblTotalTaskWeight < @dblLineItemWeight)
		BEGIN
			SET @ysnAllTasksNotGenerated = 1

			BREAK;
		END

		SELECT @intTaskRecordId = MIN(intTaskRecordId)
		FROM @tblTaskGenerated
		WHERE intTaskRecordId > @intTaskRecordId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH
