CREATE PROCEDURE [dbo].[uspMFPostConsumption] @ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@intWorkOrderId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@strRetBatchId NVARCHAR(40) = NULL OUT
	,@intBatchId INT = NULL
	,@ysnPostGL BIT=1
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
	,@INVENTORY_CONSUME AS INT = 8
	,@strBatchId AS NVARCHAR(40)
	,@GLEntries AS RecapTableType
	,@dtmDate AS DATETIME
	,@intTransactionId AS INT
	,@intCreatedEntityId AS INT
	,@strTransactionId NVARCHAR(50)
	,@intLocationId INT
	,@ItemsForPost AS ItemCostingTableType
	,@intRecordId INT
	,@intLotId INT
	,@intItemUOMId INT
	,@dblDefaultResidueQty NUMERIC(18, 6)
	,@intItemId INT
	,@intCategoryId INT
	,@intManufacturingCellId INT
	,@intSubLocationId INT
DECLARE @tblMFLot TABLE (
	intRecordId INT Identity(1, 1)
	,intLotId INT
	,intItemUOMId INT
	)

SET @ysnPost = ISNULL(@ysnPost, 0)

DECLARE @dblOtherCharges NUMERIC(18, 6)
	,@dblPercentage NUMERIC(18, 6)
	,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
	,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
	,@ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
	,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
	,@strItemNo NVARCHAR(50)
	,@intItemId1 INT
	,@strItemNo1 NVARCHAR(50)
	,@intRecipeItemUOMId INT
	,@intItemLocationId INT
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT
	,@dblWeight NUMERIC(38, 20)
	,@intAttributeId INT
	,@strInstantConsumption NVARCHAR(50)
	,@intManufacturingProcessId INT
	,@intAttributeTypeId INT
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

SELECT @intManufacturingProcessId = intManufacturingProcessId
	,@intLocationId = intLocationId
FROM tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

SELECT @intAttributeId = intAttributeId
	,@intAttributeTypeId = intAttributeTypeId
FROM tblMFAttribute
WHERE strAttributeName = 'Is Instant Consumption'

SELECT @strInstantConsumption = strAttributeValue
FROM tblMFManufacturingProcessAttribute
WHERE intManufacturingProcessId = @intManufacturingProcessId
	AND intLocationId = @intLocationId
	AND intAttributeId = @intAttributeId

IF @strInstantConsumption = 'False'
	AND @intAttributeTypeId = 5
BEGIN
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
END

SELECT TOP 1 @strTransactionId = strWorkOrderNo
	,@dtmDate = GetDate()
	,@intCreatedEntityId = @intUserId
	,@intLocationId = intLocationId
	,@intItemId = intItemId
	,@intManufacturingCellId = intManufacturingCellId
	,@intSubLocationId = intSubLocationId
FROM dbo.tblMFWorkOrder
WHERE intWorkOrderId = @intWorkOrderId

SELECT @intCategoryId = intCategoryId
FROM dbo.tblICItem
WHERE intItemId = @intItemId

IF @intBatchId IS NULL
	OR @intBatchId = 0
BEGIN
	EXEC dbo.uspMFGeneratePatternId @intCategoryId = @intCategoryId
		,@intItemId = @intItemId
		,@intManufacturingId = @intManufacturingCellId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@intOrderTypeId = NULL
		,@intBlendRequirementId = NULL
		,@intPatternCode = 33
		,@ysnProposed = 0
		,@strPatternString = @intBatchId OUTPUT
END

SELECT @intTransactionId = @intBatchId

SELECT @dtmDate = dbo.fnGetBusinessDate(@dtmDate, @intLocationId)

IF @dtmDate IS NULL
BEGIN
	SELECT @dtmDate = GetDate()
END

-- Get the next batch number
EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
	,@strBatchId OUTPUT

SELECT @strRetBatchId = @strBatchId

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	--Non Lot Tracking
	INSERT INTO @ItemsForPost (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,intSourceTransactionId
		,strSourceTransactionId
		)
	SELECT intItemId = cl.intItemId
		,intItemLocationId = il.intItemLocationId
		,intItemUOMId = cl.intItemIssuedUOMId
		,dtmDate = @dtmDate
		,dblQty = (- cl.dblIssuedQuantity)
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = IP.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intTransactionId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = NULL
		,intSubLocationId = cl.intSubLocationId
		,intStorageLocationId = cl.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strTransactionId
	FROM dbo.tblMFWorkOrderConsumedLot cl
	JOIN dbo.tblICItem i ON cl.intItemId = i.intItemId
	JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemIssuedUOMId = ItemUOM.intItemUOMId
	JOIN dbo.tblICItemLocation il ON i.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	INNER JOIN dbo.tblICItemPricing IP on IP.intItemId=i.intItemId AND IP.intItemLocationId =il.intItemLocationId
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND ISNULL(cl.intLotId, 0) = 0

	--Lot Tracking
	INSERT INTO @ItemsForPost (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,intSourceTransactionId
		,strSourceTransactionId
		)
	SELECT intItemId = l.intItemId
		,intItemLocationId = l.intItemLocationId
		,intItemUOMId = ISNULL(l.intWeightUOMId, l.intItemUOMId)
		,dtmDate = @dtmDate
		,dblQty = (- cl.dblQuantity)
		,dblUOMQty = ISNULL(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty)
		,dblCost = l.dblLastCost
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intTransactionId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strTransactionId
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = l.intLotId
		,intSubLocationId = l.intSubLocationId
		,intStorageLocationId = l.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strTransactionId
	FROM dbo.tblMFWorkOrderConsumedLot cl
	JOIN dbo.tblICLot l ON cl.intLotId = l.intLotId
	JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
	WHERE cl.intWorkOrderId = @intWorkOrderId

	-- Call the post routine 
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
	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strBatchId
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
		,@intUserId

	IF @ysnPostGL=1
	BEGIN
		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0 
		AND @strInstantConsumption = 'False'
		AND @intAttributeTypeId = 5
	BEGIN
		SELECT @intItemLocationId = intItemLocationId
		FROM tblICItemLocation
		WHERE intLocationId = @intLocationId
			AND intItemId = @intItemId

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
			,intTransactionTypeId = @INVENTORY_CONSUME

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

		--SELECT TOP 1 @intItemId1 = Item.intItemId
		--	,@strItemNo1 = Item.strItemNo
		--FROM dbo.tblICItem Item
		--INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		--WHERE ChargesGLAccounts.intOtherChargeIncome IS NULL
		--IF @intItemId1 IS NOT NULL
		--BEGIN
		--	-- {Item} is missing a GL account setup for {Account Category} account category.
		--	RAISERROR (
		--			80008
		--			,11
		--			,1
		--			,@strItemNo1
		--			,@ACCOUNT_CATEGORY_OtherChargeIncome
		--			)
		--	RETURN;
		--END
		SELECT @intRecipeItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblProduceQty = SUM(dblQuantity)
			,@intProduceUOMKey = MIN(intItemUOMId)
			,@dblWeight = SUM(dblPhysicalCount)
		FROM dbo.tblMFWorkOrderProducedLot WP
		WHERE WP.intWorkOrderId = @intWorkOrderId
			AND WP.ysnProductionReversed = 0
			AND WP.intItemId IN (
				SELECT intItemId
				FROM dbo.tblMFWorkOrderRecipeItem
				WHERE intRecipeItemTypeId = 2
					AND ysnConsumptionRequired = 1
					AND intWorkOrderId = @intWorkOrderId
				)

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
					WHEN @intRecipeItemUOMId = @intProduceUOMKey
						THEN @dblOtherCharges * @dblProduceQty
					ELSE @dblOtherCharges * @dblWeight
					END
				)
			,intTransactionTypeId = @INVENTORY_CONSUME
			,intCurrencyId = (
				SELECT TOP 1 intDefaultReportingCurrencyId
				FROM tblSMCompanyPreference
				)
			,dblExchangeRate = 1
			,intTransactionDetailId = @intWorkOrderId
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
		
		UNION ALL
		
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
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
		CROSS APPLY dbo.fnGetDebit(GLEntriesForOtherCost.dblCost) Debit
		CROSS APPLY dbo.fnGetCredit(GLEntriesForOtherCost.dblCost) Credit
		WHERE ISNULL(GLEntriesForOtherCost.ysnAccrue, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnInventoryCost, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnPrice, 0) = 0

		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0 
		AND @strInstantConsumption = 'False'
		AND @intAttributeTypeId = 5
	BEGIN
		SELECT @intItemLocationId = intItemLocationId
		FROM tblICItemLocation
		WHERE intLocationId = @intLocationId
			AND intItemId = @intItemId

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
			,intTransactionTypeId = @INVENTORY_CONSUME

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

		--SELECT TOP 1 @intItemId1 = Item.intItemId
		--	,@strItemNo1 = Item.strItemNo
		--FROM dbo.tblICItem Item
		--INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts ON Item.intItemId = ChargesGLAccounts.intChargeId
		--WHERE ChargesGLAccounts.intOtherChargeIncome IS NULL
		--IF @intItemId1 IS NOT NULL
		--BEGIN
		--	-- {Item} is missing a GL account setup for {Account Category} account category.
		--	RAISERROR (
		--			80008
		--			,11
		--			,1
		--			,@strItemNo1
		--			,@ACCOUNT_CATEGORY_OtherChargeIncome
		--			)
		--	RETURN;
		--END
		SELECT @intRecipeItemUOMId = intItemUOMId
		FROM tblMFWorkOrderRecipe
		WHERE intWorkOrderId = @intWorkOrderId

		SELECT @dblProduceQty = SUM(dblQuantity)
			,@intProduceUOMKey = MIN(intItemUOMId)
			,@dblWeight = SUM(dblPhysicalCount)
		FROM dbo.tblMFWorkOrderProducedLot WP
		WHERE WP.intWorkOrderId = @intWorkOrderId
			AND WP.ysnProductionReversed = 0
			AND WP.intItemId IN (
				SELECT intItemId
				FROM dbo.tblMFWorkOrderRecipeItem
				WHERE intRecipeItemTypeId = 2
					AND ysnConsumptionRequired = 1
					AND intWorkOrderId = @intWorkOrderId
				)

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
					WHEN @intRecipeItemUOMId = @intProduceUOMKey
						THEN @dblOtherCharges * @dblProduceQty
					ELSE @dblOtherCharges * @dblWeight
					END
				)
			,intTransactionTypeId = @INVENTORY_CONSUME
			,intCurrencyId = (
				SELECT TOP 1 intDefaultReportingCurrencyId
				FROM tblSMCompanyPreference
				)
			,dblExchangeRate = 1
			,intTransactionDetailId = @intWorkOrderId
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
		
		UNION ALL
		
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
		INNER JOIN dbo.tblGLAccount GLAccount ON GLAccount.intAccountId = OtherChargesGLAccounts.intOtherChargeIncome
		CROSS APPLY dbo.fnGetDebit(GLEntriesForOtherCost.dblCost) Debit
		CROSS APPLY dbo.fnGetCredit(GLEntriesForOtherCost.dblCost) Credit
		WHERE ISNULL(GLEntriesForOtherCost.ysnAccrue, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnInventoryCost, 0) = 0
			AND ISNULL(GLEntriesForOtherCost.ysnPrice, 0) = 0

		EXEC dbo.uspGLBookEntries @GLEntries
			,@ysnPost
	END

	UPDATE dbo.tblMFWorkOrder
	SET strBatchId = @strBatchId
		,intBatchID = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	UPDATE dbo.tblMFWorkOrderConsumedLot
	SET strBatchId = @strBatchId
		,intBatchId = @intBatchId
	WHERE intWorkOrderId = @intWorkOrderId

	INSERT INTO @tblMFLot (
		intLotId
		,intItemUOMId
		)
	SELECT intLotId
		,intItemUOMId
	FROM dbo.tblMFWorkOrderConsumedLot
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intRecordId = Min(intRecordId)
	FROM @tblMFLot

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intLotId = NULL

		SELECT @intLotId = intLotId
			,@intItemUOMId = intItemUOMId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		IF (
				(
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) < 0.00001
				AND (
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) > 0
				)
			OR (
				(
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) < 0.00001
				AND (
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId
					) > 0
				)
		BEGIN
			EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId
				,@dblNewLotQty = 0
				,@intAdjustItemUOMId = @intItemUOMId
				,@intUserId = @intUserId
				,@strReasonCode = 'Residue qty clean up'
				,@strNotes = 'Residue qty clean up'
		END

		SELECT @intRecordId = Min(intRecordId)
		FROM @tblMFLot
		WHERE intRecordId > @intRecordId
	END
END
