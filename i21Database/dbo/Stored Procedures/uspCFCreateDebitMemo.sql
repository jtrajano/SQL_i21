
CREATE PROCEDURE [dbo].[uspCFCreateDebitMemo](
	 @xmlParam					NVARCHAR(MAX)  
	,@entityId					INT			   = NULL
	,@ErrorMessage				NVARCHAR(250)  = NULL OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@ysnDevMode				BIT = 0
)
AS
BEGIN
   
DECLARE @EntriesForInvoice		AS InvoiceIntegrationStagingTable
DECLARE @TaxDetails				AS LineItemTaxDetailStagingTable 

DECLARE @companyLocationId		INT = 0

SELECT TOP 1 @companyLocationId = intARLocationId FROM tblCFCompanyPreference

CREATE TABLE #tblCFInvoiceDiscount	
(
		 intAccountId					INT
		,intSalesPersonId				INT
		,dtmInvoiceDate					DATETIME
		,intCustomerId					INT
		,intInvoiceId					INT
		,intTransactionId				INT
		,intCustomerGroupId				INT
		,intTermID						INT
		,intBalanceDue					INT
		,intDiscountDay					INT	
		,intDayofMonthDue				INT
		,intDueNextMonth				INT
		,intSort						INT
		,intConcurrencyId				INT
		,ysnAllowEFT					BIT
		,ysnActive						BIT
		,ysnEnergyTrac					BIT
		,dblQuantity					NUMERIC(18,6)
		,dblTotalQuantity				NUMERIC(18,6)
		,dblDiscountRate				NUMERIC(18,6)
		,dblDiscount					NUMERIC(18,6)
		,dblTotalAmount					NUMERIC(18,6)
		,dblAccountTotalAmount			NUMERIC(18,6)
		,dblAccountTotalDiscount		NUMERIC(18,6)
		,dblAccountTotalLessDiscount	NUMERIC(18,6)
		,dblDiscountEP					NUMERIC(18,6)
		,dblAPR							NUMERIC(18,6)	
		,strTerm						NVARCHAR(MAX)
		,strType						NVARCHAR(MAX)
		,strTermCode					NVARCHAR(MAX)	
		,strNetwork						NVARCHAR(MAX)	
		,strCustomerName				NVARCHAR(MAX)
		,strInvoiceCycle				NVARCHAR(MAX)
		,strGroupName					NVARCHAR(MAX)
		,strInvoiceNumber				NVARCHAR(MAX)
		,strInvoiceReportNumber			NVARCHAR(MAX)
		,dtmDiscountDate				DATETIME
		,dtmDueDate						DATETIME
		,dtmTransactionDate				DATETIME
		,dtmPostedDate					DATETIME
)

INSERT INTO #tblCFInvoiceDiscount
EXEC "dbo"."uspCFInvoiceReportDiscount" @xmlParam=@xmlParam

BEGIN TRANSACTION

INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intInvoiceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[intTermId]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmShipDate]
	,[intEntitySalespersonId]
	,[intFreightTermId]
	,[intShipViaId]
	,[intPaymentMethodId]
	,[strInvoiceOriginId]
	,[strPONumber]
	,[strBOLNumber]
	,[strDeliverPickup]
	,[strComments]
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
	,[ysnPost]
	,[intInvoiceDetailId]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblLicenseAmount]
	,[intTaxGroupId]
	,[ysnRecomputeTax]
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
	,[intSiteId]
	,[strBillingBy]
	,[dblPercentFull]
	,[dblNewMeterReading]
	,[dblPreviousMeterReading]
	,[dblConversionFactor]
	,[intPerformerId]
	,[ysnLeaseBilling]
	,[ysnVirtualMeterReading]
	,[ysnClearDetailTaxes]					
	,[intTempDetailIdForTaxes]
	,[strType]
	,[ysnUpdateAvailableDiscount]
	,[strItemTermDiscountBy]
	,[dblItemTermDiscount]
)
SELECT
	 [strTransactionType]					= 'Debit Memo'
	,[strSourceTransaction]					= 'CF INV'
	,[intSourceId]							= 1											-- TEMPORARY
	,[strSourceId]							= strInvoiceReportNumber
	,[intInvoiceId]							= NULL 
	,[intEntityCustomerId]					= intCustomerId
	,[intCompanyLocationId]					= @companyLocationId						--CF Company Configuration
	,[intCurrencyId]						= NULL
	,[intTermId]							= intTermID
	,[dtmDate]								= dtmInvoiceDate								
	,[dtmDueDate]							= dtmInvoiceDate
	,[dtmShipDate]							= dtmInvoiceDate							-- TEMPORARY
	,[intEntitySalespersonId]				= intSalesPersonId										-- TEMPORARY
	,[intFreightTermId]						= NULL 
	,[intShipViaId]							= NULL 
	,[intPaymentMethodId]					= NULL
	,[strInvoiceOriginId]					= ''
	,[strPONumber]							= NULL
	,[strBOLNumber]							= ''
	,[strDeliverPickup]						= NULL
	,[strComments]							= ''
	,[intShipToLocationId]					= NULL
	,[intBillToLocationId]					= NULL
	,[ysnTemplate]							= 0
	,[ysnForgiven]							= 0
	,[ysnCalculated]						= 0
	,[ysnSplitted]							= 0
	,[intPaymentId]							= NULL
	,[intSplitId]							= NULL
	,[intLoadDistributionHeaderId]			= NULL
	,[strActualCostId]						= ''
	,[intShipmentId]						= NULL
	,[intTransactionId]						= NULL
	,[intEntityId]							= @entityId											-- TEMPORARY
	,[ysnResetDetails]						= 0
	,[ysnPost]								= NULL
	,[intInvoiceDetailId]					= NULL
	,[intItemId]							= NULL
	,[ysnInventory]							= 0
	,[strItemDescription]					= NULL
	,[intItemUOMId]							= NULL
	,[dblQtyOrdered]						= NULL
	,[dblQtyShipped]						= SUM(dblQuantity)
	,[dblDiscount]							= dblDiscountRate
	,[dblPrice]								= dblAccountTotalAmount / SUM(dblQuantity)
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= ''
	,[strFrequency]							= ''
	,[dtmMaintenanceDate]					= NULL
	,[dblMaintenanceAmount]					= NULL
	,[dblLicenseAmount]						= NULL
	,[intTaxGroupId]						= NULL
	,[ysnRecomputeTax]						= 0
	,[intSCInvoiceId]						= NULL
	,[strSCInvoiceNumber]					= ''
	,[intInventoryShipmentItemId]			= NULL
	,[strShipmentNumber]					= ''
	,[intSalesOrderDetailId]				= NULL
	,[strSalesOrderNumber]					= ''
	,[intContractHeaderId]					= NULL
	,[intContractDetailId]					= NULL
	,[intShipmentPurchaseSalesContractId]	= NULL
	,[intTicketId]							= NULL
	,[intTicketHoursWorkedId]				= NULL
	,[intSiteId]							= NULL
	,[strBillingBy]							= ''
	,[dblPercentFull]						= NULL
	,[dblNewMeterReading]					= NULL
	,[dblPreviousMeterReading]				= NULL
	,[dblConversionFactor]					= NULL
	,[intPerformerId]						= NULL
	,[ysnLeaseBilling]						= NULL
	,[ysnVirtualMeterReading]				= NULL
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= NULL
	,[strType]								= 'Card Fueling'
	,[ysnUpdateAvailableDiscount]			= NULL
	,[strItemTermDiscountBy]				= NULL
	,[dblItemTermDiscount]					= NULL
FROM #tblCFInvoiceDiscount
GROUP BY 
intCustomerId
,strInvoiceReportNumber
,dblAccountTotalAmount
,dblTotalQuantity
,dblAccountTotalDiscount
,dblDiscountRate
,intTermID
,dtmInvoiceDate
,intSalesPersonId
	

SELECT * FROM @EntriesForInvoice -------TEST

EXEC [dbo].[uspARProcessInvoices]
		@InvoiceEntries	 = @EntriesForInvoice
	,@LineItemTaxEntries = @TaxDetails
	,@UserId			= 1
	,@GroupingOption	= 11
	,@RaiseError		= 1
	,@ErrorMessage		= @ErrorMessage		OUTPUT
	,@CreatedIvoices	= @CreatedIvoices	OUTPUT
	,@UpdatedIvoices	= @UpdatedIvoices	OUTPUT


SELECT @ErrorMessage	
SELECT @CreatedIvoices
SELECT @UpdatedIvoices


IF (@ErrorMessage IS NULL)
	BEGIN
		COMMIT TRANSACTION
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

		
DROP TABLE #tblCFInvoiceDiscount

END




-----------------------------------
--			  NOTES				 --
-----------------------------------

--DECLARE @total					INT = 0
--DECLARE @counter				INT = 0
--DECLARE @customerId				INT

--Declare @ErrorMessage			NVARCHAR(250) 
--Declare @CreatedIvoices			NVARCHAR(MAX) 
--Declare @UpdatedIvoices			NVARCHAR(MAX) 


--SELECT @total = count(*) from #tblCFInvoiceDiscount
--SET @counter = 1 

--WHILE @counter <= @total 
--BEGIN
--	SELECT TOP 1 @customerId = intCustomerId FROM #tblCFInvoiceDiscount
	
	
--SET @counter = @counter + 1;
--DELETE FROM #tblCFInvoiceDiscount WHERE intCustomerId = @customerId

--SELECT 
-- intCustomerId 
--,strInvoiceReportNumber
--,dblAccountTotalAmount	AS dblTotalAmount
--,dblTotalQuantity		AS dblTotalQuantity
--,dblAccountTotalDiscount 
--,dblDiscountRate
--,'need to implement' AS intEntityId
--,intTermID
--,'need to implement' AS dtmInvoiceDate
--,'need to implement' AS intSalespersonId
--,'need to implement' AS intLocationId
--,'need to implement' AS intGLAccountId
--FROM #tblCFInvoiceDiscount
----WHERE strInvoiceReportNumber = 'CFSI-4805'
--GROUP BY 
--intCustomerId
--,strInvoiceReportNumber
--,dblAccountTotalAmount
--,dblTotalQuantity
--,dblAccountTotalDiscount
--,dblDiscountRate
--,intTermID