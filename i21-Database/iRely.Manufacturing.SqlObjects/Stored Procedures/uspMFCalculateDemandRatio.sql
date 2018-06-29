CREATE PROC dbo.uspMFCalculateDemandRatio (@tblMFWorkOrder ScheduleTable READONLY)
AS
BEGIN
	DECLARE @tblWorkOrderDemandRatio TABLE (
		intWorkOrderId INT
		,intDemandRatio INT
		)
	DECLARE @tblMFInventory TABLE (
		intRecordId INT IDENTITY(1, 1)
		,intLocationId INT
		,dblDemandQty NUMERIC(18, 6)
		,dblQOH NUMERIC(38, 20)
		,dblOrderQty NUMERIC(18, 6)
		)
	DECLARE @intRecordId INT
		,@intWorkOrderId INT
		,@intItemId INT
		,@intExecutionOrder INT
		,@dblPriorQuantity NUMERIC(18, 6)
		,@dblTotalShortage NUMERIC(38, 20)
		,@dblShortage NUMERIC(38, 20)
		,@dblAvailQty NUMERIC(38, 20)
		,@dblLogonLocationAvl NUMERIC(38, 20)
		,@intRatio INT
		,@intRatioCalc INT
		,@dblTotalQOH NUMERIC(38, 20)
		,@intInvRecordId INT
		,@intLocationId INT
		,@intLogonLocationId INT
		,@dblDemandQty NUMERIC(18, 6)
		,@dblQOH NUMERIC(38, 20)
		,@dblOrderQty NUMERIC(18, 6)
		,@intDemandRatio INT
		,@dblLogonLocationShortage NUMERIC(38, 20)
		,@dblOnHand NUMERIC(38, 20)
		,@dblOnOrderQty NUMERIC(18, 6)
		,@dblReorderPoint NUMERIC(18, 6)

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFWorkOrder

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SET @intWorkOrderId = NULL
		SET @intItemId = NULL
		SET @intExecutionOrder = NULL
		SET @dblPriorQuantity = 0

		SELECT @intWorkOrderId = intWorkOrderId
			,@intItemId = intItemId
			,@intExecutionOrder = intExecutionOrder
			,@intLogonLocationId = intLocationId
		FROM @tblMFWorkOrder
		WHERE intRecordId = @intRecordId

		IF @intExecutionOrder > 0
		BEGIN
			SELECT @dblPriorQuantity = SUM(dblQuantity)
			FROM @tblMFWorkOrder
			WHERE intItemId = @intItemId
				AND intExecutionOrder < @intExecutionOrder
				AND intExecutionOrder > 0
		END
		ELSE
		BEGIN
			SELECT @dblPriorQuantity = SUM(dblQuantity)
			FROM @tblMFWorkOrder
			WHERE intItemId = @intItemId
				AND intWorkOrderId < @intWorkOrderId
				AND intExecutionOrder = 0
		END

		SELECT @dblTotalShortage = 0
			,@dblShortage = 0
			,@dblAvailQty = 0
			,@dblLogonLocationAvl = 0
			,@intRatio = 9999
			,@intRatioCalc = 9999
			,@dblTotalQOH = 0

		DELETE
		FROM @tblMFInventory

		INSERT INTO @tblMFInventory (
			intLocationId
			,dblDemandQty
			,dblQOH
			,dblOrderQty
			)
		SELECT intLocationId
			,CASE 
				WHEN ISNULL(SUM(dblOnOrderQty), 0) > ISNULL(SUM(dblReorderPoint), 0)
					THEN ISNULL(SUM(dblOnOrderQty), 0)
				ELSE ISNULL(SUM(dblReorderPoint), 0)
				END
			,ISNULL(SUM(dblOnHand), 0)
			,ISNULL(SUM(dblOnOrderQty), 0)
		FROM tblMFItemDemand
		WHERE intItemId = @intItemId
			AND SUBSTRING(strWarehouseName, 3, 2) NOT IN (
				'AF'
				,'QC'
				)
		GROUP BY intLocationId

		SELECT @intInvRecordId = MIN(intRecordId)
		FROM @tblMFInventory

		WHILE @intInvRecordId IS NOT NULL
		BEGIN
			SET @intLocationId = NULL
			SET @dblDemandQty = NULL
			SET @dblQOH = NULL
			SET @dblOrderQty = NULL

			SELECT @intLocationId = intLocationId
				,@dblDemandQty = dblDemandQty
				,@dblQOH = dblQOH
				,@dblOrderQty = dblOrderQty
			FROM @tblMFInventory
			WHERE intRecordId = @intInvRecordId

			SELECT @dblTotalQOH = @dblQOH

			IF @dblPriorQuantity > 0
				AND @intLocationId = @intLogonLocationId
			BEGIN
				SELECT @dblTotalQOH = @dblTotalQOH + @dblPriorQuantity
			END

			IF @dblOrderQty > 0
				AND @dblOrderQty > @dblTotalQOH
			BEGIN
				SELECT @dblTotalShortage = @dblTotalShortage + (@dblOrderQty - @dblTotalQOH)

				SELECT @dblShortage = @dblShortage + (@dblOrderQty - @dblTotalQOH)

				IF @intLocationId = @intLogonLocationId
				BEGIN
					SELECT @dblLogonLocationShortage = (@dblOrderQty - @dblTotalQOH)

					SELECT @dblLogonLocationAvl = 0
				END

				SELECT @intRatioCalc = - 9999

				IF (@intRatioCalc < @intRatio)
					SELECT @intRatio = @intRatioCalc
			END
			ELSE IF (@dblDemandQty > @dblTotalQOH)
			BEGIN
				SELECT @dblTotalShortage = @dblTotalShortage + (@dblDemandQty - @dblTotalQOH)

				IF @intLocationId = @intLogonLocationId
				BEGIN
					SELECT @dblLogonLocationShortage = (@dblDemandQty - @dblTotalQOH)

					SELECT @dblLogonLocationAvl = 0
				END

				SELECT @intRatioCalc = 9999

				IF @dblDemandQty <> 0
				BEGIN
					SELECT @intRatioCalc = (((@dblTotalQOH - @dblDemandQty) / @dblDemandQty) * 100)
				END

				IF @intRatioCalc < @intRatio
					AND @intLocationId <> @intLogonLocationId
					SELECT @intRatio = @intRatioCalc
			END
			ELSE
			BEGIN
				IF @intLocationId = @intLogonLocationId
				BEGIN
					SELECT @dblLogonLocationShortage = 0

					SELECT @dblLogonLocationAvl = @dblTotalQOH
				END
			END

			SELECT @intRecordId = MIN(intRecordId)
			FROM @tblMFInventory
			WHERE intRecordId > @intInvRecordId
		END

		SELECT @dblOnHand = 0

		SELECT @dblOnOrderQty = 0

		SELECT @dblReorderPoint = 0

		SELECT @dblOnHand = ISNULL(SUM(dblOnHand), 0)
			,@dblOnOrderQty = ISNULL(SUM(dblOnOrderQty), 0)
			,@dblReorderPoint = ISNULL(SUM(dblReorderPoint), 0)
		FROM dbo.tblMFItemDemand
		WHERE intItemId = @intItemId

		IF @dblPriorQuantity > 0
			SELECT @dblOnHand = @dblOnHand + @dblPriorQuantity

		SELECT @dblDemandQty = CASE 
				WHEN @dblOnOrderQty > @dblReorderPoint
					THEN @dblOnOrderQty
				ELSE @dblReorderPoint
				END

		SELECT @dblAvailQty = @dblOnHand - @dblDemandQty

		IF (
				@dblReorderPoint = 0
				AND @dblOnHand >= @dblDemandQty
				)
			OR @dblDemandQty = 0
		BEGIN
			SELECT @intDemandRatio = 9999
		END
		ELSE
		BEGIN
			SELECT @intDemandRatio = (@dblAvailQty / @dblDemandQty) * 100
		END

		IF (@dblTotalShortage - @dblShortage) > @dblLogonLocationAvl
		BEGIN
			IF @dblLogonLocationAvl = 0
				OR (@dblTotalShortage - @dblShortage = 0)
			BEGIN
				SELECT @intDemandRatio = @intRatio
			END
			ELSE
			BEGIN
				SELECT @intDemandRatio = ((@dblLogonLocationAvl - (@dblTotalShortage - @dblShortage)) / (@dblTotalShortage - @dblShortage)) * 100
			END
		END

		IF (@dblLogonLocationAvl - @dblTotalShortage) < 0
			SELECT @intDemandRatio = - 9999

		IF @intDemandRatio > 9999
			SET @intDemandRatio = 9999

		IF @intDemandRatio < - 9999
			SET @intDemandRatio = - 9999

		UPDATE @tblWorkOrderDemandRatio
		SET intDemandRatio = @intDemandRatio
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @intRecordId = Min(intRecordId)
		FROM @tblMFWorkOrder
		WHERE intRecordId > @intRecordId
	END

	SELECT *
	FROM @tblWorkOrderDemandRatio

	RETURN
END
