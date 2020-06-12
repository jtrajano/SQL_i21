CREATE PROCEDURE [dbo].[uspARCreatePrePayment]
	  @PaymentId	AS INT
	, @Post			AS BIT			= 1
	, @BatchId		AS NVARCHAR(20)	= NULL
	, @UserId		AS INT			
	, @NewInvoiceId	AS INT			= NULL OUTPUT	
	, @PostPrepayment	AS INT		= 0	
	, @PaidCPP			AS BIT			= 0
AS

BEGIN


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

DECLARE
	 @NewId								INT 
	,@EntityCustomerId				    INT
	,@CompanyLocationId					INT
	,@CurrencyId						INT				= NULL
	,@TermId							INT				= NULL
	,@EntityId							INT
	,@InvoiceDate						DATETIME	
	,@DueDate							DATETIME		= NULL
	,@ShipDate							DATETIME		= NULL	
	,@PostDate							DATETIME		= NULL
	,@TransactionType					NVARCHAR(50)	= 'Invoice'
	,@Type								NVARCHAR(200)	= 'Standard'
	,@ErrorMessage						NVARCHAR(250)	= NULL
	,@EntitySalespersonId				INT				= NULL				
	,@FreightTermId						INT				= NULL
	,@ShipViaId							INT				= NULL
	,@PaymentMethodId					INT				= NULL
	,@InvoiceOriginId					NVARCHAR(16)	= NULL
	,@PONumber							NVARCHAR(50)	= ''
	,@BOLNumber							NVARCHAR(50)	= ''
	,@Comment							NVARCHAR(500)	= ''			
	,@ShipToLocationId					INT				= NULL
	,@BillToLocationId					INT				= NULL
	,@Template							BIT				= 0			
	,@Forgiven							BIT				= 0			
	,@Calculated						BIT				= 0			
	,@Splitted							BIT				= 0			
	,@SplitId							INT				= NULL
	,@LoadDistributionHeaderId			INT				= NULL
	,@ActualCostId						NVARCHAR(50)	= NULL			
	,@ShipmentId						INT				= NULL
	,@TransactionId						INT				= NULL
	,@MeterReadingId					INT				= NULL
	,@OriginalInvoiceId					INT				= NULL
	,@PeriodsToAccrue					INT				= 1
	,@SourceId							INT				= 0
		
	,@ItemId							INT				= NULL
	,@ItemPrepayTypeId					INT				= 0
	,@ItemPrepayRate					NUMERIC(18,6)	= 0.000000
	,@ItemIsInventory					BIT				= 0
	,@ItemDocumentNumber				NVARCHAR(100)	= NULL			
	,@ItemDescription					NVARCHAR(500)	= NULL
	,@ItemOrderUOMId					INT				= NULL
	,@ItemQtyOrdered					NUMERIC(18,6)	= 0.000000
	,@ItemUOMId							INT				= NULL
	,@ItemQtyShipped					NUMERIC(18,6)	= 0.000000
	,@ItemDiscount						NUMERIC(18,6)	= 0.000000
	,@ItemPrice							NUMERIC(18,6)	= 0.000000	
	,@RefreshPrice						BIT				= 0
	,@ItemMaintenanceType				NVARCHAR(50)	= NULL
	,@ItemFrequency						NVARCHAR(50)	= NULL
	,@ItemMaintenanceDate				DATETIME		= NULL
	,@ItemMaintenanceAmount				NUMERIC(18,6)	= 0.000000
	,@ItemLicenseAmount					NUMERIC(18,6)	= 0.000000
	,@ItemTaxGroupId					INT				= NULL
	,@ItemStorageLocationId				INT				= NULL
	,@ItemCompanyLocationSubLocationId	INT				= NULL
	,@RecomputeTax						BIT				= 0
	,@ItemSCInvoiceId					INT				= NULL
	,@ItemSCInvoiceNumber				NVARCHAR(50)	= NULL
	,@ItemInventoryShipmentItemId		INT				= NULL
	,@ItemShipmentNumber				NVARCHAR(50)	= NULL
	,@ItemSalesOrderDetailId			INT				= NULL												
	,@ItemSalesOrderNumber				NVARCHAR(50)	= NULL
	,@ItemContractHeaderId				INT				= NULL
	,@ItemContractDetailId				INT				= NULL			
	,@ItemShipmentPurchaseSalesContractId	INT		= NULL	
	,@ItemWeightUOMId					INT				= NULL	
	,@ItemWeight						NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentGrossWt				NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentTareWt				NUMERIC(18,6)	= 0.000000		
	,@ItemShipmentNetWt					NUMERIC(18,6)	= 0.000000			
	,@ItemTicketId						INT				= NULL		
	,@ItemTicketHoursWorkedId			INT				= NULL		
	,@ItemOriginalInvoiceDetailId		INT				= NULL		
	,@ItemSiteId						INT				= NULL												
	,@ItemBillingBy						NVARCHAR(200)	= NULL
	,@ItemPercentFull					NUMERIC(18,6)	= 0.000000
	,@ItemNewMeterReading				NUMERIC(18,6)	= 0.000000
	,@ItemPreviousMeterReading			NUMERIC(18,6)	= 0.000000
	,@ItemConversionFactor				NUMERIC(18,8)	= 0.00000000
	,@ItemPerformerId					INT				= NULL
	,@ItemLeaseBilling					BIT				= 0
	,@ItemVirtualMeterReading			BIT				= 0



SELECT TOP 1
	 @EntityCustomerId					= ARC.[intEntityId]
	,@CompanyLocationId					= ARP.[intLocationId]
	,@CurrencyId						= ARP.[intCurrencyId]
	,@TermId							= NULL
	,@EntityId							= @UserId
	,@InvoiceDate						= ARP.dtmDatePaid
	,@DueDate							= ARP.dtmDatePaid
	,@ShipDate							= ARP.dtmDatePaid
	,@PostDate							= ARP.dtmDatePaid
	,@TransactionType					= 'Customer Prepayment'
	,@Type								= 'Standard'
	,@EntitySalespersonId				= NULL				
	,@FreightTermId						= NULL
	,@ShipViaId							= NULL
	,@PaymentMethodId					= ISNULL((SELECT TOP 1 [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethod] = 'Prepay' AND [ysnActive] = 1), ARP.[intPaymentMethodId])
	,@InvoiceOriginId					= NULL
	,@PONumber							= ''
	,@BOLNumber							= ''
	,@Comment							= ARP.strRecordNumber			
	,@ShipToLocationId					= NULL
	,@BillToLocationId					= NULL
	,@Template							= 0			
	,@Forgiven							= 0			
	,@Calculated						= 0			
	,@Splitted							= 0			
	,@SplitId							= NULL
	,@LoadDistributionHeaderId			= NULL
	,@ActualCostId						= NULL			
	,@ShipmentId						= NULL
	,@TransactionId						= NULL
	,@MeterReadingId					= NULL
	,@OriginalInvoiceId					= NULL
	,@PeriodsToAccrue					= 1
	,@SourceId							= 0
		
	,@ItemId							= NULL
	,@ItemPrepayTypeId					= 1
	,@ItemPrepayRate					= @ZeroDecimal
	,@ItemIsInventory					= 0
	,@ItemDocumentNumber				= NULL			
	,@ItemDescription					= 'Prepayment for '+ ARP.strRecordNumber
	,@ItemOrderUOMId					= NULL
	,@ItemQtyOrdered					= @ZeroDecimal
	,@ItemUOMId							= NULL
	,@ItemQtyShipped					= 1.000000
	,@ItemDiscount						= @ZeroDecimal
	,@ItemPrice							= ARP.[dblAmountPaid]	
	,@RefreshPrice						= 0
	,@ItemMaintenanceType				= NULL
	,@ItemFrequency						= NULL
	,@ItemMaintenanceDate				= NULL
	,@ItemMaintenanceAmount				= @ZeroDecimal
	,@ItemLicenseAmount					= @ZeroDecimal
	,@ItemTaxGroupId					= NULL
	,@ItemStorageLocationId				= NULL
	,@ItemCompanyLocationSubLocationId	= NULL
	,@RecomputeTax						= 0
	,@ItemSCInvoiceId					= NULL
	,@ItemSCInvoiceNumber				= NULL
	,@ItemInventoryShipmentItemId		= NULL
	,@ItemShipmentNumber				= NULL
	,@ItemSalesOrderDetailId			= NULL												
	,@ItemSalesOrderNumber				= NULL
	,@ItemContractHeaderId				= NULL
	,@ItemContractDetailId				= NULL			
	,@ItemShipmentPurchaseSalesContractId	= NULL	
	,@ItemWeightUOMId					= NULL	
	,@ItemWeight						= @ZeroDecimal		
	,@ItemShipmentGrossWt				= @ZeroDecimal		
	,@ItemShipmentTareWt				= @ZeroDecimal		
	,@ItemShipmentNetWt					= @ZeroDecimal			
	,@ItemTicketId						= NULL		
	,@ItemTicketHoursWorkedId			= NULL		
	,@ItemOriginalInvoiceDetailId		= NULL		
	,@ItemSiteId						= NULL												
	,@ItemBillingBy						= NULL
	,@ItemPercentFull					= @ZeroDecimal
	,@ItemNewMeterReading				= @ZeroDecimal
	,@ItemPreviousMeterReading			= @ZeroDecimal
	,@ItemConversionFactor				= @ZeroDecimal
	,@ItemPerformerId					= NULL
	,@ItemLeaseBilling					= 0
	,@ItemVirtualMeterReading			= 0
FROM
	[tblARPayment] ARP
INNER JOIN
	[tblARCustomer] ARC
		ON ARP.[intEntityCustomerId] = ARC.[intEntityId]
WHERE 
	ARP.[intPaymentId] = @PaymentId


EXEC [dbo].[uspARCreateCustomerInvoice]
	 @EntityCustomerId					= @EntityCustomerId
	,@CompanyLocationId					= @CompanyLocationId
	,@CurrencyId						= @CurrencyId
	,@TermId							= @TermId
	,@EntityId							= @EntityId
	,@InvoiceDate						= @InvoiceDate
	,@DueDate							= @DueDate
	,@ShipDate							= @ShipDate
	,@PostDate							= @PostDate
	,@TransactionType					= @TransactionType
	,@Type								= @Type
	,@NewInvoiceId						= @NewId		OUTPUT
	,@ErrorMessage						= @ErrorMessage	OUTPUT
	,@RaiseError						= 1
	,@EntitySalespersonId				= @EntitySalespersonId
	,@FreightTermId						= @FreightTermId
	,@ShipViaId							= @ShipViaId
	,@PaymentMethodId					= @PaymentMethodId
	,@InvoiceOriginId					= @InvoiceOriginId
	,@PONumber							= @PONumber
	,@BOLNumber							= @BOLNumber
	,@Comment							= @Comment
	,@ShipToLocationId					= @ShipToLocationId
	,@BillToLocationId					= @BillToLocationId
	,@Posted							= 1
	,@Template							= @Template
	,@Forgiven							= @Forgiven
	,@Calculated						= @Calculated
	,@Splitted							= @Splitted
	,@PaymentId							= @PaymentId
	,@SplitId							= @SplitId
	,@LoadDistributionHeaderId			= @LoadDistributionHeaderId
	,@ActualCostId						= @ActualCostId
	,@ShipmentId						= @ShipmentId
	,@TransactionId						= @TransactionId
	,@MeterReadingId					= @MeterReadingId
	,@OriginalInvoiceId					= @OriginalInvoiceId
	,@PeriodsToAccrue					= @PeriodsToAccrue
	,@SourceId							= @SourceId
	,@ItemId							= @ItemId
	,@ItemPrepayTypeId					= @ItemPrepayTypeId
	,@ItemPrepayRate					= @ItemPrepayRate
	,@ItemIsInventory					= @ItemIsInventory
	,@ItemDocumentNumber				= @ItemDocumentNumber
	,@ItemDescription					= @ItemDescription
	,@ItemOrderUOMId					= @ItemOrderUOMId
	,@ItemQtyOrdered					= @ItemQtyOrdered
	,@ItemUOMId							= @ItemUOMId
	,@ItemQtyShipped					= @ItemQtyShipped
	,@ItemDiscount						= @ItemDiscount
	,@ItemPrice							= @ItemPrice
	,@RefreshPrice						= @RefreshPrice
	,@ItemMaintenanceType				= @ItemMaintenanceType
	,@ItemFrequency						= @ItemFrequency
	,@ItemMaintenanceDate				= @ItemMaintenanceDate
	,@ItemMaintenanceAmount				= @ItemMaintenanceAmount
	,@ItemLicenseAmount					= @ItemLicenseAmount
	,@ItemTaxGroupId					= @ItemTaxGroupId
	,@ItemStorageLocationId				= @ItemStorageLocationId
	,@ItemCompanyLocationSubLocationId	= @ItemCompanyLocationSubLocationId
	,@RecomputeTax						= @RecomputeTax
	,@ItemSCInvoiceId					= @ItemSCInvoiceId
	,@ItemSCInvoiceNumber				= @ItemSCInvoiceNumber
	,@ItemInventoryShipmentItemId		= @ItemInventoryShipmentItemId
	,@ItemShipmentNumber				= @ItemShipmentNumber
	,@ItemSalesOrderDetailId			= @ItemSalesOrderDetailId
	,@ItemSalesOrderNumber				= @ItemSalesOrderNumber
	,@ItemContractHeaderId				= @ItemContractHeaderId
	,@ItemContractDetailId				= @ItemContractDetailId
	,@ItemShipmentPurchaseSalesContractId	= @ItemShipmentPurchaseSalesContractId
	,@ItemWeightUOMId					= @ItemWeightUOMId
	,@ItemWeight						= @ItemWeight
	,@ItemShipmentGrossWt				= @ItemShipmentGrossWt
	,@ItemShipmentTareWt				= @ItemShipmentTareWt
	,@ItemShipmentNetWt					= @ItemShipmentNetWt
	,@ItemTicketId						= @ItemTicketId
	,@ItemTicketHoursWorkedId			= @ItemTicketHoursWorkedId
	,@ItemOriginalInvoiceDetailId		= @ItemOriginalInvoiceDetailId
	,@ItemSiteId						= @ItemSiteId
	,@ItemBillingBy						= @ItemBillingBy
	,@ItemPercentFull					= @ItemPercentFull
	,@ItemNewMeterReading				= @ItemNewMeterReading
	,@ItemPreviousMeterReading			= @ItemPreviousMeterReading
	,@ItemConversionFactor				= @ItemConversionFactor
	,@ItemPerformerId					= @ItemPerformerId
	,@ItemLeaseBilling					= @ItemLeaseBilling
	,@ItemVirtualMeterReading			= @ItemVirtualMeterReading
	,@PaidCPP							= @PaidCPP
	      
		  
SET @NewInvoiceId = @NewId	

DECLARE @ysnHasEFTBudget BIT = 0

IF EXISTS (SELECT TOP 1 NULL FROM tblARPaymentDetail WHERE intInvoiceId IS NULL AND intBillId IS NULL AND intPaymentId = @PaymentId)
	SET @ysnHasEFTBudget = CAST(1 AS BIT)
	
---ADD CPP INVOICE TO PAYMENT DETAIL
IF(ISNULL(@NewInvoiceId, 0) <> 0) AND @PostPrepayment = 1AND @ysnHasEFTBudget = 0
	BEGIN 
		INSERT INTO [tblARPaymentDetail]
			([intPaymentId]
			,[intInvoiceId]
			,[intBillId]
			,[strTransactionNumber] 
			,[intTermId]
			,[intAccountId]
			,[dblInvoiceTotal]
			,[dblBaseInvoiceTotal]
			,[dblDiscount]
			,[dblBaseDiscount]
			,[dblDiscountAvailable]
			,[dblBaseDiscountAvailable]
			,[dblInterest]
			,[dblBaseInterest]
			,[dblAmountDue]
			,[dblBaseAmountDue]
			,[dblPayment]        
			,[dblBasePayment]        
			,[strInvoiceReportNumber]
			,[intConcurrencyId]
			,[dtmDiscountDate]
			)
		SELECT
			 [intPaymentId]					= @PaymentId
			,[intInvoiceId]					= ARI.[intInvoiceId] 
			,[intBillId]					= NULL
			,[strTransactionNumber]			= ARI.[strInvoiceNumber]
			,[intTermId]					= ARI.[intTermId] 
			,[intAccountId]					= ARI.[intAccountId] 
			,[dblInvoiceTotal]				= @ItemPrice  
			,[dblBaseInvoiceTotal]			= @ItemPrice
			,[dblDiscount]                
			,[dblBaseDiscount]            
			,[dblDiscountAvailable]       
			,[dblBaseDiscountAvailable]   
			,[dblInterest]                
			,[dblBaseInterest]            
			,[dblAmountDue]                  
			,[dblBaseAmountDue]              
			,[dblPayment]					= @ItemPrice
			,[dblBasePayment]				= @ItemPrice  
			,[strInvoiceReportNumber]		= ''
			,[intConcurrencyId]				= 0
			,[dtmDiscountDate]				= NULL
		FROM    
			tblARInvoice ARI    
		WHERE
			ARI.[intInvoiceId] = @NewInvoiceId
				
		UPDATE tblARPayment SET intCurrentStatus = 5, ysnInvoicePrepayment = 1
		WHERE intPaymentId = @PaymentId
			
	END
        
  RETURN @NewId

END