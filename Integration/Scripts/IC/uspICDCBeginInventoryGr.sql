IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCBeginInventoryGr]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCBeginInventoryGr]; 
GO 


CREATE PROCEDURE [dbo].[uspICDCBeginInventoryGr]
--** Below Stored Procedure is to migrate origin onhand unit balances from agitmmst table to i21 inventory by creating adjustments.
--   Then adjustment posting need to be done in i21 application, which will update the onhand units of inventory.
--   So here we do not directly update the onhand units from ptitmmst origin table into i21 item tblICItem table, rather we update 
--   i21 table tblICInventoryAdjustment from agitmmst table and then adjustment posting is done which updates tblICItem table. ** 
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
-- ItemStocks data migration from agitmmst origin table to tblICItem i21 table thru 
-- tblICInventoryAdjustment and tblICInventoryAdjustmentDetail creation and posting  
-- Section 9
--------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @StartingNumberId_InventoryAdjustment AS INT = 30;
DECLARE @strAdjustmentNo AS NVARCHAR(50)
		,@intAdjustmentNo AS INT
		--,@strAvgLast AS NVARCHAR(1)
		,@cnt AS INT

DECLARE @ADJUSTMENT_TYPE_QuantityChange AS INT = 1
		,@ADJUSTMENT_TYPE_UOMChange AS INT = 2
		,@ADJUSTMENT_TYPE_ItemChange AS INT = 3
		,@ADJUSTMENT_TYPE_LotStatusChange AS INT = 4
		,@ADJUSTMENT_TYPE_SplitLot AS INT = 5
		,@ADJUSTMENT_TYPE_ExpiryDateChange AS INT = 6
		,@ADJUSTMENT_TYPE_OpeningInventory AS INT = 10

SET @adjdt = ISNULL(@adjdt, GETDATE())

-- Create the Adjustment header and detail record. 
BEGIN 
	--** Fetching the next adjustment number to be assigned for the adjustment to be created from uspSMGetStartingNumber stored procedure. **
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryAdjustment, @strAdjustmentNo OUTPUT

	--select @strAvgLast = agctl_sa_cost_ind from agctlmst where agctl_key = 1

	IF ( @adjLoc IS NULL or @adjLoc = '')
		BEGIN
			DECLARE loc_cursor CURSOR
			FOR
			SELECT rtrim(agloc_loc_no) agloc_loc_no	FROM aglocmst
		END	
	ELSE
		BEGIN
			DECLARE loc_cursor CURSOR
			FOR
			SELECT @adjLoc	
		END	

		OPEN loc_cursor

		FETCH NEXT	FROM loc_cursor	INTO @adjLoc

	WHILE @@FETCH_STATUS = 0
	BEGIN	
	    SELECT @cnt = COUNT(*)
		FROM	tblICItem inv INNER JOIN gaposmst itmGr 
					ON LTRIM(RTRIM(inv.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(itmGr.gapos_com_cd)) COLLATE Latin1_General_CI_AS
				LEFT JOIN tblICItemUOM uom 
					on uom.intItemId = inv.intItemId 
				left join tblICStorageLocation sl 
					on LTRIM(RTRIM(sl.strName)) COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(itmGr.gapos_loc_no)) COLLATE Latin1_General_CI_AS	
		WHERE	
			(
				(gapos_in_house + gapos_offsite + + gapos_offsite_dp) <> 0 
				OR (gapos_stor_1 + gapos_stor_2 + gapos_stor_3 + gapos_stor_4 + gapos_stor_5 + gapos_stor_6 + gapos_stor_7 + gapos_stor_8 <> 0)
			)
			AND gapos_loc_no = @adjLoc
			AND inv.strType = 'Inventory'
	
		IF @cnt > 0
		BEGIN
			--** Update the item status, that are discontinued in Origin to Active so the the Adjustment Posting will not fail 
				UPDATE inv SET strOriginStatus = strStatus, strStatus = 'Active'
				FROM	tblICItem inv INNER JOIN agitmmst itm 
							ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.agitm_no COLLATE Latin1_General_CI_AS
						LEFT JOIN tblICItemUOM uom 
							on uom.intItemId = inv.intItemId 
				WHERE	agitm_un_on_hand <> 0 
				AND agitm_loc_no = @adjLoc
				AND inv.strType = 'Inventory'

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
				, @ADJUSTMENT_TYPE_OpeningInventory
				, @strAdjustmentNo
				, 'Begin Inventory imported by iRely'
				, 0
				, @intEntityUserSecurityId
				, 1
			)

			SELECT @intAdjustmentNo = @@IDENTITY

		--Ownership Type: Own ---- >> (gapos_in_house + gapos_offsite + + gapos_offsite_dp) <> 0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId
				,intItemId
				,dblQuantity
				,dblNewQuantity
				,dblAdjustByQuantity
				,intItemUOMId
				,intNewItemUOMId
				,dblCost
				,intSubLocationId
				,intStorageLocationId
				,intConcurrencyId
				--,strNewLotNumber 
				--,dtmNewExpiryDate
				,dblNewCost
				,intOwnershipType)
		SELECT 
			intInventoryAdjustmentId = @intAdjustmentNo
			,intItemId = inv.intItemId
			,dblQuantity = 0
			,dblNewQuantity = (gapos_in_house + gapos_offsite + gapos_offsite_dp)
			,dblAdjustByQuantity = (gapos_in_house + gapos_offsite + gapos_offsite_dp)
			,intItemUOMId = uom.intItemUOMId
			,intNewItemUOMId = uom.intItemUOMId
			,dblCost = CCP.gaprc_un_cash_prc--0 --case when @strAvgLast = 'A' then agitm_avg_un_cost else agitm_last_un_cost end
			,intSubLocationId = (SELECT sl.intSubLocationId FROM tblICStorageLocation sl 
										join tblSMCompanyLocationSubLocation cls ON sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
										join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
										WHERE sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS 
										and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS) 
			,intStorageLocationId = (SELECT sl.intSubLocationId FROM tblICStorageLocation sl 
										join tblSMCompanyLocationSubLocation cls ON sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
										join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
										WHERE sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS 
										and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS) 	
					--,sl.intSubLocationId
					--,sl.intStorageLocationId
			,intConcurrencyId = 1
			--,lot.aglot_lot_no
			--,aglot_expire_date
			,dblNewCost = CCP.gaprc_un_cash_prc --(select TOP 1 dblLastCost from vyuICGetItemPricing P WHERE uom.intItemUOMId = P.intItemUOMId AND inv.intItemId = P.intItemId AND inv.intItemId = P.intItemLocationId) lastcost
			,intOwnershipType = 1
		FROM	tblICItem inv INNER JOIN gaposmst itmGr 
					ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itmGr.gapos_com_cd COLLATE Latin1_General_CI_AS
				INNER JOIN gaprcmst CCP
					ON inv.strItemNo COLLATE Latin1_General_CI_AS = CCP.gaprc_com_cd
					AND CCP.gaprc_loc_no = itmGr.gapos_loc_no
				LEFT JOIN tblICItemUOM uom 
					on uom.intItemId = inv.intItemId 
					AND uom.ysnStockUnit = 1
				--LEFT JOIN tblICStorageLocation sl 
				--	on sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS	
		WHERE	
			(gapos_in_house + gapos_offsite + gapos_offsite_dp) <> 0
			AND  gapos_loc_no = @adjLoc
			AND inv.strType = 'Inventory'
		-----------------------------------------------------------------------------------------------------------------------------------------------------------

		--Ownership type: Storage ---- >> (gapos_stor_1 + gapos_stor_2 + gapos_stor_3 + gapos_stor_4 + gapos_stor_5 + gapos_stor_6 + gapos_stor_7 + gapos_stor_8) <> 0
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
		INSERT INTO tblICInventoryAdjustmentDetail (
				intInventoryAdjustmentId
				,intItemId
				,dblQuantity
				,dblNewQuantity
				,dblAdjustByQuantity
				,intItemUOMId
				,intNewItemUOMId
				,dblCost
				,intSubLocationId
				,intStorageLocationId
				,intConcurrencyId
				--,strNewLotNumber 
				--,dtmNewExpiryDate
				,dblNewCost
				,intOwnershipType)
		SELECT 
			@intAdjustmentNo
			,inv.intItemId
			,0
			,(gapos_stor_1 + gapos_stor_2 + gapos_stor_3 + gapos_stor_4 + gapos_stor_5 + gapos_stor_6 + gapos_stor_7 + gapos_stor_8)
			,(gapos_stor_1 + gapos_stor_2 + gapos_stor_3 + gapos_stor_4 + gapos_stor_5 + gapos_stor_6 + gapos_stor_7 + gapos_stor_8)
			,uom.intItemUOMId
			,uom.intItemUOMId
			,CCP.gaprc_un_cash_prc                                                        --0 --case when @strAvgLast = 'A' then agitm_avg_un_cost else agitm_last_un_cost end
			,(SELECT sl.intSubLocationId FROM tblICStorageLocation sl 
										join tblSMCompanyLocationSubLocation cls ON sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
										join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
										WHERE sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS 
										and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS) intSubLocationId
			,(SELECT sl.intSubLocationId FROM tblICStorageLocation sl 
										join tblSMCompanyLocationSubLocation cls ON sl.intSubLocationId = cls.intCompanyLocationSubLocationId 
										join tblSMCompanyLocation cl on cl.intCompanyLocationId = cls.intCompanyLocationId
										WHERE sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS 
										and cl.strLocationNumber COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS) intStorageLocationId	
					--,sl.intSubLocationId
					--,sl.intStorageLocationId
			,1
			--,lot.aglot_lot_no
			--,aglot_expire_date
			,CCP.gaprc_un_cash_prc --(select TOP 1 dblLastCost from vyuICGetItemPricing P WHERE uom.intItemUOMId = P.intItemUOMId AND inv.intItemId = P.intItemId AND inv.intItemId = P.intItemLocationId   )  lastcost
			,2
		FROM	tblICItem inv INNER JOIN gaposmst itmGr 
					ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itmGr.gapos_com_cd COLLATE Latin1_General_CI_AS
				INNER JOIN gaprcmst CCP
					ON inv.strItemNo COLLATE Latin1_General_CI_AS = CCP.gaprc_com_cd
					AND CCP.gaprc_loc_no = itmGr.gapos_loc_no
				LEFT JOIN tblICItemUOM uom 
					on uom.intItemId = inv.intItemId 
					AND uom.ysnStockUnit = 1
				--LEFT JOIN tblICStorageLocation sl 
				--	on sl.strName COLLATE Latin1_General_CI_AS = itmGr.gapos_loc_no COLLATE Latin1_General_CI_AS	
		WHERE	
			(gapos_stor_1 + gapos_stor_2 + gapos_stor_3 + gapos_stor_4 + gapos_stor_5 + gapos_stor_6 + gapos_stor_7 + gapos_stor_8) <> 0
			AND  gapos_loc_no = @adjLoc
			AND inv.strType = 'Inventory'
		-----------------------------------------------------------------------------------------------------------------------------------------------------------

	--FROM	tblICItem inv INNER JOIN agitmmst itm 
	--			ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.agitm_no COLLATE Latin1_General_CI_AS
	--		LEFT JOIN tblICItemUOM uom 
	--			on uom.intItemId = inv.intItemId 
	--		INNER JOIN tblICUnitMeasure B ON uom.intUnitMeasureId = B.intUnitMeasureId 
	--				AND UPPER(B.strUnitMeasure COLLATE SQL_Latin1_General_CP1_CS_AS)  = upper(rtrim(agitm_pak_desc)) COLLATE SQL_Latin1_General_CP1_CS_AS
	--		LEFT JOIN aglotmst lot ON itm.agitm_no COLLATE Latin1_General_CI_AS = lot.aglot_itm_no COLLATE Latin1_General_CI_AS
	--				--created duplicate storage location entries. converted into an inline sub query.	
	--		--left join tblICStorageLocation sl 
	--		--	on sl.strName COLLATE Latin1_General_CI_AS = itm.agitm_binloc COLLATE Latin1_General_CI_AS	
	--WHERE	agitm_un_on_hand <> 0 
	--AND agitm_loc_no = @adjLoc
	--AND aglot_loc_no = @adjLoc
	--AND aglot_un_on_hand <> 0
	--AND inv.strType = 'Inventory'
		
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
				FROM	tblICItem inv INNER JOIN agitmmst itm 
							ON  inv.strItemNo COLLATE Latin1_General_CI_AS = itm.agitm_no COLLATE Latin1_General_CI_AS
						LEFT JOIN tblICItemUOM uom 
							on uom.intItemId = inv.intItemId 
				WHERE	agitm_un_on_hand <> 0 
				AND agitm_loc_no = @adjLoc
				AND inv.strType = 'Inventory'
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

-- Rebuild the G/L Summary for that day. 
BEGIN 
	DELETE [dbo].[tblGLSummary] WHERE dbo.fnDateEquals(dtmDate, @adjdt) = 1

	INSERT INTO tblGLSummary (
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
