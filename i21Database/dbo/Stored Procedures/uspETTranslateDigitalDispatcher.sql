CREATE PROCEDURE [uspETTranslateDigitalDispatcher]        
 @StagingTable ETTranslateSDToInvoiceTable READONLY        
 ,@EntityUserId   INT        
 ,@ErrorMessage NVARCHAR(MAX) = '' OUTPUT         
         
AS        
BEGIN        
        
 DECLARE @strCustomerNumber      NVARCHAR(100)        
 DECLARE @strInvoiceNumber      NVARCHAR(25)        
 DECLARE @stri21InvoiceNumber       NVARCHAR(25)        
         
 DECLARE @dtmInvoiceDate       DATETIME        
 DECLARE @strSiteNumber       NVARCHAR(5)        
 DECLARE @strUOM         NVARCHAR(50)        
 DECLARE @dblUnitPrice       NUMERIC(18,6)        
 DECLARE @strItemDescription      NVARCHAR(250)        
 DECLARE @dblPercentFullAfterDelivery   NUMERIC(18,6)        
 DECLARE @strLocation       NVARCHAR(50)        
 DECLARE @strTermCode       NVARCHAR(100)        
 DECLARE @strSalesAccount      NVARCHAR(40)        
 DECLARE @strItemNumber       NVARCHAR(50)        
 DECLARE @strTaxGroup       NVARCHAR(50)        
 DECLARE @strDriverNumber      NVARCHAR(100)        
 DECLARE @strTruckNumber NVARCHAR(50)        
 DECLARE @strType        NVARCHAR(10)        
 DECLARE @dblQuantity       NUMERIC(18, 6)        
 DECLARE @dblTotal        NUMERIC(18, 6)        
 DECLARE @intLineItem       INT        
 DECLARE @dblPrice        NUMERIC(18, 6)        
 DECLARE @strComment        NVARCHAR(MAX)        
 DECLARE @strDetailType       NVARCHAR(2)        
 DECLARE @strContractNumber      NVARCHAR(50)        
 DECLARE @intContractSequence      INT        
 DECLARE @intContractDetailId  INT  
 DECLARE @intContractHeaderId  INT  
 DECLARE @intImportDDToInvoiceId     INT        
 DECLARE @intCustomerEntityId     INT        
 DECLARE @intDriverEntityId      INT             
 DECLARE @intLocationId       INT        
 DECLARE @intItemId        INT        
 DECLARE @intSiteId        INT        
 DECLARE @intTaxGroupId       INT          
 DECLARE @LogId         INT        
    
      
 DECLARE @intLocation INT      
 DECLARE @dblLatitude NUMERIC(18, 6)  
 DECLARE @dblLongitude NUMERIC(18, 6)  
 DECLARE @intTruckDriverReferenceId INT      
 DECLARE @intEntitySalespersonId INT   
              
 DECLARE @ValidationTableLog TABLE(      
  strCustomerNumber   NVARCHAR(100)      
  ,strInvoiceNumber   NVARCHAR(50)      
  ,strSiteNumber    NVARCHAR(5)      
  ,intLineItem    INT      
  ,strMessage     NVARCHAR(MAX)      
  ,ysnError     BIT      
 )        
        
 IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDDToInvoice'))         
 BEGIN        
  DROP TABLE #tmpDDToInvoice        
 END        
         
 SELECT intImportDDToInvoiceId = IDENTITY(INT, 1, 1), * INTO #tmpDDToInvoice         
 FROM @StagingTable        
         
 DECLARE @EntriesForInvoice AS InvoiceStagingTable        
 DECLARE @GPSTable TMGPSUpdateByIdTable  
        
 ---Loop through the unique customer invoice date        
 WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDDToInvoice)         
 BEGIN  
              
 SELECT TOP 1  
  @strCustomerNumber     = strCustomerNumber        
  ,@strInvoiceNumber     = strInvoiceNumber        
  ,@dtmInvoiceDate     = dtmDate        
  ,@intLineItem      = intLineItem        
  ,@strSiteNumber      = strSiteNumber         
  ,@strUOM       = NULL --strUOM no UOM as of this writing. (02022018)        
  ,@dblUnitPrice      = dblUnitPrice        
  ,@strItemDescription    = strItemDescription        
  ,@dblPercentFullAfterDelivery = dblPercentFullAfterDelivery        
  ,@strLocation      = strLocation --Company Location        
  ,@strTermCode      = NULL --strTermCode no TERM as of this writing. (02022018)        
  ,@strSalesAccount     = NULL --strSalesAccount no SALES ACCOUNT as of this writing. (02022018)        
  ,@strItemNumber      = strItemNumber        
  ,@strTaxGroup      = strSalesTaxId        
  ,@strDriverNumber     = strDriverNumber   
  ,@strTruckNumber     = strTruckNumber       
  ,@strType       = 'Invoice'--strType no other type as of this writing 02022018        
  ,@dblQuantity      = dblQuantity        
  ,@dblTotal       = NULL --dblTotal        
  ,@intLineItem      = intLineItem        
  ,@dblPrice       = dblPrice        
  ,@strComment      = strComment        
  ,@intImportDDToInvoiceId   = intImportDDToInvoiceId        
  ,@strDetailType      = '' --strDetailType not in use as of this writing        
  ,@strContractNumber     = strContractNumber   
  ,@intContractSequence    = intContractSequence  --contract detail id (tblCTContractDetail primary key) from TM order export.  
  ,@dblLatitude = dblLatitude  
  ,@dblLongitude = dblLongitude  
 FROM #tmpDDToInvoice        
   --ORDER BY intLineItem ASC        
        
 --SET @TransactionType = 'Invoice'        
        
 --Get Customer Entity Id        
 SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)        
        
 --Get Tax Group Id        
    SET @intTaxGroupId = (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE intTaxGroupId = @strTaxGroup)   
    -- IET-349 - use INT - select is use to somehow validate the taxcode,  if returns null .. AR will default tax from customer setup (IET-321)  
        
 --Get Item id        
 SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)        
      
 /*Contract Management */      
 /*-------------------------------------------------------------------------------------------------------------------------------------------------*/      
 --*note for now no checking. will get whatever what is in the file. no requirements yet in specs.  
 --as of this writing 05222019 the query below only purpose is to check if the contract number, detail id , using the same item Id , still exists  
 SET @intContractDetailId = NULL  
 SET @intContractHeaderId = NULL  
  
 SELECT TOP 1 @intContractDetailId = intContractDetailId  
    ,@intContractHeaderId = intContractHeaderId  
 FROM  
  [vyuCTCustomerContract] ARCC  
 WHERE  
  ARCC.[intEntityCustomerId] = @intCustomerEntityId  
  AND ARCC.[intItemId] = @intItemId  
  --AND CAST(@dtmInvoiceDate AS DATE) BETWEEN CAST(ARCC.[dtmStartDate] AS DATE) AND   
  --         CAST(ISNULL(ARCC.[dtmEndDate], @dtmInvoiceDate) AS DATE)   
  --*note AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete') -- for now will no checking. will get whatever what is in the file. no requirements yet in specs.  
  --*note AND (ARCC.[dblAvailableQty] > 0)   
  AND ARCC.strContractNumber = @strContractNumber  
  AND ARCC.intContractDetailId = @intContractSequence  
 /*-------------------------------------------------------------------------------------------------------------------------------------------------*/      
  
  
 /*Tank Management */      
 /*-------------------------------------------------------------------------------------------------------------------------------------------------*/      
 --SET @intSiteId = ( SELECT TOP 1 intSiteID FROM tblTMCustomer A INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID      
 --  WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST(@strSiteNumber AS INT))      
      
   DECLARE @intSiteItemTaxId INT  
   DECLARE @intSiteProductId INT  
   DECLARE @dblSiteProductPrice NUMERIC(18,6)  
   SET @intSiteId = NULL
   SELECT TOP 1 @intSiteId = B.intSiteID  
      ,@intSiteItemTaxId = intTaxStateID   
      ,@dblSiteProductPrice = dblPrice  
      ,@intSiteProductId = intProduct  
   FROM tblTMCustomer A  
     INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID  
     LEFT JOIN tblTMDispatch C ON B.intSiteID = C.intSiteID  
   WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST(@strSiteNumber AS INT)  
  
   SET @intTaxGroupId = (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @strTaxGroup)  
   --Tax Mismatch Checking...  
   IF ISNULL(@intSiteItemTaxId,0) <> ISNULL(@intTaxGroupId,0)  
     BEGIN  
     INSERT INTO @ValidationTableLog (strCustomerNumber ,strInvoiceNumber,strSiteNumber,intLineItem ,strMessage,ysnError)      
      SELECT strCustomerNumber = @strCustomerNumber       
       ,strInvoiceNumber = @stri21InvoiceNumber      
       ,strSiteNumber = @strSiteNumber       
       ,intLineItem = @intImportDDToInvoiceId       
       ,strMessage = 'Tax Mismatch'      
       ,ysnError = 0  
     END  
    
   --Get Item id  
   SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)  
   SET @intItemId = ISNULL(@intItemId,0)  
   --Item Mismatch Checking...  
   IF ISNULL(@intSiteProductId,0) <> ISNULL(@intItemId,0)  
     BEGIN  
        
      INSERT INTO @ValidationTableLog (strCustomerNumber ,strInvoiceNumber,strSiteNumber,intLineItem ,strMessage,ysnError)      
      SELECT strCustomerNumber = @strCustomerNumber       
       ,strInvoiceNumber = @stri21InvoiceNumber      
       ,strSiteNumber = @strSiteNumber       
       ,intLineItem = @intImportDDToInvoiceId       
       ,strMessage = 'Product Mismatch'      
       ,ysnError = 0     
     END  
  
     
    SET @dblSiteProductPrice =  (SELECT TOP 1 dblPrice   FROM tblTMDispatch  WHERE intSiteID = @intSiteId)  
   --Price Mismatch Checking...  
   IF ISNULL(@dblPrice,0) <> ISNULL(@dblSiteProductPrice ,0)  
     BEGIN  
        
      INSERT INTO @ValidationTableLog (strCustomerNumber ,strInvoiceNumber,strSiteNumber,intLineItem ,strMessage,ysnError)      
      SELECT strCustomerNumber = @strCustomerNumber       
       ,strInvoiceNumber = @stri21InvoiceNumber      
       ,strSiteNumber = @strSiteNumber       
       ,intLineItem = @intImportDDToInvoiceId       
       ,strMessage = 'Price Mismatch'  
       ,ysnError = 0     
        
     END  
  
 IF(@dblPercentFullAfterDelivery = 0 AND @dblQuantity > 0)      
 SET @dblPercentFullAfterDelivery = (SELECT TOP 1 dblDefaultFull FROM tblICItem WHERE intItemId = @intItemId)      
 /*------------------------------------------------------------------------------------------------------------------------------------------------- */      
        
 --Invoice Number        
 SET @stri21InvoiceNumber =  ISNULL((SELECT TOP 1 strPrefix COLLATE Latin1_General_CI_AS   
          FROM tblSMStartingNumber    
             WHERE strTransactionType COLLATE Latin1_General_CI_AS = 'Truck Billing'   
          AND strModule COLLATE Latin1_General_CI_AS = 'Energy Trac') , '') + REPLACE(@strInvoiceNumber COLLATE Latin1_General_CI_AS,'-', '')           
            
 --Get Entity ID of the Driver        
 --Set Driver Number from Import Column DriverNumber      
 --Error if Driver Number is not setup in Salespersons setup      
 --And Mark the transition is invalid and do not create sales invoice.      
 --SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo COLLATE Latin1_General_CI_AS = @strDriverNumber )        
 IF(LTRIM(RTRIM(@strDriverNumber)) <> '')      
 BEGIN      
 SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblARSalesperson where strType = 'Driver' and strDriverNumber COLLATE Latin1_General_CI_AS = @strDriverNumber)      
 IF (@intDriverEntityId IS NULL)      
 BEGIN      
 INSERT INTO @ValidationTableLog (strCustomerNumber ,strInvoiceNumber,strSiteNumber,intLineItem ,strMessage,ysnError)      
 SELECT strCustomerNumber = @strCustomerNumber       
  ,strInvoiceNumber = @stri21InvoiceNumber      
  ,strSiteNumber = @strSiteNumber       
  ,intLineItem = @intImportDDToInvoiceId       
  ,strMessage = 'Invalid Driver Number'      
  ,ysnError = 1     
 END      
 END      
 /*----------------------------------------------------------------------------      
 --Set Truck No from Import Column TruckNumber      
 --Error if Truck No is not setup in > tblSCTruckDriverReference      
 --And Mark the transition is invalid and do not create sales invoice.      
 */----------------------------------------------------------------------------      
 IF(LTRIM(RTRIM(@strTruckNumber)) <> '')      
 BEGIN      
 SET @intTruckDriverReferenceId = (SELECT TOP 1 intTruckDriverReferenceId FROM tblSCTruckDriverReference where strRecordType = 'T' AND strData = @strTruckNumber)      
 IF (@intTruckDriverReferenceId IS NULL)      
 BEGIN    
 INSERT INTO @ValidationTableLog (strCustomerNumber ,strInvoiceNumber,strSiteNumber,intLineItem ,strMessage,ysnError)      
 SELECT strCustomerNumber = @strCustomerNumber       
  ,strInvoiceNumber = @stri21InvoiceNumber      
  ,strSiteNumber = @strSiteNumber       
  ,intLineItem = @intImportDDToInvoiceId       
  ,strStatus = 'Invalid Truck Number'      
  ,ysnError = 1      
 END      
 END      
 /*----------------------------------------------------------------------------      
 --Default Salesperson to the Salesperson from Customer Setup (IET-319)      
 --If Customer Setup for Salesperson is blank      
 --Then Set to Driver Number      
 */----------------------------------------------------------------------------      
 SET @intEntitySalespersonId = ISNULL((SELECT TOP 1 intSalespersonId FROM tblARCustomer where intEntityId = @intCustomerEntityId),@intDriverEntityId)   
              
   --Get Location Id        
   /*Convert to Numeric DIGITAL DISPATCH send divisionNUm as numeric(int)*/      
         
 SET @intLocation  = (SELECT CASE WHEN ISNUMERIC(@strLocation) = 1 THEN CAST(@strLocation AS INT) ELSE NULL END)      
      
 SET @intLocationId = ISNULL((SELECT TOP 1 intCompanyLocationId   
                              FROM tblSMCompanyLocation   
                              WHERE (CASE WHEN ISNUMERIC(strLocationNumber) = 1 THEN CAST(strLocationNumber  AS INT) ELSE 0 END) = @intLocation),0)        
           
   --------Get Item Unit Measure Id = ()        
   ------SET @intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol = @strUOM)        
   ---------Get Uom ID        
   ------SET @intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)        
           
   --------Get Term Code        
   ------SET @intTermCode = (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTermCode = @strTermCode)        
        
   INSERT INTO @EntriesForInvoice(  
        [strSourceTransaction]        
        ,[intEntityCustomerId]        
        ,[intSiteId]        
        ,[strInvoiceOriginId]        
        ,[ysnUseOriginIdAsInvoiceNumber]        
        ,[intTaxGroupId]        
        ,[intItemId]        
        ,[strType]         
       --,[strTransactionType]        
       ,[ysnRecomputeTax]        
       ,[intInvoiceId]        
       ,[intCompanyLocationId]        
       ,[dtmDate]        
       ,[intEntitySalespersonId]        
       ,[intFreightTermId]        
       ,[intPaymentMethodId]        
       --,[strDeliverPickup]        
       ,[intShipToLocationId]        
       ,[intBillToLocationId]        
       ,[ysnTemplate]        
       ,[ysnForgiven]        
       ,[ysnCalculated]        
       ,[ysnSplitted]        
       ,[intPaymentId]        
       ,[intSplitId]        
       ,[intLoadDistributionHeaderId]        
       ,[strActualCostId]        
       ,[intShipmentId]        
       ,[intTransactionId]        
       ,[intEntityId]        
       ,[ysnResetDetails]        
       ,[intInvoiceDetailId]        
       ,[intOrderUOMId]        
       ,[dblQtyOrdered]        
       ,[dblQtyShipped]        
       ,[intItemUOMId]        
               
       ,[dblPrice]        
       ,[ysnRefreshPrice]        
       ,[strMaintenanceType]        
       ,[strFrequency]        
       ,[dtmMaintenanceDate]        
       ,[dblMaintenanceAmount]        
       ,[dblLicenseAmount]        
       ,[intSCInvoiceId]        
       ,[strSCInvoiceNumber]        
       ,[intInventoryShipmentItemId]        
       ,[strShipmentNumber]        
       ,[intSalesOrderDetailId]        
       ,[strSalesOrderNumber]        
       ,[intContractHeaderId]        
       ,[intContractDetailId]        
       ,[intShipmentPurchaseSalesContractId]        
       ,[intTicketId]        
       ,[intTicketHoursWorkedId]        
       ,[intId]        
       ,[strSourceId]        
       ,[intSourceId]        
       --,[strBillingBy]        
       ,[dblPercentFull]        
    ,[intTruckDriverId]    
    ,[intTruckDriverReferenceId]  
       --,[dblNewMeterReading]        
       --,[dblPreviousMeterReading]        
       --,[dblConversionFactor]        
       --,[intPerformerId]        
       --,[ysnLeaseBilling]        
       --,[ysnVirtualMeterReading]        
       --,[strImportFormat]        
       --,[dblCOGSAmount]        
       --,[intTempDetailIdForTaxes]        
       --,[intConversionAccountId]        
       --,[intCurrencyExchangeRateTypeId]        
       --,[intCurrencyExchangeRateId]        
       --,[dblCurrencyExchangeRate]        
       --,[intSubCurrencyId]        
       --,[dblSubCurrencyRate]        
       --,[ysnInventory]        
               
               
       --,[intCurrencyId]        
       --,[intTermId]        
       --,[dtmDueDate]        
       --,[dtmShipDate]        
       --,[dtmPostDate]        
       --,[intShipViaId]        
       --,[strPONumber]        
       --,[strBOLNumber]        
       --,[strComments]        
       --,[ysnPost]        
       --,[strItemDescription]        
       --,[dblDiscount]        
      )        
      SELECT         
        [strSourceTransaction]  = 'Direct'        
        ,[intEntityCustomerId]  = ISNULL(@intCustomerEntityId,0)        
        ,[intSiteId]    = @intSiteId        
        ,[strInvoiceOriginId]  = @stri21InvoiceNumber        
        ,[ysnUseOriginIdAsInvoiceNumber] = 1        
        ,[intTaxGroupId]   = @intTaxGroupId        
        ,[intItemId]    = @intItemId        
        ,[strType] = 'Tank Delivery'        
       --,[strTransactionType]  = 'Tank Delivery'        
       ,[ysnRecomputeTax] = (CASE WHEN @strTaxGroup = '' THEN 0 ELSE 1 END) --IET-321      
       ,[intInvoiceId]    = NULL        
       ,[intCompanyLocationId]  = ISNULL(@intLocationId,0)        
       ,[dtmDate]     = @dtmInvoiceDate        
       ,[intEntitySalespersonId] = ISNULL(@intEntitySalespersonId ,@intDriverEntityId)        
       ,[intFreightTermId]   = NULL        
               
       ,[intPaymentMethodId]  = NULL        
               
               
       --,[strDeliverPickup]   = NULL        
               
       ,[intShipToLocationId]  = NULL        
       ,[intBillToLocationId]  = NULL        
       ,[ysnTemplate]    = 0        
       ,[ysnForgiven]    = 0        
       ,[ysnCalculated]   = 0        
       ,[ysnSplitted]    = 0        
       ,[intPaymentId]    = NULL        
       ,[intSplitId]    = NULL        
       ,[intLoadDistributionHeaderId] = NULL        
       ,[strActualCostId]   = NULL        
       ,[intShipmentId]   = NULL        
       ,[intTransactionId]   = NULL        
       ,[intEntityId]    = @EntityUserId        
       ,[ysnResetDetails]   = 1        
       ,[intInvoiceDetailId]  = NULL        
       ,[intOrderUOMId]   = NULL        
       ,[dblQtyOrdered]   = @dblQuantity        
       ,[dblQtyShipped]   = @dblQuantity        
       ,[intItemUOMId]    = NULL        
               
       ,[dblPrice]     = @dblPrice        
       ,[ysnRefreshPrice]   = 0        
       ,[strMaintenanceType]  = NULL        
       ,[strFrequency]    = NULL        
       ,[dtmMaintenanceDate]  = NULL        
       ,[dblMaintenanceAmount]  = NULL        
       ,[dblLicenseAmount]   = NULL        
       ,[intSCInvoiceId]   = NULL        
       ,[strSCInvoiceNumber]  = NULL        
       ,[intInventoryShipmentItemId] = NULL        
       ,[strShipmentNumber]  = NULL        
       ,[intSalesOrderDetailId] = NULL        
       ,[strSalesOrderNumber]  = NULL        
       ,[intContractHeaderId]  = @intContractHeaderId  
       ,[intContractDetailId]  = @intContractDetailId  
       ,[intShipmentPurchaseSalesContractId] = NULL        
       ,[intTicketId]    = NULL        
       ,[intTicketHoursWorkedId] = NULL        
       ,[intId] = @intImportDDToInvoiceId        
       ,[strSourceId]    = @strInvoiceNumber        
       ,[intSourceId]    = 4
       --,[strBillingBy]    = @BillingBy        
       ,[dblPercentFull]   = @dblPercentFullAfterDelivery  
    ,[intTruckDriverId] =  @intDriverEntityId  
    ,[intTruckDriverReferenceId] = @intTruckDriverReferenceId  
       --,[dblNewMeterReading]  = @NewMeterReading        
       --,[dblPreviousMeterReading] = @PreviousMeterReading        
       --,[dblConversionFactor]  = @ConversionFactor        
       --,[intPerformerId]   = @PerformerId        
       --,[ysnLeaseBilling]   = NULL        
       --,[ysnVirtualMeterReading] = CASE WHEN @BillingBy = 'Virtual Meter' THEN 1 ELSE 0 END        
       --,[strImportFormat]   = @ImportFormat        
       --,[dblCOGSAmount]   = CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END        
       --,[intTempDetailIdForTaxes]  = @ImportLogDetailId        
       --,[intConversionAccountId] = @ConversionAccountId        
       --,[intCurrencyExchangeRateTypeId] = NULL        
       --,[intCurrencyExchangeRateId]  = NULL        
       --,[dblCurrencyExchangeRate] = 1.000000        
       --,[intSubCurrencyId]   = NULL        
       --,[dblSubCurrencyRate]  = 1.000000        
       --,[ysnInventory]    = CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST AND ISNULL(@ItemId, 0) > 0 THEN         
       --        CASE WHEN (SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @ItemId) = 'Inventory' THEN 1 ELSE 0 END        
       --         ELSE 0 END        
               
               
       --,[intCurrencyId]   = @DefaultCurrencyId        
       --,[intTermId]    = @TermId        
       --,[dtmDueDate]    = @DueDate        
       --,[dtmShipDate]    = @ShipDate        
       --,[dtmPostDate]    = @PostDate        
       --,[intShipViaId]    = @ShipViaId        
       --,[strPONumber]    = @PONumber        
       --,[strBOLNumber]    = @BOLNumber        
       --,[strComments]    = @Comment        
       --,[ysnPost]     = NULL        
       --,[strItemDescription]  = @ItemDescription        
       --,[dblDiscount]    = @DiscountPercentage        
  
 /**GPS**/      
 IF(@dblLatitude <> 0 AND @dblLongitude <> 0 AND ISNULL(@intSiteId,0) <> 0)   
 BEGIN  
   INSERT INTO @GPSTable  
  SELECT @intSiteId, @dblLatitude,  @dblLongitude   
 END  
 /**GPS**/      
   --Delete         
   DELETE FROM #tmpDDToInvoice WHERE intImportDDToInvoiceId = @intImportDDToInvoiceId          
 END        
      
 --(AR)Process        
 -------------------------------------------------------------------------------------------------------------------------------------------------------        
 DECLARE  @LineItemTaxEntries LineItemTaxDetailStagingTable        
 DECLARE @ValidEntriesForInvoice AS InvoiceStagingTable        
 INSERT INTO @ValidEntriesForInvoice  SELECT * FROM @EntriesForInvoice WHERE [strInvoiceOriginId] NOT IN (SELECT DISTINCT strInvoiceNumber COLLATE Latin1_General_CI_AS  FROM @ValidationTableLog WHERE ysnError = 1)      
 IF @@ROWCOUNT > 0   
 BEGIN  
 EXEC [dbo].[uspARProcessInvoicesByBatch]  
  @InvoiceEntries  = @ValidEntriesForInvoice        
  ,@LineItemTaxEntries =  @LineItemTaxEntries        
  ,@UserId    = @EntityUserId        
  ,@GroupingOption  = 15        
  ,@RaiseError   = 0        
  ,@ErrorMessage   = @ErrorMessage OUTPUT        
  ,@LogId     = @LogId OUTPUT           
 END        
 -------------------------------------------------------------------------------------------------------------------------------------------------------        
         
 /**GPS**/  
 DECLARE @GPSTableARInvoiceDetail AS TMGPSUpdateByIdTable   
 /** get only all sucessful invoicedetails**/  
    
 INSERT INTO @GPSTableARInvoiceDetail   
 SELECT ARD.intSiteId, GPS.dblLatitude , GPS.dblLongitude   
 FROM tblARInvoiceIntegrationLogDetail IL  
  INNER JOIN tblARInvoiceDetail ARD ON IL.intInvoiceDetailId = ARD.intInvoiceDetailId   
  INNER JOIN @GPSTable GPS ON ARD.intSiteId = GPS.intSiteId  
 WHERE IL.intIntegrationLogId = @LogId AND IL.intInvoiceDetailId IS NOT NULL AND ysnSuccess = 1  
  AND ISNULL(ARD.intSiteId,0) <> 0    
  
 IF @@rowcount > 0  
 BEGIN  
  Exec uspTMUpdateSiteGPSById @GPSTableARInvoiceDetail  
 END  
 /**END GPS**/  
      
 SELECT * FROM (   
   SELECT tblARCustomer.strCustomerNumber AS strCustomerNumber          
    ,ISNULL(tblARInvoice.strInvoiceNumber, '') AS strInvoiceNumber          
    ,'' COLLATE Latin1_General_CI_AS AS strSiteNumber           
    ,tblARInvoice.dtmDate AS dtmDate            
    ,tblICItem.strItemNo AS strItemNumber      
    ,0 AS intLineItem           
    ,'' AS strFileName           
    --,strMessage AS strStatus            
    ,strMessage  +  STUFF((SELECT ',' + CAST(T2.strMessage AS VARCHAR(100))  FROM @ValidationTableLog T2 WHERE intId = T2.intLineItem AND ysnError = 0 FOR XML PATH('')),1,1,'') AS strStatus      
    ,ISNULL(ysnSuccess,0) AS ysnSuccessful           
    ,ISNULL(tblARInvoiceIntegrationLogDetail.intInvoiceId,0) AS intInvoiceId        
    ,tblARInvoiceIntegrationLogDetail.strTransactionType AS strTransactionType        
   FROM tblARInvoiceIntegrationLogDetail          
    LEFT JOIN tblARInvoice ON tblARInvoiceIntegrationLogDetail.intInvoiceId = tblARInvoice.intInvoiceId --  AND intInvoiceDetailId IS null  
    LEFT JOIN tblARInvoiceDetail ON tblARInvoiceIntegrationLogDetail.intInvoiceDetailId = tblARInvoiceDetail.intInvoiceDetailId  
    LEFT JOIN tblICItem ON tblARInvoiceDetail.intItemId = tblICItem.intItemId      
    LEFT JOIN tblARCustomer ON tblARInvoice.intEntityCustomerId = tblARCustomer.intEntityId          
   WHERE intIntegrationLogId = @LogId       
        
     UNION  
  
   SELECT      
    strCustomerNumber COLLATE Latin1_General_CI_AS AS strCustomerNumber          
    ,strInvoiceNumber COLLATE Latin1_General_CI_AS AS strInvoiceNumber          
    ,'' AS strSiteNumber           
    ,getdate() AS dtmDate            
    ,'' AS strItemNumber      
    ,0 AS intLineItem           
    ,'' AS strFileName           
    ,strMessage COLLATE Latin1_General_CI_AS AS strStatus            
    , CAST(0 AS BIT)  AS ysnSuccessful           
    ,0 AS intInvoiceId        
    ,'' strTransactionType        
   FROM @ValidationTableLog      
   WHERE ysnError = 1  
   ) ResultTableLog      
  ORDER BY ysnSuccessful,strInvoiceNumber,strItemNumber  
  --SELECT * FROM @ResultTableLog      
     
      
END    
  
GO