CREATE PROCEDURE [dbo].[uspMFUnpostProducedLot] 
(
	@strXML NVARCHAR(MAX)
	,@ysnRecap BIT = 0
	,@strBatchId NVARCHAR(50) = '' OUT
)
AS
BEGIN TRY
	DECLARE @intWorkOrderId INT
		--,@strBatchId NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmDate DATETIME
		,@dblWeightPerUnit NUMERIC(38, 20)
		,@GLEntries AS RecapTableType
		,@intItemId INT
		,@intStorageLocationId INT
		,@strLotNumber NVARCHAR(50)
		,@idoc INT
		,@ErrMsg NVARCHAR(MAX)
		,@intLotId INT
		,@dblQty NUMERIC(38, 20)
		,@intItemUOMId INT
		,@dblWeight NUMERIC(38, 20)
		,@intWeightUOMId INT
		,@intBatchId INT
		,@intUserId INT
		,@intTransactionCount INT
		,@intManufacturingProcessId INT
		,@intAttributeTypeId INT
		,@STARTING_NUMBER_BATCH AS INT = 3
		,@intWorkOrderProducedLotId INT
		,@intLocationId INT
		,@dtmTransactionDate DATETIME
		,@dblQty2 NUMERIC(38, 20)
		,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
		,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
		,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
		,@dblOtherCharges NUMERIC(18, 6)
		,@ysnConsumptionRequired BIT
		,@strInstantConsumption NVARCHAR(MAX)
		,@dblChargeCost NUMERIC(38, 20)
		,@intRecipeItemUOMId INT
		,@intItemId1 INT
		,@intTransactionId INT
	,@strItemNo1 NVARCHAR(50)
	,@strLocationName NVARCHAR(50)
	,@strProduceBatchId NVARCHAR(40)
	,@strTransactionId NVARCHAR(40)
	,@intManufacturingCellId INT
	,@ysnLifeTimeByEndOfMonth INT
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(30) = 'Work In Progress'





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

DECLARE @tblMFOtherChargeItem TABLE (
	intRecipeItemId INT
	,intItemId INT
	,dblOtherCharge NUMERIC(18, 6)
	)


	SELECT @dtmTransactionDate = GETDATE()

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXML

	SELECT @intWorkOrderId = intWorkOrderId
		,@intLotId = intLotId
		,@intBatchId = intBatchId
		,@intUserId = intUserId
	FROM OPENXML(@idoc, 'root', 2) WITH (
			intWorkOrderId INT
			,intLotId INT
			,dblQty NUMERIC(38, 20)
			,intItemUOMId INT
			,dblWeight NUMERIC(38, 20)
			,intWeightUOMId INT
			,intBatchId INT
			,intUserId INT
			)

	SELECT @intBatchId = intBatchId
		,@intWorkOrderId = intWorkOrderId
		,@intItemId = intItemId
		,@intStorageLocationId = intStorageLocationId
		,@intLotId = intLotId
		,@intWorkOrderProducedLotId = intWorkOrderProducedLotId
		,@dblQty = dblPhysicalCount
		,@intItemUOMId = intPhysicalItemUOMId
		,@dblWeight = dblQuantity
		,@intWeightUOMId = intItemUOMId
	FROM dbo.tblMFWorkOrderProducedLot
	WHERE intLotId = @intLotId
		OR intWorkOrderId = @intWorkOrderId

	SELECT @strLotNumber = strLotNumber
	FROM tblICLot
	WHERE intLotId = @intLotId

	IF EXISTS (
			SELECT *
			FROM tblICInventoryTransaction
			WHERE intLotId = @intLotId
				AND ysnIsUnposted = 0
				AND intTransactionTypeId <> 9
			)
	BEGIN
		RAISERROR (
				'There have been subsequent transactions on Lot %s. Unposting will not be allowed to proceed unless these subsequent transactions are each reversed (starting with the most recent).'
				,14
				,1
				,@strLotNumber
				)
	END

	SELECT @strWorkOrderNo = strWorkOrderNo
		,@intManufacturingProcessId = intManufacturingProcessId
		,@intLocationId = intLocationId
	FROM tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intAttributeTypeId = intAttributeTypeId
	FROM tblMFManufacturingProcess
	WHERE intManufacturingProcessId = @intManufacturingProcessId

	SELECT @dtmDate = dtmDate
	FROM tblICInventoryTransaction
	WHERE intTransactionId = @intBatchId
		AND strTransactionId = @strWorkOrderNo

	IF @dtmDate IS NULL
	BEGIN
		RETURN
	END

	SET @strBatchId = ''

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	SELECT @intTransactionCount = @@TRANCOUNT

	IF @intTransactionCount = 0
		BEGIN TRANSACTION

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
		,@strWorkOrderNo
		,@strBatchId
		,@intUserId
		,0

	IF ISNULL(@ysnRecap, 0) = 0
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
				,1
		END
		ELSE
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,0
		END
	END

	/* Unpost Other Charge. */

	SELECT @ysnConsumptionRequired = ysnConsumptionRequired
	FROM tblMFWorkOrderRecipeItem RI
	WHERE intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = @intItemId

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 20 --Is Instant Consumption

	IF @ysnConsumptionRequired = 1 AND @strInstantConsumption = 'True'
	BEGIN
		INSERT INTO @tblMFOtherChargeItem
		SELECT RI.intRecipeItemId
			,RI.intItemId
			,SUM((
					CASE 
						WHEN intCostDriverId = 2
							THEN ISNULL(P.dblStandardCost, 0)
						ELSE ISNULL(P.dblStandardCost, 0) * ISNULL(RI.dblCostRate, 1)
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
		GROUP BY RI.intRecipeItemId
			,RI.intItemId

		SELECT @dblOtherCharges = SUM(dblOtherCharge)
		FROM @tblMFOtherChargeItem

		IF @dblOtherCharges IS NOT NULL
			AND @dblOtherCharges > 0
		BEGIN
			SELECT @dblChargeCost = @dblChargeCost + @dblOtherCharges
		END
	END


	IF @dblOtherCharges IS NOT NULL
	OR @dblOtherCharges > 0
	BEGIN
		SELECT @intRecipeItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId
	END

	DECLARE @intRecipeItemId INT
		,@intOtherChargeItemId INT
		,@dblOtherCharge NUMERIC(18, 6)
		,@intOtherChargeItemLocationId INT

	SELECT @intRecipeItemId = MIN(intRecipeItemId)
	FROM @tblMFOtherChargeItem

	WHILE @intRecipeItemId IS NOT NULL
BEGIN
	SELECT @intOtherChargeItemId = NULL
		,@dblOtherCharges = NULL
		,@intOtherChargeItemLocationId = NULL

	SELECT @intOtherChargeItemId = intItemId
		,@dblOtherCharges = dblOtherCharge
	FROM @tblMFOtherChargeItem
	WHERE intRecipeItemId = @intRecipeItemId

	SELECT TOP 1 @intTransactionId = @intBatchId
			,@dtmDate = IsNULL(dtmPostDate, GetDate())
			,@strTransactionId = strWorkOrderNo
			,@intLocationId = intLocationId
			,@intManufacturingCellId = intManufacturingCellId
			,@intManufacturingProcessId = intManufacturingProcessId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0
	BEGIN
		SELECT @intOtherChargeItemLocationId = intItemLocationId
		FROM tblICItemLocation
		WHERE intLocationId = @intLocationId
			AND intItemId = @intOtherChargeItemId

		DELETE
		FROM @OtherChargesGLAccounts

		INSERT INTO @OtherChargesGLAccounts (
			intChargeId
			,intItemLocationId
			,intOtherChargeExpense
			,intOtherChargeIncome
			,intTransactionTypeId
			)
		SELECT intChargeId = @intOtherChargeItemId
			,intItemLocationId = @intOtherChargeItemLocationId
			,intOtherChargeExpense = dbo.fnGetItemGLAccount(@intOtherChargeItemId, @intOtherChargeItemLocationId, @ACCOUNT_CATEGORY_OtherChargeExpense)
			,intOtherChargeIncome = dbo.fnGetItemGLAccount(@intOtherChargeItemId, @intOtherChargeItemLocationId, @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY)
			,intTransactionTypeId = 9

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

		SELECT TOP 1 @intItemId1 = Item.intItemId
			,@strItemNo1 = Item.strItemNo
		FROM dbo.tblICItem Item
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		WHERE ChargesGLAccounts.intOtherChargeIncome IS NULL

		SELECT TOP 1 @strLocationName = c.strLocationName
		FROM tblICItemLocation il
		INNER JOIN tblSMCompanyLocation c ON il.intLocationId = c.intCompanyLocationId
		INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON ChargesGLAccounts.intChargeId = il.intItemId
			AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
		WHERE il.intItemId = @intItemId1
			AND ChargesGLAccounts.intOtherChargeIncome IS NULL

		IF @intItemId1 IS NOT NULL
		BEGIN
			-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
			EXEC uspICRaiseError 80008
				,@strItemNo1
				,@strLocationName
				,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY;

			RETURN;
		END

		DELETE
		FROM @GLEntriesForOtherCost

		INSERT INTO @GLEntriesForOtherCost
		SELECT dtmDate = @dtmDate
			,intItemId = @intOtherChargeItemId
			,intChargeId = @intOtherChargeItemId
			,intItemLocationId = @intOtherChargeItemLocationId
			,intChargeItemLocation = @intOtherChargeItemLocationId
			,intTransactionId = @intBatchId
			,strTransactionId = @strTransactionId
			,dblCost = (
				CASE 
					WHEN @intRecipeItemUOMId = @intItemUOMId
						THEN @dblOtherCharges * @dblQty
					ELSE @dblOtherCharges * @dblWeight
					END
				)
			,intTransactionTypeId = 9
			,intCurrencyId = (
				SELECT TOP 1 intDefaultReportingCurrencyId
				FROM tblSMCompanyPreference
				)
			,dblExchangeRate = 1
			,intTransactionDetailId = NULL
			,strInventoryTransactionTypeName = 'Consume'
			,strTransactionForm = 'Consume'
			,ysnAccrue = 0
			,ysnPrice = 0
			,ysnInventoryCost = 0

		DELETE
		FROM @GLEntries

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
			,ysnIsUnposted = 1
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
		
		UNION ALL
		
		SELECT dtmDate = GLEntriesForOtherCost.dtmDate
			,strBatchId = @strBatchId
			,intAccountId = GLAccount.intAccountId
			,dblDebit = Credit.Value
			,dblCredit = Debit.Value
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
			,ysnIsUnposted = 1
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
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
		CROSS APPLY dbo.fnGetDebit(GLEntriesForOtherCost.dblCost) Debit
		CROSS APPLY dbo.fnGetCredit(GLEntriesForOtherCost.dblCost) Credit
		WHERE ISNULL(GLEntriesForOtherCost.ysnAccrue, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnInventoryCost, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnPrice, 0) = 0

		IF EXISTS (
				SELECT *
				FROM @GLEntries
				)
			AND ISNULL(@ysnRecap, 0) = 0
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
					,1
			END
			ELSE
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,0
			END
		END
	END

	SELECT @intRecipeItemId = MIN(intRecipeItemId)
	FROM @tblMFOtherChargeItem
	WHERE intRecipeItemId > @intRecipeItemId
END



	IF @intAttributeTypeId = 2
	BEGIN
		UPDATE tblMFWorkOrder
		SET intStatusId = 10
		WHERE intWorkOrderId = @intWorkOrderId

		UPDATE tblMFWorkOrderProducedLot
		SET ysnProductionReversed = 1
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblQty2 = - @dblQty

		EXEC dbo.uspMFAdjustInventory @dtmDate = @dtmTransactionDate
			,@intTransactionTypeId = 9
			,@intItemId = @intItemId
			,@intSourceLotId = @intLotId
			,@intDestinationLotId = NULL
			,@dblQty = @dblQty2
			,@intItemUOMId = @intItemUOMId
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
	END

	IF @dblQty > 0
	BEGIN
		--DECLARE @tblMFWorkOrderConsumedLot TABLE (intWorkOrderConsumedLotId INT);
		--DELETE
		--FROM tblMFWorkOrderConsumedLot
		--OUTPUT deleted.intWorkOrderConsumedLotId
		--INTO @tblMFWorkOrderConsumedLot
		--WHERE intWorkOrderId = @intWorkOrderId
		--	AND intBatchId = @intBatchId
		IF @intAttributeTypeId = 2
		BEGIN
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
				,dtmBusinessDate
				,intBusinessShiftId
				,intWorkOrderId
				)
			SELECT dtmDate
				,intTransactionTypeId
				,IA.intItemId
				,intSourceLotId
				,- dblQty
				,IA.intItemUOMId
				,intUserId
				,intLocationId
				,IA.intStorageLocationId
				,IA.intWorkOrderConsumedLotId
				,dtmBusinessDate
				,intBusinessShiftId
				,IA.intWorkOrderId
			FROM tblMFInventoryAdjustment IA
			JOIN tblMFWorkOrderConsumedLot WC ON IA.intWorkOrderConsumedLotId = WC.intWorkOrderConsumedLotId
			WHERE WC.intWorkOrderId = @intWorkOrderId
				AND WC.intBatchId = @intBatchId
		END
				--UPDATE dbo.tblMFWorkOrderProducedLot
				--SET dblQuantity = @dblWeight
				--	,intItemUOMId = @intWeightUOMId
				--	,dblPhysicalCount = @dblQty
				--	,intPhysicalItemUOMId = @intItemUOMId
				--	,dblWeightPerUnit = @dblWeight / @dblQty
				--WHERE intWorkOrderId = @intWorkOrderId
				--	AND intBatchId = @intBatchId
				--SELECT @dblWeightPerUnit = @dblWeight / @dblQty
				--EXEC dbo.uspMFPickWorkOrder @intWorkOrderId = @intWorkOrderId
				--	,@dblProduceQty = @dblWeight
				--	,@intProduceUOMId = @intWeightUOMId
				--	,@intBatchId = @intBatchId
				--	,@intUserId = @intUserId
				--	,@dblUnitQty = @dblWeightPerUnit
				--	,@ysnProducedQtyByWeight = 1
				--EXEC [dbo].uspMFPostConsumptionProduction @intWorkOrderId = @intWorkOrderId
				--	,@intItemId = @intItemId
				--	,@strLotNumber = @strLotNumber
				--	,@dblWeight = @dblWeight
				--	,@intWeightUOMId = @intWeightUOMId
				--	,@dblUnitQty = @dblWeightPerUnit
				--	,@dblQty = @dblQty
				--	,@intItemUOMId = @intItemUOMId
				--	,@intUserId = @intUserId
				--	,@intBatchId = @intBatchId
				--	,@intLotId = @intLotId OUTPUT
				--	,@strLotAlias = @strWorkOrderNo
				--	,@strVendorLotNo = NULL
				--	,@strParentLotNumber = NULL
				--	,@intStorageLocationId = @intStorageLocationId
				--	,@dtmProductionDate = @dtmDate
	END

	IF ISNULL(@ysnRecap, 0) = 1
	BEGIN
		--Create Temp Table if not exists, so that insert statement for the temp table will not fail.
		IF OBJECT_ID('tempdb..#tblRecap') IS NULL
			SELECT *
			INTO #tblRecap
			FROM @GLEntries
			WHERE 1 = 2

		--Insert Recap Data to temp table
		INSERT INTO #tblRecap
		SELECT *
		FROM @GLEntries
	END

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