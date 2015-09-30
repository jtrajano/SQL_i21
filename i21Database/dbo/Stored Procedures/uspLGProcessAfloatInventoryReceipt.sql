CREATE PROCEDURE [dbo].[uspLGProcessAfloatInventoryReceipt]
	 @intShipmentId AS INT
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
        @total as int;
BEGIN TRY

-- Insert Entries to Stagging table that needs to processed from Inbound Shipments
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
	 	,ysnIsStorage
	 	,dblFreightRate
		,intSourceId		 	
	 )	
      SELECT strReceiptType = 'Purchase Contract',
       CH.intEntityId,
       EN.intDefaultLocationId,
	   CT.intCompanyLocationId,
       CT.intItemId,
	   CT.intCompanyLocationId,
	   CT.intItemUOMId,
	   NULL,
	   CT.intContractHeaderId,
	   SC.intContractDetailId,
	   GETDATE(),
	   NULL,	  
	   SC.dblNetWt,
	   CT.dblCashPrice,
	   CT.intCurrencyId,
	   1,
	   NULL,
	   SH.intSubLocationId,
	   NULL,
	   0,
	   NULL,
	   SC.intShipmentContractQtyId	   
	   FROM tblLGShipmentContractQty SC
	   JOIN tblLGShipment SH ON SH.intShipmentId = SC.intShipmentId
	   JOIN tblCTContractDetail CT ON CT.intContractDetailId = SC.intContractDetailId
	   JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
	   JOIN tblEntity EN ON EN.intEntityId = CH.intEntityId
       WHERE SH.intShipmentId = @intShipmentId;

    select @total = count(*) from @ReceiptStagingTable;
    IF (@total = 0)
	BEGIN
		RAISERROR('Inventorize process failure #1', 11, 1);
		RETURN;
	END

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

	IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult)
	BEGIN
		RAISERROR('Inventorize process failure #2', 11, 1);
		RETURN;
	END

	DECLARE @SourceId INT, @ReceiptId INT
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpAddItemReceiptResult) 
	BEGIN
		SELECT TOP 1 
				@SourceId = intSourceId
				,@ReceiptId = intInventoryReceiptId  
		FROM	#tmpAddItemReceiptResult 

		UPDATE	tblLGShipmentContractQty 
		SET		intInventoryReceiptId = @ReceiptId
		WHERE	intShipmentContractQtyId = @SourceId 

		DELETE	FROM #tmpAddItemReceiptResult 
		WHERE	intSourceId = @SourceId
				AND intInventoryReceiptId = @ReceiptId
	END;

	UPDATE tblLGShipment SET ysnInventorized = 1, dtmInventorizedDate=GETDATE() WHERE intShipmentId=@intShipmentId

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH