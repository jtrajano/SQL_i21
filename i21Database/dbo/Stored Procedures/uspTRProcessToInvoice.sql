CREATE PROCEDURE [dbo].[uspTRProcessToInvoice]
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

DECLARE @InvoiceStagingTable AS InvoiceStagingTable,
        @total as int;

BEGIN TRY

-- Insert Entries to Stagging table that needs to processed to Transport Load
     INSERT into @InvoiceStagingTable(    
	 	 intEntityCustomerId
	 	,intLocationId
	 	,intItemId
	 	,intItemUOMId
	 	,dtmDate
		,intContractDetailId
	 	,intShipViaId
		,intSalesPersonId
	    ,dblQty
	    ,dblPrice
	  	,intCurrencyId
	 	,dblExchangeRate
	 	,dblFreightRate
		,strComments
		,strSourceId	
		,intSourceId
		,strPurchaseOrder		 	
	 )	 
	 select     
       DH.intEntityCustomerId,     
	   DH.intCompanyLocationId,
       DD.intItemId,	  
	   intItemUOMId = (SELECT	TOP 1 
										IU.intItemUOMId		
										FROM	dbo.tblICItemUOM IU
										WHERE	IU.intItemId = DD.intItemId ), -- Need to add the Gallons UOM from Company Preference	   
	   TL.dtmLoadDateTime,
	   DD.intContractDetailId,	   
	   TL.intShipViaId,	  
	   DH.intEntitySalespersonId, 
	   DD.dblUnits,
       DD.dblPrice,
	   intCurrencyId = (SELECT	TOP 1 
										CP.intDefaultCurrencyId		
										FROM	dbo.tblSMCompanyPreference CP
										WHERE	CP.intCompanyPreferenceId = 1 
												
						), -- USD default from company Preference 
	   1, -- Need to check this	  
	   TR.dblFreightRate,
	   NULL,
	   TL.strTransaction,
	   DH.intDistributionHeaderId,
	   DH.strPurchaseOrder   
	   from tblTRTransportLoad TL
            JOIN tblTRTransportReceipt TR on TR.intTransportLoadId = TL.intTransportLoadId
			JOIN tblTRDistributionHeader DH on DH.intTransportReceiptId = TR.intTransportReceiptId
			JOIN tblTRDistributionDetail DD on DD.intDistributionHeaderId = DH.intDistributionHeaderId
            where TL.intTransportLoadId = @intTransportLoadId and DH.strDestination = 'Customer';

--No Records to process so exit
 select @total = count(*) from @InvoiceStagingTable;
    if (@total = 0)
	   return;

DECLARE @InvoiceOutputTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
    intSourceId int,
	intInvoiceId int
    )

INSERT into @InvoiceOutputTable(
		 intSourceId	
		,intInvoiceId		 	
	 )	
  EXEC dbo.uspARAddInvoice @InvoiceStagingTable,@intUserId;

Declare @incval int,
        @SouceId int,
		@InvoiceId int;
select @total = count(*) from @InvoiceOutputTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN

  select @SouceId = intSourceId,@InvoiceId =intInvoiceId  from @InvoiceOutputTable where @incval = intId
  
   update tblTRDistributionHeader 
       set intInvoiceId = @InvoiceId
         where @SouceId = intDistributionHeaderId 
   SET @incval = @incval + 1;
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