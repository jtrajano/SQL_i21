/****** Object:  StoredProcedure [dbo].[uspARImportInvoiceFromPTTICMST]    Script Date: 08/30/2016 06:36:20 ******/

CREATE PROCEDURE [dbo].[uspARImportInvoiceFromPTTICMST]
	@UserId INT ,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@totalHeaderImported INT OUTPUT,
	@totalDetailImported INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @defaultCurrencyId INT;
DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()

DECLARE  @transCount		INT = @@TRANCOUNT
		,@intInvoiceLogId	INT = NULL
		,@strErrorMsg	NVARCHAR(MAX) = NULL

IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspARImportInvoiceFromPTTICMST


--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

--ALTER TABLE tblARInvoice DROP CONSTRAINT [UK_dbo.tblARInvoice_strBillId]

--AR Account
DECLARE @ARAccount VARCHAR(250)
SET @ARAccount = (SELECT [intARAccountId] FROM tblARCompanyPreference)

DECLARE @maxInvoiceId INT
	
SELECT @maxInvoiceId = MAX(intInvoiceId) FROM tblARInvoice
SET @maxInvoiceId = ISNULL(@maxInvoiceId, 0)

DECLARE @EntriesForInvoice InvoiceStagingTable
DECLARE @TaxDetails 		LineItemTaxDetailStagingTable

INSERT INTO @EntriesForInvoice
(
	[intId],
	[strInvoiceOriginId],
	[intEntityCustomerId],
	[dtmDate],
	[dtmDueDate],
	[dtmPostDate],
	[intCurrencyId],
	[intCompanyLocationId],
	[intEntitySalespersonId],
	[strPONumber],
	[intTermId],
	[dblDiscount],
	[strType],
	[strTransactionType],
	[strSourceTransaction],
	[strSourceId],
	[intSourceId],
	[strComments],
	[intAccountId], 
	[ysnPost],
	[intEntityId],
	[intItemId],
	[intTaxGroupId],
	[strItemDescription],
	[dblQtyOrdered],
	[dblQtyShipped],
	[dblPrice]
)
SELECT
	[intId] = A4GLIdentity,
	[strInvoiceOriginId] = 'O' + '-' + pttic_ivc_no,
	[intEntityCustomerId] = Cus.intEntityId,
	[dtmDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
	[dtmDueDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN DATEADD(day,Term.intBalanceDue,CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112)) ELSE GETDATE() END),
	[dtmPostDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
	[intCurrencyId] = @defaultCurrencyId,
	[intCompanyLocationId] = (SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = pttic_itm_loc_no COLLATE Latin1_General_CI_AS),
	[intEntitySalespersonId] = Salesperson.intEntityId,
	[strPONumber] = pttic_po_no,
	[intTermId] = ISNULL(Term.intTermID,1),
	[dblDiscount] = pttic_itm_disc_amt,
	[strType] = 'Standard',
	[strTransactionType] = (CASE 
							WHEN pttic_type = 'I' THEN 'Invoice' 
							WHEN pttic_type = 'C' THEN 'Credit Memo' 
							WHEN pttic_type = 'D' THEN 'Debit Memo' 
							WHEN pttic_type = 'S' THEN 'Cash'
							WHEN pttic_type = 'R' THEN 'Cash Refund' 
							WHEN pttic_type = 'X' THEN 'Transfer'
							END),
	[strSourceTransaction] = 'Store Charge',
	[strSourceId] = pttic_ivc_no,
	[intSourceId] = pttic_ivc_no,
	[strComments] = pttic_comments,
	[intAccountId] = @ARAccount, 
	[ysnPost] = 0,
	[intEntityId] = @UserId,
	[intItemId]		=  ITM.intItemId,
	[intTaxGroupId] =  LOC.[intTaxGroupId],
	[strItemDescription] = ITM.strDescription,
	[dblQtyOrdered] = NULL,
	[dblQtyShipped] = CASE WHEN ISNULL(pttic_qty_ship, 0) = 0 THEN 1 ELSE pttic_qty_ship END,
	[dblPrice]		= CASE WHEN ISNULL(pttic_unit_prc, 0) = 0 THEN pttic_actual_total ELSE pttic_unit_prc END
	FROM tmp_ptticmstImport A
	INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = A.pttic_cus_no COLLATE Latin1_General_CI_AS
	LEFT JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = A.pttic_slsmn_id COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(pttic_itm_no  COLLATE Latin1_General_CI_AS)
	INNER JOIN tblEMEntityLocation LOC ON LOC.intEntityId = Cus.intEntityId
	LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,A.pttic_terms_code)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblARInvoice 
		ON A.pttic_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceOriginId COLLATE Latin1_General_CI_AS
		AND tblARInvoice.[dtmDate] = CONVERT(DATE, CAST(A.pttic_rev_dt AS CHAR(12)), 112)
		AND tblARInvoice.[dblInvoiceTotal] = ROUND(ISNULL(pttic_actual_total, 0), [dbo].[fnARGetDefaultDecimal]())
		AND ISNULL(tblARInvoice.[ysnImportedFromOrigin],0) = 1 AND ISNULL(tblARInvoice.[ysnImportedAsPosted],0) = 0
	WHERE 
		pttic_type NOT IN ('O','X')
		AND pttic_line_no = 1
		AND tblARInvoice.strInvoiceOriginId IS NULL 

EXEC [dbo].[uspARPopulateTaxFromOrigin]

--PROCESS TO INVOICE
EXEC dbo.uspARProcessInvoicesByBatch @InvoiceEntries		= @EntriesForInvoice
									, @LineItemTaxEntries	= @TaxDetails
									, @UserId				= @UserId
									, @GroupingOption		= 11
									, @RaiseError			= 1
									, @ErrorMessage			= @strErrorMsg OUT
									, @LogId				= @intInvoiceLogId OUT


INSERT INTO [tblARInvoiceDetailTax]
	([intInvoiceDetailId]
	,[intTaxGroupId]
	,[intTaxCodeId]
	,[intTaxClassId]
	,[intSalesTaxAccountId]
	,[strTaxableByOtherTaxes]
	,[strCalculationMethod]
	,[dblRate]
	,[dblTax]
	,[dblAdjustedTax]
	,[ysnTaxAdjusted]
	,[ysnSeparateOnInvoice]
	,[ysnCheckoffTax]
	,[ysnTaxOnly]			
	,[strNotes]
	)		
	SELECT DISTINCT 
	intInvoiceDetailId,
	TAXGROUP.intTaxGroupId,
	TAXGROUP.intTaxCodeId,
	TAXGROUP.intTaxClassId,
	TAXGROUP.intSalesTaxAccountId,
	NULL,
	TAXR.strCalculationMethod,
	TAXR.dblRate,
	origin.dblTaxAMount,
	origin.dblTaxAMount,
	0,
	0,
	TAXGROUP.ysnCheckoffTax,
	TAXGROUP.[ysnTaxOnly],
	''
	FROM ##ORIGINTAXES origin
	INNER JOIN 
	(
			select C.intTaxGroupId,C.strTaxGroup,B.* from tblSMTaxGroupCode A
				INNER JOIN tblSMTaxCode B ON A.intTaxCodeId = B.intTaxCodeId
				INNER JOIN tblSMTaxGroup C ON A.intTaxGroupId=C.intTaxGroupId
	)TAXGROUP  ON strTaxGroup COLLATE SQL_Latin1_General_CP1_CI_AS= origin.strOriginTaxGroup
	INNER JOIN
	(
		select  CAT.*,TR.strOrgItemNo,TR.strOrgState,TR.strOrgLocal1,TR.strOrgTaxType,C.strOriginTaxType from tblSMTaxXRef TR
		INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = TR.strOrgItemNo  COLLATE Latin1_General_CI_AS
		INNER JOIN tblICCategoryTax CAT ON CAT.intCategoryId = ITM.intCategoryId
		INNER JOIN tblSMTaxClass C ON C.intTaxClassId = CAT.intTaxClassId

	)TAX ON TAXGROUP.intTaxClassId= TAX.intTaxClassId  
	INNER JOIN tblSMTaxCodeRate TAXR ON TAXR.intTaxCodeId=TAXGROUP.intTaxCodeId
	AND TAX.strOrgItemNo COLLATE Latin1_General_CI_AS=origin.strOriginItemNumber  
	and TAX.strOrgState  COLLATE Latin1_General_CI_AS=origin.strOriginState 
	and TAX.strOrgLocal1  COLLATE Latin1_General_CI_AS= origin.strOriginTaxKey  
	AND TAX.strOriginTaxType COLLATE Latin1_General_CI_AS = origin.strTaxType
	INNER JOIN(
		SELECT c.intInvoiceDetailId,SUBSTRING(strInvoiceOriginId,3,7)[strInvoiceOriginId] FROM tblARInvoiceIntegrationLogDetail a    
		INNER JOIN tblARInvoice  b ON b.intInvoiceId=a.intInvoiceId
		INNER JOIN tblARInvoiceDetail  c ON c.intInvoiceId=a.intInvoiceId
		WHERE intIntegrationLogId = @intInvoiceLogId AND ysnSuccess = 1
	)InvoiceLog ON InvoiceLog.strInvoiceOriginId COLLATE SQL_Latin1_General_CP1_CI_AS=origin.strOriginInvoiceNumber 



	DECLARE @RecomputeAmountIds InvoiceId	
	DELETE FROM @RecomputeAmountIds

	INSERT INTO @RecomputeAmountIds(
			 [intHeaderId]
			,[ysnUpdateAvailableDiscountOnly]
			,[intDetailId])
		SELECT 
			 [intHeaderId]						= Invoice.[intInvoiceId]
			,[ysnUpdateAvailableDiscountOnly]	= 0
			,[intDetailId]						= Invoice.[intInvoiceDetailId]
		 FROM (
		 SELECT c.intInvoiceDetailId,b.intInvoiceId,ysnSuccess FROM tblARInvoiceIntegrationLogDetail a    
						INNER JOIN tblARInvoice  b ON b.intInvoiceId=a.intInvoiceId
						INNER JOIN tblARInvoiceDetail  c ON c.intInvoiceId=a.intInvoiceId
		 )Invoice 
		 WHERE
			Invoice.[ysnSuccess] = 1


		EXEC [dbo].[uspARReComputeInvoicesAmounts] @InvoiceIds = @RecomputeAmountIds

----UPDATE THE intInvoiceId of tblARptticmst
UPDATE A
	SET A.intInvoiceId = B.intInvoiceId
FROM tblARptticmst A
INNER JOIN @EntriesForInvoice B ON A.A4GLIdentity = B.intId

UPDATE 
	IVC 
SET
     IVC.intBillToLocationId    = C.intBillToId			
	,IVC.strBillToAddress		= B.strAddress 
	,IVC.strBillToCity			= B.strCity
	,IVC.strBillToCountry		= B.strCountry
	,IVC.strBillToLocationName	= B.strLocationName 
	,IVC.strBillToState		    = B.strState 
	,IVC.strBillToZipCode		= B.strZipCode 
	,IVC.intShipToLocationId    = C.intShipToId
	,IVC.strShipToAddress		= S.strAddress 
	,IVC.strShipToCity			= S.strCity
	,IVC.strShipToCountry		= S.strCountry
	,IVC.strShipToLocationName	= S.strLocationName 
	,IVC.strShipToState		    = S.strState 
	,IVC.strShipToZipCode		= S.strZipCode 
FROM
	tblARCustomer C
LEFT OUTER JOIN
	tblEMEntityLocation B
		ON C.intBillToId = B.intEntityLocationId 
LEFT OUTER JOIN
	tblEMEntityLocation S
		ON C.intShipToId = S.intEntityLocationId 													
INNER JOIN tblARInvoice IVC on IVC.intEntityCustomerId = C.intEntityId		
WHERE
	intInvoiceId > @maxInvoiceId

SELECT @totalHeaderImported = COUNT(I.intInvoiceId)
FROM tblARInvoice I
INNER JOIN @EntriesForInvoice EI
ON I.strInvoiceOriginId = EI.strInvoiceOriginId
WHERE I.intInvoiceId > @maxInvoiceId
GROUP BY I.intInvoiceId

INSERT INTO tblARImportInvoiceLog
(
	[strDescription], 
    [intEntityId], 
    [dtmDate],
	[strLogKey]
)
SELECT
	CAST(@totalHeaderImported AS NVARCHAR) + ' records imported from ptticmst.'
	,@UserId
	,@logDate
	,@key

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorImport NVARCHAR(500) = ERROR_MESSAGE();
	IF XACT_STATE() = -1
		ROLLBACK TRANSACTION;
	IF @transCount = 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION
	IF @transCount > 0 AND XACT_STATE() = 1
		ROLLBACK TRANSACTION uspARImportInvoiceFromPTTICMST
	
	RAISERROR(@errorImport, 16, 1);
END CATCH


GO


