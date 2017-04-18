IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportInvoice')
	DROP PROCEDURE uspARImportInvoice
GO

CREATE PROCEDURE uspARImportInvoice
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@Posted INT = 0,
	@LogKey NVARCHAR(100) = NULL OUTPUT
	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================

	DECLARE  @ZeroDecimal		DECIMAL(18,6)
	SET @ZeroDecimal = 0.000000	
	
	IF (@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0)
		BEGIN
			SET @StartDate = NULL
			SET @EndDate = NULL
		END			
	
	DECLARE @EntityId int
	SET @EntityId = ISNULL((SELECT TOP 1 intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId),@UserId)
	
	DECLARE @ARAccount VARCHAR(250)
	--AR Account
	SET @ARAccount = (SELECT TOP 1 [intARAccountId] FROM tblARCompanyPreference)

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	
	
	IF(@Checking = 0 and @Posted = 0)
	BEGIN
	    DECLARE @totalDetailImported int
		IF @ysnAG		= 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agordmst')	
		BEGIN
			DECLARE @totalagordmst int
			EXEC [uspARImportInvoiceBackupAGORDMST] @StartDate ,@EndDate ,@totalagordmst OUTPUT			
			EXEC [uspARImportInvoiceFromAGORDMST] @UserId ,@StartDate ,@EndDate ,@Total OUTPUT ,@totalDetailImported OUTPUT 			
		END
		
		IF @ysnPT		= 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptticmst')
		BEGIN
			DECLARE @totalptticmst int
			EXEC [uspARImportInvoiceBackupPTTICMST] @StartDate ,@EndDate ,@totalptticmst OUTPUT
			EXEC [uspARImportInvoiceFromPTTICMST] @UserId ,@StartDate ,@EndDate ,@Total OUTPUT ,@totalDetailImported OUTPUT 			
		END
		
	END
	
	
	IF(@Checking = 0 and @Posted = 1)
	BEGIN
		
		DECLARE @Sucess BIT
		DECLARE @Message NVARCHAR(100)		
		EXEC uspARValidations @UserId, @Sucess OUT, @Message OUT, @StartDate, @EndDate, @LogKey OUT
		
		IF(@Sucess = 0)
		BEGIN
			RAISERROR(@Message,16,1)
			RETURN
		END
	
		--1 Time synchronization here
		PRINT '1 Time Invoice Synchronization'
		
		DECLARE @maxInvoiceId INT
		
		SELECT @maxInvoiceId = MAX(intInvoiceId) FROM tblARInvoice
		SET @maxInvoiceId = ISNULL(@maxInvoiceId, 0)
		
			--================================================
			--     Insert into tblARInvoice --AG INVOICES--
			--================================================			
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 Begin
			INSERT INTO [dbo].[tblARInvoice]
			   ([strInvoiceOriginId]
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
			   ,[dblInterest]
			   ,[strTransactionType]
			   ,[intPaymentMethodId]
			   ,[strComments]
			   ,[intAccountId]
			   ,[ysnPosted]
			   ,[ysnPaid]
			   ,[ysnImportedFromOrigin]
			   ,[ysnImportedAsPosted]
			   ,[intEntityId]
			   ,[strShipToAddress] --just for insertion of identity field from origin in format LTRIM(RTRIM(agivc_ivc_no)) + LTRIM(RTRIM(agivc_bill_to_cus))
			   )
			SELECT
				agivc_ivc_no,--[strInvoiceOriginId]		
				Cus.intEntityId,--[intEntityCustomerId]		
				(CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDate]
				(CASE WHEN ISDATE(agivc_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_net_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDueDate]
				(CASE WHEN ISDATE(agivc_orig_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_orig_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmPostDate]
				ISNULL(Cur.intCurrencyID,0),--[intCurrencyId]
				(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = agivc_loc_no COLLATE Latin1_General_CI_AS),--[intCompanyLocationId]
				Salesperson.intEntityId,--[intEntitySalespersonId]
				NULL, -- [dtmShipDate]
				NULL, --to do [intShipViaId]
				agivc_po_no, --[strPONumber]
				ISNULL(Term.intTermID,1),-- [intTermId]
				0,--[dblInvoiceSubtotal]
				0,--[dblShipping]
				0,--[dblTax]
				ROUND(ISNULL(agivc_slsmn_tot, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblInvoiceTotal]
				ROUND(ISNULL(agivc_disc_amt, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblDiscount]
				ROUND(ISNULL(agivc_bal_due, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblAmountDue]
				ROUND(ISNULL(agivc_amt_paid, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblPayment]
				ROUND(ISNULL(agivc_srvchr_amt, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblInterest]
				(CASE 
					WHEN agivc_type = 'I' 
						THEN 'Invoice' 
					WHEN agivc_type = 'C' 
						THEN 'Credit Memo' 
					WHEN agivc_type = 'D' 
						THEN 'Debit Memo' 
					WHEN agivc_type = 'S' 
						THEN 'Cash'
					WHEN agivc_type = 'R' 
						THEN 'Cash Refund' 
					WHEN agivc_type = 'X' 
						THEN 'Transfer'
				 END),--[strTransactionType]
				NULL, --agivc_pay_type [intPaymentMethodId]
				agivc_comment, --[strComments]
				@ARAccount, --to do [intAccountId]
				1, --"If Invoice exists in the agivcmst, that means it is posted" -Joe [ysnPosted]
				(CASE WHEN agivc_bal_due = 0 THEN 1 ELSE 0 END),--"If the agivc-bal-due equals zero, then it is paid." -Joe [ysnPaid]
				1,
				1,
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

			UPDATE  IVC SET ysnPaid = 0 FROM tblARInvoice IVC
			INNER JOIN agcrdmst CRD ON CRD.agcrd_ref_no COLLATE SQL_Latin1_General_CP1_CS_AS = IVC.strInvoiceOriginId COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CRD.agcrd_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE intInvoiceId > @maxInvoiceId AND strTransactionType = 'Credit Memo' AND (CRD.agcrd_amt - CRD.agcrd_amt_used) > 0				

		 End 
			--================================================
			--     Insert into tblARInvoice --PT INVOICES--
			--================================================	
					
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 Begin
			INSERT INTO [dbo].[tblARInvoice]
			   ([strInvoiceOriginId]
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
			   ,[dblInterest]
			   ,[strTransactionType]
			   ,[intPaymentMethodId]
			   ,[strComments]
			   ,[intAccountId]
			   ,[ysnPosted]
			   ,[ysnPaid]
			   ,[ysnImportedFromOrigin]
			   ,[ysnImportedAsPosted]
			   ,[intEntityId]
			   ,[strShipToAddress] --just for insertion of identity field from origin in format LTRIM(RTRIM(agivc_ivc_no)) + LTRIM(RTRIM(agivc_bill_to_cus))
			   )
			SELECT
				ptivc_invc_no,--[strInvoiceOriginId]		
				Cus.intEntityId,--[intEntityCustomerId]		
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDate]
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmDueDate]
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),--[dtmPostDate]
				(select intDefaultCurrencyId from tblSMCompanyPreference),--[intCurrencyId]
				(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = ptivc_loc_no COLLATE Latin1_General_CI_AS),--[intCompanyLocationId]
				Salesperson.intEntityId,--[intEntitySalespersonId]
				NULL, -- [dtmShipDate]
				NULL, --to do [intShipViaId]
				ptivc_po_no, --[strPONumber]
				ISNULL(Term.intTermID,1),-- [intTermId]
				0,--[dblInvoiceSubtotal]
				0,--[dblShipping]
				0,--[dblTax]
				ROUND(ISNULL(ptivc_sold_by_tot, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblInvoiceTotal]
				ROUND(ISNULL(ptivc_disc_amt, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblDiscount]
				ROUND(ISNULL(ptivc_bal_due, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblAmountDue]
				ROUND(ISNULL(ptivc_amt_applied, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblPayment]
				ROUND(ISNULL(ptivc_serv_chg, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblInterest]				
				(CASE 
					WHEN ptivc_type = 'I' 
						THEN 'Invoice' 
					WHEN ptivc_type = 'C' 
						THEN 'Credit Memo' 
					WHEN ptivc_type = 'D' 
						THEN 'Debit Memo' 
					WHEN ptivc_type = 'S' 
						THEN 'Cash'
					WHEN ptivc_type = 'R' 
						THEN 'Cash Refund' 
					WHEN ptivc_type = 'X' 
						THEN 'Transfer'
				 END),--[strTransactionType]
				NULL, --ptivc_pay_type [intPaymentMethodId]
				ptivc_comment, --[strComments]
				@ARAccount, --to do [intAccountId]
				1, --"If Invoice exists in the ptivcmst, that means it is posted" -Joe [ysnPosted]
				(CASE WHEN ptivc_bal_due = 0 THEN 1 ELSE 0 END),--"If the ptivc-bal-due equals zero, then it is paid." -Joe [ysnPaid]
				1,
				1,
				@EntityId,
				LTRIM(RTRIM(ptivc_invc_no)) + LTRIM(RTRIM(ptivc_sold_to))		
			FROM ptivcmst
			LEFT JOIN tblARInvoice Inv ON ptivcmst.ptivc_invc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptivc_sold_to COLLATE Latin1_General_CI_AS
			INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = ptivc_sold_by COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,ptivc_terms_code)) COLLATE Latin1_General_CI_AS
            --LEFT JOIN tblSMCurrency Cur ON Cur.strCurrency COLLATE Latin1_General_CI_AS = ptivc_currency COLLATE Latin1_General_CI_AS			
			WHERE Inv.strInvoiceNumber IS NULL AND ptivcmst.ptivc_invc_no = UPPER(ptivcmst.ptivc_invc_no) COLLATE Latin1_General_CS_AS
			AND (
					((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			    )
				
			UPDATE  IVC SET ysnPaid = 0 FROM tblARInvoice IVC
			INNER JOIN ptcrdmst CRD ON CRD.ptcrd_invc_no COLLATE SQL_Latin1_General_CP1_CS_AS = IVC.strInvoiceOriginId COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CRD.ptcrd_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE intInvoiceId > @maxInvoiceId AND strTransactionType = 'Credit Memo' AND (CRD.ptcrd_amt - CRD.ptcrd_amt_used) > 0				
		 End

			
			--==========================================================
			--     Insert into tblARInvoiceDetail - AG INVOICE DETAILS
			--==========================================================
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 Begin
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
				ITM.intItemId,
				ITM.strDescription,
				NULL,
				agstm_un,
				agstm_un_prc,
				agstm_sls								
			FROM agstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(agstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL	

			EXEC [dbo].[uspARImportAGTax] 
		 end 

			--==========================================================
			--     Insert into tblARInvoiceDetail - PT INVOICE DETAILS
			--==========================================================
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 Begin
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
				ITM.intItemId,
				ITM.strDescription,
				NULL,
				ptstm_un,
				ptstm_un_prc,
				ptstm_net
			FROM ptstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(ptstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL	

			EXEC [dbo].[uspARImportPTTax] 

		 end

		 			
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

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1)
	BEGIN
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
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

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
		--Check first on ptivcmst
			SELECT @Total = COUNT(ptivc_invc_no)  
				FROM ptivcmst
			LEFT JOIN tblARInvoice ON ptivcmst.ptivc_invc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			WHERE tblARInvoice.strInvoiceOriginId IS NULL AND ptivcmst.ptivc_invc_no = UPPER(ptivcmst.ptivc_invc_no) COLLATE Latin1_General_CS_AS
			AND (
					((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
					OR
					((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
				)

			IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptticmst')
				BEGIN
					SELECT @Total = ISNULL(@Total, 0) + COUNT(pttic_ivc_no)
					FROM ptticmst
					WHERE (
							((CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END) BETWEEN @StartDate AND @EndDate)
							OR
							((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
						  )
				END
		 END		 
		
	END
		
END	



