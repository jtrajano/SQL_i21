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

DECLARE @userLocation INT;
DECLARE @defaultTermId INT;
DECLARE @defaultCurrencyId INT;
DECLARE @totalInsertedInvoice INT;
DECLARE @totalInsertedInvoiceDetail INT;
DECLARE @key NVARCHAR(100) = NEWID()
DECLARE @logDate DATETIME = GETDATE()
--LOCATION VARIABLES
DECLARE @shipToAddress NVARCHAR(200)
DECLARE @shipToCity NVARCHAR(50)
DECLARE @shipToState NVARCHAR(50)
DECLARE @shipToZipCode NVARCHAR(12)
DECLARE @shipToCountry NVARCHAR(25)
DECLARE @shipToPhone NVARCHAR(25)
DECLARE @shipToAttention NVARCHAR(200)
--STARTING RECORD NUMBER
DECLARE @invoice NVARCHAR(5)
DECLARE @nextInvoiceNumber INT;

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 
	BEGIN TRANSACTION
ELSE 
	SAVE TRANSACTION uspARImportInvoiceFromPTTICMST

--SET STARTING RECORD NUMBER PREFIX
SELECT
	@invoice = strPrefix,
	@nextInvoiceNumber = A.intNumber
FROM tblSMStartingNumber A
WHERE A.intStartingNumberId = 19


--GET THE USER LOCATION
SELECT 
	@userLocation		= A.intCompanyLocationId ,
	@shipToAddress		= A.strAddress,
	@shipToCity			= A.strCity,
	@shipToState		= A.strStateProvince,
	@shipToZipCode		= A.strZipPostalCode,
	@shipToCountry		= A.strCountry,
	@shipToPhone		= A.strPhone,
	@shipToAttention	= A.strAddress
FROM tblSMCompanyLocation A
	INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

--GET DEFAULT TERM TO USE
SELECT TOP 1 @defaultTermId = intTermID FROM tblSMTerm WHERE strTerm = 'Due on Receipt'

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

--ALTER TABLE tblARInvoice DROP CONSTRAINT [UK_dbo.tblARInvoice_strBillId]

--AR Account
DECLARE @ARAccount VARCHAR(250)
SET @ARAccount = (SELECT [intARAccountId] FROM tblARCompanyPreference)

DECLARE @maxInvoiceId INT
	
SELECT @maxInvoiceId = MAX(intInvoiceId) FROM tblARInvoice
SET @maxInvoiceId = ISNULL(@maxInvoiceId, 0)


IF OBJECT_ID(N'tempdb..#tmpInvoice') IS NOT NULL DROP TABLE #tmpInvoice
CREATE TABLE #tmpInvoice(intInvoiceId INT, intBackupId INT);

MERGE INTO tblARInvoice AS destination
USING
(
SELECT
	[strInvoiceOriginId] = pttic_ivc_no,
	[intEntityCustomerId] = Cus.intEntityCustomerId,
	[dtmDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
	[dtmDueDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN DATEADD(day,Term.intBalanceDue,CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112)) ELSE GETDATE() END),
	[dtmPostDate] = (CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
	[intCurrencyId] = @defaultCurrencyId,
	[intCompanyLocationId] = (SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = pttic_itm_loc_no COLLATE Latin1_General_CI_AS),
	[intEntitySalespersonId] = Salesperson.intEntitySalespersonId,
	[dtmShipDate] = NULL,
	[intShipViaId] = NULL,
	[strPONumber] = pttic_po_no,
	[intTermId] = ISNULL(Term.intTermID,1),
	[dblInvoiceSubtotal] = 0,
	[dblShipping] = 0,
	[dblTax] = 0,
	[dblInvoiceTotal] = pttic_actual_total,
	[dblDiscount] = pttic_itm_disc_amt,
	[dblAmountDue] = pttic_actual_total,
	[dblPayment] = 0,
	[strTransactionType] = (CASE 
							WHEN pttic_type = 'I' THEN 'Invoice' 
							WHEN pttic_type = 'C' THEN 'Credit Memo' 
							WHEN pttic_type = 'D' THEN 'Debit Memo' 
							WHEN pttic_type = 'S' THEN 'Cash Sale'
							WHEN pttic_type = 'R' THEN 'Cash Refund' 
							WHEN pttic_type = 'X' THEN 'Transfer'
							END),
	[intPaymentMethodId] = NULL,
	[strComments] = pttic_comments,
	[intAccountId] = @ARAccount, 
	[ysnPosted] = 0,
	[ysnPaid] = 0,
	[ysnImportedFromOrigin] = 1,
	[ysnImportedAsPosted] = 0,
	[intEntityId] = @UserId,
	[intBackupId] =	A.intBackupId
	FROM tmp_ptticmstImport A
	INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = A.pttic_bill_to_cus_no COLLATE Latin1_General_CI_AS
	INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = A.pttic_slsmn_id COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,A.pttic_terms_code)) COLLATE Latin1_General_CI_AS
	WHERE pttic_type <> 'O' AND pttic_line_no = 1
) AS SourceData
ON (1=0)
WHEN NOT MATCHED THEN
INSERT
(
	 [strInvoiceOriginId]
	,[intEntityCustomerId]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmPostDate]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[intEntitySalespersonId]
	,[dtmShipDate]
	,[intShipViaId]
	,[strPONumber]
	,[intTermId]
	,[dblInvoiceSubtotal]
	,[dblShipping]
	,[dblTax]
	,[dblInvoiceTotal]
	,[dblDiscount]
	,[dblAmountDue]
	,[dblPayment]
	,[strTransactionType]
	,[intPaymentMethodId]
	,[strComments]
	,[intAccountId]
	,[ysnPosted]
	,[ysnPaid]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intEntityId]
)
VALUES
(
	 [strInvoiceOriginId]
	,[intEntityCustomerId]
	,[dtmDate]
	,[dtmDueDate]
	,[dtmPostDate]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[intEntitySalespersonId]
	,[dtmShipDate]
	,[intShipViaId]
	,[strPONumber]
	,[intTermId]
	,[dblInvoiceSubtotal]
	,[dblShipping]
	,[dblTax]
	,[dblInvoiceTotal]
	,[dblDiscount]
	,[dblAmountDue]
	,[dblPayment]
	,[strTransactionType]
	,[intPaymentMethodId]
	,[strComments]
	,[intAccountId]
	,[ysnPosted]
	,[ysnPaid]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intEntityId]
	)
OUTPUT inserted.intInvoiceId, SourceData.intBackupId INTO #tmpInvoice;

SET @totalInsertedInvoice = @@ROWCOUNT

IF OBJECT_ID('tempdb..#tmpInvoicesWithRecordNumber') IS NOT NULL DROP TABLE #tmpInvoicesWithRecordNumber

--UPDATE strBillId
CREATE TABLE #tmpInvoicesWithRecordNumber
(
	intInvoiceId INT NOT NULL,
	[strTransactionType] [nvarchar](25) NOT NULL,
	intRecordNumber INT NOT NULL
)

INSERT INTO #tmpInvoicesWithRecordNumber
SELECT
	A.intInvoiceId,
	A.[strTransactionType],
	  @nextInvoiceNumber +
		ROW_NUMBER() OVER(PARTITION BY A.strTransactionType ORDER BY A.intInvoiceId)
FROM tblARInvoice A
INNER JOIN #tmpInvoice B ON A.intInvoiceId = B.intInvoiceId

UPDATE A
	SET A.strInvoiceNumber = @invoice + (CAST(B.intRecordNumber AS NVARCHAR))
FROM tblARInvoice A
INNER JOIN #tmpInvoicesWithRecordNumber B ON A.intInvoiceId = B.intInvoiceId

--ALTER TABLE tblARInvoice ADD CONSTRAINT [UK_dbo.tblARInvoice_strBillId] UNIQUE (strBillId);

IF @totalInsertedInvoice <= 0 
BEGIN
	SET @totalHeaderImported = 0;
	SET @totalDetailImported = 0;
	IF @transCount = 0 COMMIT TRANSACTION
	RETURN;
END

SET @totalHeaderImported = @totalInsertedInvoice;

--IMPORT DETAIL
INSERT INTO tblARInvoiceDetail
(
  [intInvoiceId]
 ,[intItemId]
 ,[intTaxGroupId]
 ,[strItemDescription]
 ,[dblQtyOrdered]
 ,[dblQtyShipped]
 ,[dblPrice]
 ,[dblTotal]
)
SELECT 
		[intInvoiceId]	=	A.intInvoiceId,
		[intItemId]		=  ITM.intItemId,
		[intTaxGroupId] =  LOC.[intTaxGroupId],
		[strItemDescription] = ITM.strDescription,
		[dblQtyOrdered] = NULL,
		[dblQtyShipped] = pttic_qty_ship,
		[dblPrice]		= pttic_unit_prc,
		[dblTotal]		= (pttic_qty_ship * pttic_unit_prc) 
	FROM tblARInvoice A
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = A.intEntityCustomerId
	INNER JOIN tmp_ptticmstImport INV ON INV.pttic_ivc_no COLLATE Latin1_General_CI_AS = A.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND INV.pttic_cus_no COLLATE Latin1_General_CI_AS = ENT.strEntityNo	
	INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(pttic_itm_no  COLLATE Latin1_General_CI_AS)
	INNER JOIN tblEMEntityLocation LOC ON LOC.intEntityId = A.intEntityCustomerId
	WHERE pttic_qty_ship IS NOT NULL AND pttic_unit_prc IS NOT NULL AND pttic_line_no <> 0 
	
--IMPORT DEBIT MEMO DETAIL	
INSERT INTO tblARInvoiceDetail
(
  [intInvoiceId]
 ,[intSalesAccountId]
 ,[dblQtyOrdered]
 ,[dblQtyShipped]
 ,[dblPrice]
 ,[dblTotal]
)
SELECT 
		[intInvoiceId]		=	A.intInvoiceId,
		[intSalesAccountId]	= GL.inti21Id,
		[dblQtyOrdered]		= NULL,
		[dblQtyShipped]		= 1,
		[dblPrice]			= pttic_computed_total,
		[dblTotal]			= pttic_computed_total 
	FROM tblARInvoice A
	INNER JOIN tblEMEntity ENT on ENT.intEntityId = A.intEntityCustomerId
	INNER JOIN tmp_ptticmstImport INV ON INV.pttic_ivc_no COLLATE Latin1_General_CI_AS = A.strInvoiceOriginId  COLLATE Latin1_General_CI_AS
	AND INV.pttic_cus_no COLLATE Latin1_General_CI_AS = ENT.strEntityNo	
	INNER JOIN [tblGLCOACrossReference] GL ON INV.pttic_gl_acct = GL.[strExternalId]
	INNER JOIN tblEMEntityLocation LOC ON LOC.intEntityId = A.intEntityCustomerId
	WHERE pttic_qty_ship IS NOT NULL AND pttic_unit_prc IS NOT NULL AND pttic_line_no <> 0 AND pttic_type = 'D'
	

SET @totalInsertedInvoiceDetail = @@ROWCOUNT;

SET @totalDetailImported = @totalInsertedInvoiceDetail;

--UPDATE THE intInvoiceId of tblARptticmst
UPDATE A
	SET A.intInvoiceId = B.intInvoiceId
FROM tblARptticmst A
INNER JOIN #tmpInvoice B ON A.intId = B.intBackupId

--UPDATE ITEM TAXES
		DECLARE @InvoiceID int, @return_value int 
		SET @return_value = 0
		SELECT intInvoiceId INTO #tmpivc FROM #tmpInvoice 
			WHILE (EXISTS(SELECT 1 FROM #tmpivc))
			BEGIN
				BEGIN TRY
					SELECT @InvoiceID = intInvoiceId FROM #tmpivc
						EXEC	@return_value = [dbo].[uspARReComputeInvoiceTaxes]
								@InvoiceId = @InvoiceID
				END TRY								
							
				BEGIN CATCH
					PRINT @@ERROR;
					DELETE FROM #tmpInvoice WHERE intInvoiceId = @InvoiceID					
					GOTO CONTINUELOOP;
				END CATCH
				
				CONTINUELOOP:
				PRINT @InvoiceID
				DELETE FROM #tmpivc WHERE intInvoiceId = @InvoiceID
			END 
			
			

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
			INNER JOIN tblARInvoice IVC on IVC.intEntityCustomerId = C.intEntityCustomerId		
			WHERE
				intInvoiceId > @maxInvoiceId

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


