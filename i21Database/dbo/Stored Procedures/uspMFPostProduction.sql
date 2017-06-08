CREATE PROCEDURE [dbo].[uspMFPostProduction] 
	@ysnPost BIT = 0
	,@ysnRecap BIT = 0
	,@intWorkOrderId INT = NULL
	,@intItemId INT
	,@intUserId INT = NULL
	,@intEntityId INT = NULL
	,@intStorageLocationId INT = NULL
	,@dblWeight NUMERIC(38, 20)
	,@intWeightUOMId INT
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblProduceQty NUMERIC(38, 20)
	,@intProduceUOMKey INT
	,@strBatchId NVARCHAR(40)
	,@strLotNumber NVARCHAR(50)
	,@intBatchId INT = NULL
	,@intLotId INT OUTPUT
	,@strLotAlias NVARCHAR(50)
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strParentLotNumber NVARCHAR(50) = NULL
	,@strVessel NVARCHAR(100) = NULL
	,@dtmProductionDate DATETIME = NULL
	,@intTransactionDetailId INT = NULL
	,@strShiftActivityNo NVARCHAR(50) = NULL
	,@intShiftId int=NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @STARTING_NUMBER_BATCH AS INT = 3
	,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Work In Progress'
	,@INVENTORY_PRODUCE AS INT = 9
	,@GLEntries AS RecapTableType
	,@dtmDate AS DATETIME
	,@intTransactionId AS INT
	,@strTransactionId NVARCHAR(50)
	,@intItemLocationId INT
	,@intLocationId INT
	,@intSubLocationId INT
	,@strLotTracking NVARCHAR(50)
	,@dblNewCost NUMERIC(38, 20)
	,@dblNewUnitCost NUMERIC(38, 20)
	,@ItemsThatNeedLotId AS dbo.ItemLotTableType
	,@strLifeTimeType NVARCHAR(50)
	,@intLifeTime INT
	,@dtmExpiryDate DATETIME
	,@ItemsForPost AS ItemCostingTableType
	,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
	,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
	,@ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Inventory'
	,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
	,@strItemNo NVARCHAR(50)
	,@intItemId1 INT
	,@strItemNo1 NVARCHAR(50)
	,@intRecipeItemUOMId INT
	,@strLocationName NVARCHAR(50)

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

SET @ysnPost = ISNULL(@ysnPost, 0)

IF @strShiftActivityNo IS NOT NULL
BEGIN
	SELECT @intTransactionId = @intBatchId
		,@dtmDate = IsNULL(@dtmProductionDate,GetDate())
		,@strTransactionId = @strShiftActivityNo

	SELECT @intLocationId = intLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId
END
ELSE
BEGIN
	SELECT TOP 1 @intTransactionId = @intBatchId
		,@dtmDate = IsNULL(@dtmProductionDate,GetDate())
		,@strTransactionId = strWorkOrderNo
		,@intLocationId = intLocationId
	FROM dbo.tblMFWorkOrder
	WHERE intWorkOrderId = @intWorkOrderId
END

IF @dtmProductionDate > @dtmDate
	OR @dtmProductionDate IS NULL
BEGIN
	SELECT @dtmProductionDate = @dtmDate
END

SELECT @intItemLocationId = intItemLocationId
FROM tblICItemLocation
WHERE intLocationId = @intLocationId
	AND intItemId = @intItemId

SELECT @intSubLocationId = intSubLocationId
FROM tblICStorageLocation
WHERE intStorageLocationId = @intStorageLocationId

SELECT @strLotTracking = strLotTracking
FROM tblICItem
WHERE intItemId = @intItemId

IF @strShiftActivityNo IS NOT NULL
BEGIN
	
	SELECT @dblNewUnitCost=dblStandardCost
	FROM dbo.tblICItemPricing
	WHERE intItemId=@intItemId AND intItemLocationId=@intItemLocationId

	If @dblNewUnitCost is null
	Select @dblNewUnitCost=0
END
ELSE
BEGIN
	SELECT @dblNewCost = [dbo].[fnGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId)

	SET @dblNewCost = ABS(@dblNewCost)
	SET @dblNewUnitCost = ABS(@dblNewCost) / @dblProduceQty
END

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
	SELECT @dblNewUnitCost = @dblNewUnitCost + @dblOtherCharges
END

CREATE TABLE #GeneratedLotItems (
	intLotId INT
	,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intDetailId INT
	,intParentLotId INT
	,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

IF @strLotTracking <> 'No'
BEGIN
	SELECT @strLifeTimeType = strLifeTimeType
		,@intLifeTime = intLifeTime
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF @strLifeTimeType = 'Years'
		SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Months'
		SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Days'
		SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Hours'
		SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Minutes'
		SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, @dtmProductionDate)
	ELSE
		SET @dtmExpiryDate = DateAdd(yy, 1, @dtmProductionDate)

	INSERT INTO @ItemsThatNeedLotId (
		intLotId
		,strLotNumber
		,strLotAlias
		,intItemId
		,intItemLocationId
		,intSubLocationId
		,intStorageLocationId
		,dblQty
		,intItemUOMId
		,dblWeight
		,intWeightUOMId
		,dtmExpiryDate
		,dtmManufacturedDate
		,intOriginId
		,strBOLNo
		,strVessel
		,strReceiptNumber
		,strMarkings
		,strNotes
		,intEntityVendorId
		,strVendorLotNo
		,strGarden
		,intDetailId
		,ysnProduced
		,strTransactionId
		,strSourceTransactionId
		,intSourceTransactionTypeId
		,intShiftId
		)
	SELECT intLotId = NULL
		,strLotNumber = @strLotNumber
		,strLotAlias = @strLotAlias
		,intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,dblQty = @dblProduceQty
		,intItemUOMId = @intProduceUOMKey
		,dblWeight = @dblWeight
		,intWeightUOMId = @intWeightUOMId
		,dtmExpiryDate = @dtmExpiryDate
		,dtmManufacturedDate = @dtmProductionDate
		,intOriginId = NULL
		,strBOLNo = NULL
		,strVessel = @strVessel
		,strReceiptNumber = NULL
		,strMarkings = NULL
		,strNotes = NULL
		,intEntityVendorId = NULL
		,strVendorLotNo = @strVendorLotNo
		,strGarden = NULL
		,intDetailId = @intTransactionId
		,ysnProduced = 1
		,strTransactionId = @strTransactionId
		,strSourceTransactionId = @strTransactionId
		,intSourceTransactionTypeId = @INVENTORY_PRODUCE
		,intShiftId=@intShiftId

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intTransactionId

	EXEC dbo.uspMFCreateUpdateParentLotNumber @strParentLotNumber = @strParentLotNumber
		,@strParentLotAlias = ''
		,@intItemId = @intItemId
		,@dtmExpiryDate = @dtmExpiryDate
		,@intLotStatusId = 1
		,@intEntityUserSecurityId = @intUserId
		,@intLotId = @intLotId
		,@intSubLocationId = @intSubLocationId
		,@intLocationId = @intLocationId
		,@dtmDate = @dtmProductionDate
		,@intShiftId  = @intShiftId
END

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

	SELECT	TOP 1 
			@strLocationName = c.strLocationName
	FROM	tblICItemLocation il INNER JOIN tblSMCompanyLocation c
				ON il.intLocationId = c.intCompanyLocationId
			INNER JOIN @OtherChargesGLAccounts ChargesGLAccounts
				ON ChargesGLAccounts.intChargeId = il.intItemId
				AND ChargesGLAccounts.intItemLocationId = il.intItemLocationId
	WHERE	il.intItemId = @intItemId1
			AND ChargesGLAccounts.intOtherChargeExpense IS NULL

	IF @intItemId1 IS NOT NULL
	BEGIN
		-- {Item} in {Location} is missing a GL account setup for {Account Category} account category.
		EXEC uspICRaiseError 80008, @strItemNo1, @strLocationName, @ACCOUNT_CATEGORY_OtherChargeExpense;
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
				WHEN @intRecipeItemUOMId = @intProduceUOMKey
					THEN @dblOtherCharges * @dblProduceQty
				ELSE @dblOtherCharges * @dblWeight
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

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	IF @strLotTracking = 'No'
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
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			,dblUOMQty =
			-- Get the unit qty of the Weight UOM or qty UOM
			CASE 
				WHEN (@intWeightUOMId = @intProduceUOMKey)
					THEN (
							SELECT 1
							)
				ELSE (
						CASE 
							WHEN @dblUnitQty IS NOT NULL
								THEN @dblUnitQty
							ELSE (
									SELECT TOP 1 dblUnitQty
									FROM dbo.tblICItemUOM
									WHERE intItemUOMId = @intProduceUOMKey
									)
							END
						)
				END
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0
			,intCurrencyId = NULL
			,dblExchangeRate = 1
			,intTransactionId = @intTransactionId
			,intTransactionDetailId = @intTransactionDetailId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @INVENTORY_PRODUCE
			,intLotId = NULL
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
			,intSourceTransactionId = @INVENTORY_PRODUCE
			,strSourceTransactionId = @strTransactionId
	ELSE
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
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			,dblUOMQty =
			-- Get the unit qty of the Weight UOM or qty UOM
			CASE 
				WHEN (@intWeightUOMId = @intProduceUOMKey)
					THEN (
							SELECT 1
							)
				ELSE (
						CASE 
							WHEN @dblUnitQty IS NOT NULL
								THEN @dblUnitQty
							ELSE (
									SELECT TOP 1 dblUnitQty
									FROM dbo.tblICItemUOM
									WHERE intItemUOMId = @intProduceUOMKey
									)
							END
						)
				END
			,dblCost = @dblNewUnitCost
			,dblSalesPrice = 0
			,intCurrencyId = NULL
			,dblExchangeRate = 1
			,intTransactionId = @intTransactionId
			,intTransactionDetailId = @intTransactionDetailId
			,strTransactionId = @strTransactionId
			,intTransactionTypeId = @INVENTORY_PRODUCE
			,intLotId = @intLotId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
			,intSourceTransactionId = @INVENTORY_PRODUCE
			,strSourceTransactionId = @strTransactionId

	DELETE
	FROM @GLEntries

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

	DELETE
	FROM @GLEntries
	WHERE strTransactionType = 'Consume'

	EXEC dbo.uspGLBookEntries @GLEntries
		,@ysnPost

	IF @intWorkOrderId IS NOT NULL
	BEGIN
		UPDATE dbo.tblMFWorkOrderProducedLot
		SET strBatchId = @strBatchId
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId
	END
END
