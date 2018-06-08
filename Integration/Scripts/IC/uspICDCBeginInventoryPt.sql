IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCBeginInventoryPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCBeginInventoryPt]; 
GO 

CREATE PROCEDURE [dbo].[uspICDCBeginInventoryPt]
--** Below Stored Procedure is to migrate origin onhand unit balances from ptitmmst table to i21 inventory by creating adjustments.
--   Then adjustment posting need to be done in i21 application, which will update the onhand units of inventory.
--   So here we do not directly update the onhand units from ptitmmst origin table into i21 item tblICItem table, rather we update 
--   i21 table tblICInventoryAdjustment from ptitmmst table and then adjustment posting is done which updates tblICItem table. ** 
 @adjLoc NVARCHAR(3) = NULL,	
 @adjdt  DATETIME  = NULL, 
 @intEntityUserSecurityId AS INT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--------------------------------------------------------------------------------------------------------------------------------------------
-- ItemStocks data migration from ptitmmst origin table to tblICItem i21 table thru 
-- tblICInventoryAdjustment and tblICInventoryAdjustmentDetail creation and posting  
-- Section 9
--------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @StartingNumberId_InventoryAdjustment AS INT = 30;
DECLARE @strAdjustmentNo AS NVARCHAR(50)
		,@intAdjustmentNo AS INT
		,@strAvgLast AS NVARCHAR(1)
		,@cnt AS INT

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6

SET @adjdt = ISNULL(@adjdt, GETDATE())

-- Create the Adjustment header and detail record. 
BEGIN 
	
	select @strAvgLast = ptctl_sa_lst_or_avg_cost from ptctlmst where ptctl_key = 1

	IF ( @adjLoc IS NULL or @adjLoc = '')
		BEGIN
			DECLARE loc_cursor CURSOR
			FOR
			SELECT rtrim(ptloc_loc_no) ptloc_loc_no	FROM ptlocmst
		END	
	ELSE
		BEGIN
			DECLARE loc_cursor CURSOR
			FOR
			SELECT @adjLoc	
		END	

	OPEN loc_cursor

	FETCH NEXT
	FROM loc_cursor
	INTO @adjLoc

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	SELECT @cnt = COUNT(*)
		FROM	tblICItem inv INNER JOIN ptitmmst itm 
					ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.ptitm_itm_no COLLATE Latin1_General_CI_AS
				LEFT JOIN tblICItemUOM uom 
					on uom.intItemId = inv.intItemId 
				left join tblICStorageLocation sl 
					on sl.strName COLLATE Latin1_General_CI_AS = itm.ptitm_binloc COLLATE Latin1_General_CI_AS	
		WHERE	ptitm_on_hand <> 0 
		AND ptitm_loc_no = @adjLoc
		AND inv.strType in ('Inventory', 'Finished Good', 'Raw Material')
	
		IF @cnt > 0
		BEGIN
		--** Update the item status, that are discontinued in Origin to Active so the the Adjustment Posting will not fail 
				UPDATE inv SET strOriginStatus = strStatus, strStatus = 'Active'
				FROM	tblICItem inv INNER JOIN ptitmmst itm 
							ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.ptitm_itm_no COLLATE Latin1_General_CI_AS
						LEFT JOIN tblICItemUOM uom 
							on uom.intItemId = inv.intItemId 
				WHERE	ptitm_on_hand <> 0 
				AND ptitm_loc_no = @adjLoc
				AND inv.strType in ('Inventory', 'Finished Good', 'Raw Material')

			--** Fetching the next adjustment number to be assigned for the adjustment to be created from uspSMGetStartingNumber stored procedure. **
			EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryAdjustment, @strAdjustmentNo OUTPUT

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
				,intNewItemUOMId
				,dblNewCost
				,intSubLocationId
				,intStorageLocationId
				,intConcurrencyId
			)
		     
			SELECT 
				@intAdjustmentNo
				,inv.intItemId
				,0
				,ptitm_on_hand
				,ptitm_on_hand
				,uom.intItemUOMId
				,uom.intItemUOMId
				--,case when @strAvgLast = 'A' then ptitm_avg_cost else ptitm_cost1 end
				,ptitm_avg_cost 
				,(select sl.intSubLocationId 
					from 
						tblICStorageLocation sl 
						join tblSMCompanyLocationSubLocation cls on sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
						join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
						where sl.strName COLLATE Latin1_General_CI_AS = itm.ptitm_binloc COLLATE Latin1_General_CI_AS 
						and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itm.ptitm_loc_no COLLATE Latin1_General_CI_AS) intSubLocationId
				,(select sl.intSubLocationId 
					from 
						tblICStorageLocation sl 
						join tblSMCompanyLocationSubLocation cls on sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
						join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
						where sl.strName COLLATE Latin1_General_CI_AS = itm.ptitm_binloc COLLATE Latin1_General_CI_AS 
						and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itm.ptitm_loc_no COLLATE Latin1_General_CI_AS) intStorageLocationId	

				--,sl.intSubLocationId
				--,sl.intStorageLocationId
				,1
			FROM	tblICItem inv INNER JOIN ptitmmst itm 
						ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.ptitm_itm_no COLLATE Latin1_General_CI_AS
					LEFT JOIN tblICItemUOM uom 
						on uom.intItemId = inv.intItemId 
					LEFT JOIN tblICItemLocation il ON il.intItemId = inv.intItemId
					--created duplicate storage location entries. converted into an inline sub query.	
					--left join tblICStorageLocation sl 
					--	on sl.strName COLLATE Latin1_General_CI_AS = itm.ptitm_binloc COLLATE Latin1_General_CI_AS	
			WHERE	(ptitm_on_hand > 0 OR (ptitm_on_hand < 0 AND il.intAllowNegativeInventory))
			AND ptitm_loc_no = @adjLoc
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


			--Adjustment has to be posted. it will book inventory account. However amount is already imported during the gl import.
			--adjustment posting will book the amount again. This has to be handled with the following steps. 
			--post the adjustment. This will debit inventory and credit the inventory adjustment account.
			--update the credit also to inventory account to washout the debit.

				   --Call IC posting code here

			--------------------------------------------------------------------------------------------------------------------------------------------
			-- Auto post the inventory adjustment
			BEGIN TRY
				EXEC dbo.uspICPostInventoryAdjustment
					@ysnPost = 1
					,@ysnRecap = 0
					,@strTransactionId = @strAdjustmentNo
					,@intEntityUserSecurityId = @intEntityUserSecurityId
			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessage NVARCHAR(4000);
				DECLARE @ErrorSeverity INT;
				DECLARE @ErrorState INT;

				SELECT 
					@ErrorMessage = ERROR_MESSAGE(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE();

				-- Use RAISERROR inside the CATCH block to return error
				-- information about the original error that caused
				-- execution to jump to the CATCH block.
				RAISERROR (
					@ErrorMessage, -- Message text.
					@ErrorSeverity, -- Severity.
					@ErrorState -- State.
				);

				GOTO BreakLoopWithError
			END CATCH 

		--** Revert the original Origin status, after the posting 
				UPDATE inv SET  strStatus = strOriginStatus
				FROM	tblICItem inv INNER JOIN ptitmmst itm 
							ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.ptitm_itm_no COLLATE Latin1_General_CI_AS
						LEFT JOIN tblICItemUOM uom 
							on uom.intItemId = inv.intItemId 
				WHERE	ptitm_on_hand <> 0 
				AND ptitm_loc_no = @adjLoc
				AND inv.strType in ('Inventory', 'Finished Good', 'Raw Material')

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
		END
		FETCH NEXT
		FROM loc_cursor
		INTO @adjLoc

	END
	GOTO CloseLoop

	BreakLoopWithError:  
	CLOSE loc_cursor
	DEALLOCATE loc_cursor
	GOTO Post_Exit 

	CloseLoop:
	CLOSE loc_cursor
	DEALLOCATE loc_cursor
END
	--ELSE
	--BEGIN 
	--		INSERT INTO [dbo].[tblICInventoryAdjustment](
	--			intLocationId
	--			, dtmAdjustmentDate
	--			, intAdjustmentType
	--			, strAdjustmentNo
	--			, strDescription
	--			, ysnPosted
	--			, intEntityId
	--			, intConcurrencyId
	--		)
	--		VALUES (
	--			(SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @adjLoc)
	--			, @adjdt
	--			, @ADJUSTMENT_TYPE_QuantityChange
	--			, @strAdjustmentNo
	--			, 'Begin Inventory imported by iRely'
	--			, 0
	--			, @intEntityUserSecurityId
	--			, 1
	--		)
	--END
	


-- Rebuild the G/L Summary for that day. 
BEGIN 
	DELETE [dbo].[tblGLSummary] WHERE dbo.fnDateEquals(dtmDate, @adjdt) = 1

	INSERT INTO tblGLSummary(
		intMultiCompanyId
		,intAccountId
		,dtmDate
		,dblDebit 
		,dblCredit
		,dblDebitUnit 
		,dblCreditUnit 
		,strCode
		,intConcurrencyId 
	)
	SELECT
			intMultiCompanyId
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
	GROUP BY intMultiCompanyId, intAccountId, dtmDate, strCode
END

Post_Exit:

