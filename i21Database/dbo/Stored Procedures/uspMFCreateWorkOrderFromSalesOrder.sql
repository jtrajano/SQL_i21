CREATE PROCEDURE [dbo].[uspMFCreateWorkOrderFromSalesOrder] @strXml NVARCHAR(Max)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intSalesOrderDetailId INT
	DECLARE @intLocationId INT
	DECLARE @intRecipeId INT
	DECLARE @strWorkOrderNo NVARCHAR(50)
	DECLARE @intItemId INT
	DECLARE @dblQuantity NUMERIC(18, 6)
	DECLARE @intItemUOMId INT
	DECLARE @dtmDueDate DATETIME
	DECLARE @intCellId INT
	DECLARE @intUserId INT
	DECLARE @intAttributeTypeId INT
	DECLARE @intManufacturingProcessId INT
	DECLARE @strDemandNo NVARCHAR(50)
	DECLARE @intUOMId INT
	DECLARE @dtmCurrentDate DATETIME = GetDate()
	DECLARE @intBlendRequirementId INT
	DECLARE @intMachineId INT
	DECLARE @dblBlendBinSize NUMERIC(18, 6)
	DECLARE @ysnKittingEnabled BIT
	DECLARE @ErrMsg NVARCHAR(max)
	DECLARE @idoc INT
	DECLARE @ysnBlendSheetRequired BIT
	DECLARE @intWorkOrderStatusId INT
	DECLARE @intKitStatusId INT
	DECLARE @intWokrOrderId INT
	DECLARE @intExecutionOrder INT = 1
	DECLARE @intNoOfSheet INT
	DECLARE @intSubLocationId INT
	DECLARE @intCustomerId INT
	DECLARE @strSalesOrderNo NVARCHAR(50)
	DECLARE @intNoOfSheetCounter INT = 0
	DECLARE @intNoOfSheetOrig INT
	DECLARE @strWorkOrderNoOrig NVARCHAR(50)
	DECLARE @ysnRequireCustomerApproval BIT
	DECLARE @intMinWO INT
	DECLARE @intCategoryId INT
	DECLARE @strItemNo NVARCHAR(50)
	DECLARE @strOrderType NVARCHAR(50)
	DECLARE @intInvoiceDetailId INT
	DECLARE @intLoadDistributionDetailId INT
	DECLARE @dtmPlannedDate DATETIME
	DECLARE @intPlannedShiftId INT
	DECLARE @intTransactionFrom INT
	DECLARE @dtmBusinessDate DATETIME
	DECLARE @intSalesRepresentativeId INT
	DECLARE @tblWO AS TABLE (
		intRowNo INT IDENTITY
		,dblQuantity NUMERIC(18, 6)
		,dtmDueDate DATETIME
		,intCellId INT
		,intMachineId INT
		,dblMachineCapacity NUMERIC(18, 6)
		,dtmPlannedDate DATETIME
		,intPlannedShiftId INT
		)

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	SELECT @intSalesOrderDetailId = intSalesOrderDetailId
		,@intInvoiceDetailId = intInvoiceDetailId
		,@intLoadDistributionDetailId = intLoadDistributionDetailId
		,@strOrderType = strOrderType
		,@intLocationId = intLocationId
		,@intRecipeId = intRecipeId
		,@intItemId = intItemId
		,@intItemUOMId = intItemUOMId
		,@intUserId = intUserId
		,@intTransactionFrom = intTransactionFrom
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intSalesOrderDetailId INT
			,intInvoiceDetailId INT
			,intLoadDistributionDetailId INT
			,strOrderType NVARCHAR(50)
			,intLocationId INT
			,intRecipeId INT
			,intItemId INT
			,intItemUOMId INT
			,intUserId INT
			,intTransactionFrom INT
			)

	INSERT INTO @tblWO (
		dblQuantity
		,dtmDueDate
		,intCellId
		,intMachineId
		,dblMachineCapacity
		,dtmPlannedDate
		,intPlannedShiftId
		)
	SELECT dblQuantity
		,dtmDueDate
		,intCellId
		,intMachineId
		,dblMachineCapacity
		,dtmPlannedDate
		,intPlannedShiftId
	FROM OPENXML(@idoc, 'root/wo', 2) WITH (
			dblQuantity NUMERIC(18, 6)
			,dtmDueDate DATETIME
			,intCellId INT
			,intMachineId INT
			,dblMachineCapacity NUMERIC(18, 6)
			,dtmPlannedDate DATETIME
			,intPlannedShiftId INT
			)

	IF @intSalesOrderDetailId = 0
		SET @intSalesOrderDetailId = NULL

	IF @intInvoiceDetailId = 0
		SET @intInvoiceDetailId = NULL

	IF @intLoadDistributionDetailId = 0
		SET @intLoadDistributionDetailId = NULL

	UPDATE @tblWO
	SET intPlannedShiftId = NULL
	WHERE intPlannedShiftId = 0

	SELECT @intItemUOMId = intItemUOMId
	FROM tblMFRecipe
	WHERE intRecipeId = @intRecipeId

	SELECT @intManufacturingProcessId = r.intManufacturingProcessId
		,@intAttributeTypeId = mp.intAttributeTypeId
	FROM tblMFRecipe r
	JOIN tblMFManufacturingProcess mp ON r.intManufacturingProcessId = mp.intManufacturingProcessId
	WHERE r.intItemId = @intItemId
		AND r.intLocationId = @intLocationId
		AND r.ysnActive = 1

	IF ISNULL(@intManufacturingProcessId, 0) = 0
	BEGIN
		SELECT @strItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SET @ErrMsg = 'No active recipe found for item ' + @strItemNo + '.'

		RAISERROR (
				@ErrMsg
				,16
				,1
				)
	END

	SELECT TOP 1 @intCustomerId = sh.intEntityCustomerId
		,@strSalesOrderNo = sh.strSalesOrderNumber
		,@intSalesRepresentativeId = sh.intEntitySalespersonId
	FROM tblSOSalesOrder sh
	JOIN tblSOSalesOrderDetail sd ON sh.intSalesOrderId = sd.intSalesOrderId
	WHERE sd.intSalesOrderDetailId = @intSalesOrderDetailId

	BEGIN TRAN

	IF @intAttributeTypeId = 2 --Blending
	BEGIN
		--Validation
		SELECT @intMinWO = Min(intRowNo)
		FROM @tblWO

		WHILE (@intMinWO IS NOT NULL)
		BEGIN
			SELECT @dblQuantity = dblQuantity
				,@intCellId = intCellId
				,@intMachineId = intMachineId
				,@dblBlendBinSize = dblMachineCapacity
				,@dtmPlannedDate = dtmPlannedDate
				,@intPlannedShiftId = intPlannedShiftId
			FROM @tblWO
			WHERE intRowNo = @intMinWO

			IF @dtmPlannedDate IS NULL
			BEGIN
				SET @dtmPlannedDate = Convert(DATETIME, Convert(CHAR, GETDATE(), 101))

				SELECT @intPlannedShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND @dtmCurrentDate BETWEEN GETDATE() + dtmShiftStartTime + intStartOffset
						AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

				IF @intPlannedShiftId IS NULL
				BEGIN
					SELECT @intPlannedShiftId = intShiftId
					FROM dbo.tblMFShift
					WHERE intLocationId = @intLocationId
						AND intShiftSequence = 1
				END
			END

			IF @intPlannedShiftId IS NULL
			BEGIN
				SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmPlannedDate, @intLocationId)

				SELECT @intPlannedShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
						AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

				IF @intPlannedShiftId IS NULL
				BEGIN
					SELECT @intPlannedShiftId = intShiftId
					FROM dbo.tblMFShift
					WHERE intLocationId = @intLocationId
						AND intShiftSequence = 1
				END
			END

			IF ISNULL(@intMachineId, 0) = 0
				SELECT TOP 1 @intMachineId = m.intMachineId
					,@dblBlendBinSize = mp.dblMachineCapacity
				FROM tblMFMachine m
				JOIN tblMFMachinePackType mp ON m.intMachineId = mp.intMachineId
				JOIN tblMFManufacturingCellPackType mcp ON mp.intPackTypeId = mcp.intPackTypeId
				JOIN tblMFManufacturingCell mc ON mcp.intManufacturingCellId = mc.intManufacturingCellId
				WHERE mc.intManufacturingCellId = @intCellId

			IF ISNULL(@intMachineId, 0) = 0
				RAISERROR (
						'Machine is not defined for the Manufacturing Cell'
						,16
						,1
						)

			IF ISNULL(@dblBlendBinSize, 0) = 0
				RAISERROR (
						'Blend Bin Size is zero for the machine'
						,16
						,1
						)

			IF @dblQuantity > @dblBlendBinSize
				RAISERROR (
						'Quantity cannot be greater than blend bin size'
						,16
						,1
						)

			SELECT @intMinWO = Min(intRowNo)
			FROM @tblWO
			WHERE intRowNo > @intMinWO
		END

		SELECT TOP 1 @ysnBlendSheetRequired = ISNULL(ysnBlendSheetRequired, 0)
		FROM tblMFCompanyPreference

		SELECT @ysnRequireCustomerApproval = ysnRequireCustomerApproval
		FROM tblICItem
		WHERE intItemId = @intItemId

		IF @ysnBlendSheetRequired = 1
			SET @intWorkOrderStatusId = 2 --Not Released
		ELSE
		BEGIN
			IF @ysnRequireCustomerApproval = 1
				SET @intWorkOrderStatusId = 5 --Hold
			ELSE
				SET @intWorkOrderStatusId = 9 --Released
		END

		SELECT @intUOMId = intUnitMeasureId
		FROM tblICItemUOM
		WHERE intItemUOMId = @intItemUOMId
			AND intItemId = @intItemId

		SELECT @ysnKittingEnabled = CASE 
				WHEN UPPER(pa.strAttributeValue) = 'TRUE'
					THEN 1
				ELSE 0
				END
		FROM tblMFManufacturingProcessAttribute pa
		JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND at.strAttributeName = 'Enable Kitting'

		IF @ysnKittingEnabled = 1
			SET @intKitStatusId = 6
		ELSE
			SET @intKitStatusId = NULL

		EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
			,@intItemId = @intItemId
			,@intManufacturingId = NULL
			,@intSubLocationId = @intSubLocationId
			,@intLocationId = @intLocationId
			,@intOrderTypeId = NULL
			,@intBlendRequirementId = NULL
			,@intPatternCode = 46
			,@ysnProposed = 0
			,@strPatternString = @strDemandNo OUTPUT

		SELECT @dtmDueDate = Min(dtmDueDate)
		FROM @tblWO

		INSERT INTO tblMFBlendRequirement (
			strDemandNo
			,intItemId
			,dblQuantity
			,intUOMId
			,dtmDueDate
			,intLocationId
			,intStatusId
			,dblIssuedQty
			,intCreatedUserId
			,dtmCreated
			,intLastModifiedUserId
			,dtmLastModified
			,intMachineId
			)
		VALUES (
			@strDemandNo
			,@intItemId
			,@dblQuantity
			,@intUOMId
			,@dtmDueDate
			,@intLocationId
			,2
			,@dblQuantity
			,@intUserId
			,@dtmCurrentDate
			,@intUserId
			,@dtmCurrentDate
			,@intMachineId
			)

		SELECT @intBlendRequirementId = SCOPE_IDENTITY()

		INSERT INTO tblMFBlendRequirementRule (
			intBlendRequirementId
			,intBlendSheetRuleId
			,strValue
			,intSequenceNo
			)
		SELECT @intBlendRequirementId
			,a.intBlendSheetRuleId
			,b.strValue
			,a.intSequenceNo
		FROM tblMFBlendSheetRule a
		JOIN tblMFBlendSheetRuleValue b ON a.intBlendSheetRuleId = b.intBlendSheetRuleId
			AND b.ysnDefault = 1

		SELECT @intMinWO = Min(intRowNo)
		FROM @tblWO

		WHILE (@intMinWO IS NOT NULL)
		BEGIN
			SELECT @dblQuantity = dblQuantity
				,@intCellId = intCellId
				,@dtmDueDate = dtmDueDate
				,@intMachineId = intMachineId
				,@dblBlendBinSize = dblMachineCapacity
			FROM @tblWO
			WHERE intRowNo = @intMinWO

			IF ISNULL(@intMachineId, 0) = 0
				SELECT TOP 1 @intMachineId = m.intMachineId
					,@dblBlendBinSize = mp.dblMachineCapacity
				FROM tblMFMachine m
				JOIN tblMFMachinePackType mp ON m.intMachineId = mp.intMachineId
				JOIN tblMFManufacturingCellPackType mcp ON mp.intPackTypeId = mcp.intPackTypeId
				JOIN tblMFManufacturingCell mc ON mcp.intManufacturingCellId = mc.intManufacturingCellId
				WHERE mc.intManufacturingCellId = @intCellId

			EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
				,@intItemId = @intItemId
				,@intManufacturingId = @intCellId
				,@intSubLocationId = 0
				,@intLocationId = @intLocationId
				,@intOrderTypeId = NULL
				,@intBlendRequirementId = @intBlendRequirementId
				,@intPatternCode = 93
				,@ysnProposed = 0
				,@strPatternString = @strWorkOrderNo OUTPUT

			SELECT @intExecutionOrder = Count(1)
			FROM tblMFWorkOrder
			WHERE intManufacturingCellId = @intCellId
				AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
				AND intBlendRequirementId IS NOT NULL
				AND intStatusId NOT IN (
					2
					,13
					)

			SET @intExecutionOrder = @intExecutionOrder + 1

			INSERT INTO tblMFWorkOrder (
				strWorkOrderNo
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intStatusId
				,intManufacturingCellId
				,intMachineId
				,intLocationId
				,dblBinSize
				,dtmExpectedDate
				,intExecutionOrder
				,intProductionTypeId
				,dblPlannedQuantity
				,intBlendRequirementId
				,ysnKittingEnabled
				,intKitStatusId
				,ysnUseTemplate
				,strComment
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,dtmReleasedDate
				,intManufacturingProcessId
				,intSalesOrderLineItemId
				,intSalesRepresentativeId
				,intInvoiceDetailId
				,intLoadDistributionDetailId
				,dtmPlannedDate
				,intPlannedShiftId
				,intCustomerId
				,intConcurrencyId
				,intTransactionFrom
				)
			SELECT @strWorkOrderNo
				,@intItemId
				,@dblQuantity
				,@intItemUOMId
				,@intWorkOrderStatusId
				,@intCellId
				,@intMachineId
				,@intLocationId
				,@dblBlendBinSize
				,@dtmDueDate
				,@intExecutionOrder
				,1
				,@dblQuantity
				,@intBlendRequirementId
				,@ysnKittingEnabled
				,@intKitStatusId
				,0
				,''
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intManufacturingProcessId
				,@intSalesOrderDetailId
				,@intSalesRepresentativeId
				,@intInvoiceDetailId
				,@intLoadDistributionDetailId
				,@dtmPlannedDate
				,@intPlannedShiftId
				,@intCustomerId
				,1
				,ISNULL(@intTransactionFrom, 2) --Work Order Planning(2), AutoBlend(5)

			SELECT @intWokrOrderId = SCOPE_IDENTITY()

			--Copy Recipe
			EXEC uspMFCopyRecipe @intItemId
				,@intLocationId
				,@intUserId
				,@intWokrOrderId

			SELECT @intMinWO = Min(intRowNo)
			FROM @tblWO
			WHERE intRowNo > @intMinWO
		END
	END

	IF @intAttributeTypeId >= 3 --Packaging
	BEGIN
		DECLARE @strWOStatusName NVARCHAR(50)
		DECLARE @intStatusId INT = NULL

		SELECT @strWOStatusName = ISNULL(pa.strAttributeValue, 0)
		FROM tblMFManufacturingProcessAttribute pa
		JOIN tblMFAttribute at ON pa.intAttributeId = at.intAttributeId
		WHERE intManufacturingProcessId = @intManufacturingProcessId
			AND intLocationId = @intLocationId
			AND at.strAttributeName = 'Status for Newly Created Work Order'

		SELECT @intStatusId = intStatusId
		FROM tblMFWorkOrderStatus
		WHERE strName = @strWOStatusName

		IF @intStatusId IS NULL
			SET @intStatusId = 1

		SELECT @intMinWO = Min(intRowNo)
		FROM @tblWO

		WHILE (@intMinWO IS NOT NULL)
		BEGIN
			SELECT @dblQuantity = dblQuantity
				,@intCellId = intCellId
				,@dtmDueDate = dtmDueDate
				,@dtmPlannedDate = dtmPlannedDate
				,@intPlannedShiftId = intPlannedShiftId
			FROM @tblWO
			WHERE intRowNo = @intMinWO

			IF @dtmPlannedDate IS NULL
			BEGIN
				SET @dtmPlannedDate = Convert(DATETIME, Convert(CHAR, GETDATE(), 101))

				SELECT @intPlannedShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND @dtmCurrentDate BETWEEN GETDATE() + dtmShiftStartTime + intStartOffset
						AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

				IF @intPlannedShiftId IS NULL
				BEGIN
					SELECT @intPlannedShiftId = intShiftId
					FROM dbo.tblMFShift
					WHERE intLocationId = @intLocationId
						AND intShiftSequence = 1
				END
			END

			IF @intPlannedShiftId IS NULL
			BEGIN
				SELECT @dtmBusinessDate = dbo.fnGetBusinessDate(@dtmPlannedDate, @intLocationId)

				SELECT @intPlannedShiftId = intShiftId
				FROM dbo.tblMFShift
				WHERE intLocationId = @intLocationId
					AND @dtmCurrentDate BETWEEN @dtmBusinessDate + dtmShiftStartTime + intStartOffset
						AND @dtmBusinessDate + dtmShiftEndTime + intEndOffset

				IF @intPlannedShiftId IS NULL
				BEGIN
					SELECT @intPlannedShiftId = intShiftId
					FROM dbo.tblMFShift
					WHERE intLocationId = @intLocationId
						AND intShiftSequence = 1
				END
			END

			--Get Work Order No
			IF ISNULL(@strWorkOrderNo, '') = ''
				--EXEC dbo.uspSMGetStartingNumber 34
				--	,@strWorkOrderNo OUTPUT
			BEGIN
				EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
					,@intItemId = @intItemId
					,@intManufacturingId = @intCellId
					,@intSubLocationId = @intSubLocationId
					,@intLocationId = @intLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 34
					,@ysnProposed = 0
					,@strPatternString = @strWorkOrderNo OUTPUT
			END

			SELECT @intExecutionOrder = Count(1)
			FROM tblMFWorkOrder
			WHERE intManufacturingCellId = @intCellId
				AND convert(DATE, dtmExpectedDate) = convert(DATE, @dtmDueDate)
				AND intStatusId NOT IN (
					2
					,13
					)

			SET @intExecutionOrder = @intExecutionOrder + 1

			SELECT @intSubLocationId = intSubLocationId
			FROM tblMFManufacturingCell
			WHERE intManufacturingCellId = @intCellId

			SELECT @intItemUOMId = intItemUOMId
			FROM tblSOSalesOrderDetail
			WHERE intSalesOrderDetailId = @intSalesOrderDetailId

			--if the item does not belong to the SO, it is the recipe input item (next level recipe), use stock uom
			IF NOT EXISTS (
					SELECT 1
					FROM tblSOSalesOrderDetail
					WHERE intSalesOrderDetailId = @intSalesOrderDetailId
						AND intItemId = @intItemId
					)
				SELECT @intItemUOMId = intItemUOMId
				FROM tblICItemUOM
				WHERE intItemId = @intItemId
					AND ysnStockUnit = 1

			INSERT INTO tblMFWorkOrder (
				strWorkOrderNo
				,intItemId
				,dblQuantity
				,intItemUOMId
				,intStatusId
				,intManufacturingCellId
				,intMachineId
				,intLocationId
				,dtmExpectedDate
				,intExecutionOrder
				,intProductionTypeId
				,dblPlannedQuantity
				,ysnKittingEnabled
				,ysnUseTemplate
				,strComment
				,dtmCreated
				,intCreatedUserId
				,dtmLastModified
				,intLastModifiedUserId
				,intManufacturingProcessId
				,intSalesOrderLineItemId
				,intSalesRepresentativeId
				,dtmOrderDate
				,dtmPlannedDate
				,intSupervisorId
				,intSubLocationId
				,intCustomerId
				,strSalesOrderNo
				,intPlannedShiftId
				,intConcurrencyId
				,intTransactionFrom
				)
			SELECT @strWorkOrderNo
				,@intItemId
				,@dblQuantity
				,@intItemUOMId
				,@intStatusId
				,@intCellId
				,NULL
				,@intLocationId
				,@dtmDueDate
				,1
				,1
				,@dblQuantity
				,0
				,0
				,''
				,@dtmCurrentDate
				,@intUserId
				,@dtmCurrentDate
				,@intUserId
				,@intManufacturingProcessId
				,@intSalesOrderDetailId
				,@intSalesRepresentativeId
				,@dtmCurrentDate
				,@dtmPlannedDate
				,@intUserId
				,@intSubLocationId
				,@intCustomerId
				,@strSalesOrderNo
				,@intPlannedShiftId
				,1
				,2

			SELECT @intWokrOrderId = SCOPE_IDENTITY()

			--Copy Recipe
			EXEC uspMFCopyRecipe @intItemId
				,@intLocationId
				,@intUserId
				,@intWokrOrderId
				Select @strWorkOrderNo=''
			SELECT @intMinWO = Min(intRowNo)
			FROM @tblWO
			WHERE intRowNo > @intMinWO
		END
	END

	COMMIT TRAN

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
