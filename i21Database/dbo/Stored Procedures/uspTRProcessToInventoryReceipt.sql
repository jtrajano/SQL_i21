CREATE PROCEDURE [dbo].[uspTRProcessToItemReceipt]
	 @intTransportLoadId AS INT
	,@intUserId AS INT	

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg                    NVARCHAR(MAX);

DECLARE @ReceiptStagingTable AS ReceiptStagingTable,
		@OtherCharges AS ReceiptOtherChargesTableType, 
        @total as int,
		@intSurchargeItemId as int,
		@intFreightItemId as int;
BEGIN TRY

	-- Insert Entries to Stagging table that needs to processed to Transport Load
     INSERT into @ReceiptStagingTable(
			strReceiptType
			,intEntityVendorId
			,intShipFromId
			,intLocationId
			,intItemId
			,intItemLocationId
			,intItemUOMId
			,strBillOfLadding
			,intContractHeaderId
			,intContractDetailId
			,dtmDate
			,intShipViaId
			,dblQty
			,dblCost
			,intCurrencyId
			,dblExchangeRate
			,intLotId
			,intSubLocationId
			,intStorageLocationId
			,ysnIsCustody
			,dblFreightRate
			,intSourceId	
			,intSourceType		 	
			,dblGross
			,dblNet
			,intInventoryReceiptId
			,dblSurcharge
			,ysnFreightInPrice
	)	
	select 
			strReceiptType = CASE
								WHEN TR.intContractDetailId IS NULL
										THEN 'Direct'
								WHEN TR.intContractDetailId IS NOT NULL
										THEN 'Purchase Contract'
								END,
			TR.intTerminalId,
			SP.intEntityLocationId,
			TR.intCompanyLocationId,
			TR.intItemId,
			TR.intCompanyLocationId,
			intItemUOMId =CASE
								WHEN TR.intContractDetailId is NULL  
									THEN (SELECT	TOP 1 
											IU.intItemUOMId											
											FROM dbo.tblICItemUOM IU 
											WHERE	IU.intItemId = TR.intItemId and IU.ysnStockUnit = 1)
								WHEN TR.intContractDetailId is NOT NULL 
									THEN	(select intItemUOMId from vyuCTContractDetailView CT where CT.intContractDetailId = TR.intContractDetailId)
									END,-- Need to add the Gallons UOM from Company Preference	   
			TR.strBillOfLadding,
			CT.intContractHeaderId,
			TR.intContractDetailId,
			TL.dtmLoadDateTime,
			TL.intShipViaId,	  
			dblGallons              = CASE
										WHEN SP.strGrossOrNet = 'Gross'
										THEN TR.dblGross
										WHEN SP.strGrossOrNet = 'Net'
										THEN TR.dblNet
										END,
			
			dblUnitCost              = CASE
										WHEN TR.ysnFreightInPrice = 0
										THEN TR.dblUnitCost
										WHEN TR.ysnFreightInPrice = 1 and TR.dblPurSurcharge !=0
										THEN TR.dblUnitCost + TR.dblFreightRate + (TR.dblPurSurcharge / 100)
                                        WHEN TR.ysnFreightInPrice = 1 
										THEN TR.dblUnitCost + TR.dblFreightRate 
										END,
			intCurrencyId = (SELECT	TOP 1 
											CP.intDefaultCurrencyId		
											FROM	dbo.tblSMCompanyPreference CP
											WHERE	CP.intCompanyPreferenceId = 1 
												
							), -- USD default from company Preference 
			1, -- Need to check this
			NULL,--No LOTS from transport
			NULL, -- No Sub Location from transport
			NULL, -- No Storage Location from transport
			0,-- No Custody from transports
			TR.dblFreightRate,
			TR.intTransportReceiptId,	  
			3, -- Source type for transports is 3 
			dblGross = TR.dblGross,
			dblNet = TR.dblNet,
			TR.intInventoryReceiptId,
			TR.dblPurSurcharge,
			TR.ysnFreightInPrice
	from	tblTRTransportLoad TL JOIN tblTRTransportReceipt TR 
				ON TR.intTransportLoadId = TL.intTransportLoadId			
			LEFT JOIN vyuCTContractDetailView CT 
				ON CT.intContractDetailId = TR.intContractDetailId
			LEFT JOIN tblTRSupplyPoint SP 
				ON SP.intSupplyPointId = TR.intSupplyPointId
	where	TL.intTransportLoadId = @intTransportLoadId 
			AND TR.strOrigin = 'Terminal';
   select @intFreightItemId = intItemForFreightId from tblTRCompanyPreference
   select top 1 @intSurchargeItemId = intItemId from vyuICGetOtherCharges where intOnCostTypeId = @intFreightItemId
--Fuel Freight
   INSERT INTO @OtherCharges
   (
     [intEntityVendorId] 
	,[strBillOfLadding] 
	,[strReceiptType] 
	,[intLocationId] 
	,[intShipViaId] 
	,[intShipFromId] 
	,[intCurrencyId]  	
	,[intChargeId] 
    ,[ysnInventoryCost] 
    ,[strCostMethod] 
    ,[dblRate] 
    ,[intCostUOMId] 
    ,[intOtherChargeEntityVendorId] 
    ,[dblAmount] 
    ,[strAllocateCostBy] 
	,[intContractDetailId] 
	,[ysnAccrue]
   ) 
   select RE.intEntityVendorId,
          RE.strBillOfLadding,
		  RE.strReceiptType,
		  RE.intLocationId,
		  RE.intShipViaId,
		  RE.intShipFromId,
		  RE.intCurrencyId,
		  @intFreightItemId,
		  ysnInventoryCost   = CASE
							       WHEN RE.ysnFreightInPrice = 0
							       THEN 1
							       WHEN RE.ysnFreightInPrice = 1
							       THEN 0                                        
							       END,		  
		  'Per Unit',
		  RE.dblFreightRate,
		  (select top 1 intItemUOMId from tblICItemUOM where intItemId =  @intFreightItemId) as intItemUOMId,          
		  intOtherChargeEntityVendorId      = CASE
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor'
								                  THEN RE.intEntityVendorId
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal'
								                  THEN null
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other'
								                  THEN RE.intShipViaId
								                  END,
		  0,
		  'Unit',		  		 
		  RE.intContractDetailId,
		  ysnAccure      = CASE
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor'
								  THEN 1
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal'
								  THEN 0
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other'
								  THEN 1
								  END
    from @ReceiptStagingTable RE where RE.dblFreightRate != 0 

--Fuel Surcharge
	INSERT INTO @OtherCharges
   (
     [intEntityVendorId] 
	,[strBillOfLadding] 
	,[strReceiptType] 
	,[intLocationId] 
	,[intShipViaId] 
	,[intShipFromId] 
	,[intCurrencyId]  	
	,[intChargeId] 
    ,[ysnInventoryCost] 
    ,[strCostMethod] 
    ,[dblRate] 
    ,[intCostUOMId] 
    ,[intOtherChargeEntityVendorId] 
    ,[dblAmount] 
    ,[strAllocateCostBy] 
	,[intContractDetailId] 
	,[ysnAccrue]
   ) 
   select RE.intEntityVendorId,
          RE.strBillOfLadding,
		  RE.strReceiptType,
		  RE.intLocationId,
		  RE.intShipViaId,
		  RE.intShipFromId,
		  RE.intCurrencyId,
		  @intSurchargeItemId,
		  ysnInventoryCost       = CASE
										WHEN RE.ysnFreightInPrice = 0
										THEN 1
										WHEN RE.ysnFreightInPrice = 1
										THEN 0                                        
										END,	
		  'Percentage',
		  RE.dblSurcharge,
		  (select top 1 intItemUOMId from tblICItemUOM where intItemId =  @intSurchargeItemId) as intItemUOMId,
          intOtherChargeEntityVendorId      = CASE
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor'
								                  THEN RE.intEntityVendorId
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal'
								                  THEN null
								                  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other'
								                  THEN RE.intShipViaId
								                  END,
		  0,
		  'Unit',		  
		  RE.intContractDetailId,
		  ysnAccure      = CASE
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Vendor'
								  THEN 1
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Internal'
								  THEN 0
								  WHEN (select strFreightBilledBy from tblSMShipVia SM where SM.intEntityShipViaId = RE.intShipViaId) = 'Other'
								  THEN 1
								  END
    from @ReceiptStagingTable RE where RE.dblSurcharge != 0 
	--No Records to process so exit
    SELECT @total = COUNT(*) FROM @ReceiptStagingTable;
    IF (@total = 0)
	   RETURN;

	-- Create the temp table if it does not exists. 
	IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpAddItemReceiptResult')) 
	BEGIN 
		CREATE TABLE #tmpAddItemReceiptResult (
			intSourceId INT
			,intInventoryReceiptId INT
		)
	END 

    EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable
			,@OtherCharges
			,@intUserId;

	-- Update the Inventory Receipt Key to the Transaction Table
	UPDATE	TR
	SET		intInventoryReceiptId = addResult.intInventoryReceiptId
	FROM	dbo.tblTRTransportReceipt TR INNER JOIN #tmpAddItemReceiptResult addResult
				ON TR.intTransportReceiptId = addResult.intSourceId

	-- Post the Inventory Receipts                                            
	DECLARE @ReceiptId INT
			,@intEntityId INT
			,@strTransactionId NVARCHAR(50);

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult) 
	BEGIN

		SELECT TOP 1 
				@ReceiptId = intInventoryReceiptId  
		FROM	#tmpAddItemReceiptResult 
  
		-- Post the Inventory Receipt that was created
		SELECT	@strTransactionId = strReceiptNumber 
		FROM	tblICInventoryReceipt 
		WHERE	intInventoryReceiptId = @ReceiptId

		SELECT	TOP 1 @intEntityId = intEntityId 
		FROM	dbo.tblSMUserSecurity 
		WHERE	intUserSecurityID = @intUserId

		EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId, @intEntityId;			
		
		--EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;

		DELETE	FROM #tmpAddItemReceiptResult 
		WHERE	intInventoryReceiptId = @ReceiptId
	END;

END TRY
BEGIN CATCH
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
END CATCH