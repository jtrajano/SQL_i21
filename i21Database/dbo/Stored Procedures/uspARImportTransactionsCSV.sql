CREATE PROCEDURE [dbo].[uspARImportTransactionsCSV]
	 @ImportLogId			INT
	,@ImportFormat			NVARCHAR(50)
	,@ImportItemId			INT = NULL
	,@ImportLocationId		INT = NULL
	,@ConversionAccountId	INT = NULL
	,@IsTank				BIT = 0
	,@IsFromOldVersion		BIT = 0	
	,@UserEntityId			INT	= NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal		NUMERIC(18, 6)
	  , @DateNow			DATETIME
	  , @DefaultCurrencyId	INT
	  , @DefaultAccountId	INT
	  , @CreatedIvoices		NVARCHAR(MAX)
	  , @BOLNumber			NVARCHAR(50)
	  , @intInvoiceLogId	INT = NULL
	  , @FailedCount        INT

DECLARE @InvoicesForImport AS 
TABLE(intImportLogDetailId INT UNIQUE,strTransactionType NVARCHAR(50),ysnImported BIT,ysnSuccess BIT,ysnRecap BIT)

DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable

DECLARE @IMPORTFORMAT_STANDARD NVARCHAR(50) = 'Standard'
      , @IMPORTFORMAT_CARQUEST NVARCHAR(50) = 'CarQuest'

SET @ZeroDecimal = 0.000000
SET @DateNow = CAST(GETDATE() AS DATE)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultAccountId = (SELECT TOP 1 intARAccountId FROM tblARCompanyPreference)

DECLARE	@EntityCustomerId			INT
,@Date							DATETIME
,@CompanyLocationId				INT
,@LocationSalesAccountId		INT
,@LocationName					NVARCHAR(500)	= ''
,@EntityId						INT
,@NewTransactionId				INT				= NULL		
,@ErrorMessage					NVARCHAR(250)	= NULL
,@TermId						INT				= NULL
,@EntitySalespersonId			INT				= NULL
,@EntityContactId				INT				= NULL
,@DueDate						DATETIME		= NULL		
,@ShipDate						DATETIME		= NULL
,@CalculatedDate				DATETIME		= NULL
,@PostDate						DATETIME		= NULL
,@TransactionType				NVARCHAR(50)	= 'Invoice'
,@Type							NVARCHAR(200)	= 'Standard'
,@Comment						NVARCHAR(500)	= ''
,@OriginId						NVARCHAR(16)	= ''
,@PONumber						NVARCHAR(50)	= ''		
,@FreightTermId					INT				= NULL
,@ShipViaId						INT				= NULL		
,@DiscountAmount				NUMERIC(18,6)   = @ZeroDecimal
,@DiscountPercentage			NUMERIC(18,6)	= @ZeroDecimal
,@ItemQtyShipped				NUMERIC(18,6)	= @ZeroDecimal
,@ItemPrice						NUMERIC(18,6)	= @ZeroDecimal
,@ItemId						INT				= NULL
,@ItemDescription				NVARCHAR(500)	= NULL
,@TaxGroupId					INT				= NULL
,@TaxClassId					INT				= NULL
,@AmountDue						NUMERIC(18,6)	= @ZeroDecimal
,@TaxAmount						NUMERIC(18,6)	= @ZeroDecimal
,@Total							NUMERIC(18,6)	= @ZeroDecimal
,@SiteId						INT				= NULL
,@PerformerId					INT				= NULL
,@PercentFull					NUMERIC(18,6)   = @ZeroDecimal
,@NewMeterReading				NUMERIC(18,6)   = @ZeroDecimal
,@PreviousMeterReading			NUMERIC(18,6)   = @ZeroDecimal
,@ConversionFactor				NUMERIC(18,6)   = @ZeroDecimal	
,@BillingBy						NVARCHAR(50)	= NULL
,@COGSAmount					NUMERIC(18,6)   = @ZeroDecimal
,@CustomerNumber				NVARCHAR(100)	= ''
,@ItemCategory					NVARCHAR(100)	= NULL
,@intItemLocationId				INT				= NULL
,@ysnAllowNegativeStock			BIT				= 0
,@intStockUnit					INT				= NULL
,@intCostingMethod				INT				= NULL
,@ysnOrigin						BIT				= 0
,@ysnRecap						BIT			 	= 0
,@ysnImpactInventory			BIT			 	= 1

BEGIN TRY
--VALIDATE
IF EXISTS (SELECT top 1 1 FROM tblARInvoice I 
			INNER JOIN tblARImportLogDetail ILD  ON I.strInvoiceOriginId = ILD.strTransactionNumber  
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			WHERE  IL.intImportLogId = @ImportLogId AND LEN(RTRIM(LTRIM(ISNULL(strInvoiceOriginId,'')))) > 0)
BEGIN 	
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'Invoice:' + RTRIM(LTRIM(ISNULL(INV.strInvoiceOriginId,''))) + ' was already imported! (' + strInvoiceNumber + '). '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARInvoice INV  ON INV.strInvoiceOriginId = ILD.strTransactionNumber  
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId AND LEN(RTRIM(LTRIM(ISNULL(strInvoiceOriginId,'')))) > 0 

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARInvoice INV  ON INV.strInvoiceOriginId = ILD.strTransactionNumber  
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND LEN(RTRIM(LTRIM(ISNULL(strInvoiceOriginId,'')))) > 0 ) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT top 1 1 FROM tblSOSalesOrder SO
			INNER JOIN tblARImportLogDetail ILD  ON SO.strSalesOrderOriginId = ILD.strTransactionNumber  AND LEN(RTRIM(LTRIM(ISNULL(SO.strSalesOrderOriginId,'')))) > 0
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			WHERE  IL.intImportLogId = @ImportLogId)
BEGIN 	
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'Sales Order:' + RTRIM(LTRIM(ISNULL(SO.strSalesOrderOriginId,''))) + ' was already imported! (' + SO.strSalesOrderNumber + '). '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblSOSalesOrder SO  ON SO.strSalesOrderOriginId = ILD.strTransactionNumber  AND LEN(RTRIM(LTRIM(ISNULL(SO.strSalesOrderOriginId,'')))) > 0 
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblSOSalesOrder SO  ON SO.strSalesOrderOriginId = ILD.strTransactionNumber  AND LEN(RTRIM(LTRIM(ISNULL(SO.strSalesOrderOriginId,'')))) > 0 
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
WHERE strTransactionType NOT IN ('Invoice', 'Sales Order', 'Credit Memo', 'Tank Delivery', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment') AND IL.intImportLogId = @ImportLogId)
BEGIN 

	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Transaction Type provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId AND strTransactionType NOT IN ('Invoice', 'Sales Order', 'Credit Memo', 'Tank Delivery', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment')

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0  AND strTransactionType NOT IN ('Invoice', 'Sales Order', 'Credit Memo', 'Tank Delivery', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment')) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId

END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) = 0 AND ILD.strCustomerNumber <> '')
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Customer Number provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber 
	WHERE  IL.intImportLogId = @ImportLogId  AND ISNULL(C.intEntityId, 0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber 
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND ISNULL(C.intEntityId, 0) = 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END


IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(L.intCompanyLocationId, 0) = 0)
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Location Name provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName 
	WHERE  IL.intImportLogId = @ImportLogId  AND ISNULL(L.intCompanyLocationId, 0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND ISNULL(L.intCompanyLocationId, 0) = 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId

END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(L.intSalesAccount, 0) = 0 AND ISNULL(L.intCompanyLocationId, 0) > 0)
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= CASE WHEN intSalesAccount IS NULL THEN 'The Sales account of Company Location ' + L.strLocationName + ' is not valid. ' ELSE 'The Sales account of Company Location ' + L.strLocationName + ' was not set. ' END
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName 
	WHERE  IL.intImportLogId = @ImportLogId  AND ISNULL(L.intSalesAccount, 0) = 0 AND ISNULL(L.intCompanyLocationId, 0) > 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = ILD.strLocationName
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND ISNULL(L.intSalesAccount, 0) = 0 AND ISNULL(L.intCompanyLocationId, 0) > 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF  EXISTS (SELECT * FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblSMTerm T ON T.strTerm = ILD.strTerms 
WHERE  IL.intImportLogId = @ImportLogId  AND T.intTermID IS NULL AND ILD.strTerms <> '')
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Term Code provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	INNER JOIN tblSMTerm T ON T.strTerm = ILD.strTerms  
	WHERE  IL.intImportLogId = @ImportLogId AND T.intTermID IS NULL

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	INNER JOIN tblSMTerm T ON T.strTerm = ILD.strTerms 
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND T.intTermID IS NULL)
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND ISNULL(C.intTermsId, 0) = 0 AND @IsTank = 0)
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The customer provided doesn''t have default terms. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber 
	WHERE  IL.intImportLogId = @ImportLogId  AND ISNULL(C.intEntityId, 0) > 0 AND ISNULL(C.intTermsId, 0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber 
	WHERE  IL.intImportLogId = @ImportLogId AND ysnSuccess =0 AND ISNULL(C.intEntityId, 0) > 0 AND ISNULL(C.intTermsId, 0) = 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblSMFreightTerms F ON ILD.strFreightTerm = F.strFreightTerm
LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND EL.ysnDefaultLocation=1 and ISNULL(F.intFreightTermId, 0) = 0 AND ILD.strFreightTerm <> '')
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Freight Term provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMFreightTerms F ON ILD.strFreightTerm = F.strFreightTerm
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND EL.ysnDefaultLocation=1 and ISNULL(F.intFreightTermId, 0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMFreightTerms F ON ILD.strFreightTerm = F.strFreightTerm
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND EL.ysnDefaultLocation=1 and ISNULL(F.intFreightTermId, 0) = 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0  AND ysnDefaultLocation = 1 AND ISNULL(EL.intShipViaId,0) = 0)
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Ship Via provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0  AND ysnDefaultLocation = 1 AND ISNULL(EL.intShipViaId,0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblEMEntityLocation EL  ON EL.intEntityId = C.intEntityId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0  AND ysnDefaultLocation = 1 AND ISNULL(EL.intShipViaId,0) = 0) 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
LEFT JOIN tblARSalesperson S on ILD.strSalespersonNumber=S.strSalespersonId
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND ISNULL(intSalespersonId, 0) = 0 AND ILD.strSalespersonNumber <> '')
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= 'The Salesperson provided does not exists. '
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblARSalesperson S on ILD.strSalespersonNumber=S.strSalespersonId
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND ISNULL(intSalespersonId, 0) = 0 AND ILD.strSalespersonNumber <> ''

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblARCustomer C ON C.strCustomerNumber=ILD.strCustomerNumber
	LEFT JOIN tblARSalesperson S on ILD.strSalespersonNumber=S.strSalespersonId
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(C.intEntityId, 0) > 0 AND @IsTank = 0 AND ISNULL(intSalespersonId, 0) = 0 AND ILD.strSalespersonNumber <> '') 
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0)
BEGIN 
	UPDATE ILD
	SET [ysnImported]		= 0
	   ,[ysnSuccess]        = 0
	   ,[strEventResult]	= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST
									THEN 'Category ' + ISNULL(ICC.strCategoryCode, '') + ' - ' + ISNULL(ICC.strDescription, '') + ' doesn''t have default tax class set up.'
									ELSE 'The Tax Group provided does not exists. '
								END		
	FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0

	SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICCategory ICC ON ICI.intCategoryId = ICC.intCategoryId
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0)
	
	UPDATE tblARImportLog 
	SET [intSuccessCount]	= intSuccessCount - @FailedCount
	  , [intFailedCount]	= intFailedCount + @FailedCount
	WHERE [intImportLogId]  = @ImportLogId
END

IF @ImportFormat = @IMPORTFORMAT_CARQUEST
BEGIN 
	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '')
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item is required.'	
			FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '')
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0 AND NOT EXISTS (SELECT NULL FROM tblSMTaxGroupCode WHERE intTaxGroupId = TAX.intTaxGroupId))
	BEGIN 
		UPDATE ILD
		SET [ysnImported]		= 0
		   ,[ysnSuccess]        = 0
		   ,[strEventResult]	= 'Tax Group must have atleast (1) one Tax Code setup.'	
		FROM tblARImportLogDetail ILD
		INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
		LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
		WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0 AND NOT EXISTS (SELECT NULL FROM tblSMTaxGroupCode WHERE intTaxGroupId = TAX.intTaxGroupId)

		SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
		INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
		LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = ILD.strTaxGroup
		WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ILD.strTaxGroup, '') <> '' AND ISNULL(TAX.intTaxGroupId,0) = 0 AND NOT EXISTS (SELECT NULL FROM tblSMTaxGroupCode WHERE intTaxGroupId = TAX.intTaxGroupId))
	
		UPDATE tblARImportLog 
		SET [intSuccessCount]	= intSuccessCount - @FailedCount
		  , [intFailedCount]	= intFailedCount + @FailedCount
		WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	CROSS APPLY (SELECT TOP 1 intCategoryId, intTaxClassId FROM tblICCategoryTax  WHERE intCategoryId = ICI.intCategoryId ) CATEGORYTAX
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(CATEGORYTAX.intTaxClassId, 0) = 0)
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item Category doesn''t have default tax class set up.'	
			FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			CROSS APPLY (SELECT TOP 1 intCategoryId, intTaxClassId FROM tblICCategoryTax  WHERE intCategoryId = ICI.intCategoryId ) CATEGORYTAX
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(CATEGORYTAX.intTaxClassId, 0) = 0

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			CROSS APPLY (SELECT TOP 1 intCategoryId, intTaxClassId FROM tblICCategoryTax  WHERE intCategoryId = ICI.intCategoryId ) CATEGORYTAX
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(CATEGORYTAX.intTaxClassId, 0) = 0)
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(ICIL.intItemLocationId, 0) = 0)
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item Location for the selected item is required.'	
			FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(ICIL.intItemLocationId, 0) = 0

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND ISNULL(ICIL.intItemLocationId, 0) = 0)
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intAllowNegativeInventory, 0) = 0)
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item should allow negative stock.'	
			FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intAllowNegativeInventory, 0) = 0

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intAllowNegativeInventory, 0) = 0)
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICItemUOM ICUOM ON ICUOM.intItemId = ICI.intItemId AND ICUOM.ysnStockUnit = 1
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND  ISNULL(ICUOM.intItemUOMId,0) =0)
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item''s stock unit should not be null.'	
			FROM tblARImportLogDetail ILD
				INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemUOM ICUOM ON ICUOM.intItemId = ICI.intItemId AND ICUOM.ysnStockUnit = 1
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND  ISNULL(ICUOM.intItemUOMId,0) =0

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemUOM ICUOM ON ICUOM.intItemId = ICI.intItemId AND ICUOM.ysnStockUnit = 1
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> '' AND  ISNULL(ICUOM.intItemUOMId,0) =0)
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

	IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
	INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
	LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
	LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
	WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intCostingMethod,0) = 0)
	BEGIN 
		UPDATE ILD
			SET [ysnImported]		= 0
			   ,[ysnSuccess]        = 0
			   ,[strEventResult]	= 'Item''s location costing method should be either FIFO or LIFO.'	
			FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intCostingMethod,0) = 0

			SET @FailedCount = (SELECT COUNT(ysnSuccess) FROM tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			LEFT JOIN tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
			LEFT JOIN tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
			WHERE  IL.intImportLogId = @ImportLogId AND ISNULL(ICI.intItemId,0) = 0 AND ISNULL(@ImportItemId,'') <> ''AND ISNULL(ICIL.intItemLocationId, 0) <> 0 AND  ISNULL(ICIL.intCostingMethod,0) = 0)
	
			UPDATE tblARImportLog 
			SET [intSuccessCount]	= intSuccessCount - @FailedCount
			  , [intFailedCount]	= intFailedCount + @FailedCount
			WHERE [intImportLogId]  = @ImportLogId
	END

END

INSERT INTO @InvoicesForImport
SELECT ILD.intImportLogDetailId,ILD.strTransactionType,ysnImported,ILD.ysnSuccess,IL.ysnRecap FROM tblARImportLogDetail ILD
INNER JOIN tblARImportLog  IL ON ILD.intImportLogId=IL.intImportLogId
WHERE ILD.intImportLogId = @ImportLogId
	AND ISNULL(ysnSuccess,0) = 1
	AND ISNULL(ysnImported,0) = 0
ORDER BY intImportLogDetailId

IF EXISTS  (SELECT TOP 1 NULL FROM @InvoicesForImport  where strTransactionType <> 'Sales Order' AND ISNULL(ysnImported, 0) = 0 AND ISNULL(ysnSuccess, 0) = 1 AND ISNULL(ysnRecap, 0) = 0)
BEGIN 
	INSERT INTO @EntriesForInvoice(
				[intId]
			, [strSourceTransaction]
			,[strTransactionType]
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
			,[dtmCalculated]
			,[dtmPostDate]
			,[intEntitySalespersonId]
			,[intFreightTermId]
			,[intShipViaId]
			,[intPaymentMethodId]
			,[strInvoiceOriginId]
			,[strPONumber]
			,[strBOLNumber]
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
			,[intLoadId]
			,[strActualCostId]
			,[intShipmentId]
			,[intTransactionId]
			,[intEntityId]
			,[ysnResetDetails]
			,[ysnPost]
			,[ysnImportedFromOrigin]
			,[ysnImportedAsPosted]
			,[intInvoiceDetailId]
			,[intItemId]
			,[ysnInventory]
			,[strItemDescription]
			,[intOrderUOMId]
			,[dblQtyOrdered]
			,[intItemUOMId]
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
			,[strImportFormat]
			,[dblCOGSAmount]
			,[intTempDetailIdForTaxes]
			,[intConversionAccountId]
			,[intCurrencyExchangeRateTypeId]
			,[intCurrencyExchangeRateId]
			,[dblCurrencyExchangeRate]
			,[intSubCurrencyId]
			,[dblSubCurrencyRate]
			,[ysnUseOriginIdAsInvoiceNumber]
			,[ysnImpactInventory]
			)
			SELECT 
			D.intImportLogDetailId
			, [strSourceTransaction]		= 'Import'
			,[strTransactionType]		= 'Invoice'
			,[intSourceId]				= D.intImportLogDetailId
			,[strSourceId]				= CAST(D.intImportLogDetailId AS NVARCHAR(250))
			,[intInvoiceId]				= NULL
			,[intEntityCustomerId]		= C.intEntityId
			,[intCompanyLocationId]		= L.intCompanyLocationId
			,[intCurrencyId]			= @DefaultCurrencyId
			,[intTermId]				= S.intDeliveryTermID
			,[dtmDate]					= D.dtmDate
			,[dtmDueDate]				= CAST(dbo.fnGetDueDateBasedOnTerm(D.dtmDate, S.intDeliveryTermID) AS DATE)
			,[dtmShipDate]				= D.dtmDate
			,[dtmCalculated]			= NULL
			,[dtmPostDate]				= NULL
			,[intEntitySalespersonId]	= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' AND @IsFromOldVersion = 1 THEN SP.intEntityId END
			,[intFreightTermId]			= NULL
			,[intShipViaId]				= NULL
			,[intPaymentMethodId]		= NULL
			,[strInvoiceOriginId]		= D.strTransactionNumber
			,[strPONumber]				= NULL
			,[strBOLNumber]				= D.strBOLNumber
			,[strComments]				= D.strTransactionNumber
			,[intShipToLocationId]		= NULL
			,[intBillToLocationId]		= NULL
			,[ysnTemplate]				= 0
			,[ysnForgiven]				= 0
			,[ysnCalculated]			= CASE WHEN D.dtmCalculated IS NULL THEN 0 ELSE 1 END
			,[ysnSplitted]				= 0
			,[intPaymentId]				= NULL
			,[intSplitId]				= NULL
			,[intLoadDistributionHeaderId]	= NULL
			,[intLoadId]				= NULL
			,[strActualCostId]			= NULL
			,[intShipmentId]			= NULL
			,[intTransactionId]			= NULL
			,[intEntityId]				= H.intEntityId
			,[ysnResetDetails]			= 1
			,[ysnPost]					= CASE WHEN isnull(D.ysnOrigin, 0) = 1 
											THEN NULL
											ELSE  
												CASE WHEN @TransactionType IN ('Customer Prepayment', 'Overpayment') THEN 0
												ELSE CASE WHEN D.dtmPostDate IS NULL THEN 0 
													 ELSE 1 
											    END
											END
										  END 
			,[ysnImportedFromOrigin]	= CASE WHEN D.ysnOrigin = 1 THEN 1 ELSE 0 END
			,[ysnImportedAsPosted]		= CASE WHEN D.ysnOrigin = 1 THEN 1 ELSE 0 END
			,[intInvoiceDetailId]		= NULL
			,[intItemId]				= CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST THEN TMS.intProduct ELSE NULL END
			,[ysnInventory]				= CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST AND ISNULL(TMS.intProduct, 0) > 0 THEN 
											CASE WHEN TMS.strType = 'Inventory' THEN 1 ELSE 0 END
										  ELSE 0 END
			,[strItemDescription]		= TMS.strDescription
			,[intOrderUOMId]			= NULL
			,[dblQtyOrdered]			= ISNULL(D.dblQuantity, @ZeroDecimal)
			,[intItemUOMId]				= NULL
			,[dblQtyShipped]			= ISNULL(D.dblQuantity, @ZeroDecimal)
			,[dblDiscount]				= (CASE WHEN ISNULL(D.dblDiscount, @ZeroDecimal) > 0 
															THEN (1 - ((ABS(D.dblTotal) - ISNULL(D.dblDiscount, @ZeroDecimal)) / ABS(D.dblTotal))) * 100
															ELSE @ZeroDecimal
													   END)
			,[dblPrice]					= ISNULL(D.dblSubtotal, @ZeroDecimal)	
			,[ysnRefreshPrice]			= 0
			,[strMaintenanceType]		= NULL
			,[strFrequency]				= NULL
			,[dtmMaintenanceDate]		= NULL
			,[dblMaintenanceAmount]		= NULL
			,[dblLicenseAmount]			= NULL
			,[intTaxGroupId]			= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN TAX.intTaxGroupId ELSE 0 END
			,[ysnRecomputeTax]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST 
											   THEN 0 
											   ELSE CASE WHEN ISNULL(TAX.intTaxGroupId, 0) > 0 THEN 1 ELSE 0 END
										  END
			,[intSCInvoiceId]			= NULL
			,[strSCInvoiceNumber]		= NULL
			,[intInventoryShipmentItemId] = NULL
			,[strShipmentNumber]		= NULL
			,[intSalesOrderDetailId]	= NULL
			,[strSalesOrderNumber]		= NULL
			,[intContractHeaderId]		= NULL
			,[intContractDetailId]		= NULL
			,[intShipmentPurchaseSalesContractId]	= NULL
			,[intTicketId]				= NULL
			,[intTicketHoursWorkedId]	= NULL
			,[intSiteId]				= S.intSiteID
			,[strBillingBy]				= TMS.strBillingBy
			,[dblPercentFull]			= ISNULL(D.dblPercentFull, @ZeroDecimal)
			,[dblNewMeterReading]		= ISNULL(D.dblNewMeterReading, @ZeroDecimal)
			,[dblPreviousMeterReading]	= TMS.dblLastMeterReading
			,[dblConversionFactor]		= TMS.dblConversionFactor
			,[intPerformerId]			= NULL
			,[ysnLeaseBilling]			= NULL
			,[ysnVirtualMeterReading]	= CASE WHEN TMS.strBillingBy = 'Virtual Meter' THEN 1 ELSE 0 END
			,[strImportFormat]			= @ImportFormat
			,[dblCOGSAmount]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END
			,[intTempDetailIdForTaxes]  = D.intImportLogDetailId
			,[intConversionAccountId]	= NULL
			,[intCurrencyExchangeRateTypeId]	= NULL
			,[intCurrencyExchangeRateId]		= NULL
			,[dblCurrencyExchangeRate]	= 1.000000
			,[intSubCurrencyId]			= NULL
			,[dblSubCurrencyRate]		= 1.000000
			,[ysnUseOriginIdAsInvoiceNumber] = CASE WHEN ISNULL(D.strTransactionNumber, '') <> '' AND  D.strCustomerNumber <> '9998' THEN 1 ELSE 0 END
			,[ysnImpactInventory]		= 1
			 FROM
			[tblARImportLogDetail] D
			INNER JOIN [tblARImportLog] H ON D.[intImportLogId] = H.[intImportLogId] 
			LEFT JOIN tblARCustomer C ON C.strCustomerNumber=D.strCustomerNumber
			LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = D.strLocationName
			LEFT JOIN tblTMSite S ON S.intSiteNumber=D.strSiteNumber
			LEFT JOIN tblARSalesperson SP ON CONVERT(INT, D.strSalespersonNumber) = SP.intEntityId
			LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = D.strTaxGroup
			LEFT JOIN (
				SELECT TOP 1 		 TMS.strBillingBy
									, TMS.intProduct 
									, I.strDescription
									, CCS.dblLastMeterReading
									, CCS.dblConversionFactor
									, TMS.intSiteID
									, I.strType
						FROM tblTMSite TMS 
							INNER JOIN vyuARCustomerConsumptionSite CCS ON TMS.intSiteID = CCS.intSiteID
							LEFT JOIN tblICItem I ON TMS.intProduct = I.intItemId
			) TMS ON TMS.intSiteID = S.intSiteID

			WHERE @IsTank = 1 AND H.intImportLogId=@ImportLogId AND ISNULL(ysnImported, 0) = 0 AND ISNULL(ysnSuccess, 0) = 1
	
			UNION ALL
			SELECT 
						ILD.intImportLogDetailId
				 ,[strSourceTransaction]		= 'Import'
				,[strTransactionType]		= 'Invoice'
				,[intSourceId]				= ILD.intImportLogDetailId
				,[strSourceId]				= CAST(ILD.intImportLogDetailId AS NVARCHAR(250))
				,[intInvoiceId]				= NULL
				,[intEntityCustomerId]		= C.intEntityId
				,[intCompanyLocationId]		= CL.intCompanyLocationId
				,[intCurrencyId]			= @DefaultCurrencyId
				,[intTermId]				= C.intTermsId
				,[dtmDate]					= ILD.dtmDate
				,[dtmDueDate]				= CAST(dbo.fnGetDueDateBasedOnTerm(ILD.dtmDate, C.intTermsId) AS DATE)
				,[dtmShipDate]				= ILD.dtmDate
				,[dtmCalculated]			= NULL
				,[dtmPostDate]				= NULL
				,[intEntitySalespersonId]	= CASE WHEN ISNULL(ILD.strSalespersonNumber, '') <> '' AND @IsFromOldVersion = 1 THEN SP.intEntityId END
				,[intFreightTermId]			= NULL
				,[intShipViaId]				= NULL
				,[intPaymentMethodId]		= NULL
				,[strInvoiceOriginId]		= ILD.strTransactionNumber
				,[strPONumber]				= NULL
				,[strBOLNumber]				= ILD.strBOLNumber
				,[strComments]				= ILD.strTransactionNumber
				,[intShipToLocationId]		= NULL
				,[intBillToLocationId]		= NULL
				,[ysnTemplate]				= 0
				,[ysnForgiven]				= 0
				,[ysnCalculated]			= CASE WHEN ILD.dtmCalculated IS NULL THEN 0 ELSE 1 END
				,[ysnSplitted]				= 0
				,[intPaymentId]				= NULL
				,[intSplitId]				= NULL
				,[intLoadDistributionHeaderId]	= NULL
				,[intLoadId]				= NULL
				,[strActualCostId]			= NULL
				,[intShipmentId]			= NULL
				,[intTransactionId]			= NULL
				,[intEntityId]				= H.intEntityId
				,[ysnResetDetails]			= 1
				,[ysnPost]					= CASE WHEN isnull(ILD.ysnOrigin, 0) = 1 
												THEN NULL
												ELSE  
													CASE WHEN @TransactionType IN ('Customer Prepayment', 'Overpayment') THEN 0
													ELSE CASE WHEN ILD.dtmPostDate IS NULL THEN 0 
														 ELSE 1 
													END
												END
											  END 
				,[ysnImportedFromOrigin]	= CASE WHEN ILD.ysnOrigin = 1 THEN 1 ELSE 0 END
				,[ysnImportedAsPosted]		= CASE WHEN ILD.ysnOrigin = 1 THEN 1 ELSE 0 END
				,[intInvoiceDetailId]		= NULL
				,[intItemId]				= ICI.intItemId
				,[ysnInventory]				= 0
				,[strItemDescription]		= ICI.strDescription
				,[intOrderUOMId]			= NULL
				,[dblQtyOrdered]			= 1
				,[intItemUOMId]				= NULL
				,[dblQtyShipped]			= 1
				,[dblDiscount]				= ISNULL(ABS(ILD.dblDiscount), @ZeroDecimal)
				,[dblPrice]					= ABS(ISNULL(ILD.dblSubtotal, @ZeroDecimal))	
				,[ysnRefreshPrice]			= 0
				,[strMaintenanceType]		= NULL
				,[strFrequency]				= NULL
				,[dtmMaintenanceDate]		= NULL
				,[dblMaintenanceAmount]		= NULL
				,[dblLicenseAmount]			= NULL
				,[intTaxGroupId]			= TGC.intTaxGroupId
				,[ysnRecomputeTax]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST 
												   THEN 0 
												   ELSE CASE WHEN ISNULL(TGC.intTaxGroupId, 0) > 0 THEN 1 ELSE 0 END
											  END
				,[intSCInvoiceId]			= NULL
				,[strSCInvoiceNumber]		= NULL
				,[intInventoryShipmentItemId] = NULL
				,[strShipmentNumber]		= NULL
				,[intSalesOrderDetailId]	= NULL
				,[strSalesOrderNumber]		= NULL
				,[intContractHeaderId]		= NULL
				,[intContractDetailId]		= NULL
				,[intShipmentPurchaseSalesContractId]	= NULL
				,[intTicketId]				= NULL
				,[intTicketHoursWorkedId]	= NULL
				,[intSiteId]				= NULL
				,[strBillingBy]				= NULL
				,[dblPercentFull]			= ISNULL(ILD.dblPercentFull, @ZeroDecimal)
				,[dblNewMeterReading]		= ISNULL(ILD.dblNewMeterReading, @ZeroDecimal)
				,[dblPreviousMeterReading]	= NULL
				,[dblConversionFactor]		= NULL
				,[intPerformerId]			= NULL
				,[ysnLeaseBilling]			= NULL
				,[ysnVirtualMeterReading]	= 0
				,[strImportFormat]			= @ImportFormat
				,[dblCOGSAmount]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END
				,[intTempDetailIdForTaxes]  = ILD.intImportLogDetailId
				,[intConversionAccountId]	= NULL
				,[intCurrencyExchangeRateTypeId]	= NULL
				,[intCurrencyExchangeRateId]		= NULL
				,[dblCurrencyExchangeRate]	= 1.000000
				,[intSubCurrencyId]			= NULL
				,[dblSubCurrencyRate]		= 1.000000
				,[ysnUseOriginIdAsInvoiceNumber] = CASE WHEN ISNULL(ILD.strTransactionNumber, '') <> '' AND  ILD.strCustomerNumber <> '9998' THEN 1 ELSE 0 END
				,[ysnImpactInventory]		= 1
				FROM
					tblARImportLogDetail ILD
				INNER JOIN
					[tblARImportLog] H
						ON ILD.[intImportLogId] = H.[intImportLogId] 
				INNER JOIN
					tblARImportLog IL
						ON ILD.intImportLogId = IL.intImportLogId
				LEFT JOIN
					(tblARCustomer C
						INNER JOIN tblEMEntity EC
							ON C.[intEntityId] = EC.intEntityId
						INNER JOIN tblEMEntityLocation EL
							ON C.[intEntityId] = EL.intEntityId
							AND EL.ysnDefaultLocation = 1)
						ON ILD.strCustomerNumber = EC.strEntityNo
				LEFT JOIN
					tblSMCompanyLocation CL
						ON CL.intCompanyLocationId = @ImportLocationId
				LEFT JOIN
					(tblARSalesperson SP 
						INNER JOIN tblEMEntity ESP
							ON SP.[intEntityId] = ESP.intEntityId)
						ON ILD.strSalespersonNumber = ESP.strEntityNo
				LEFT JOIN
					tblICItem ICI
						ON ICI.intItemId = @ImportItemId
						AND ICI.strType = 'Inventory'
				LEFT JOIN
					tblICCategory ICC
						ON ICI.intCategoryId = ICC.intCategoryId
				CROSS APPLY
					(SELECT TOP 1 intCategoryId, intTaxClassId
					FROM tblICCategoryTax 
					WHERE intCategoryId = ICI.intCategoryId
					) CATEGORYTAX
				CROSS APPLY
					(SELECT TOP 1 intTaxCodeId, intTaxClassId
					FROM tblSMTaxCode
					WHERE intTaxClassId = CATEGORYTAX.intTaxClassId
					) TC
				LEFT JOIN
					tblSMTaxGroupCode TGC ON TC.intTaxCodeId = TGC.intTaxCodeId
				LEFT JOIN
					tblICItemLocation ICIL 
						ON ICIL.intItemId = ICI.intItemId 
						AND ICIL.intLocationId = @ImportLocationId
				LEFT JOIN
					tblICItemUOM ICUOM
						ON ICUOM.intItemId = ICI.intItemId						
						AND ICUOM.ysnStockUnit = 1

				WHERE @ImportFormat = @IMPORTFORMAT_CARQUEST  AND H.intImportLogId=@ImportLogId AND ISNULL(ysnImported, 0) = 0 AND ISNULL(ysnSuccess, 0) = 1

			UNION ALL
			SELECT 
				  D.intImportLogDetailId
				 ,[strSourceTransaction]		= 'Import'
				,[strTransactionType]		= 'Invoice'
				,[intSourceId]				= D.intImportLogDetailId
				,[strSourceId]				= CAST(D.intImportLogDetailId AS NVARCHAR(250))
				,[intInvoiceId]				= NULL
				,[intEntityCustomerId]		= C.intEntityId
				,[intCompanyLocationId]		= L.intCompanyLocationId
				,[intCurrencyId]			= @DefaultCurrencyId
				,[intTermId]				= T.intTermID
				,[dtmDate]					= D.dtmDate
				,[dtmDueDate]				= CAST(dbo.fnGetDueDateBasedOnTerm(D.dtmDate, C.intTermsId) AS DATE)
				,[dtmShipDate]				= D.dtmDate
				,[dtmCalculated]			= NULL
				,[dtmPostDate]				= NULL
				,[intEntitySalespersonId]	= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' AND @IsFromOldVersion = 1 THEN SP.intEntityId END
				,[intFreightTermId]			= NULL
				,[intShipViaId]				= NULL
				,[intPaymentMethodId]		= NULL
				,[strInvoiceOriginId]		= D.strTransactionNumber
				,[strPONumber]				= NULL
				,[strBOLNumber]				= D.strBOLNumber
				,[strComments]				= D.strTransactionNumber
				,[intShipToLocationId]		= NULL
				,[intBillToLocationId]		= NULL
				,[ysnTemplate]				= 0
				,[ysnForgiven]				= 0
				,[ysnCalculated]			= CASE WHEN D.dtmCalculated IS NULL THEN 0 ELSE 1 END
				,[ysnSplitted]				= 0
				,[intPaymentId]				= NULL
				,[intSplitId]				= NULL
				,[intLoadDistributionHeaderId]	= NULL
				,[intLoadId]				= NULL
				,[strActualCostId]			= NULL
				,[intShipmentId]			= NULL
				,[intTransactionId]			= NULL
				,[intEntityId]				= H.intEntityId
				,[ysnResetDetails]			= 1
				,[ysnPost]					= CASE WHEN isnull(D.ysnOrigin, 0) = 1 
												THEN NULL
												ELSE  
													CASE WHEN @TransactionType IN ('Customer Prepayment', 'Overpayment') THEN 0
													ELSE CASE WHEN D.dtmPostDate IS NULL THEN 0 
														 ELSE 1 
													END
												END
											  END 
				,[ysnImportedFromOrigin]	= CASE WHEN D.ysnOrigin = 1 THEN 1 ELSE 0 END
				,[ysnImportedAsPosted]		= CASE WHEN D.ysnOrigin = 1 THEN 1 ELSE 0 END
				,[intInvoiceDetailId]		= NULL
				,[intItemId]				= NULL
				,[ysnInventory]				= 0
				,[strItemDescription]		= D.strItemDescription
				,[intOrderUOMId]			= NULL
				,[dblQtyOrdered]			= 1
				,[intItemUOMId]				= NULL
				,[dblQtyShipped]			= 1
				,[dblDiscount]				= ISNULL(ABS(D.dblDiscount), @ZeroDecimal)
				,[dblPrice]					= ABS(ISNULL(D.dblSubtotal, @ZeroDecimal))	
				,[ysnRefreshPrice]			= 0
				,[strMaintenanceType]		= NULL
				,[strFrequency]				= NULL
				,[dtmMaintenanceDate]		= NULL
				,[dblMaintenanceAmount]		= NULL
				,[dblLicenseAmount]			= NULL
				,[intTaxGroupId]			= TAX.intTaxGroupId
				,[ysnRecomputeTax]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST 
												   THEN 0 
												   ELSE CASE WHEN ISNULL(TAX.intTaxGroupId, 0) > 0 THEN 1 ELSE 0 END
											  END
				,[intSCInvoiceId]			= NULL
				,[strSCInvoiceNumber]		= NULL
				,[intInventoryShipmentItemId] = NULL
				,[strShipmentNumber]		= NULL
				,[intSalesOrderDetailId]	= NULL
				,[strSalesOrderNumber]		= NULL
				,[intContractHeaderId]		= NULL
				,[intContractDetailId]		= NULL
				,[intShipmentPurchaseSalesContractId]	= NULL
				,[intTicketId]				= NULL
				,[intTicketHoursWorkedId]	= NULL
				,[intSiteId]				= NULL
				,[strBillingBy]				= NULL
				,[dblPercentFull]			= ISNULL(D.dblPercentFull, @ZeroDecimal)
				,[dblNewMeterReading]		= ISNULL(D.dblNewMeterReading, @ZeroDecimal)
				,[dblPreviousMeterReading]	= NULL
				,[dblConversionFactor]		= NULL
				,[intPerformerId]			= NULL
				,[ysnLeaseBilling]			= NULL
				,[ysnVirtualMeterReading]	= 0
				,[strImportFormat]			= @ImportFormat
				,[dblCOGSAmount]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END
				,[intTempDetailIdForTaxes]  = D.intImportLogDetailId
				,[intConversionAccountId]	= NULL
				,[intCurrencyExchangeRateTypeId]	= NULL
				,[intCurrencyExchangeRateId]		= NULL
				,[dblCurrencyExchangeRate]	= 1.000000
				,[intSubCurrencyId]			= NULL
				,[dblSubCurrencyRate]		= 1.000000
				,[ysnUseOriginIdAsInvoiceNumber] = CASE WHEN ISNULL(D.strTransactionNumber, '') <> '' AND  D.strCustomerNumber <> '9998' THEN 1 ELSE 0 END
				,[ysnImpactInventory]		= 1
				FROM
				 [tblARImportLogDetail] D
				 INNER JOIN [tblARImportLog] H ON D.[intImportLogId] = H.[intImportLogId] 
				 LEFT JOIN tblARCustomer C ON C.strCustomerNumber=D.strCustomerNumber
				 LEFT JOIN tblSMCompanyLocation L ON L.strLocationName = D.strLocationName
				 LEFT JOIN tblTMSite S ON S.intSiteNumber=D.strSiteNumber
				 LEFT JOIN tblARSalesperson SP ON CONVERT(INT, D.strSalespersonNumber) = SP.intEntityId
				 LEFT JOIN tblSMTaxGroup TAX ON TAX.strTaxGroup = D.strTaxGroup
				 LEFT JOIN tblSMTerm T ON T.strTerm = D.strTerms
				 WHERE @ImportFormat <> @IMPORTFORMAT_CARQUEST AND @IsTank = 0   AND H.intImportLogId=@ImportLogId AND ISNULL(ysnImported, 0) = 0 AND ISNULL(ysnSuccess, 0) = 1

			IF @IsTank = 1
			BEGIN
			UPDATE ILD
			SET dblTotal = @Total, strTransactionType = 'Invoice'
			FROM  tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId=IL.intImportLogId
			END

			IF @ImportFormat = @IMPORTFORMAT_CARQUEST
							BEGIN
								INSERT INTO @TaxDetails(
									[intDetailId] 
								  , [intTaxGroupId]
								  , [intTaxCodeId]
								  , [intTaxClassId]
								  , [strTaxableByOtherTaxes]
								  , [strCalculationMethod]
								  , [dblRate]
								  , [intTaxAccountId]
								  , [dblTax]
								  , [dblAdjustedTax]
								  , [ysnTaxAdjusted]
								  , [ysnSeparateOnInvoice]
								  , [ysnCheckoffTax]
								  , [ysnTaxExempt]
								  , [ysnTaxOnly]
								  , [strNotes]
								  , [intTempDetailIdForTaxes])
								SELECT  
								    [intDetailId]				= NULL
								  , [intTaxGroupId]				= TGC.intTaxGroupId
								  , [intTaxCodeId]				= TGC.intTaxCodeId
								  , [intTaxClassId]				= TC.intTaxClassId
								  , [strTaxableByOtherTaxes]	= TC.strTaxableByOtherTaxes
								  , [strCalculationMethod]		= TCR.strCalculationMethod
								  , [dblRate]					= TCR.dblRate
								  , [intTaxAccountId]			= TC.intSalesTaxAccountId
								  , [dblTax]					= 0
								  , [dblAdjustedTax]			= @TaxAmount
								  , [ysnTaxAdjusted]			= 1
								  , [ysnSeparateOnInvoice]		= 0 
								  , [ysnCheckoffTax]			= TC.ysnCheckoffTax
								  , [ysnTaxExempt]				= CASE WHEN ISNULL(@TaxAmount, 0) > 0 THEN 0 ELSE 1 END
								  , [ysnTaxOnly]				= TC.ysnTaxOnly
								  , [strNotes]					= NULL
								  , [intTempDetailIdForTaxes]	= ILD.intImportLogDetailId
								FROM tblSMTaxGroupCode TGC
									
									INNER JOIN tblSMTaxCode TC
										ON TGC.intTaxCodeId = TC.intTaxCodeId
									INNER JOIN tblSMTaxCodeRate TCR
										ON TC.intTaxCodeId = TCR.intTaxCodeId
									INNER JOIN  [tblARImportLogDetail] ILD ON ILD.strTaxGroup = TC.strTaxCode
								WHERE TGC.intTaxGroupId = @TaxGroupId 
								  AND TC.intTaxClassId = @TaxClassId
							END


							select ysnPost,ysnImportedFromOrigin,* from @EntriesForInvoice
	--PROCESS TO INVOICE
			EXEC dbo.uspARProcessInvoicesByBatch @InvoiceEntries		= @EntriesForInvoice
											, @LineItemTaxEntries	= @TaxDetails
											, @UserId				= @UserEntityId
											, @GroupingOption		= 11
											, @RaiseError			= 0
											, @ErrorMessage			= @ErrorMessage OUT
											, @LogId				= @intInvoiceLogId OUT

						UPDATE
						ARI
						SET

						ARI.dblBaseDiscountAvailable = T.[Discount],	
						ARI.dblDiscountAvailable = T.[Discount],
						ARI.dblInvoiceTotal = ARI.dblInvoiceTotal +T.[Discount] ,
						ARI.dblBaseInvoiceTotal = ARI.dblInvoiceTotal + T.[Discount],
						ARI.dblAmountDue	= ARI.dblInvoiceTotal + T.[Discount],
						ARI.dblBaseAmountDue = ARI.dblInvoiceTotal + T.[Discount],
						ARI.dblInvoiceSubtotal   =  ARI.dblInvoiceSubtotal +  T.[Discount],
						ARI.dblBaseInvoiceSubtotal  =  ARI.dblBaseInvoiceSubtotal + T.[Discount],
						ARI.ysnImportFromCSV = 1

						FROM tblARInvoice ARI
						INNER JOIN tblARInvoiceIntegrationLogDetail I ON ARI.intInvoiceId= I.intSourceId AND ARI.strInvoiceNumber = I.strSourceId
						INNER JOIN (
								SELECT  dblPrice - dblTotal [Discount],
										ID.intInvoiceId
							FROM
								tblARInvoiceDetail ID
								INNER JOIN tblARInvoiceIntegrationLogDetail I ON ID.intInvoiceId= I.intSourceId
							WHERE
								ID.[intInvoiceId] =  I.intInvoiceId
						)T ON T.[intInvoiceId]  = ARI.[intInvoiceId] 

						WHERE I.intIntegrationLogId	= @intInvoiceLogId

				 		UPDATE
						ARID
						SET 
						ARID.dblTotal  = ARID.dblTotal  + ARI.dblDiscountAvailable,
						ARID.dblBaseTotal = ARID.dblBaseTotal  + ARI.dblDiscountAvailable
						FROM tblARInvoiceDetail ARID
						INNER JOIN tblARInvoiceIntegrationLogDetail I ON ARID.intInvoiceId= I.intSourceId 
						INNER JOIN tblARInvoice ARI  ON ARI.intInvoiceId = I.intInvoiceId
						WHERE I.intIntegrationLogId	= @intInvoiceLogId

						UPDATE
						ARID
						SET dblDiscount = @ZeroDecimal
						FROM tblARInvoiceDetail ARID
						INNER JOIN tblARInvoiceIntegrationLogDetail I ON ARID.intInvoiceId= I.intSourceId 
						WHERE I.intIntegrationLogId	= @intInvoiceLogId

						
						UPDATE
						ARI
						
						SET intEntitySalespersonId = S.intEntityId
						, strType = CASE WHEN @IsTank = 1 THEN 'Tank Delivery' ELSE ISNULL(ILD.strSourceType, 'Standard') END

						FROM tblARInvoice ARI
						INNER JOIN tblARInvoiceIntegrationLogDetail I ON ARI.intInvoiceId= I.intSourceId AND ARI.strInvoiceNumber = I.strSourceId
						INNER JOIN tblARImportLogDetail ILD ON ARI.strInvoiceOriginId = ILD.strTransactionNumber 
						LEFT JOIN tblARSalesperson S ON ILD.strSalespersonNumber=S.strSalespersonId
						WHERE I.intIntegrationLogId	= @intInvoiceLogId


						IF @ImportFormat = @IMPORTFORMAT_CARQUEST
							BEGIN

							UPDATE  PRICING
							SET dblLastCost = ILD.dblCOGSAmount 
							FROM tblICItemPricing PRICING
							INNER JOIN tblARImportLog IL ON   IL.intImportLogId = @ImportLogId
							INNER JOIN tblARImportLogDetail ILD ON IL.intImportLogId=ILD.intImportLogId
							LEFT JOIN  tblICItem ICI ON ICI.intItemId = @ImportItemId AND ICI.strType = 'Inventory'
							LEFT JOIN  tblICItemLocation ICIL ON ICIL.intItemId = ICI.intItemId  AND ICIL.intLocationId = @ImportLocationId 
							WHERE ICI.intItemId = @ImportItemId  AND ICIL.intItemLocationId = PRICING.intItemLocationId

							END


			UPDATE ILD
			SET [intConversionAccountId] = @ConversionAccountId
			FROM  tblARImportLogDetail ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId=IL.intImportLogId

			IF EXISTS (SELECT TOP 1 1 FROM tblARImportLogDetail  ILD
			INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
			WHERE  IL.intImportLogId = @ImportLogId  AND ILD.strEventResult = 'Unable to find an open fiscal year period to match the transaction date.')
			BEGIN 	
				UPDATE ILD
				SET [ysnImported]		= 0
				   ,[ysnSuccess]        = 0
				   ,[strEventResult]	= CASE WHEN ILD.strTransactionType IN ('Invoice', 'Credit Memo', 'Debit Memo', 'Cash',  'Cash Refund', 'Overpayment', 'Customer Prepayment') AND @ErrorMessage = 'Unable to find an open fiscal year period to match the transaction date.'
														THEN
															ARI.strTransactionType + ':' + ARI.strInvoiceNumber + ' Imported. But unable to post due to: ' + @ErrorMessage
														ELSE
															ARI.strTransactionType + ':' + ARI.strInvoiceNumber + ' Imported.'
													END
				FROM tblARImportLogDetail ILD
				INNER JOIN tblARImportLog IL ON ILD.intImportLogId = IL.intImportLogId
				INNER JOIN tblARInvoice ARI ON ARI.strInvoiceOriginId = ILD.strTransactionNumber 
				INNER JOIN tblARInvoiceIntegrationLogDetail I ON ARI.intInvoiceId= I.intSourceId AND ARI.strInvoiceNumber = I.strSourceId 
				WHERE  IL.intImportLogId = @ImportLogId  AND ILD.strEventResult = 'Unable to find an open fiscal year period to match the transaction date.'

			END
END

			WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoicesForImport  where strTransactionType = 'Sales Order')
			BEGIN

			DECLARE @ImportLogDetailId INT
			SELECT TOP 1 @ImportLogDetailId = intImportLogDetailId FROM @InvoicesForImport ORDER BY intImportLogDetailId

			SELECT 
					 @EntityCustomerId				= (SELECT TOP 1 intEntityId FROM tblARCustomer WHERE strCustomerNumber = D.strCustomerNumber)
					,@Date							= D.dtmDate
					,@CompanyLocationId				= (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationName = D.strLocationName)
					,@EntityId						= ISNULL(@UserEntityId, H.intEntityId)
					,@TermId						= CASE WHEN ISNULL(D.strTerms, '') <> '' THEN (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = D.strTerms) ELSE 0 END
					,@EntitySalespersonId			= CASE WHEN ISNULL(D.strSalespersonNumber, '') <> '' THEN (SELECT TOP 1 SP.[intEntityId] FROM tblARSalesperson SP INNER JOIN tblEMEntity E ON SP.[intEntityId] = E.intEntityId WHERE E.strEntityNo = D.strSalespersonNumber) ELSE 0 END
					,@DueDate						= D.dtmDueDate		
					,@ShipDate						= D.dtmShipDate
					,@CalculatedDate				= D.dtmCalculated
					,@PostDate						= D.dtmPostDate 
					,@TransactionType				= D.strTransactionType
					,@Type							= ISNULL(D.strSourceType,@Type)
					,@Comment						= D.strTransactionNumber
					,@OriginId						= D.strTransactionNumber
					,@PONumber						= D.strPONumber
					,@BOLNumber						= D.strBOLNumber
					,@FreightTermId					= CASE WHEN ISNULL(D.strFreightTerm, '') <> '' THEN (SELECT TOP 1 intFreightTermId FROM tblSMFreightTerms WHERE strFreightTerm = D.strFreightTerm) ELSE 0 END
					,@ShipViaId						= CASE WHEN ISNULL(D.strShipVia, '') <> '' THEN (SELECT TOP 1 [intEntityId] FROM tblSMShipVia WHERE strShipVia = D.strShipVia)	ELSE 0 END
					,@DiscountAmount				= ISNULL(D.dblDiscount, @ZeroDecimal)
					,@DiscountPercentage			= (CASE WHEN ISNULL(D.dblDiscount, @ZeroDecimal) > 0 
															THEN (1 - ((ABS(D.dblTotal) - ISNULL(D.dblDiscount, @ZeroDecimal)) / ABS(D.dblTotal))) * 100
															ELSE @ZeroDecimal
													   END)
					,@ItemQtyShipped				= 1.000000
					,@ItemPrice						= ISNULL(D.[dblSubtotal], @ZeroDecimal)
					,@ItemDescription				= D.strItemDescription
					,@TaxGroupId					= CASE WHEN ISNULL(D.strTaxGroup, '') <> '' THEN (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = D.strTaxGroup) ELSE 0 END
					,@AmountDue						= CASE WHEN D.strTransactionType <> 'Sales Order' THEN ISNULL(D.dblAmountDue, @ZeroDecimal) ELSE @ZeroDecimal END
					,@TaxAmount						= ISNULL(D.dblTax, @ZeroDecimal)
					,@Total							= ISNULL(D.dblTotal, @ZeroDecimal)
					,@ysnOrigin						= D.ysnOrigin
					,@ysnRecap						= H.ysnRecap			
				FROM
					[tblARImportLogDetail] D
				INNER JOIN
					[tblARImportLog] H
						ON D.[intImportLogId] = H.[intImportLogId] 
				WHERE
					[intImportLogDetailId] = @ImportLogDetailId


			DECLARE @computedDueDate DATETIME
							  , @shipToId		 INT
							  , @shipToName		 NVARCHAR(50)
							  , @shipToAddress	 NVARCHAR(300)
							  , @shipToCity		 NVARCHAR(100)
							  , @shipToState	 NVARCHAR(100)
							  , @shipToZipCode	 NVARCHAR(100)
							  , @shipToCountry	 NVARCHAR(100)

						SELECT @computedDueDate = dbo.fnGetDueDateBasedOnTerm(@Date, @TermId)
						SELECT TOP 1 
							   @shipToId		= intEntityLocationId
							 , @shipToName		= strLocationName
							 , @shipToAddress	= strAddress
							 , @shipToCity		= strCity
							 , @shipToState		= strState
							 , @shipToZipCode	= strZipCode
							 , @shipToCountry	= strCountry
						FROM [tblEMEntityLocation] WHERE intEntityId = @EntityCustomerId AND ysnDefaultLocation = 1
						SET @DueDate = ISNULL(@DueDate, @computedDueDate)


			INSERT INTO tblSOSalesOrder 
							([strSalesOrderOriginId]
							,[intEntityCustomerId]
							,[dtmDate]
							,[dtmDueDate]
							,[intCurrencyId]
							,[intCompanyLocationId]
							,[intEntitySalespersonId]
							,[intEntityContactId]
							,[intOrderedById]
							,[intShipViaId]
							,[strPONumber]
							,[intTermId]
							,[dblSalesOrderSubtotal]
							,[dblTax]
							,[dblSalesOrderTotal]
							,[dblDiscount]
							,[dblAmountDue]
							,[dblPayment]
							,[strTransactionType]
							,[strType]
							,[strOrderStatus]
							,[intAccountId]
							,[strBOLNumber]
							,[strComments]
							,[intFreightTermId]
							,[intEntityId]
							,[intShipToLocationId]
							,[intBillToLocationId]
							,[strShipToLocationName]
							,[strBillToLocationName]
							,[strShipToAddress]
							,[strBillToAddress]
							,[strShipToCity]
							,[strBillToCity]
							,[strShipToState]
							,[strBillToState]
							,[strShipToZipCode]
							,[strBillToZipCode]
							,[strShipToCountry]
							,[strBillToCountry])
						SELECT NULL
							, @EntityCustomerId
							, @Date
							, @DueDate
							, @DefaultCurrencyId
							, @CompanyLocationId
							, @EntitySalespersonId
							, @EntityContactId
							, @UserEntityId
							, @ShipViaId
							, @PONumber
							, @TermId
							, @ItemPrice
							, @TaxAmount
							, @Total
							, @DiscountAmount
							, @ZeroDecimal
							, @ZeroDecimal
							, 'Order'
							, 'Standard'
							, 'Open'
							, @DefaultAccountId
							, @BOLNumber
							, NULL
							, @FreightTermId
							, @UserEntityId
							, @shipToId
							, @shipToId
							, @shipToName
							, @shipToName
							, @shipToAddress
							, @shipToAddress
							, @shipToCity
							, @shipToCity
							, @shipToState
							, @shipToState
							, @shipToZipCode
							, @shipToZipCode
							, @shipToCountry
							, @shipToCountry
					
						SET @NewTransactionId = SCOPE_IDENTITY()

						INSERT INTO tblSOSalesOrderDetail
							([intSalesOrderId]
							,[intItemId]
							,[strItemDescription]
							,[intItemUOMId]
							,[dblQtyOrdered]
							,[dblQtyAllocated]
							,[dblQtyShipped]
							,[dblDiscount]
							,[dblPrice]
							,[dblTotalTax]
							,[dblTotal])
						SELECT @NewTransactionId
							 , NULL
							 , @ItemDescription
							 , NULL
							 , @ItemQtyShipped
							 , @ZeroDecimal
							 , @ZeroDecimal
							 , @DiscountPercentage
							 , @ItemPrice
							 , @TaxAmount
							 , @Total

			IF(ISNULL(@NewTransactionId,0) <> 0) OR @ErrorMessage = 'Unable to find an open fiscal year period to match the transaction date.'
			BEGIN
							UPDATE tblARImportLogDetail
							SET [ysnImported]		= 1
							   ,[strEventResult]	= (SELECT strTransactionType + ':' + strSalesOrderNumber FROM tblSOSalesOrder WHERE intSalesOrderId = @NewTransactionId) + ' Imported.'
							WHERE [intImportLogDetailId] = @ImportLogDetailId
			END



			 UPDATE tblARImportLogDetail SET [intConversionAccountId] = @ConversionAccountId  WHERE intImportLogDetailId = @ImportLogDetailId
		
			 DELETE FROM @InvoicesForImport WHERE [intImportLogDetailId] = @ImportLogDetailId

			END
END TRY

BEGIN CATCH
		SET @ErrorMessage = ERROR_MESSAGE();
END CATCH