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
      SELECT strReceiptType = 'Purchase Contract',
       CH.intEntityId,
       EN.intDefaultLocationId,
	   CT.intCompanyLocationId,
       CT.intItemId,
	   CT.intCompanyLocationId,
	   CT.intItemUOMId,
	   NULL,
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

DECLARE @ReceiptOutputTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
    intSourceId int,
	intInventoryReceiptId int
    )

INSERT into @ReceiptOutputTable(
		 intSourceId	
		,intInventoryReceiptId		 	
	 )	
    EXEC dbo.uspICAddItemReceipt 
			@ReceiptStagingTable 
			,@OtherCharges
			,@intUserId;

Declare @incval int,
        @SourceId int,
		@ReceiptId int;
select @total = count(*) from @ReceiptOutputTable;
    IF (@total = 0)
	BEGIN
		RAISERROR('Inventorize process failure #2', 11, 1);
		RETURN;
	END

set @incval = 1 
WHILE @incval <=@total 
BEGIN

  select @SourceId = intSourceId, @ReceiptId =intInventoryReceiptId  from @ReceiptOutputTable where @incval = intId
  
   update tblLGShipmentContractQty 
       set intInventoryReceiptId = @ReceiptId
         where intShipmentContractQtyId = @SourceId 
   SET @incval = @incval + 1;
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