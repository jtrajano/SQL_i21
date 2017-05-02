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

	SELECT @intTransactionId = @intBatchId

	SELECT @strTransactionId = strWorkOrderNo
		,@intItemId = intItemId
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strLotTracking = strLotTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	SELECT @dblQuantity = dblQuantity
		,@intItemUOMId = intItemUOMId
		,@dblPhysicalCount = dblPhysicalCount
		,@intTransactionDetailId = intWorkOrderProducedLotId
	FROM tblMFWorkOrderProducedLot
	WHERE intWorkOrderId = @intWorkOrderId
		--AND intLotId = @intLotId
		AND intBatchId = @intBatchId

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
		AND @strLotTracking = 'Yes'
	BEGIN
		RAISERROR (
				'Pallet Lot has been marked as a ghost and cannot be Undone.'
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
		AND @strLotTracking = 'Yes'
	BEGIN
		RAISERROR (
				'Production reversal is not allowed for lots having zero qty.'
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

		IF @intItemId1 IS NOT NULL
		BEGIN
			-- {Item} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008, @strItemNo1, @ACCOUNT_CATEGORY_OtherChargeExpense;
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
	)
	EXEC dbo.uspICUnpostCosting @intTransactionId
		,@strTransactionId
		,@strBatchId
		,@intUserId
		,0

	EXEC dbo.uspGLBookEntries @GLEntries
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


