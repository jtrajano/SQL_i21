CREATE PROCEDURE [dbo].[uspARImportInvoiceCSV]
	 @ImportLogId	INT		
	,@UserEntityId	INT	= NULL
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal NUMERIC(18, 6)
		,@DateNow DATETIME
		,@DefaultCompanyLocation INT

SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
--For Delta
SET @DefaultCompanyLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1 AND strLocationType = 'Office' AND strLocationName LIKE 'AePEX%')

IF ISNULL(@DefaultCompanyLocation,0) = 0
	SET @DefaultCompanyLocation = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE ysnLocationActive = 1)


DECLARE @InvoicesForImport AS TABLE(intImportLogDetailId INT UNIQUE)

INSERT INTO 
	@InvoicesForImport
SELECT
	[intImportLogDetailId] 
FROM
	[tblARImportLogDetail]
WHERE
	[intImportLogId] = @ImportLogId 
	--AND LEN(LTRIM(RTRIM(ISNULL([strEventResult], '')))) <= 0
	AND ISNULL([ysnSuccess],0) = 1
	AND ISNULL(ysnImported,0) = 0
ORDER BY
	[intImportLogDetailId]
	
WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicesForImport)
BEGIN
	DECLARE @ImportLogDetailId INT
	SELECT TOP 1
		@ImportLogDetailId = [intImportLogDetailId]
	FROM
		@InvoicesForImport
	ORDER BY
		[intImportLogDetailId]
		
	DECLARE	@EntityCustomerId			INT
		,@InvoiceDate					DATETIME
		,@CompanyLocationId				INT
		,@EntityId						INT
		,@NewInvoiceId					INT				= NULL		
		,@ErrorMessage					NVARCHAR(250)	= NULL
		,@TermId						INT				= NULL
		,@EntitySalespersonId			INT				= NULL
		,@DueDate						DATETIME		= NULL		
		,@ShipDate						DATETIME		= NULL
		,@PostDate						DATETIME		= NULL
		,@TransactionType				NVARCHAR(50)	= 'Invoice'
		,@Type							NVARCHAR(200)	= 'Standard'
		,@Comment						NVARCHAR(500)	= ''
		,@InvoiceOriginId				NVARCHAR(16)	= ''
		,@PONumber						NVARCHAR(50)	= ''
		,@DistributionHeaderId			INT				= NULL
		,@PaymentMethodId				INT				= 0
		,@FreightTermId					INT				= NULL
		,@DeliverPickUp					NVARCHAR(100)	= NULL
		,@ItemId						INT				= NULL
		,@ItemUOMId						INT				= NULL
		,@ItemQtyShipped				NUMERIC(18,6)	= @ZeroDecimal
		,@ItemPrice						NUMERIC(18,6)	= @ZeroDecimal
		,@ItemDescription				NVARCHAR(500)	= NULL
		,@ItemSiteId					INT				= NULL			
		,@ItemBillingBy					NVARCHAR(200)	= NULL
		,@ItemPercentFull				NUMERIC(18,6)	= @ZeroDecimal
		,@ItemNewMeterReading			NUMERIC(18,6)	= @ZeroDecimal
		,@ItemPreviousMeterReading		NUMERIC(18,6)	= @ZeroDecimal
		,@ItemConversionFactor			NUMERIC(18,8)	= 0.00000000
		,@ItemPerformerId				INT				= NULL
		,@ItemLeaseBilling				BIT				= 0
		,@TaxMasterId					INT				= NULL
		,@ItemContractHeaderId			INT				= NULL
		,@ItemContractDetailId			INT				= NULL
		,@ItemMaintenanceType			NVARCHAR(50)	= NULL
		,@ItemFrequency					NVARCHAR(50)	= NULL
		,@ItemMaintenanceDate			DATETIME		= NULL
		,@ItemMaintenanceAmount			NUMERIC(18,6)	= @ZeroDecimal
		,@ItemLicenseAmount				NUMERIC(18,6)	= @ZeroDecimal	
		,@ItemTicketId					INT				= NULL		
		,@ItemSCInvoiceId				INT				= NULL
		,@ItemSCInvoiceNumber			NVARCHAR(50)	= NULL
		,@ItemServiceChargeAccountId	INT				= NULL
		,@ItemTaxGroupId				INT				= NULL
		
		
			
	SELECT 
		 @EntityCustomerId				= (SELECT TOP 1 [intEntityId] FROM tblEntity WHERE [strEntityNo] = D.[strCustomerNumber])
		,@InvoiceDate					= D.[dtmInvoiceDate] 					
		,@CompanyLocationId				= @DefaultCompanyLocation --(SELECT [intCompanyLocationId] FROM tblSMCompanyLocation WHERE strLocationName = D.[strDivision])
		,@EntityId						= ISNULL(@UserEntityId, H.[intEntityId])
		,@TermId						= (SELECT [intTermID] FROM tblSMTerm WHERE [strTermCode] = D.[strTermsCode])
		,@EntitySalespersonId			= (SELECT [intEntityId] FROM tblEntity WHERE [strEntityNo] = D.[strSalespersonCode])
		,@DueDate						= NULL		
		,@ShipDate						= NULL
		,@PostDate						= D.[dtmPostingDate] 
		,@TransactionType				= (CASE WHEN D.[strTransactionType] = 'IN' AND D.[dblBalance] > 0 THEN 'Invoice'
												WHEN D.[strTransactionType] = 'IN' AND D.[dblBalance] < 0 THEN 'Credit Memo'
												WHEN D.[strTransactionType] = 'PP' THEN 'Prepayment'												
											ELSE 'Overpayment'
										END)
		,@Type							= (CASE WHEN D.[strTransactionType] = 'IN' AND D.[dblBalance] < 0 THEN 'Credit Memo'
											ELSE 'Standard'
										END)
		,@Comment						= D.[strInvoiceNumber]
		,@InvoiceOriginId				= D.[strInvoiceNumber]
		,@PONumber						= D.[strPONumber] 
		,@DistributionHeaderId			= NULL
		,@PaymentMethodId				= 0
		,@FreightTermId					= NULL
		,@DeliverPickUp					= NULL
		,@ItemId						= NULL
		,@ItemUOMId						= NULL
		,@ItemQtyShipped				= 1.000000
		,@ItemPrice						= ABS((CASE WHEN D.[dblSalesTaxAmount] <> 0 THEN D.[dblTaxableAmount] ELSE D.[dblNonTaxableAmount] END))
		,@ItemDescription				= D.[strComment] 
		,@ItemSiteId					= NULL			
		,@ItemBillingBy					= NULL
		,@ItemPercentFull				= @ZeroDecimal
		,@ItemNewMeterReading			= @ZeroDecimal
		,@ItemPreviousMeterReading		= @ZeroDecimal
		,@ItemConversionFactor			= 0.00000000
		,@ItemPerformerId				= NULL
		,@ItemLeaseBilling				= 0
		,@TaxMasterId					= NULL
		,@ItemContractHeaderId			= NULL
		,@ItemContractDetailId			= NULL
		,@ItemMaintenanceType			= NULL
		,@ItemFrequency					= NULL
		,@ItemMaintenanceDate			= NULL
		,@ItemMaintenanceAmount			= @ZeroDecimal
		,@ItemLicenseAmount				= @ZeroDecimal	
		,@ItemTicketId					= NULL		
		,@ItemSCInvoiceId				= NULL
		,@ItemSCInvoiceNumber			= NULL
		,@ItemServiceChargeAccountId	= NULL
		,@ItemTaxGroupId				= (CASE WHEN D.[dblSalesTaxAmount] <> 0 AND D.[dblBalance] > 0
											THEN (SELECT TOP 1 [intTaxGroupId] FROM tblSMTaxGroup WHERE UPPER(LTRIM(RTRIM(ISNULL(strTaxGroup,'')))) = UPPER(LTRIM(RTRIM(ISNULL(D.[strTaxSchedule],''))))) 
											ELSE NULL 
										END)
	FROM
		[tblARImportLogDetail] D
	INNER JOIN
		[tblARImportLog] H
			ON D.[intImportLogId] = H.[intImportLogId] 
	WHERE
		[intImportLogDetailId] = @ImportLogDetailId
		
	SELECT @ErrorMessage = 'Invoice:' + RTRIM(LTRIM(ISNULL(@InvoiceOriginId,''))) + ' was already imported! (' + strInvoiceNumber + ')' FROM [tblARInvoice] WHERE RTRIM(LTRIM(ISNULL([strInvoiceOriginId],''))) = RTRIM(LTRIM(ISNULL(@InvoiceOriginId,''))) AND LEN(RTRIM(LTRIM(ISNULL([strInvoiceOriginId],'')))) > 0

	IF ISNULL(@EntityCustomerId, 0) = 0
		SET @ErrorMessage = 'Customer Number does not exists!'

	IF ISNULL(@TermId, 0) = 0 AND LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1 AND @TransactionType IN ('Invoice', 'Credit Memo')
		SET @ErrorMessage = 'Term is required! The Term Code provided does not exists.'

	IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) < 1		
		BEGIN TRY		
			EXEC [dbo].[uspARCreateCustomerInvoice]
				 @EntityCustomerId				= @EntityCustomerId
				,@InvoiceDate					= @InvoiceDate
				,@CompanyLocationId				= @CompanyLocationId
				,@EntityId						= @EntityId
				,@NewInvoiceId					= @NewInvoiceId OUTPUT
				,@ErrorMessage					= @ErrorMessage OUTPUT
				,@TermId						= @TermId
				,@EntitySalespersonId			= @EntitySalespersonId
				,@DueDate						= @DueDate
				,@ShipDate						= @ShipDate
				,@PostDate						= @PostDate
				,@TransactionType				= @TransactionType
				,@Type							= @Type
				,@Comment						= @Comment
				,@InvoiceOriginId				= @InvoiceOriginId
				,@PONumber						= @PONumber
				,@DistributionHeaderId			= @DistributionHeaderId
				,@PaymentMethodId				= @PaymentMethodId
				,@FreightTermId					= @FreightTermId
				,@DeliverPickUp					= @DeliverPickUp
				,@ItemId						= @ItemId
				,@ItemUOMId						= @ItemUOMId
				,@ItemQtyShipped				= @ItemQtyShipped
				,@ItemPrice						= @ItemPrice
				,@ItemDescription				= @ItemDescription
				,@ItemSiteId					= @ItemSiteId
				,@ItemBillingBy					= @ItemBillingBy
				,@ItemPercentFull				= @ItemPercentFull
				,@ItemNewMeterReading			= @ItemNewMeterReading
				,@ItemPreviousMeterReading		= @ItemPreviousMeterReading
				,@ItemConversionFactor			= @ItemConversionFactor
				,@ItemPerformerId				= @ItemPerformerId
				,@ItemLeaseBilling				= @ItemLeaseBilling
				,@TaxMasterId					= @TaxMasterId
				,@ItemContractHeaderId			= @ItemContractHeaderId
				,@ItemContractDetailId			= @ItemContractDetailId
				,@ItemMaintenanceType			= @ItemMaintenanceType
				,@ItemFrequency					= @ItemFrequency
				,@ItemMaintenanceDate			= @ItemMaintenanceDate
				,@ItemMaintenanceAmount			= @ItemMaintenanceAmount
				,@ItemLicenseAmount				= @ItemLicenseAmount
				,@ItemTicketId					= @ItemTicketId
				,@ItemSCInvoiceId				= @ItemSCInvoiceId
				,@ItemSCInvoiceNumber			= @ItemSCInvoiceNumber
				,@ItemServiceChargeAccountId	= @ItemServiceChargeAccountId
				,@ItemTaxGroupId				= @ItemTaxGroupId			
				
		END TRY
		BEGIN CATCH
			SET @ErrorMessage = ERROR_MESSAGE();
		END CATCH
	
	IF LEN(RTRIM(LTRIM(ISNULL(@ErrorMessage,'')))) > 0
		BEGIN
			UPDATE
				tblARImportLogDetail
			SET
				 [ysnImported]		= 0
				,[ysnSuccess]       = 0
				,[strEventResult]	= @ErrorMessage
			WHERE
				[intImportLogDetailId] = @ImportLogDetailId

			UPDATE 
				tblARImportLog 
			SET intSuccessCount = intSuccessCount - 1
			  , intFailedCount = intFailedCount + 1
			WHERE intImportLogId = @ImportLogId
		END
	ELSE IF(ISNULL(@NewInvoiceId,0) <> 0)
		BEGIN
			UPDATE
				tblARImportLogDetail
			SET
				 [ysnImported]		= 1
				,[strEventResult]	= (SELECT strTransactionType + ':' + strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @NewInvoiceId) + ' Imported.'
			WHERE
				[intImportLogDetailId] = @ImportLogDetailId
		END
		
	DELETE FROM @InvoicesForImport WHERE [intImportLogDetailId] = @ImportLogDetailId

END
	
	
END