CREATE PROCEDURE [dbo].[uspTRLoadProcessToInvoice]
	 @intLoadHeaderId AS INT
	,@intUserId AS INT	
	,@ysnRecap AS BIT
	,@ysnPostOrUnPost AS BIT
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
        @strReceiptLink AS NVARCHAR(100),
		@strBOL AS NVARCHAR(50),
        @total as int;

DECLARE @InvoiceOutputTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
    intSourceId int,
	intInvoiceId int
    )
DECLARE @InvoicePostOutputTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intInvoiceId int
    )
BEGIN TRY

if @ysnPostOrUnPost = 0 and @ysnRecap = 0
BEGIN
   INSERT INTO @InvoiceOutputTable
               select DH.intLoadDistributionHeaderId,DH.intInvoiceId from 
                        tblTRLoadHeader TL
                        JOIN tblTRLoadReceipt TR on TR.intLoadHeaderId = TL.intLoadHeaderId
	            		JOIN tblTRLoadDistributionHeader DH on DH.intLoadHeaderId = TL.intLoadHeaderId
	            		JOIN tblTRLoadDistributionDetail DD on DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId 
	            		LEFT JOIN vyuTRSupplyPointView SP on SP.intSupplyPointId = TR.intSupplyPointId
	            		LEFT JOIN vyuLGLoadView LG on LG.intLoadId = TL.intLoadId
                        where TL.intLoadHeaderId = @intLoadHeaderId and DH.strDestination = 'Customer';
   
   SELECT @total = COUNT(*) FROM @InvoiceOutputTable;
    IF (@total = 0)
	   BEGIN
	     RETURN;
	   END
	ELSE
	    BEGIN
        	GOTO _PostOrUnPost;
		END
END

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
		,strDeliverPickup	 
		,dblSurcharge
		,ysnFreightInPrice
		,intTaxGroupId	
		,strActualCostId
		,intShipToLocationId
		,strBOLNumber
		,intInvoiceId
		,strSourceScreenName
	 )	 
	 	 select     
       DH.intEntityCustomerId,     
	   DH.intCompanyLocationId,
       DD.intItemId,	  
	   intItemUOMId = CASE
                            WHEN DD.intContractDetailId is NULL  
	                           THEN (SELECT	TOP 1 
										IU.intItemUOMId											
										FROM dbo.tblICItemUOM IU 
										WHERE	IU.intItemId = DD.intItemId and IU.ysnStockUnit = 1)
							WHEN DD.intContractDetailId is NOT NULL 
							   THEN	(select top 1 intItemUOMId from vyuCTContractDetailView CT where CT.intContractDetailId = DD.intContractDetailId)
							   END, 	   
	   DH.dtmInvoiceDateTime,
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
	   DD.dblFreightRate,	   
	   strComments = CASE
                            WHEN (select top 1 intSupplyPointId from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) is NULL and TL.intLoadId is NULL
	                           THEN RTRIM(DH.strComments)
							WHEN (select top 1 intSupplyPointId from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) is NOT NULL and TL.intLoadId is NULL 
							   THEN	'Origin:' + RTRIM((select top 1 strSupplyPoint from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId))) + ' ' + RTRIM(DH.strComments)
							WHEN (select top 1 intSupplyPointId from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) is NULL and TL.intLoadId is NOT NULL 
							   THEN	'Load #:' + RTRIM(LG.strExternalLoadNumber) + ' ' + RTRIM(DH.strComments)
							WHEN (select top 1 intSupplyPointId from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)) is NOT NULL and TL.intLoadId is NOT NULL 
							   THEN	'Origin:' + RTRIM((select top 1 strSupplyPoint from dbo.fnTRLinkedReceipt(DD.strReceiptLink,DH.intLoadHeaderId)))  + ' Load #:' + RTRIM(LG.strExternalLoadNumber) + ' ' + RTRIM(DH.strComments)
							   END, 
	   TL.strTransaction,
	   DH.intLoadDistributionHeaderId,
	   DH.strPurchaseOrder,
	   'Deliver',   
	   DD.dblDistSurcharge,
	   DD.ysnFreightInPrice,
	   DD.intTaxGroupId,
	   (select top 1 strTransaction from tblTRLoadHeader TT
                   join tblTRLoadReceipt RR on TT.intLoadHeaderId = RR.intLoadHeaderId
			       join tblTRLoadDistributionHeader HH on HH.intLoadHeaderId = TT.intLoadHeaderId 
				   join tblTRLoadDistributionDetail HD on HD.intLoadDistributionHeaderId = HH.intLoadDistributionHeaderId 
                   where RR.strOrigin = 'Terminal' 
			         and HH.strDestination = 'Customer' 
			         and HH.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId ) as strActualCostId,
		DH.intShipToLocationId,
		NULL,
		DH.intInvoiceId,
		'Transport Loads' 
	   from tblTRLoadHeader TL           
			JOIN tblTRLoadDistributionHeader DH on DH.intLoadHeaderId = TL.intLoadHeaderId
			JOIN tblTRLoadDistributionDetail DD on DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId			
			LEFT JOIN vyuLGLoadView LG on LG.intLoadId = TL.intLoadId
            where TL.intLoadHeaderId = @intLoadHeaderId and DH.strDestination = 'Customer';

--No Records to process so exit
 select @total = count(*) from @InvoiceStagingTable;
    if (@total = 0)
	   return;

EXEC dbo.uspARAddInvoice @InvoiceStagingTable,@intUserId;


INSERT INTO @InvoiceOutputTable
select IE.intSourceId,
       IV.intInvoiceId
FROM
    @InvoiceStagingTable IE  
    JOIN tblARInvoice IV
        on IE.intSourceId = IV.intLoadDistributionHeaderId

_PostOrUnPost:

Declare @incval int,
        @SouceId int,
		@InvoiceId int;

DECLARE @minId int = 0,
        @maxId int,
		@SuccessCount int,
		@InvCount int,
		@IsSuccess BIT,
		@batchId NVARCHAR(20);
select @total = count(*) from @InvoiceOutputTable;
set @incval = 1 
WHILE @incval <=@total 
BEGIN
     select @SouceId = intSourceId,@InvoiceId =intInvoiceId  from @InvoiceOutputTable where @incval = intId
     
   --if @minId = 0
   --BEGIN
   --   set @minId = @InvoiceId
   --END
   --if @minId != 0
   --BEGIN
   --   set @maxId = @InvoiceId
   --END
   update tblTRLoadDistributionHeader 
       set intInvoiceId = @InvoiceId
         where @SouceId = intLoadDistributionHeaderId 

   set @strReceiptLink = (select dbo.fnTRConcatString('',@InvoiceId,',','strReceiptLink'))
   set @strBOL = (select dbo.fnTRConcatString(@strReceiptLink,@intLoadHeaderId,',','strBillOfLading'))

    update tblARInvoice 
       set strBOLNumber = @strBOL
         where intInvoiceId = @InvoiceId 

   SET @incval = @incval + 1;

END;

 if @ysnRecap = 0
    BEGIN
        INSERT INTO @InvoicePostOutputTable
        select Distinct IV.intInvoiceId              
        FROM
            @InvoiceStagingTable IE  
            JOIN tblARInvoice IV
                on IE.intSourceId = IV.intLoadDistributionHeaderId
        select @total = count(*) from @InvoicePostOutputTable;
        set @incval = 1 
        WHILE @incval <=@total 
        BEGIN
           select @InvoiceId =intInvoiceId  from @InvoicePostOutputTable where @incval = intId
        
          		
                EXEC	 [dbo].[uspARPostInvoice]
                     				@batchId = NULL,
                     				@post = @ysnPostOrUnPost,
                     				@recap = 0,
                     				@param = NULL,
                     				@userId = @intUserId,
                     				@beginDate = NULL,
                     				@endDate = NULL,
                     				@beginTransaction = @InvoiceId,
                     				@endTransaction = @InvoiceId,
                     				@exclude = NULL,
                     				@successfulCount = @SuccessCount OUTPUT,
                     				@invalidCount = @InvCount OUTPUT,
                     				@success = @IsSuccess OUTPUT,
                     				@batchIdUsed = @batchId OUTPUT,
                     				@recapId = NULL,
                     				@transType = N'Invoice',
                                    @raiseError = 1
                     if @IsSuccess = 0
                     BEGIN
                        RAISERROR('Invoice did not Post/UnPost', 16, 1);
                     END
           
        
        
           SET @incval = @incval + 1;
        
        END;
--Post the invoice that was created
    END

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