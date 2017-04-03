IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCBeginInventoryAg]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCBeginInventoryAg]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCBeginInventoryAg]
--** Below Stored Procedure is to migrate origin onhand unit balances from agitmmst table to i21 inventory by creating adjustments.
--   Then adjustment posting need to be done in i21 application, which will update the onhand units of inventory.
--   So here we do not directly update the onhand units from ptitmmst origin table into i21 item tblICItem table, rather we update 
--   i21 table tblICInventoryAdjustment from agitmmst table and then adjustment posting is done which updates tblICItem table. ** 
 @adjLoc NVARCHAR(3),	
 @adjdt  DATETIME , 
 @intEntityUserSecurityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemStocks data migration from agitmmst origin table to tblICItem i21 table thru 
-- tblICInventoryAdjustment and tblICInventoryAdjustmentDetail creation and posting  
-- Section 9
--------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @StartingNumberId_InventoryAdjustment AS INT = 30;
DECLARE @strAdjustmentNo AS NVARCHAR(50)
		,@intAdjustmentNo AS INT
		,@strAvgLast AS NVARCHAR(1)

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

-- Create the Adjustment header and detail record. 
BEGIN 
	--** Fetching the next adjustment number to be assigned for the adjustment to be created from uspSMGetStartingNumber stored procedure. **
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryAdjustment, @strAdjustmentNo OUTPUT

	select @strAvgLast = agctl_sa_cost_ind from agctlmst where agctl_key = 1

	INSERT INTO [dbo].[tblICInventoryAdjustment](
		intLocationId
		, dtmAdjustmentDate
		, intAdjustmentType
		, strAdjustmentNo
		, strDescription
		, ysnPosted
		, intEntityId
		, intConcurrencyId
	)
	VALUES (
		(SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @adjLoc)
		, @adjdt
		, @ADJUSTMENT_TYPE_QuantityChange
		, @strAdjustmentNo
		, 'Begin Inventory imported by iRely'
		, 0
		, @intEntityUserSecurityId
		, 1
	)

	SELECT @intAdjustmentNo = @@IDENTITY

	INSERT INTO tblICInventoryAdjustmentDetail (
		intInventoryAdjustmentId
        ,intItemId
        ,dblQuantity
        ,dblNewQuantity
        ,dblAdjustByQuantity
		,intItemUOMId
        ,dblCost
		,intSubLocationId
		,intStorageLocationId
        ,intConcurrencyId
	)
     
	SELECT 
		@intAdjustmentNo
		,inv.intItemId
		,0
		,agitm_un_on_hand
		,agitm_un_on_hand
		,uom.intItemUOMId
		,case when @strAvgLast = 'A' then agitm_avg_un_cost else agitm_last_un_cost end
		,sl.intSubLocationId
		,sl.intStorageLocationId
		,1
	FROM	tblICItem inv INNER JOIN agitmmst itm 
				ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.agitm_no COLLATE Latin1_General_CI_AS
			LEFT JOIN tblICItemUOM uom 
				on uom.intItemId = inv.intItemId 
			left join tblICStorageLocation sl 
				on sl.strName COLLATE Latin1_General_CI_AS = itm.agitm_binloc COLLATE Latin1_General_CI_AS	
	WHERE	agitm_un_on_hand <> 0 
	AND inv.strType in ('Inventory', 'Finished Good', 'Raw Material')


	-- Create an Audit Log
	BEGIN 
		DECLARE @strDescription AS NVARCHAR(100) 
				,@actionType AS NVARCHAR(50)

		SELECT @actionType = 'Imported'
			
		EXEC	dbo.uspSMAuditLog 
				@keyValue = @intAdjustmentNo							-- Primary Key Value of the Inventory Adjustment. 
				,@screenName = 'Inventory.view.InventoryAdjustment'     -- Screen Namespace
				,@entityId = @intEntityUserSecurityId                   -- Entity Id.
				,@actionType = @actionType                              -- Action Type
				,@changeDescription = @strDescription					-- Description
				,@fromValue = ''										-- Previous Value
				,@toValue = ''											-- New Value
	END
END 

	--Adjustment has to be posted. it will book inventory account. However amount is already imported during the gl import.
	--adjustment posting will book the amount again. This has to be handled with the following steps. 
	--post the adjustment. This will debit inventory and credit the inventory adjustment account.
	--update the credit also to inventory account to washout the debit.

		   --Call IC posting code here

--------------------------------------------------------------------------------------------------------------------------------------------
-- Auto post the inventory adjustment
BEGIN 

	EXEC dbo.uspICPostInventoryAdjustment
		@ysnPost = 1
		,@ysnRecap = 0
		,@strTransactionId = @strAdjustmentNo
		,@intEntityUserSecurityId = @intEntityUserSecurityId
END 

-- Tweak the contra-gl account used. 
BEGIN 
	-- Update the GL credit entries to use Inventory account id
	UPDATE	gd
	SET		gd.intAccountId = dbo.fnGetItemGLAccount(t.intItemId, t.intItemLocationId, 'Inventory') 
	FROM	tblGLDetail gd INNER JOIN  tblICInventoryTransaction t 
				ON gd.intJournalLineNo = t.intInventoryTransactionId
				AND gd.strTransactionId = t.strTransactionId
				AND gd.intTransactionId = t.intTransactionId
				AND gd.strBatchId = t.strBatchId	
	WHERE	t.strTransactionId = @strAdjustmentNo
			AND t.intTransactionId = @intAdjustmentNo
			AND gd.ysnIsUnposted = 0 
			AND gd.dblCredit <> 0 
END 

-- Rebuild the G/L Summary for that day. 
BEGIN 
	DELETE [dbo].[tblGLSummary] WHERE dbo.fnDateEquals(dtmDate, @adjdt) = 1
	/* this line is commented by Mon.Gonzales 20170403 just to push through EntityDistribution#*/
	/*INSERT INTO tblGLSummary
	SELECT
			intCompanyId
			,intAccountId
			,dtmDate
			,SUM(ISNULL(dblDebit,0)) as dblDebit
			,SUM(ISNULL(dblCredit,0)) as dblCredit
			,SUM(ISNULL(dblDebitUnit,0)) as dblDebitUnit
			,SUM(ISNULL(dblCreditUnit,0)) as dblCreditUnit
			,strCode
			,0 as intConcurrencyId
	FROM	tblGLDetail
	WHERE	ysnIsUnposted = 0
			AND dbo.fnDateEquals(dtmDate, @adjdt) = 1	
	GROUP BY intCompanyId, intAccountId, dtmDate, strCode*/
END