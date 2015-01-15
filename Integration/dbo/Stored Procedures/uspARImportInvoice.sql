IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportInvoice')
	DROP PROCEDURE uspARImportInvoice
GO

CREATE PROCEDURE uspARImportInvoice
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL

	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================
	
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
		BEGIN
			SET @StartDate = NULL
			SET @EndDate = NULL
		END			
	
	DECLARE @EntityId int
	SET @EntityId = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @UserId),@UserId)
	
	IF(@Checking = 0) 
	BEGIN
		
		DECLARE @Sucess BIT
		DECLARE @Message NVARCHAR(100)
		EXEC uspARValidations @Sucess OUT, @Message OUT
		
		IF(@Sucess = 0)
		BEGIN
			RAISERROR(@Message,16,1)
			RETURN
		END
	
		--1 Time synchronization here
		PRINT '1 Time Invoice Synchronization'
		
		DECLARE @maxInvoiceId INT
		
		SELECT @maxInvoiceId = MAX(intInvoiceId) FROM tblARInvoice
		
			--================================================
			--     Insert into tblARInvoice
			--================================================
			INSERT INTO [dbo].[tblARInvoice]
			   ([strInvoiceOriginId]
			   ,[intCustomerId]
			   ,[dtmDate]
			   ,[dtmDueDate]
			   ,[dtmPostDate]
			   ,[intCurrencyId]
			   ,[intCompanyLocationId]
			   ,[intSalespersonId]
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
			   ,[intEntityId]
			   ,[strShipToAddress] --just for insertion of identity field from origin in format LTRIM(RTRIM(agivc_ivc_no)) + LTRIM(RTRIM(agivc_bill_to_cus))
			   )
			SELECT
				agivc_ivc_no,--[strInvoiceOriginId]		
				Cus.intCustomerId,--[intCustomerId]		
				(CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDate]
				(CASE WHEN ISDATE(agivc_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_net_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDueDate]
				(CASE WHEN ISDATE(agivc_orig_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_orig_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmPostDate]
				ISNULL(Cur.intCurrencyID,0),--[intCurrencyId]
				(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = agivc_loc_no COLLATE Latin1_General_CI_AS),--[intCompanyLocationId]
				Salesperson.intSalespersonId,--[intSalespersonId]
				NULL, -- [dtmShipDate]
				0, --to do [intShipViaId]
				agivc_po_no, --[strPONumber]
				ISNULL(Term.intTermID,0),-- [intTermId]
				NULL,--[dblInvoiceSubtotal]
				NULL,--[dblShipping]
				NULL,--[dblTax]
				agivc_slsmn_tot,--[dblInvoiceTotal]
				agivc_disc_amt,--[dblDiscount]
				agivc_bal_due,--[dblAmountDue]
				agivc_amt_paid,--[dblPayment]
				(CASE 
					WHEN agivc_type = 'I' 
						THEN 'Invoice' 
					WHEN agivc_type = 'C' 
						THEN 'Credit' 
					WHEN agivc_type = 'D' 
						THEN 'Debit' 
					WHEN agivc_type = 'S' 
						THEN 'Cash Sale'
					WHEN agivc_type = 'R' 
						THEN 'Cash Refund' 
					WHEN agivc_type = 'X' 
						THEN 'Transfer'
				 END),--[strTransactionType]
				0, --agivc_pay_type [intPaymentMethodId]
				agivc_comment, --[strComments]
				0, --to do [intAccountId]
				1, --"If Invoice exists in the agivcmst, that means it is posted" -Joe [ysnPosted]
				(CASE WHEN agivc_bal_due = 0 THEN 1 ELSE 0 END),--"If the agivc-bal-due equals zero, then it is paid." -Joe [ysnPaid]
				@EntityId,
				LTRIM(RTRIM(agivc_ivc_no)) + LTRIM(RTRIM(agivc_bill_to_cus))		
			FROM agivcmst
			LEFT JOIN tblARInvoice Inv ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = agivc_bill_to_cus COLLATE Latin1_General_CI_AS
			INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = agivc_slsmn_no COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMCurrency Cur ON Cur.strCurrency COLLATE Latin1_General_CI_AS = agivc_currency COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,agivc_terms_code)) COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
			AND (
					((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			    )
			   
			
			
			--================================================
			--     Insert into tblARInvoiceDetail
			--================================================
			INSERT INTO [dbo].[tblARInvoiceDetail]
			   ([intInvoiceId]
			   ,[intItemId]
			   ,[strItemDescription]
			   ,[dblQtyOrdered]
			   ,[dblQtyShipped]
			   ,[dblPrice]
			   ,[dblTotal])		
			SELECT 
				INV.intInvoiceId,
				NULL,
				agstm_itm_no,
				NULL,
				agstm_un,
				agstm_un_prc,
				agstm_sls 
			FROM agstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL	
				
			--update strShipToAddress to null 	   
			UPDATE tblARInvoice SET strShipToAddress = NULL WHERE intInvoiceId > @maxInvoiceId

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1) 
	BEGIN
		--Check first on agivcmst
		SELECT @Total = COUNT(agivc_ivc_no)  
			FROM agivcmst
		LEFT JOIN tblARInvoice ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceOriginId COLLATE Latin1_General_CI_AS
		WHERE tblARInvoice.strInvoiceOriginId IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
		AND (
				((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
				OR
				((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			)
		
	END
		
END	



