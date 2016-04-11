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
 	            		 tblTRLoadDistributionHeader DH            		
                        where DH.intLoadHeaderId = @intLoadHeaderId and DH.strDestination = 'Customer' and isNull(DH.intInvoiceId,0) !=0;
   
   
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
       min(DH.intEntityCustomerId),     
	   min(DH.intCompanyLocationId),
       min(DD.intItemId),	  
	   intItemUOMId = CASE
                            WHEN min(DD.intContractDetailId) is NULL  
	                           THEN (SELECT	TOP 1 
										IU.intItemUOMId											
										FROM dbo.tblICItemUOM IU 
										WHERE	IU.intItemId = min(DD.intItemId) and IU.ysnStockUnit = 1)
							WHEN min(DD.intContractDetailId) is NOT NULL 
							   THEN	(select top 1 intItemUOMId from vyuCTContractDetailView CT where CT.intContractDetailId = min(DD.intContractDetailId))
							   END, 	   
	   min(DH.dtmInvoiceDateTime),
	   min(DD.intContractDetailId),	   
	   min(TL.intShipViaId),	  
	   min(DH.intEntitySalespersonId), 
	   min(DD.dblUnits),
       min(DD.dblPrice),
	   intCurrencyId = (SELECT	TOP 1 
										CP.intDefaultCurrencyId		
										FROM	dbo.tblSMCompanyPreference CP
										WHERE	CP.intCompanyPreferenceId = 1 
												
						), -- USD default from company Preference 
	   1, -- Need to check this	  
	   min(DD.dblFreightRate),	   
	   strComments = CASE
                            WHEN min(TR.intSupplyPointId) is NULL and min(TL.intLoadId) is NULL
	                           THEN RTRIM(min(DH.strComments))
							WHEN min(TR.intSupplyPointId) is NOT NULL and min(TL.intLoadId) is NULL 
							   THEN	'Origin:' + RTRIM(min(ee.strSupplyPoint)) + ' ' + RTRIM(min(DH.strComments))
							WHEN (min(TR.intSupplyPointId)) is NULL and min(TL.intLoadId) is NOT NULL 
							   THEN	'Load #:' + RTRIM(min(LG.strExternalLoadNumber)) + ' ' + RTRIM(min(DH.strComments))
							WHEN (min(TR.intSupplyPointId)) is NOT NULL and min(TL.intLoadId) is NOT NULL 
							   THEN	'Origin:' + RTRIM(min(ee.strSupplyPoint))  + ' Load #:' + RTRIM(min(LG.strExternalLoadNumber)) + ' ' + RTRIM(min(DH.strComments))
							   END, 
	   min(TL.strTransaction),
	   min(DH.intLoadDistributionHeaderId),
	   min(DH.strPurchaseOrder),
	   'Deliver',   
	   min(DD.dblDistSurcharge),
	   CAST(MIN(CAST(DD.ysnFreightInPrice AS INT)) AS BIT),
	   min(DD.intTaxGroupId),
	   strActualCostId = CASE
                            WHEN min(TR.strOrigin) = 'Terminal' and min(DH.strDestination) = 'Customer'
	                           THEN min(TL.strTransaction)
							ELSE
							    NULL
							END, 
		min(DH.intShipToLocationId),
		NULL,
		min(DH.intInvoiceId),
		'Transport Loads' 
	   from dbo.tblTRLoadHeader TL           
			JOIN dbo.tblTRLoadDistributionHeader DH on DH.intLoadHeaderId = TL.intLoadHeaderId
			JOIN dbo.tblTRLoadDistributionDetail DD on DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId			
			LEFT JOIN dbo.vyuLGLoadView LG on LG.intLoadId = TL.intLoadId
			left join dbo.tblTRLoadReceipt TR on TR.intLoadHeaderId = TL.intLoadHeaderId and TR.strReceiptLine in (select Item from dbo.fnTRSplit(DD.strReceiptLink,','))
			left JOIN(
		SELECT		DISTINCT intLoadDistributionDetailId,STUFF(															
								   (
										SELECT	DISTINCT												
										', ' + CD.strSupplyPoint 										
										FROM dbo.vyuTRLinkedReceipts CD																								
									    WHERE CD.intLoadHeaderId=CH.intLoadHeaderId	 and CD.intLoadDistributionDetailId=CH.intLoadDistributionDetailId																			
										FOR XML PATH('')
								   )											
									,1,2, ''													
								)strSupplyPoint
															
																				
	FROM dbo.vyuTRLinkedReceipts CH		
		)ee ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId 
		
			where TL.intLoadHeaderId = @intLoadHeaderId and DH.strDestination = 'Customer'
			group by DH.intLoadDistributionHeaderId,DD.intLoadDistributionDetailId;

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
	    if @ysnPostOrUnPost = 0 and @ysnRecap = 0
		   BEGIN
		   INSERT INTO @InvoicePostOutputTable
                select Distinct DH.intInvoiceId from                                     
	            		 tblTRLoadDistributionHeader DH            		
                        where DH.intLoadHeaderId = @intLoadHeaderId and DH.strDestination = 'Customer' and ISNULL(DH.intInvoiceId,0) != 0
		   END
		ELSE
		    BEGIN
			INSERT INTO @InvoicePostOutputTable
                select Distinct IV.intInvoiceId              
                FROM
                    @InvoiceStagingTable IE  
                    JOIN tblARInvoice IV
                        on IE.intSourceId = IV.intLoadDistributionHeaderId
		    END
        

		

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