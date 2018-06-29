CREATE PROCEDURE uspWHGeneratePickTask
		@intOrderHeaderId INT,
		@strUserName NVARChAR(100)
AS 
BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @AllowablePickDayRange INT = 30
	DECLARE @RequiredQty NUMERIC(18,6)

	DECLARE @strBOLNo NVARCHAR(100)
	DECLARE @strOrderType NVARCHAR(10)
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intTransactionCount INT
	DECLARE @dtmCurrentDateTime DATETIME
	DECLARE @dtmCurrentDate DATETIME
	DECLARE @intDayOfYear INT
	
	DECLARE @intSKURecordId INT
	DECLARE @intItemRecordId INT
	DECLARE @intOrderLineItemId INT
	DECLARE @intItemId INT
	DECLARE @dblRequiredQty NUMERIC(18,6)
	DECLARE @ysnStrictTracking BIT
	DECLARE @intSKUId INT
	DECLARE @intUserSecurityId INT
	DECLARE @intTaskTypeId INT
	DECLARE @intLineItemLotId INT

	DECLARE @dblPutbackQty NUMERIC(16,8)
	DECLARE @dblQty NUMERIC(18,6)
	DECLARE @dblRemainingSKUQty NUMERIC(18,6)
	
	SELECT @intTransactionCount = @@TRANCOUNT
	SELECT @dtmCurrentDateTime	= GETDATE()
	SELECT @dtmCurrentDate		= CONVERT(DATETIME, CONVERT(CHAR, @dtmCurrentDateTime, 101))
	SELECT @intDayOfYear		= DATEPART(dy,@dtmCurrentDateTime)
		
	SELECT @strOrderType=ot.strInternalCode 
	FROM tblWHOrderHeader oh 
	JOIN tblWHOrderType ot ON ot.intOrderTypeId=oh.intOrderTypeId 
	WHERE intOrderHeaderId = @intOrderHeaderId

	SELECT @strBOLNo=strBOLNo 
	FROM tblWHOrderHeader 
	WHERE intOrderHeaderId = @intOrderHeaderId
 
	SELECT @intUserSecurityId = [intEntityId] -- this is a hiccup
	FROM tblSMUserSecurity
	WHERE strUserName = @strUserName

 	IF @intTransactionCount = 0
	BEGIN TRANSACTION
	
		DECLARE @tblLineItem TABLE 
		(intItemRecordId INT Identity(1, 1),
		intOrderHeaderId INT, 
		intOrderLineItemId INT, 
		intItemId INT,
		dblRequiredQty NUMERIC(18, 6),
		ysnStrictTracking BIT,
		intLotId INT
		)

		DECLARE @tblSKU TABLE
		(intSKURecordId INT Identity(1,1),
		intSKUId INT,
		intItemId INT,
		dblQty NUMERIC(18,6),
		dblRemainingSKUQty NUMERIC(18,6),
		dtmProductionDate DATETIME,
		intGroupId INT
		)
		
		IF EXISTS (SELECT * FROM tblWHTask WHERE intOrderHeaderId = @intOrderHeaderId AND ISNULL(intAssigneeId, 0) = 0 AND ( intTaskTypeId IN ( 2 ,7 ,13 )))
		BEGIN
			DELETE
			FROM tblWHTask
			WHERE intOrderHeaderId = @intOrderHeaderId
				AND ISNULL(intAssigneeId, 0) = 0
				AND (
						intTaskTypeId IN (2,7,13)
					)
		END

		
		INSERT INTO @tblLineItem (
			intOrderHeaderId,
			intOrderLineItemId,
			intItemId,
			dblRequiredQty,
			ysnStrictTracking,
			intLotId
			)
			SELECT DISTINCT oh.intOrderHeaderId, 
							oli.intOrderLineItemId, 
							i.intItemId, 
							oli.dblQty - ISNULL((
										 SELECT SUM(CASE 
													WHEN t.intTaskTypeId = 13
														THEN s.dblQty - t.dblQty
													ELSE t.dblQty
													END)
										 FROM tblWHTask t
										 JOIN tblWHSKU s ON s.intSKUId = t.intSKUId
										 WHERE t.intOrderHeaderId = oh.intOrderHeaderId
											AND t.intItemId = oli.intItemId
										), 0) dblRemainingLineItemQty, 
							i.ysnStrictFIFO,
							oli.intLotId
			FROM tblWHOrderHeader oh
			JOIN tblWHOrderLineItem oli ON oh.intOrderHeaderId = oli.intOrderHeaderId
			JOIN tblICItem i ON i.intItemId = oli.intItemId
			WHERE oh.intOrderHeaderId = @intOrderHeaderId
		
		SELECT @intItemRecordId = MIN(intItemRecordId)
		FROM @tblLineItem
 
		WHILE (@intItemRecordId IS NOT NULL)
		BEGIN
			SET @intSKURecordId = NULL
			SET @intItemId = NULL
			SET @dblRequiredQty = NULL
			SET @dblPutbackQty = NULL
			SET @ysnStrictTracking = NULL
			SET @dblRequiredQty = NULL
			SET @dblQty = NULL
			SET @intLineItemLotId = NULL

			DELETE FROM @tblSKU
			
			SELECT @intOrderLineItemId = @intOrderLineItemId,
				   @intItemId=intItemId,
				   @dblRequiredQty=dblRequiredQty,
				   @ysnStrictTracking=ysnStrictTracking ,
				   @intLineItemLotId = intLotId
			FROM @tblLineItem
			WHERE intItemRecordId = @intItemRecordId

	IF @strOrderType = 'SS'		
	BEGIN
			INSERT INTO @tblSKU (intSKUId, 
								 intItemId, 
								 dblQty, 
								 dblRemainingSKUQty, 
								 dtmProductionDate,
								 intGroupId)
			SELECT s.intSKUId, 
				   s.intItemId, 
				   s.dblQty, 
				   s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) AS dblRemainingSKUQty, 
				   s.dtmProductionDate,1
			FROM tblWHSKU s
			LEFT JOIN tblWHTask t ON t.intSKUId = s.intSKUId AND t.intTaskTypeId NOT IN (5,6,8,9,10,11)
			WHERE s.intItemId = @intItemId
				AND dtmProductionDate BETWEEN (
							SELECT MIN(dtmProductionDate)
							FROM tblWHSKU
							WHERE intItemId = @intItemId
							)
					AND (
							SELECT MIN(dtmProductionDate) + @AllowablePickDayRange
							FROM tblWHSKU
							WHERE intItemId = @intItemId
							)
					AND s.intSKUStatusId IN (1,2)
					AND ISNULL(s.intLotId,0) = ISNULL((CASE WHEN @intLineItemLotId IS NULL THEN s.intLotId ELSE @intLineItemLotId END ),0)
			GROUP BY s.intSKUId, s.intItemId, s.dblQty, s.dtmProductionDate
			HAVING s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) > 0
			ORDER BY ABS((s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0)))) - @dblRequiredQty), s.dtmProductionDate ASC

			INSERT INTO @tblSKU (intSKUId, 
									intItemId, 
									dblQty, 
									dblRemainingSKUQty, 
									dtmProductionDate,
									intGroupId)
			SELECT s.intSKUId, 
					s.intItemId, 
					s.dblQty, 
					s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) AS dblRemainingSKUQty, 
					s.dtmProductionDate,2
			FROM tblWHSKU s
			LEFT JOIN tblWHTask t ON t.intSKUId = s.intSKUId AND t.intTaskTypeId NOT IN (5,6,8,9,10,11)
			WHERE s.intItemId = @intItemId
					AND s.intSKUStatusId IN (1,2)
					AND NOT EXISTS (SELECT * FROM @tblSKU WHERE intSKUId = s.intSKUId)
					AND ISNULL(s.intLotId,0) = ISNULL((CASE WHEN @intLineItemLotId IS NULL THEN s.intLotId ELSE @intLineItemLotId END ),0)
			GROUP BY s.intSKUId, s.intItemId, s.dblQty, s.dtmProductionDate
			HAVING s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) > 0
			ORDER BY ABS((s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0)))) - @dblRequiredQty), s.dtmProductionDate ASC
	END
	ELSE 
	BEGIN
				INSERT INTO @tblSKU (intSKUId, 
								 intItemId, 
								 dblQty, 
								 dblRemainingSKUQty, 
								 dtmProductionDate,
								 intGroupId)
				SELECT s.intSKUId, 
					   s.intItemId, 
					   s.dblQty, 
					   s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) AS dblRemainingSKUQty, 
					   s.dtmProductionDate,1
				FROM tblWHSKU s
				LEFT JOIN tblWHTask t ON t.intSKUId = s.intSKUId AND t.intTaskTypeId NOT IN (5,6,8,9,10,11)
				WHERE s.intItemId = @intItemId
					AND dtmProductionDate BETWEEN (
								SELECT MIN(dtmProductionDate)
								FROM tblWHSKU
								WHERE intItemId = @intItemId
								)
						AND (
								SELECT MIN(dtmProductionDate) + @AllowablePickDayRange
								FROM tblWHSKU
								WHERE intItemId = @intItemId
								)
						AND s.intSKUStatusId = 1
						AND ISNULL(s.intLotId,0) = ISNULL((CASE WHEN @intLineItemLotId IS NULL THEN s.intLotId ELSE @intLineItemLotId END ),0)
				GROUP BY s.intSKUId, s.intItemId, s.dblQty, s.dtmProductionDate
				HAVING s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) > 0
				ORDER BY ABS((s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0)))) - @dblRequiredQty), s.dtmProductionDate ASC

				INSERT INTO @tblSKU (intSKUId, 
										intItemId, 
										dblQty, 
										dblRemainingSKUQty, 
										dtmProductionDate,
										intGroupId)
				SELECT s.intSKUId, 
						s.intItemId, 
						s.dblQty, 
						s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) AS dblRemainingSKUQty, 
						s.dtmProductionDate,2
				FROM tblWHSKU s
				LEFT JOIN tblWHTask t ON t.intSKUId = s.intSKUId AND t.intTaskTypeId NOT IN (5,6,8,9,10,11)
				WHERE s.intItemId = @intItemId
						AND s.intSKUStatusId = 1
						AND NOT EXISTS (SELECT * FROM @tblSKU WHERE intSKUId = s.intSKUId)
						AND ISNULL(s.intLotId,0) = ISNULL((CASE WHEN @intLineItemLotId IS NULL THEN s.intLotId ELSE @intLineItemLotId END ),0)
				GROUP BY s.intSKUId, s.intItemId, s.dblQty, s.dtmProductionDate
				HAVING s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0))) > 0
				ORDER BY ABS((s.dblQty - (SUM(ISNULL(CASE WHEN t.intTaskTypeId = 13 THEN s.dblQty-t.dblQty ELSE  t.dblQty END,0)))) - @dblRequiredQty), s.dtmProductionDate ASC
	END

			SELECT @intSKURecordId = MIN(intSKURecordId) 
			FROM @tblSKU 
			
			WHILE (@intSKURecordId IS NOT NULL)
			BEGIN
					SELECT @dblQty = dblQty, @intSKUId = intSKUId, @dblRemainingSKUQty = dblRemainingSKUQty FROM @tblSKU WHERE intSKURecordId = @intSKURecordId				
			
					IF (@dblRemainingSKUQty > @dblRequiredQty) AND (@dblRequiredQty > (@dblRemainingSKUQty/2))
					BEGIN
						SET @dblPutbackQty = @dblRemainingSKUQty - @dblRequiredQty
						--SELECT 1,@intItemId
						EXEC [uspWHCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId, 
														   @intSKUId = @intSKUId,
														   @strUserName = @strUserName, 
														   @dblSplitAndPickQty = @dblPutbackQty,
														   @intTaskTypeId = 13
						SET @dblRequiredQty = @dblRequiredQty - @dblRemainingSKUQty
						IF @dblRequiredQty <= 0
						BEGIN
							BREAK;
						END
					END
					ELSE IF (@dblRemainingSKUQty <= @dblRequiredQty) AND @dblQty = @dblRemainingSKUQty
					BEGIN
						EXEC [uspWHCreatePickTask] @intOrderHeaderId = @intOrderHeaderId,
												   @intSKUId = @intSKUId,
												   @strUserName = @strUserName
						SET @dblRequiredQty = @dblRequiredQty - @dblQty
						--SELECT 2,@intItemId
						IF @dblRequiredQty <= 0
						BEGIN
							BREAK;
						END
					END
					ELSE
					BEGIN
						IF @dblRequiredQty <= 0
						BEGIN
							BREAK;
						END
						IF (@dblRemainingSKUQty <= @dblRequiredQty)
						BEGIN
								EXEC [uspWHCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId, 
																   @intSKUId = @intSKUId,
																   @strUserName = @strUserName, 
																   @dblSplitAndPickQty = @dblRemainingSKUQty,
																   @intTaskTypeId = 7
						END
						ELSE 
						BEGIN
								EXEC [uspWHCreateSplitAndPickTask] @intOrderHeaderId = @intOrderHeaderId, 
																   @intSKUId = @intSKUId,
																   @strUserName = @strUserName, 
																   @dblSplitAndPickQty = @dblRequiredQty,
																   @intTaskTypeId = 7
						END--SELECT 3,@intItemId
						SET @dblRequiredQty = @dblRequiredQty - @dblQty
						IF @dblRequiredQty <= 0
						BEGIN
							BREAK;
						END
					END
					DELETE FROM @tblSKU WHERE intSKUId = @intSKUId
					SET @intSKURecordId = NULL
					
					SELECT TOP 1 @intSKURecordId = intSKURecordId
					FROM @tblSKU s WHERE intGroupId = 1
					ORDER BY ABS(s.dblQty - @dblRequiredQty) ASC

					IF @intSKURecordId IS NULL
					BEGIN 
						SELECT TOP 1 @intSKURecordId = intSKURecordId
						FROM @tblSKU s WHERE intGroupId = 2
						ORDER BY ABS(s.dblQty - @dblRequiredQty) ASC
					END
			END
			SELECT @intItemRecordId = MIN(intItemRecordId)
			FROM @tblLineItem WHERE intItemRecordId > @intItemRecordId
		END
 
	IF @intTransactionCount = 0
	COMMIT TRANSACTION		
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0 AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')

END CATCH