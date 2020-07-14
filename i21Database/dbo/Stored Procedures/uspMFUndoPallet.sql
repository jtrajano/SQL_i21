CREATE PROCEDURE uspMFUndoPallet (@strXML NVARCHAR(MAX))
AS
BEGIN TRY
	DECLARE @idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intWorkOrderId INT
		,@intLotId INT
		,@intUserId INT
		,@strBatchId NVARCHAR(40)
		,@intTransactionId INT
		,@strTransactionId NVARCHAR(50)
		,@dblQuantity NUMERIC(38, 20)
		,@intItemId INT
		,@intBatchId INT
		,@ysnForceUndo BIT
		,@intTransactionCount INT
		,@intItemUOMId INT
		,@dblPhysicalCount NUMERIC(18, 6)
		,@intLocationId INT
		,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
		,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
		,@ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
		,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
		,@intItemId1 INT
		,@strItemNo1 AS NVARCHAR(50)
		,@intRecipeItemUOMId INT
		,@intItemLocationId INT
		,@INVENTORY_PRODUCE AS INT = 9
		,@dtmDate DATETIME
		,@intTransactionDetailId INT
		,@strLotTracking NVARCHAR(50)
		,@intSpecialPalletLotId INT
		,@strLocationName NVARCHAR(50)
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@intMachineId INT
		,@intManufacturingProcessId INT
		,@strInstantConsumption NVARCHAR(50)
		,@intWorkOrderProducedLotParentId INT
		,@intWorkOrderProducedLotId INT
		,@intBiProductWorkOrderProducedLotId int
		,@intPhysicalItemUOMId INT
		,@dtmProductionDate DATETIME


	DECLARE @GLEntriesForOtherCost TABLE (
		dtmDate DATETIME
		,intItemId INT
		,intChargeId INT
		,intItemLocationId INT
		,intChargeItemLocation INT
		,intTransactionId INT
		,strTransactionId NVARCHAR(50)
		,dblCost NUMERIC(18, 6)
		,intTransactionTypeId INT
		,intCurrencyId INT
		,dblExchangeRate NUMERIC(18, 6)
		,intTransactionDetailId INT
		,strInventoryTransactionTypeName NVARCHAR(50)
		,strTransactionForm NVARCHAR(50)
		,ysnAccrue BIT
		,ysnPrice BIT
		,ysnInventoryCost BIT
		)

	SELECT @dtmDate = GETDATE()

	SELECT @intTransactionCount = @@TRANCOUNT

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intBatchId = intBatchId
		,@intLotId = intLotId
		,@intUserId = intUserId
		,@ysnForceUndo = ysnForceUndo
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intBatchId INT
			,intLotId INT
			,intUserId INT
			,ysnForceUndo BIT
			)

	IF EXISTS (
			SELECT 1
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND intBatchId = @intBatchId
			GROUP BY intWorkOrderId
				,intBatchId
			HAVING Count(*) > 1
			)
	BEGIN
		RAISERROR (
				'Unable to reverse the selected lot/pallet.'
				,11
				,1
				)

		RETURN
	END

	SELECT @intTransactionId = @intBatchId

	SELECT @strTransactionId = strWorkOrderNo
		,@intLocationId = intLocationId
		,@intManufacturingProcessId = intManufacturingProcessId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

		SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 20 --Is Instant Consumption

	SELECT @dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dblPhysicalCount = dblPhysicalCount
		,@intTransactionDetailId = intWorkOrderProducedLotId
		,@intStorageLocationId = intStorageLocationId
		,@intItemId = intItemId
		,@intWorkOrderProducedLotParentId = intWorkOrderProducedLotParentId
		,@intPhysicalItemUOMId = intPhysicalItemUOMId
		,@dtmProductionDate = dtmProductionDate
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	SELECT @strLotTracking = strLotTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	--IF EXISTS (
	--		SELECT *
	--		FROM tblMFWorkOrderProducedLot
	--		WHERE intWorkOrderId = @intWorkOrderId
	--			AND intLotId = @intLotId
	--			AND ysnReleased = 1
	--		)
	--BEGIN
	--	RAISERROR (
	--			51137
	--			,11
	--			,1
	--			)
	--	RETURN
	--END
	IF EXISTS (
			SELECT *
			FROM tblMFWorkOrderProducedLot
			WHERE intWorkOrderId = @intWorkOrderId
				AND intBatchId = @intBatchId
				AND ysnProductionReversed = 1
			)
	BEGIN
		RAISERROR (
				'This lot is already reversed. You can''t undo.'
				,11
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND intLotStatusId = 2
			)
		AND @ysnForceUndo = 0
		AND @strLotTracking <> 'No'
	BEGIN
		RAISERROR (
				'Pallet/Lot has been marked as a ghost and cannot be Undone.'
				,11
				,1
				)

		RETURN
	END

	IF EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE intLotId = @intLotId
				AND dblQty = 0
			)
		AND @ysnForceUndo = 0
		AND @strLotTracking <> 'No'
	BEGIN
		RAISERROR (
				'Production reversal is not allowed for lots having zero qty.'
				,11
				,1
				)

		RETURN
	END

	SELECT @strLotNumber = strLotNumber
	FROM dbo.tblICLot
	WHERE intLotId = @intLotId

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblICLot
			WHERE strLotNumber = @strLotNumber
				AND intStorageLocationId = @intStorageLocationId
				AND dblQty > 0
			)
		AND @strLotTracking <> 'No'
	BEGIN
		RAISERROR (
				'Pallet/Lot cannot be reversed. It is moved/adjusted/shipped.'
				,11
				,1
				)

		RETURN
	END

	IF @intWorkOrderProducedLotParentId IS NOT NULL
	BEGIN
		RAISERROR (
				'You cannot reverse a bi-product. Please try reversing the main product.'
				,11
				,1
				)

		RETURN
	END

	IF NOT EXISTS (
			SELECT *
			FROM tblICInventoryTransaction
			WHERE intTransactionId = @intTransactionId
				AND strTransactionId = @strTransactionId
			)
	BEGIN
		SELECT @strTransactionId = strLotNumber
		FROM tblICLot
		WHERE intLotId = @intLotId
	END

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

	DECLARE @STARTING_NUMBER_BATCH AS INT = 3

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	DECLARE @GLEntries AS RecapTableType
	DECLARE @dblOtherCharges NUMERIC(18, 6)
		,@dblPercentage NUMERIC(18, 6)

	SELECT @dblPercentage = CASE 
			WHEN ysnConsumptionRequired = 1
				AND dblPercentage IS NULL
				THEN 100
			WHEN ysnConsumptionRequired = 0
				AND dblPercentage IS NULL
				THEN 0
			ELSE dblPercentage
			END
	FROM tblMFWorkOrderRecipeItem RI
	WHERE intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = @intItemId

	SELECT @dblOtherCharges = SUM((
				CASE 
					WHEN intMarginById = 2
						THEN ISNULL(P.dblStandardCost, 0) + ISNULL(RI.dblMargin, 0)
					ELSE ISNULL(P.dblStandardCost, 0) + (ISNULL(P.dblStandardCost, 0) * ISNULL(RI.dblMargin, 0) / 100)
					END
				) / R.dblQuantity)
	FROM dbo.tblMFWorkOrderRecipeItem RI
	JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
		AND R.intRecipeId = RI.intRecipeId
	JOIN dbo.tblICItem I ON I.intItemId = RI.intItemId
		AND RI.intRecipeItemTypeId = 1
		AND RI.ysnCostAppliedAtInvoice = 0
		AND I.strType = 'Other Charge'
	JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		AND IL.intLocationId = @intLocationId
	JOIN dbo.tblICItemPricing P ON P.intItemId = I.intItemId
		AND P.intItemLocationId = IL.intItemLocationId
	WHERE RI.intWorkOrderId = @intWorkOrderId

	IF @dblPercentage IS NOT NULL
		SELECT @dblOtherCharges = @dblOtherCharges * @dblPercentage / 100

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0
		AND @strInstantConsumption='True'
	BEGIN
		INSERT INTO @OtherChargesGLAccounts (
			intChargeId
			,intItemLocationId
			,intOtherChargeExpense
			,intOtherChargeIncome
			,intTransactionTypeId
			)
		SELECT intChargeId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(@intItemId, @intItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense)
			,intOtherChargeIncome = dbo.fnGetItemGLAccount(@intItemId, @intItemLocationId, @ACCOUNT_CATEGORY_Inventory)
			,intTransactionTypeId = @INVENTORY_PRODUCE

		SELECT TOP 1 @intItemId1 = Item.intItemId
			,@strItemNo1 = Item.strItemNo
		FROM dbo.tblICItem Item
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE ChargesGLAccounts.intOtherChargeExpense IS NULL

		SELECT TOP 1 @strLocationName = c.strLocationName
		FROM tblICItemLocation il
		INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON ChargesGLAccounts.intChargeId = il.intItemId
			AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE il.intItemId = @intItemId1
			AND ChargesGLAccounts.intOtherChargeExpense IS NULL

		IF @intItemId1 IS NOT NULL
		BEGIN
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008
				,@strItemNo1
				,@strLocationName
				,@ACCOUNT_CATEGORY_OtherChargeExpense;

			RETURN;
		END

		SELECT @intRecipeItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		INSERT INTO @GLEntriesForOtherCost
		SELECT dtmDate = @dtmDate
			,intItemId = @intItemId
			,intChargeId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intChargeItemLocation = @intItemLocationId
			,intTransactionId = @intBatchId
			,strTransactionId = @strTransactionId
			,dblCost = (
				CASE 
					WHEN @intRecipeItemUOMId = @intItemUOMId
						THEN @dblOtherCharges * @dblQuantity
					ELSE @dblOtherCharges * @dblPhysicalCount
					END
				)
			,intTransactionTypeId = @INVENTORY_PRODUCE
			,intCurrencyId = (
				SELECT TOP 1 intDefaultReportingCurrencyId
				FROM tblSMCompanyPreference
				)
			,dblExchangeRate = 1
			,intTransactionDetailId = @intTransactionDetailId
			,strInventoryTransactionTypeName = 'Consume'
			,strTransactionForm = 'Consume'
			,ysnAccrue = 0
			,ysnPrice = 0
			,ysnInventoryCost = 0

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			)
		SELECT dtmDate = GLEntriesForOtherCost.dtmDate
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = Debit.Value
			,dblCredit = Credit.Value
			,dblDebitUnit = 0
			,dblCreditUnit = 0
			,strDescription = GLAccount.strDescription
			,strCode = 'IC'
			,strReference = ''
			,intCurrencyId = GLEntriesForOtherCost.intCurrencyId
			,dblExchangeRate = GLEntriesForOtherCost.dblExchangeRate
			,dtmDateEntered = GETDATE()
			,dtmTransactionDate = GLEntriesForOtherCost.dtmDate
			,strJournalLineDescription = ''
			,intJournalLineNo = GLEntriesForOtherCost.intTransactionDetailId
			,ysnIsUnposted = 0
			,intUserId = NULL
			,intEntityId = @intUserId
			,strTransactionId = GLEntriesForOtherCost.strTransactionId
			,intTransactionId = GLEntriesForOtherCost.intTransactionId
			,strTransactionType = GLEntriesForOtherCost.strInventoryTransactionTypeName
			,strTransactionForm = GLEntriesForOtherCost.strTransactionForm
			,strModuleName = 'Inventory'
			,intConcurrencyId = 1
			,dblDebitForeign = NULL
			,dblDebitReport = NULL
			,dblCreditForeign = NULL
			,dblCreditReport = NULL
			,dblReportingRate = NULL
			,dblForeignRate = NULL
		FROM @GLEntriesForOtherCost GLEntriesForOtherCost
		INNER JOIN @OtherChargesGLAccounts OtherChargesGLAccounts ON GLEntriesForOtherCost.intChargeId = OtherChargesGLAccounts.intChargeId
			AND GLEntriesForOtherCost.intChargeItemLocation = OtherChargesGLAccounts.intItemLocationId
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeExpense
		CROSS APPLY dbo.fnGetDebit(GLEntriesForOtherCost.dblCost) Debit
		CROSS APPLY dbo.fnGetCredit(GLEntriesForOtherCost.dblCost) Credit
		WHERE ISNULL(GLEntriesForOtherCost.ysnAccrue, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnInventoryCost, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnPrice, 0) = 0
	END

	INSERT INTO @GLEntries (
		[dtmDate]
		,[strBatchId]
		,[intAccountId]
		,[dblDebit]
		,[dblCredit]
		,[dblDebitUnit]
		,[dblCreditUnit]
		,[strDescription]
		,[strCode]
		,[strReference]
		,[intCurrencyId]
		,[dblExchangeRate]
		,[dtmDateEntered]
		,[dtmTransactionDate]
		,[strJournalLineDescription]
		,[intJournalLineNo]
		,[ysnIsUnposted]
		,[intUserId]
		,[intEntityId]
		,[strTransactionId]
		,[intTransactionId]
		,[strTransactionType]
		,[strTransactionForm]
		,[strModuleName]
		,[intConcurrencyId]
		,[dblDebitForeign]
		,[dblDebitReport]
		,[dblCreditForeign]
		,[dblCreditReport]
		,[dblReportingRate]
		,[dblForeignRate]
		,[strRateType]
		,[intSourceEntityId]
		,[intCommodityId]
		)
	EXEC dbo.uspICUnpostCosting @intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intUserId
		,0

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET ysnProductionReversed = 1
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	SELECT @dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dblPhysicalCount = dblPhysicalCount
		,@intSpecialPalletLotId = intSpecialPalletLotId
		,@intMachineId = intMachineId
		,@intWorkOrderProducedLotId = intWorkOrderProducedLotId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	IF @intSpecialPalletLotId IS NOT NULL
	BEGIN
		DELETE
		FROM tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intLotId = @intSpecialPalletLotId
	END

	UPDATE tblMFWorkOrder
	SET dblProducedQuantity = isnull(dblProducedQuantity, 0) - (
			CASE 
				WHEN intItemId = @intItemId
					THEN (
							CASE 
								WHEN intItemUOMId = @intItemUOMId
									THEN @dblQuantity
								ELSE @dblPhysicalCount
								END
							)
				ELSE 0
				END
			)
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE tblMFProductionSummary
	SET dblOutputQuantity = dblOutputQuantity - @dblQuantity
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intItemId
		AND IsNULL(intMachineId, 0) = IsNULL(@intMachineId, 0)

	DELETE
	FROM tblMFProductionSummary
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intItemId
		AND IsNULL(intMachineId, 0) = IsNULL(@intMachineId, 0)
		AND dblOutputQuantity = 0



	DECLARE @tblMFWorkOrderConsumedLot TABLE (
		intWorkOrderId INT
		,intItemId INT
		,dblQuantity INT
		,intMachineId INT
		,intWorkOrderConsumedLotId INT
		);

	IF @strInstantConsumption = 'True'
	BEGIN
		DELETE
		FROM dbo.tblMFWorkOrderConsumedLot
		OUTPUT deleted.intWorkOrderId
			,deleted.intItemId
			,deleted.dblQuantity
			,deleted.intMachineId
			,deleted.intWorkOrderConsumedLotId
		INTO @tblMFWorkOrderConsumedLot
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId

		UPDATE PS
		SET dblConsumedQuantity = dblConsumedQuantity - WC.dblQuantity
		FROM tblMFProductionSummary PS
		JOIN @tblMFWorkOrderConsumedLot WC ON PS.intWorkOrderId = WC.intWorkOrderId
			AND PS.intItemId = WC.intItemId
			AND IsNULL(PS.intMachineId, 0) = IsNULL(WC.intMachineId, 0)
		WHERE PS.intWorkOrderId = @intWorkOrderId
			AND PS.intItemId = @intItemId
			AND IsNULL(PS.intMachineId, 0) = IsNULL(@intMachineId, 0)

		INSERT INTO tblMFInventoryAdjustment (
			dtmDate
			,intTransactionTypeId
			,intItemId
			,intSourceLotId
			,dblQty
			,intItemUOMId
			,intUserId
			,intLocationId
			,intStorageLocationId
			,intWorkOrderConsumedLotId
			,intWorkOrderId
			)
		SELECT dtmDate
			,intTransactionTypeId
			,IA.intItemId
			,intSourceLotId
			,- dblQty
			,intItemUOMId
			,intUserId
			,intLocationId
			,intStorageLocationId
			,IA.intWorkOrderConsumedLotId
			,IA.intWorkOrderId
		FROM tblMFInventoryAdjustment IA
		JOIN @tblMFWorkOrderConsumedLot WC ON IA.intWorkOrderConsumedLotId = WC.intWorkOrderConsumedLotId
	END

	DECLARE @tblMFWorkOrderProducedLot TABLE (
		intWorkOrderProducedLotId INT
		,intBatchId INT
		,intItemId INT
		)

	INSERT INTO @tblMFWorkOrderProducedLot (
		intWorkOrderProducedLotId
		,intBatchId
		,intItemId
		)
	SELECT intWorkOrderProducedLotId
		,intBatchId
		,intItemId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderProducedLotParentId = @intWorkOrderProducedLotId

	SELECT @intBiProductWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
	FROM @tblMFWorkOrderProducedLot

	WHILE @intBiProductWorkOrderProducedLotId IS NOT NULL
	BEGIN
		SELECT @intBatchId = NULL

		SELECT @strBatchId = NULL

		SELECT @intItemId = NULL

		SELECT @intBatchId = intBatchId
			,@intItemId = intItemId
		FROM @tblMFWorkOrderProducedLot
		WHERE intWorkOrderProducedLotId = @intBiProductWorkOrderProducedLotId

		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
			,@strBatchId OUTPUT

		INSERT INTO @GLEntries (
			[dtmDate]
			,[strBatchId]
			,[intAccountId]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[strDescription]
			,[strCode]
			,[strReference]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[dtmDateEntered]
			,[dtmTransactionDate]
			,[strJournalLineDescription]
			,[intJournalLineNo]
			,[ysnIsUnposted]
			,[intUserId]
			,[intEntityId]
			,[strTransactionId]
			,[intTransactionId]
			,[strTransactionType]
			,[strTransactionForm]
			,[strModuleName]
			,[intConcurrencyId]
			,[dblDebitForeign]
			,[dblDebitReport]
			,[dblCreditForeign]
			,[dblCreditReport]
			,[dblReportingRate]
			,[dblForeignRate]
			,[strRateType]
			,[intSourceEntityId]
			,[intCommodityId]
			)
		EXEC dbo.uspICUnpostCosting @intBatchId
			,@strTransactionId
			,@strBatchId
			,@intUserId
			,0

		UPDATE dbo.tblMFWorkOrderProducedLot
		SET ysnProductionReversed = 1
			,dtmLastModified = GETDATE()
			,intLastModifiedUserId = @intUserId
		WHERE intWorkOrderProducedLotId = @intBiProductWorkOrderProducedLotId

		UPDATE tblMFProductionSummary
		SET dblOutputQuantity = dblOutputQuantity - @dblQuantity
		WHERE intWorkOrderId = @intWorkOrderId
			AND intItemId = @intItemId
			AND IsNULL(intMachineId, 0) = IsNULL(@intMachineId, 0)

		SELECT @intBiProductWorkOrderProducedLotId = MIN(intWorkOrderProducedLotId)
		FROM @tblMFWorkOrderProducedLot
		WHERE intWorkOrderProducedLotId > @intBiProductWorkOrderProducedLotId
	END

	IF EXISTS (
			SELECT *
			FROM @GLEntries
			)
	BEGIN
		IF EXISTS (
						SELECT *
						FROM tblMFWorkOrderRecipeItem WRI
						JOIN tblICItem I ON I.intItemId = WRI.intItemId
						WHERE I.strType = 'Other Charge'
							AND WRI.intWorkOrderId = @intWorkOrderId
						)
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries
						,0
						,1
				END
				ELSE
				BEGIN
					EXEC dbo.uspGLBookEntries @GLEntries
						,0
				END
	END

	SELECT @dblPhysicalCount = - @dblPhysicalCount

	EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmProductionDate
		,@intTransactionTypeId = 9
		,@intItemId = @intItemId
		,@intSourceLotId = @intLotId
		,@intDestinationLotId = NULL
		,@dblQty = @dblPhysicalCount
		,@intItemUOMId = @intPhysicalItemUOMId
		,@intOldItemId = NULL
		,@dtmOldExpiryDate = NULL
		,@dtmNewExpiryDate = NULL
		,@intOldLotStatusId = NULL
		,@intNewLotStatusId = NULL
		,@intUserId = @intUserId
		,@strNote = NULL
		,@strReason = NULL
		,@intLocationId = @intLocationId
		,@intInventoryAdjustmentId = NULL
		,@intStorageLocationId = @intStorageLocationId
		,@intDestinationStorageLocationId = NULL
		,@intWorkOrderInputLotId = NULL
		,@intWorkOrderProducedLotId = @intWorkOrderProducedLotId
		,@intWorkOrderId = @intWorkOrderId


	IF @intTransactionCount = 0
		COMMIT TRANSACTION

	EXEC sp_xml_removedocument @idoc
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	IF XACT_STATE() != 0
		AND @intTransactionCount = 0
		ROLLBACK TRANSACTION

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
GO


