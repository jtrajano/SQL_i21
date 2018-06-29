CREATE PROCEDURE [dbo].[uspMFPostConsumptionProduction] @intWorkOrderId INT
	,@intItemId INT
	,@strLotNumber NVARCHAR(50)
	,@dblWeight NUMERIC(38, 20)
	,@intWeightUOMId INT
	,@dblUnitQty NUMERIC(38, 20) = NULL
	,@dblQty NUMERIC(38, 20)
	,@intItemUOMId INT
	,@intUserId INT = NULL
	,@intBatchId INT
	,@intLotId INT OUTPUT
	,@strLotAlias NVARCHAR(50)
	,@strVendorLotNo NVARCHAR(50) = NULL
	,@strParentLotNumber NVARCHAR(50)
	,@intStorageLocationId INT
	,@dtmProductionDate DATETIME = NULL
	,@intTransactionDetailId INT = NULL
	,@strNotes NVARCHAR(MAX) = NULL
	,@intLotStatusId INT = NULL
AS
BEGIN
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @STARTING_NUMBER_BATCH AS INT = 3
		,@INVENTORY_CONSUME AS INT = 8
		,@INVENTORY_PRODUCE AS INT = 9
		,@ItemsThatNeedLotId AS dbo.ItemLotTableType
		,@ItemsForPost AS ItemCostingTableType
		,@GLEntries AS RecapTableType
		,@strBatchId NVARCHAR(40)
		,@intItemLocationId INT
		,@strItemNo AS NVARCHAR(50)
		,@intLocationId INT
		,@intSubLocationId INT
		,@dblNewCost NUMERIC(38, 20)
		,@dblNewUnitCost NUMERIC(38, 20)
		,@strLifeTimeType NVARCHAR(50)
		,@intLifeTime INT
		,@dtmExpiryDate DATETIME
		,@intItemStockUOMId INT
		,@strWorkOrderNo NVARCHAR(50)
		,@dtmDate DATETIME
		,@intRecordId INT
		,@intLotId1 INT
		,@dblDefaultResidueQty NUMERIC(18, 6)
		,@ACCOUNT_CATEGORY_OtherChargeExpense AS NVARCHAR(30) = 'Other Charge Expense'
		,@ACCOUNT_CATEGORY_OtherChargeIncome AS NVARCHAR(30) = 'Other Charge Income'
		,@ACCOUNT_CATEGORY_Inventory AS NVARCHAR(30) = 'Work In Progress'
		,@OtherChargesGLAccounts AS dbo.ItemOtherChargesGLAccount
		,@intItemId1 INT
		,@strItemNo1 AS NVARCHAR(50)
		,@intRecipeItemUOMId INT
		,@strLotTracking NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@intManufacturingCellId INT
		,@ysnLifeTimeByEndOfMonth BIT
		,@strCertificate NVARCHAR(50)
		,@intProducerId INT
		,@strCertificateId NVARCHAR(50)
		,@strTrackingNumber NVARCHAR(255)
	DECLARE @tblMFCertification TABLE (
		strCertificate NVARCHAR(50)
		,intProducerId INT
		,strCertificateId NVARCHAR(50)
		,strTrackingNumber NVARCHAR(255)
		)

	SELECT TOP 1 @dblDefaultResidueQty = ISNULL(dblDefaultResidueQty, 0.00001)
		,@ysnLifeTimeByEndOfMonth = ysnLifeTimeByEndOfMonth
	FROM tblMFCompanyPreference

	DECLARE @tblMFLot TABLE (
		intRecordId INT Identity(1, 1)
		,intLotId INT
		,intItemUOMId INT
		)
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

	SELECT TOP 1 @intLocationId = W.intLocationId
		,@strWorkOrderNo = strWorkOrderNo
		,@intManufacturingCellId = intManufacturingCellId
	FROM dbo.tblMFWorkOrder W
	WHERE intWorkOrderId = @intWorkOrderId

	SELECT @intSubLocationId = SL.intSubLocationId
	FROM dbo.tblICStorageLocation SL
	WHERE SL.intStorageLocationId = @intStorageLocationId

	EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH
		,@strBatchId OUTPUT

	IF @dtmProductionDate > @dtmDate
		OR @dtmProductionDate IS NULL
	BEGIN
		SELECT @dtmProductionDate = @dtmDate
	END

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
		,dtmDate = @dtmProductionDate
		,dblQty = (- cl.dblIssuedQuantity)
		,dblUOMQty = ItemUOM.dblUnitQty
		,dblCost = ISNULL(IP.dblLastCost, 0)
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = NULL
		,intSubLocationId = cl.intSubLocationId
		,intStorageLocationId = cl.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strWorkOrderNo
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICItem i ON cl.intItemId = i.intItemId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON cl.intItemIssuedUOMId = ItemUOM.intItemUOMId
	INNER JOIN tblICItemLocation il ON i.intItemId = il.intItemId
		AND il.intLocationId = @intLocationId
	INNER JOIN dbo.tblICItemPricing IP ON IP.intItemId = i.intItemId
		AND IP.intItemLocationId = il.intItemLocationId
	INNER JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intWorkOrderId = cl.intWorkOrderId
		AND RI.intItemId = cl.intItemId
	INNER JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
		AND R.intRecipeId = RI.intRecipeId
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND cl.intBatchId = @intBatchId
		AND ISNULL(cl.intLotId, 0) = 0

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
		,dtmDate = @dtmProductionDate
		,dblQty = (- cl.dblQuantity)
		,dblUOMQty = ISNULL(WeightUOM.dblUnitQty, ItemUOM.dblUnitQty)
		,dblCost = ISNULL(dbo.[fnCalculateCostBetweenUOM](IU.intItemUOMId, cl.intItemUOMId, l.dblLastCost), 0)
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,intTransactionDetailId = cl.intWorkOrderConsumedLotId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_CONSUME
		,intLotId = l.intLotId
		,intSubLocationId = l.intSubLocationId
		,intStorageLocationId = l.intStorageLocationId
		,intSourceTransactionId = @INVENTORY_CONSUME
		,strSourceTransactionId = @strWorkOrderNo
	FROM tblMFWorkOrderConsumedLot cl
	INNER JOIN tblICLot l ON cl.intLotId = l.intLotId
	INNER JOIN dbo.tblICItemUOM ItemUOM ON l.intItemUOMId = ItemUOM.intItemUOMId
	LEFT JOIN dbo.tblICItemUOM WeightUOM ON l.intWeightUOMId = WeightUOM.intItemUOMId
	INNER JOIN dbo.tblMFWorkOrderRecipeItem RI ON RI.intWorkOrderId = cl.intWorkOrderId
		AND RI.intItemId = cl.intItemId
	INNER JOIN dbo.tblMFWorkOrderRecipe R ON R.intWorkOrderId = RI.intWorkOrderId
		AND R.intRecipeId = RI.intRecipeId
	INNER JOIN dbo.tblICItemUOM IU ON l.intItemId = IU.intItemId
		AND IU.ysnStockUnit = 1
	WHERE cl.intWorkOrderId = @intWorkOrderId
		AND cl.intBatchId = @intBatchId

	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strBatchId
		,NULL
		,@intUserId

	SELECT @intItemLocationId = intItemLocationId
	FROM tblICItemLocation
	WHERE intLocationId = @intLocationId
		AND intItemId = @intItemId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @strLotTracking = strLotTracking
	FROM tblICItem
	WHERE intItemId = @intItemId

	SELECT @dblNewCost = [dbo].[fnMFGetTotalStockValueFromTransactionBatch](@intBatchId, @strBatchId)

	SET @dblNewCost = ABS(@dblNewCost)
	SET @dblNewUnitCost = ABS(@dblNewCost) / @dblQty

	DECLARE @dblOtherCharges NUMERIC(18, 6)
		,@ysnConsumptionRequired BIT
		,@dblTotalOtherCharges NUMERIC(18, 6)

	SELECT @ysnConsumptionRequired = ysnConsumptionRequired
	FROM tblMFWorkOrderRecipeItem RI
	WHERE intWorkOrderId = @intWorkOrderId
		AND RI.intRecipeItemTypeId = 2
		AND RI.intItemId = @intItemId

	DECLARE @tblMFOtherChargeItem TABLE (
		intRecipeItemId INT
		,intItemId INT
		,dblOtherCharge NUMERIC(38, 20)
		)

	IF @ysnConsumptionRequired = 1
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
			AND I.strType IN (
				'Other Charge'
				,'Service'
				)
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
			AND IL.intLocationId = @intLocationId
		JOIN dbo.tblICItemPricing P ON P.intItemId = I.intItemId
			AND P.intItemLocationId = IL.intItemLocationId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND IsNULL(IsNULL(RI.intManufacturingCellId, @intManufacturingCellId), 0) = IsNULL(@intManufacturingCellId, 0)
		GROUP BY RI.intRecipeItemId
			,RI.intItemId

		SELECT @dblTotalOtherCharges = SUM(dblOtherCharge)
		FROM @tblMFOtherChargeItem
	END

	DECLARE @dblCostPerStockUOM NUMERIC(38, 20)

	IF @intItemStockUOMId = @intItemUOMId
	BEGIN
		SELECT @dblCostPerStockUOM = @dblNewUnitCost
	END
	ELSE
	BEGIN
		SELECT @dblCostPerStockUOM = dbo.fnCalculateUnitCost(@dblNewUnitCost, @dblUnitQty)
	END

	IF @dblTotalOtherCharges IS NOT NULL
		AND @dblTotalOtherCharges > 0
	BEGIN
		SELECT @dblCostPerStockUOM = @dblCostPerStockUOM + @dblTotalOtherCharges
	END

	IF @strLotTracking <> 'No'
	BEGIN
		CREATE TABLE #GeneratedLotItems (
			intLotId INT
			,strLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
			,intDetailId INT
			,intParentLotId INT
			,strParentLotNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
			)

		SELECT @strLifeTimeType = strLifeTimeType
			,@intLifeTime = intLifeTime
		FROM dbo.tblICItem
		WHERE intItemId = @intItemId

		IF @strLifeTimeType = 'Years'
			SET @dtmExpiryDate = DateAdd(yy, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Months'
			AND @ysnLifeTimeByEndOfMonth = 0
			SET @dtmExpiryDate = DateAdd(mm, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Months'
			AND @ysnLifeTimeByEndOfMonth = 1
			SET @dtmExpiryDate = DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, DateAdd(mm, @intLifeTime, GetDate())) + 1, 0))
		ELSE IF @strLifeTimeType = 'Days'
			SET @dtmExpiryDate = DateAdd(dd, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Hours'
			SET @dtmExpiryDate = DateAdd(hh, @intLifeTime, GetDate())
		ELSE IF @strLifeTimeType = 'Minutes'
			SET @dtmExpiryDate = DateAdd(mi, @intLifeTime, GetDate())
		ELSE
			SET @dtmExpiryDate = DateAdd(yy, 1, GetDate())

		IF (
				SELECT Count(*)
				FROM (
					SELECT DISTINCT intProducerId
						,strCertificate
					FROM dbo.tblICLot L
					JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = L.intLotId
					WHERE WC.intWorkOrderId = @intWorkOrderId
						AND WC.intBatchId = @intBatchId
					) AS DT
				) = 1
		BEGIN
			INSERT INTO @tblMFCertification (
				strCertificate
				,intProducerId
				,strCertificateId
				,strTrackingNumber
				)
			SELECT DISTINCT strCertificate
				,intProducerId
				,strCertificateId
				,strTrackingNumber
			FROM dbo.tblICLot L
			JOIN dbo.tblMFWorkOrderConsumedLot WC ON WC.intLotId = L.intLotId
			WHERE WC.intWorkOrderId = @intWorkOrderId
				AND WC.intBatchId = @intBatchId

			SELECT @strCertificate = strCertificate
				,@intProducerId = intProducerId
			FROM @tblMFCertification

			SELECT @strCertificateId = ''

			SELECT @strCertificateId = @strCertificateId + strCertificateId + ','
			FROM (
				SELECT DISTINCT strCertificateId
				FROM @tblMFCertification
				) AS DT

			IF Len(@strCertificateId) > 0
			BEGIN
				SELECT @strCertificateId = Left(@strCertificateId, Len(@strCertificateId) - 1)
			END

			SELECT @strTrackingNumber = ''

			SELECT @strTrackingNumber = @strTrackingNumber + strTrackingNumber + ','
			FROM (
				SELECT DISTINCT strTrackingNumber
				FROM @tblMFCertification
				) AS DT

			IF Len(@strTrackingNumber) > 0
			BEGIN
				SELECT @strTrackingNumber = Left(@strTrackingNumber, Len(@strTrackingNumber) - 1)
			END
		END

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
			,intGradeId
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
			,strCertificate
			,intProducerId
			,strCertificateId
			,strTrackingNumber
			)
		SELECT intLotId = NULL
			,strLotNumber = @strLotNumber
			,strLotAlias = @strLotAlias
			,intItemId = @intItemId
			,intItemLocationId = @intItemLocationId
			,intSubLocationId = @intSubLocationId
			,intStorageLocationId = @intStorageLocationId
			,dblQty = @dblQty
			,intItemUOMId = @intItemUOMId
			,dblWeight = @dblWeight
			,intWeightUOMId = @intWeightUOMId
			,dtmExpiryDate = @dtmExpiryDate
			,dtmManufacturedDate = @dtmProductionDate
			,intOriginId = NULL
			,intGradeId = NULL
			,strBOLNo = NULL
			,strVessel = NULL
			,strReceiptNumber = NULL
			,strMarkings = NULL
			,strNotes = @strNotes
			,intEntityVendorId = NULL
			,strVendorLotNo = @strVendorLotNo
			,strGarden = NULL
			,intDetailId = @intBatchId
			,ysnProduced = 1
			,strTransactionId = @strWorkOrderNo
			,strSourceTransactionId = @strWorkOrderNo
			,intSourceTransactionTypeId = @INVENTORY_PRODUCE
			,strCertificate = @strCertificate
			,intProducerId = @intProducerId
			,strCertificateId = @strCertificateId
			,strTrackingNumber = @strTrackingNumber

		EXEC dbo.uspICCreateUpdateLotNumber @ItemsThatNeedLotId
			,@intUserId
			,@intLotStatusId

		SELECT TOP 1 @intLotId = intLotId
		FROM #GeneratedLotItems
		WHERE intDetailId = @intBatchId

	END

	DECLARE @intRecipeItemId INT
		,@intOtherChargeItemId INT
		,@dblOtherCharge NUMERIC(18, 6)
		,@intOtherChargeItemLocationId INT

	IF @dblTotalOtherCharges IS NOT NULL
		AND @dblTotalOtherCharges > 0
	BEGIN
		SELECT @intRecipeItemUOMId = IsNULL(RS.intItemUOMId, RI.intItemUOMId)
		FROM tblMFWorkOrderRecipeItem RI
		LEFT JOIN tblMFWorkOrderRecipeSubstituteItem RS ON RS.intRecipeItemId = RI.intRecipeItemId
		WHERE RI.intWorkOrderId = @intWorkOrderId
			AND (
				RI.intItemId = @intItemId
				OR RS.intSubstituteItemId = @intItemId
				)
	END

	DELETE
	FROM @GLEntries

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
				,intOtherChargeIncome = dbo.fnGetItemGLAccount(@intOtherChargeItemId, @intOtherChargeItemLocationId, @ACCOUNT_CATEGORY_Inventory)
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

			DELETE
			FROM @GLEntriesForOtherCost

			INSERT INTO @GLEntriesForOtherCost
			SELECT dtmDate = @dtmDate
				,intItemId = @intOtherChargeItemId
				,intChargeId = @intOtherChargeItemId
				,intItemLocationId = @intOtherChargeItemLocationId
				,intChargeItemLocation = @intOtherChargeItemLocationId
				,intTransactionId = @intBatchId
				,strTransactionId = @strWorkOrderNo
				,dblCost = (
					CASE 
						WHEN @intRecipeItemUOMId = @intItemUOMId
							THEN @dblOtherCharges * @dblQty
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
		END

		SELECT @intRecipeItemId = MIN(intRecipeItemId)
		FROM @tblMFOtherChargeItem
		WHERE intRecipeItemId > @intRecipeItemId
	END

	DELETE
	FROM @ItemsForPost

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
		,strTransactionId
		,intTransactionTypeId
		,intLotId
		,intSubLocationId
		,intStorageLocationId
		,intSourceTransactionId
		,strSourceTransactionId
		,intTransactionDetailId
		)
	SELECT intItemId = @intItemId
		,intItemLocationId = @intItemLocationId
		,intItemUOMId = (
			CASE 
				WHEN (
						@intItemStockUOMId = @intItemUOMId
						OR @intWeightUOMId IS NULL
						)
					THEN @intItemUOMId
				ELSE @intWeightUOMId
				END
			)
		,dtmDate = @dtmProductionDate
		,dblQty = (
			CASE 
				WHEN (
						@intItemStockUOMId = @intItemUOMId
						OR @intWeightUOMId IS NULL
						)
					THEN @dblQty
				ELSE @dblWeight
				END
			)
		,dblUOMQty = 1
		,dblCost = @dblCostPerStockUOM
		,dblSalesPrice = 0
		,intCurrencyId = NULL
		,dblExchangeRate = 1
		,intTransactionId = @intBatchId
		,strTransactionId = @strWorkOrderNo
		,intTransactionTypeId = @INVENTORY_PRODUCE
		,intLotId = @intLotId
		,intSubLocationId = @intSubLocationId
		,intStorageLocationId = @intStorageLocationId
		,intSourceTransactionId = @INVENTORY_PRODUCE
		,strSourceTransactionId = @strWorkOrderNo
		,intTransactionDetailId = @intTransactionDetailId

	EXEC dbo.uspICPostCosting @ItemsForPost
		,@strBatchId
		,NULL
		,@intUserId

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
	EXEC dbo.uspICCreateGLEntries @strBatchId
		,NULL
		,@intUserId

	UPDATE @GLEntries
	SET dblDebit = (
			SELECT sum(dblCredit)
			FROM @GLEntries
			WHERE strTransactionType = 'Consume'
			)
	WHERE strTransactionType = 'Produce'

	EXEC dbo.uspGLBookEntries @GLEntries
		,1

	UPDATE dbo.tblMFWorkOrderConsumedLot
	SET strBatchId = @strBatchId
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

	UPDATE dbo.tblMFWorkOrderProducedLot
	SET strBatchId = @strBatchId
		,dblOtherCharges = (
			CASE 
				WHEN @intRecipeItemUOMId = @intItemUOMId
					THEN @dblTotalOtherCharges * @dblQty
				ELSE @dblTotalOtherCharges * @dblWeight
				END
			)
	WHERE intWorkOrderId = @intWorkOrderId
		AND intBatchId = @intBatchId

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
		SELECT @intLotId1 = NULL
			,@intItemUOMId = NULL

		SELECT @intLotId1 = intLotId
			,@intItemUOMId = intItemUOMId
		FROM @tblMFLot
		WHERE intRecordId = @intRecordId

		IF (
				(
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) < @dblDefaultResidueQty
				AND (
					SELECT dblWeight
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) > 0
				)
			OR (
				(
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) < @dblDefaultResidueQty
				AND (
					SELECT dblQty
					FROM dbo.tblICLot
					WHERE intLotId = @intLotId1
					) > 0
				)
		BEGIN
			EXEC dbo.uspMFLotAdjustQty @intLotId = @intLotId1
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
