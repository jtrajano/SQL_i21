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

DECLARE @ReceiptStagingTable AS ReceiptStagingTable

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
	 )	
      select strReceiptType = CASE
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
	   intItemUOMId = (SELECT	TOP 1 
										IU.intItemUOMId		
										FROM	dbo.tblICItemUOM IU
										WHERE	IU.intItemId = TR.intItemId ), -- Need to add the Gallons UOM from Company Preference	   
	   TR.strBillOfLadding,
	   TR.intContractDetailId,
	   TL.dtmLoadDateTime,
	   intShipViaId,	  
	   dblGallons              = CASE
								  WHEN SP.strGrossOrNet = 'Gross'
								  THEN TR.dblGross
								  WHEN SP.strGrossOrNet = 'Net'
								  THEN TR.dblNet
								  END,
       TR.dblUnitCost,
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
	   TR.intTransportReceiptId	   
	   from tblTRTransportLoad TL
            JOIN tblTRTransportReceipt TR on TR.intTransportLoadId = TL.intTransportLoadId
			LEFT JOIN tblTRSupplyPoint SP on SP.intSupplyPointId = TR.intSupplyPointId
            where TL.intTransportLoadId = @intTransportLoadId and TR.strOrigin = 'Terminal'


    EXEC dbo.uspICAddItemReceipt @ReceiptStagingTable,@intUserId, @InventoryReceiptId;

--Update thr Transport Load as Posted
	UPDATE	TransportLoad
	      SET	TransportLoad.ysnPosted = 1
		  FROM	dbo.tblTRTransportLoad TransportLoad 
		  WHERE	TransportLoad.intTransportLoadId = @intTransportLoadId

--	EXEC dbo.uspICPostInventoryReceipt 1, 0, @strTransactionId, @intUserId, @intEntityId;
--	EXEC dbo.uspAPCreateBillFromIR @InventoryReceiptId, @intUserId;

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