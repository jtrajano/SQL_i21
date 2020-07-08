CREATE PROCEDURE [dbo].[uspMFPostProduction] @ysnPost BIT = 0
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
	,@intShiftId INT = NULL
	,@intLoadDistributionDetailId INT = NULL
	,@dblUnitCost NUMERIC(38, 20) = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@intLotStatusId INT = NULL
	,@intBookId INT = NULL
	,@intSubBookId INT = NULL
	,@intOriginId INT = NULL
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
	--,@ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Work In Progress'
	,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
	,@strItemNo NVARCHAR(50)
	,@intItemId1 INT
	,@strItemNo1 NVARCHAR(50)
	,@intRecipeItemUOMId INT
	,@strLocationName NVARCHAR(50)
	,@strProduceBatchId NVARCHAR(40)
	,@intManufacturingCellId INT
	,@ysnLifeTimeByEndOfMonth INT
	,@strInstantConsumption NVARCHAR(50)
	,@intManufacturingProcessId int

SET @strProduceBatchId = ISNULL(@strBatchId, '') + '-P'

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
		,@dtmDate = IsNULL(@dtmProductionDate, GetDate())
		,@strTransactionId = @strShiftActivityNo

	SELECT @intLocationId = intLocationId
	FROM tblICStorageLocation
	WHERE intStorageLocationId = @intStorageLocationId
END
ELSE
BEGIN
	IF @intWorkOrderId IS NULL
	BEGIN
		SELECT @intTransactionId = @intBatchId
			,@dtmDate = IsNULL(@dtmProductionDate, GetDate())
			,@strTransactionId = 'Manual Lot'

		SELECT @intLocationId = intLocationId
		FROM tblICStorageLocation
		WHERE intStorageLocationId = @intStorageLocationId
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intTransactionId = @intBatchId
			,@dtmDate = IsNULL(@dtmProductionDate, GetDate())
			,@strTransactionId = strWorkOrderNo
			,@intLocationId = intLocationId
			,@intManufacturingCellId = intManufacturingCellId
			,@intManufacturingProcessId = intManufacturingProcessId
		FROM dbo.tblMFWorkOrder
		WHERE intWorkOrderId = @intWorkOrderId

	SELECT @strInstantConsumption = strAttributeValue
	FROM tblMFManufacturingProcessAttribute
	WHERE intManufacturingProcessId = @intManufacturingProcessId
		AND intLocationId = @intLocationId
		AND intAttributeId = 20
	END
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
	SELECT @dblNewUnitCost = dblStandardCost
	FROM dbo.tblICItemPricing
	WHERE intItemId = @intItemId
		AND intItemLocationId = @intItemLocationId

	IF @dblNewUnitCost IS NULL
		SELECT @dblNewUnitCost = 0
END
ELSE
BEGIN
	IF @intWorkOrderId IS NULL
	BEGIN
		SELECT @dblNewUnitCost = @dblUnitCost
	END
	ELSE
	BEGIN
		SELECT @dblNewCost = [dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intTransactionId, @strBatchId)

		SET @dblNewCost = ABS(@dblNewCost)
		----For Blend use WorkOrder Qty
		--IF EXISTS (
		--		SELECT 1
		--		FROM tblMFWorkOrder w
		--		JOIN tblMFManufacturingProcess mp ON w.intManufacturingProcessId = mp.intManufacturingProcessId
		--		WHERE w.intWorkOrderId = @intWorkOrderId
		--			AND mp.intAttributeTypeId = 2
		--		)
		--	SET @dblNewUnitCost = ABS(@dblNewCost) / (
		--			SELECT dblQuantity
		--			FROM tblMFWorkOrder
		--			WHERE intWorkOrderId = @intWorkOrderId
		--			)
		--ELSE
		SET @dblNewUnitCost = ABS(@dblNewCost) / @dblProduceQty
	END
END

DECLARE @dblOtherCharges NUMERIC(18, 6)
	,@ysnConsumptionRequired BIT

SELECT @ysnConsumptionRequired = ysnConsumptionRequired
FROM tblMFWorkOrderRecipeItem RI
WHERE intWorkOrderId = @intWorkOrderId
	AND RI.intRecipeItemTypeId = 2
	AND RI.intItemId = @intItemId

DECLARE @tblMFOtherChargeItem TABLE (
	intRecipeItemId INT
	,intItemId INT
	,dblOtherCharge NUMERIC(18, 6)
	)

IF @ysnConsumptionRequired = 1 AND @strInstantConsumption = 'True'
BEGIN
	INSERT INTO @tblMFOtherChargeItem
	SELECT RI.intRecipeItemId
		,RI.intItemId
		,SUM((
				CASE 
					WHEN intCostDriverId = 2
						THEN ISNULL(P.dblStandardCost, 0)
					ELSE ISNULL(P.dblStandardCost, 0) * ISNULL(RI.dblCostRate, 0)
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
		AND IsNULL(IsNULL(RI.intManufacturingCellId, @intManufacturingCellId), 0) = IsNULL(@intManufacturingCellId, 0)
	GROUP BY RI.intRecipeItemId
		,RI.intItemId

	SELECT @dblOtherCharges = SUM(dblOtherCharge)
	FROM @tblMFOtherChargeItem

	IF @dblOtherCharges IS NOT NULL
		AND @dblOtherCharges > 0
	BEGIN
		SELECT @dblNewUnitCost = @dblNewUnitCost + @dblOtherCharges
	END
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

	SELECT @ysnLifeTimeByEndOfMonth = ysnLifeTimeByEndOfMonth
	FROM tblMFCompanyPreference

	IF @strLifeTimeType = 'Years'
		SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Months'
		AND @ysnLifeTimeByEndOfMonth = 0
		SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, @dtmProductionDate)
	ELSE IF @strLifeTimeType = 'Months'
		AND @ysnLifeTimeByEndOfMonth = 1
		SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, @dtmProductionDate)) + 1, 0))
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
		,strParentLotNumber
		,intBookId
		,intSubBookId
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
		,intOriginId = @intOriginId
		,strBOLNo = NULL
		,strVessel = @strVessel
		,strReceiptNumber = NULL
		,strMarkings = NULL
		,strNotes = @strNotes
		,intEntityVendorId = NULL
		,strVendorLotNo = @strVendorLotNo
		,strGarden = NULL
		,intDetailId = @intTransactionId
		,ysnProduced = 1
		,strTransactionId = @strTransactionId
		,strSourceTransactionId = @strTransactionId
		,intSourceTransactionTypeId = @INVENTORY_PRODUCE
		,intShiftId = @intShiftId
		,strParentLotNumber = @strParentLotNumber
		,intBookId = @intBookId
		,intSubBookId = @intSubBookId

	EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
		,@intUserId
		,@intLotStatusId

	SELECT TOP 1 @intLotId = intLotId
	FROM #GeneratedLotItems
	WHERE intDetailId = @intTransactionId
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
					,@ysnPost
					,1
			END
			ELSE
			BEGIN
				EXEC dbo.uspGLBookEntries @GLEntries
					,@ysnPost
			END
		END
	END

	SELECT @intRecipeItemId = MIN(intRecipeItemId)
	FROM @tblMFOtherChargeItem
	WHERE intRecipeItemId > @intRecipeItemId
END

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @ysnPost = 1
BEGIN
	DECLARE @strActualCost NVARCHAR(50) = NULL

	SELECT strActualCost = (
			CASE 
				WHEN Receipt.strOrigin = 'Terminal'
					AND HeaderDistItem.strDestination = 'Customer'
					THEN LoadHeader.strTransaction
				WHEN Receipt.strOrigin = 'Terminal'
					AND HeaderDistItem.strDestination = 'Location'
					THEN NULL
				WHEN Receipt.strOrigin = 'Location'
					AND HeaderDistItem.strDestination = 'Customer'
					AND Receipt.intCompanyLocationId = HeaderDistItem.intCompanyLocationId
					THEN NULL
				WHEN Receipt.strOrigin = 'Location'
					AND HeaderDistItem.strDestination = 'Customer'
					AND Receipt.intCompanyLocationId != HeaderDistItem.intCompanyLocationId
					THEN LoadHeader.strTransaction
				WHEN Receipt.strOrigin = 'Location'
					AND HeaderDistItem.strDestination = 'Location'
					THEN NULL
				END
			)
	INTO #tmpBlendIngredients
	FROM tblTRLoadDistributionDetail DistItem
	LEFT JOIN tblTRLoadDistributionHeader HeaderDistItem ON HeaderDistItem.intLoadDistributionHeaderId = DistItem.intLoadDistributionHeaderId
	LEFT JOIN tblTRLoadHeader LoadHeader ON LoadHeader.intLoadHeaderId = HeaderDistItem.intLoadHeaderId
	LEFT JOIN vyuTRGetLoadBlendIngredient BlendIngredient ON BlendIngredient.intLoadDistributionDetailId = DistItem.intLoadDistributionDetailId
	LEFT JOIN tblTRLoadReceipt Receipt ON Receipt.intLoadHeaderId = LoadHeader.intLoadHeaderId
		AND Receipt.strReceiptLine = BlendIngredient.strReceiptLink
	WHERE DistItem.intLoadDistributionDetailId = @intLoadDistributionDetailId
		AND ISNULL(DistItem.strReceiptLink, '') = ''

	SELECT TOP 1 @strActualCost = strActualCost
	FROM #tmpBlendIngredients
	WHERE ISNULL(strActualCost, '') <> ''

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
			,strActualCostId
			)
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			-- Get the unit qty of the Weight UOM or qty UOM
			,dblUOMQty = CASE 
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
			,strActualCostId = @strActualCost
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
			,strActualCostId
			)
		SELECT intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intItemUOMId = @intProduceUOMKey
			,dtmDate = @dtmProductionDate
			,dblQty = @dblProduceQty
			-- Get the unit qty of the Weight UOM or qty UOM
			,dblUOMQty = CASE 
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
			,strActualCostId = @strActualCost

	DELETE
	FROM @GLEntries

	-- Call the post routine 
	-- Use @strProduceBatchId as the Batch Id so that the GL entries for the Produce does not mix with the Consume. 
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
	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strProduceBatchId
		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
		,@intUserId

	-- Replace @strProduceBatchId with the original @strBatchId. 
	-- After sorting out the Batch for the Consume and Produce, the Produce still need to be posted using the original @strBatchId. 
	BEGIN
		UPDATE t
		SET t.strBatchId = @strBatchId
		FROM tblICInventoryTransaction t
		WHERE t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.strBatchId = @strProduceBatchId

		UPDATE t
		SET t.strBatchId = @strBatchId
		FROM tblICInventoryLotTransaction t
		WHERE t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.strBatchId = @strProduceBatchId

		UPDATE @GLEntries
		SET strBatchId = @strBatchId

		UPDATE t
		SET t.strBatchId = @strBatchId
		FROM tblICInventoryStockMovement t
		WHERE t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.strBatchId = @strProduceBatchId
	END

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
				,@ysnPost
				,1
		END
		ELSE
		BEGIN
			EXEC dbo.uspGLBookEntries @GLEntries
				,@ysnPost
		END
	END

	DROP TABLE #tmpBlendIngredients

	IF @intWorkOrderId IS NOT NULL
	BEGIN
		UPDATE dbo.tblMFWorkOrderProducedLot
		SET strBatchId = @strBatchId
		WHERE intWorkOrderId = @intWorkOrderId
			AND intBatchId = @intBatchId
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
END
