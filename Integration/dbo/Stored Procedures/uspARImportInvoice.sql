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
	@OutputMessage NVARCHAR(4000) = '' OUTPUT
	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================
	
	declare @current_date datetime
	set @current_date = getdate()


	DECLARE  @ZeroDecimal		DECIMAL(18,6)
	SET @ZeroDecimal = 0.000000
	DECLARE @cnt INT = 1
	DECLARE @SQLCMD NVARCHAR(4000)	
			
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
		DECLARE @Message NVARCHAR(MAX)		
		EXEC uspARValidations @UserId, @Sucess OUT, @Message OUT, @StartDate, @EndDate
		
		IF(@Sucess = 0)
		BEGIN
			SET @OutputMessage = @Message
			RETURN
		END
	
		--1 Time synchronization here
		PRINT '1 Time Invoice Synchronization'
		
		DECLARE @maxInvoiceId INT
		
		SELECT @maxInvoiceId = MAX(intInvoiceId) FROM tblARInvoice
		SET @maxInvoiceId = ISNULL(@maxInvoiceId, 0)

		IF EXISTS (SELECT NULL FROM sys.key_constraints WHERE name = 'UK_tblARInvoice_strInvoiceNumber')
			ALTER TABLE tblARInvoice DROP CONSTRAINT [UK_tblARInvoice_strInvoiceNumber]
		
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
				(CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDate]
				(CASE WHEN ISDATE(agivc_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_net_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDueDate]
				(CASE WHEN ISDATE(agivc_orig_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_orig_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmPostDate]
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
					--WHEN agivc_type = 'X' 
					--	THEN 'Transfer'
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
			LEFT JOIN tblARInvoice Inv 
				ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112)
				AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(agivc_slsmn_tot, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = agivc_bill_to_cus COLLATE Latin1_General_CI_AS
			INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = agivc_slsmn_no COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMCurrency Cur ON Cur.strCurrency COLLATE Latin1_General_CI_AS = agivc_currency COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,agivc_terms_code)) COLLATE Latin1_General_CI_AS
			WHERE 
				Inv.strInvoiceNumber IS NULL 
				AND (
						((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
				AND agivc_type NOT IN ('O','X')
				and agivc_bal_due <> 0

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
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDate]
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDueDate]
				(CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmPostDate]
				(select intDefaultCurrencyId from tblSMCompanyPreference),--[intCurrencyId]
				(SELECT intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber  COLLATE Latin1_General_CI_AS = ptivc_loc_no COLLATE Latin1_General_CI_AS),--[intCompanyLocationId]
				ISNULL((SELECT intEntityId FROM tblARSalesperson Salesperson WHERE strSalespersonId COLLATE Latin1_General_CI_AS = ptivc_sold_by COLLATE Latin1_General_CI_AS),Cus.intSalespersonId),--[intEntitySalespersonId],--[intEntitySalespersonId]
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
				Case ptivc_type when 'C' then 
					(select ROUND(ISNULL(ptcrd_amt_used, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) from ptcrdmst 
					where ptcrd_type = 'C' and ptivc_cus_no = ptcrd_cus_no and ptivc_invc_no = ptcrd_invc_no and ptcrd_rev_dt = ptivc_rev_dt and ptcrd_loc_no = ptivc_loc_no
					and ptcrd_amt = ptivc_sold_by_tot)
				else
					ROUND(ISNULL(ptivc_amt_applied, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]())
				end,--[dblPayment]
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
					--WHEN ptivc_type = 'X' 
					--	THEN 'Transfer'
				 END),--[strTransactionType]
				NULL, --ptivc_pay_type [intPaymentMethodId]
				ptivc_comment, --[strComments]
				@ARAccount, --to do [intAccountId]
				1, --"If Invoice exists in the ptivcmst, that means it is posted" -Joe [ysnPosted]
				(CASE WHEN ptivc_bal_due = 0 THEN 1 ELSE 0 END),--"If the ptivc-bal-due equals zero, then it is paid." -Joe [ysnPaid]
				1,
				1,
				@EntityId,
				LTRIM(RTRIM(ptivc_invc_no)) + LTRIM(RTRIM(ptivc_cus_no))		
			FROM ptivcmst
			LEFT JOIN tblARInvoice Inv 
				ON ptivcmst.ptivc_invc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112)
				AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptivc_sold_by_tot, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptivc_cus_no COLLATE Latin1_General_CI_AS
			--INNER JOIN tblARSalesperson Salesperson ON strSalespersonId COLLATE Latin1_General_CI_AS = ptivc_sold_by COLLATE Latin1_General_CI_AS
			LEFT JOIN tblSMTerm Term ON Term.strTermCode COLLATE Latin1_General_CI_AS = CONVERT(NVARCHAR(10),CONVERT(INT,ptivc_terms_code)) COLLATE Latin1_General_CI_AS
            --LEFT JOIN tblSMCurrency Cur ON Cur.strCurrency COLLATE Latin1_General_CI_AS = ptivc_currency COLLATE Latin1_General_CI_AS			
			WHERE 
				Inv.strInvoiceNumber IS NULL 
				AND Cus.ysnActive = 1
				AND (
						((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
				AND ptivc_type NOT IN ('O','X')
				and ptivc_bal_due <> 0
				
			UPDATE  IVC SET ysnPaid = 0 FROM tblARInvoice IVC
			INNER JOIN ptcrdmst CRD ON CRD.ptcrd_invc_no COLLATE SQL_Latin1_General_CP1_CS_AS = IVC.strInvoiceOriginId COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CRD.ptcrd_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE intInvoiceId > @maxInvoiceId AND strTransactionType = 'Credit Memo' AND (CRD.ptcrd_amt - CRD.ptcrd_amt_used) > 0	
			
			--IMPORT PREPAYMENT INVOICES FOR THE PREPAID/REGULAR CREDITS
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
			   ,[strShipToAddress] --just for insertion of identity field from origin in format LTRIM(RTRIM(agivc_ivc_no)) + LTRIM(RTRIM(agivc_bill_to_cus))
			   )
		SELECT
				 LTRIM(RTRIM(ptcrd_invc_no))+'_'+CONVERT(CHAR(3),ptcrd_seq_no),--[strInvoiceOriginId]		
				Cus.intEntityId,--[intEntityCustomerId]		
				(CASE WHEN ISDATE(ptcrd_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptcrd_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDate]
				(CASE WHEN ISDATE(ptcrd_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptcrd_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmDueDate]
				(CASE WHEN ISDATE(ptcrd_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptcrd_rev_dt AS CHAR(12)), 112) ELSE @current_date END),--[dtmPostDate]
				(select intDefaultCurrencyId from tblSMCompanyPreference),--[intCurrencyId]
				LOC.intCompanyLocationId,--[intCompanyLocationId]
				Cus.intSalespersonId,--[intEntitySalespersonId]
				NULL, -- [dtmShipDate]
				NULL, --to do [intShipViaId]
				null, --[strPONumber]
				1,-- [intTermId]
				0,--[dblInvoiceSubtotal]
				0,--[dblShipping]
				0,--[dblTax]
				ROUND(ISNULL(ptcrd_amt, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblInvoiceTotal]
				--CASE WHEN CRD.ptcrd_cred_ind = 'P' AND (SELECT COUNT (ptcrd_amt) FROM ptcrdmst WHERE ptcrd_cus_no = CRD.ptcrd_cus_no AND ptcrd_invc_no = CRD.ptcrd_invc_no AND ptcrd_note = 'xfer PPD to REG')>0 
				--THEN CRD.ptcrd_amt - (SELECT ptcrd_amt FROM ptcrdmst WHERE ptcrd_cus_no = CRD.ptcrd_cus_no AND ptcrd_invc_no = CRD.ptcrd_invc_no AND ptcrd_note = 'xfer PPD to REG') ELSE ptcrd_amt END,--[dblInvoiceTotal]
				ROUND(ISNULL((ptcrd_amt-ptcrd_amt_used), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblAmountDue]
				--CASE WHEN CRD.ptcrd_cred_ind = 'P' AND (SELECT COUNT (ptcrd_amt) FROM ptcrdmst WHERE ptcrd_cus_no = CRD.ptcrd_cus_no AND ptcrd_invc_no = CRD.ptcrd_invc_no AND ptcrd_note = 'xfer PPD to REG')>0 
				--THEN CRD.ptcrd_amt - (SELECT ptcrd_amt FROM ptcrdmst WHERE ptcrd_cus_no = CRD.ptcrd_cus_no AND ptcrd_invc_no = CRD.ptcrd_invc_no AND ptcrd_note = 'xfer PPD to REG') ELSE ptcrd_amt_used END,--[dblPayment]			
				ROUND(ISNULL(ptcrd_amt, @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()),--[dblPayment]
				'Customer Prepayment',--[strTransactionType]
				PM.intPaymentMethodID, --ptivc_pay_type [intPaymentMethodId]
				ptcrd_note, --[strComments]
				[dbo].[fnARGetInvoiceTypeAccount]('Customer Prepayment', LOC.intCompanyLocationId), --to do [intAccountId]
				1, --"If Invoice exists in the ptivcmst, that means it is posted" -Joe [ysnPosted]
				(CASE WHEN (ptcrd_amt-ptcrd_amt_used) = 0 THEN 1 ELSE 0 END),--"If the ptivc-bal-due equals zero, then it is paid." -Joe [ysnPaid]
				1,
				1,
				@EntityId,
				LTRIM(RTRIM(ptcrd_invc_no COLLATE Latin1_General_CI_AS))+LTRIM(RTRIM(ptcrd_cus_no COLLATE Latin1_General_CI_AS))
				+LTRIM(RTRIM(CONVERT(CHAR(10),ptcrd_rev_dt)))+LTRIM(RTRIM(CONVERT(CHAR(3),ptcrd_seq_no)))			
			FROM ptcrdmst CRD
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptcrd_cus_no COLLATE Latin1_General_CI_AS
			LEFT JOIN tblARInvoice Inv 
				ON LTRIM(RTRIM(CRD.ptcrd_invc_no))+'_'+CONVERT(CHAR(3),CRD.ptcrd_seq_no) COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(CRD.ptcrd_rev_dt AS CHAR(12)), 112)
				--AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptcrd_amt, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1 AND Inv.strTransactionType = 'Customer Prepayment'
			INNER JOIN tblSMCompanyLocation LOC ON strLocationNumber  COLLATE Latin1_General_CI_AS = CRD.ptcrd_loc_no COLLATE Latin1_General_CI_AS
			LEFT OUTER JOIN [tblSMPaymentMethod] PM	ON CRD.ptcrd_pay_type COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL 
			AND Cus.ysnActive = 1 
			AND  CRD.ptcrd_type IN ( 'P','U') --AND ISNULL(CRD.ptcrd_note,'') <> 'xfer PPD to REG'
			AND ROUND(ISNULL((ptcrd_amt-ptcrd_amt_used), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) <> 0 --[dblAmountDue] NOT EQUAL TO ZERO


		-- UPDATE PREPAYMENT INVOICE TOTALS FOR THE PREPAID/REGULAR CREDITS - XREF FROM PPD TO REG
				DECLARE @ptcrd_cus_no  AS VARCHAR (10), @ptcrd_invc_no   AS VARCHAR (6), @ptcrd_amt AS NUMERIC (18,2), @ptcrd_loc_no as CHAR(3) , @ptcrd_rev_dt AS INT
				DECLARE ppd_cursor CURSOR
				FOR
					SELECT  ptcrd_cus_no, ptcrd_invc_no, ptcrd_amt  FROM ptcrdmst WHERE ptcrd_cus_no = ptcrd_cus_no AND ptcrd_invc_no = ptcrd_invc_no AND ptcrd_note = 'xfer PPD to REG'
				OPEN ppd_cursor
				FETCH NEXT
				FROM ppd_cursor
				INTO  @ptcrd_cus_no, @ptcrd_invc_no, @ptcrd_amt
				WHILE @@FETCH_STATUS = 0
				BEGIN
					UPDATE I SET I.dblInvoiceTotal = I.dblInvoiceTotal - @ptcrd_amt,I.dblPayment = I.dblPayment - @ptcrd_amt  FROM tblARInvoice I
					JOIN (
							SELECT TOP (1) I.intInvoiceId--,I.dblInvoiceTotal,*--,c.ptcrd_cus_no,c.ptcrd_invc_no, I.strComments
							FROM ptcrdmst c
							JOIN tblARCustomer cr on cr.strCustomerNumber = c.ptcrd_cus_no collate SQL_Latin1_General_CP1_CS_AS
							JOIN tblARInvoice I on cr.intEntityId = I.intEntityCustomerId and I.strInvoiceOriginId = LTRIM(RTRIM(c.ptcrd_invc_no))+'_'+CONVERT(CHAR(3),c.ptcrd_seq_no) collate SQL_Latin1_General_CP1_CS_AS
							WHERE c.ptcrd_cus_no = @ptcrd_cus_no  AND c.ptcrd_invc_no = @ptcrd_invc_no AND 	c.ptcrd_note <> 'xfer PPD to REG' AND I.strComments <> 'xfer PPD to REG'
							ORDER BY I.dtmDate desc ) AS PPDI 
							on I.intInvoiceId = PPDI.intInvoiceId			
				FETCH NEXT
				FROM ppd_cursor
				INTO @ptcrd_cus_no, @ptcrd_invc_no, @ptcrd_amt			
				END	
				CLOSE ppd_cursor
				DEALLOCATE ppd_cursor
			
		 End

		IF NOT EXISTS (SELECT NULL FROM sys.key_constraints WHERE name = 'UK_tblARInvoice_strInvoiceNumber')
			ALTER TABLE tblARInvoice ADD CONSTRAINT [UK_tblARInvoice_strInvoiceNumber] UNIQUE ([strInvoiceNumber])
						
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

			--EXEC [dbo].[uspARImportAGTax] 
			
			--IMPORT SET TAX DETAILS 			
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
				agstm_set_amt/agstm_un,
				agstm_set_amt
			FROM agstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'SET'-- COLLATE Latin1_General_CI_AS = RTRIM(agstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL AND agstm_set_amt <> 0

			--IMPORT FET TAX DETAILS 			
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
				agstm_fet_amt/agstm_un,
				agstm_fet_amt
			FROM agstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'FET'-- COLLATE Latin1_General_CI_AS = RTRIM(agstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL AND agstm_fet_amt <> 0

			--IMPORT SST TAX DETAILS 			
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
				agstm_sst_amt/agstm_un,
				agstm_sst_amt
			FROM agstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'SST'-- COLLATE Latin1_General_CI_AS = RTRIM(agstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL AND agstm_sst_amt <> 0

			--IMPORT LOCALE TAX DETAILS 			

			WHILE @cnt < 7
					BEGIN
					   SET @SQLCMD = ' INSERT INTO [dbo].[tblARInvoiceDetail]
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
						agstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt/agstm_un,
						agstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt
					FROM agstmmst
					INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(agstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(agstm_bill_to_cus COLLATE Latin1_General_CI_AS))
					INNER JOIN tblICItem ITM ON ITM.strItemNo = ''LC'+CAST(@cnt AS NVARCHAR)+'-''+agstm_state COLLATE Latin1_General_CI_AS
					WHERE agstm_un IS NOT NULL AND agstm_un_prc IS NOT NULL AND agstm_sls IS NOT NULL AND agstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt <> 0'			

					   EXEC (@SQLCMD)

					   SET @cnt = @cnt + 1;
					END
			
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
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_un * -1 ELSE ptstm_un END,
				ptstm_un_prc,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_net * -1 ELSE ptstm_net END 
			FROM ptstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE Latin1_General_CI_AS = RTRIM(ptstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL	

			--EXEC [dbo].[uspARImportPTTax] 

			--IMPORT SET TAX DETAILS 			
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
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_un * -1 ELSE ptstm_un END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN (ptstm_set_amt/ptstm_un) * -1 ELSE (ptstm_set_amt/ptstm_un) END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_set_amt * -1 ELSE ptstm_set_amt END 
			FROM ptstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'SET'-- COLLATE Latin1_General_CI_AS = RTRIM(ptstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL AND ptstm_set_amt <> 0

			--IMPORT FET TAX DETAILS 			
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
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_un * -1 ELSE ptstm_un END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN (ptstm_fet_amt/ptstm_un) * -1 ELSE (ptstm_fet_amt/ptstm_un) END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_fet_amt * -1 ELSE ptstm_fet_amt END 
			FROM ptstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'FET'-- COLLATE Latin1_General_CI_AS = RTRIM(ptstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL AND ptstm_fet_amt <> 0

			--IMPORT SST TAX DETAILS 			
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
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_un * -1 ELSE ptstm_un END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN (ptstm_sst_amt/ptstm_un) * -1 ELSE (ptstm_sst_amt/ptstm_un) END,
				CASE WHEN INV.strTransactionType IN ('Credit Memo', 'Cash Refund') THEN ptstm_sst_amt * -1 ELSE ptstm_sst_amt END 
			FROM ptstmmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
			INNER JOIN tblICItem ITM ON ITM.strItemNo = 'SST'-- COLLATE Latin1_General_CI_AS = RTRIM(ptstm_itm_no  COLLATE Latin1_General_CI_AS)
			WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL AND ptstm_sst_amt <> 0

			--IMPORT LOCALE TAX DETAILS 			

			WHILE @cnt < 13
					BEGIN
					   SET @SQLCMD = ' INSERT INTO [dbo].[tblARInvoiceDetail]
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
						CASE WHEN INV.strTransactionType IN (''Credit Memo'', ''Cash Refund'') THEN ptstm_un * -1 ELSE ptstm_un END,
						CASE WHEN INV.strTransactionType IN (''Credit Memo'', ''Cash Refund'') THEN (ptstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt/ptstm_un) * -1 ELSE (ptstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt/ptstm_un) END,
						CASE WHEN INV.strTransactionType IN (''Credit Memo'', ''Cash Refund'') THEN ptstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt * -1 ELSE ptstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt END 
					FROM ptstmmst
					INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptstm_ivc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptstm_bill_to_cus COLLATE Latin1_General_CI_AS))
					INNER JOIN tblICItem ITM ON ITM.strItemNo = ''LC'+CAST(@cnt AS NVARCHAR)+'-''+SUBSTRING (ptstm_tax_key ,11 , 2 ) COLLATE Latin1_General_CI_AS
					WHERE ptstm_un IS NOT NULL AND ptstm_un_prc IS NOT NULL AND ptstm_net IS NOT NULL AND ptstm_lc'+CAST(@cnt AS NVARCHAR)+'_amt <> 0'			

					   EXEC (@SQLCMD)

					   SET @cnt = @cnt + 1;
					END	
					
			--IMPORT DEBIT MEMO DETAILS	
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
				ptivc_comment,
				NULL,
				1,
				ptivc_sold_by_tot,
				ptivc_sold_by_tot
			FROM ptivcmst
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptivc_invc_no COLLATE Latin1_General_CI_AS)) + LTRIM(RTRIM(ptivc_cus_no COLLATE Latin1_General_CI_AS))
			WHERE  ptivc_type = 'D'

			--IMPORT PREPAID/REGULAR CREDIT DETAILS	
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
				ptcrd_note,
				NULL,
				1,
				INV.dblInvoiceTotal, 
				INV.dblInvoiceTotal 
			FROM ptcrdmst 
			INNER JOIN tblARInvoice INV ON INV.strShipToAddress COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ptcrd_invc_no COLLATE Latin1_General_CI_AS)) 
			+ LTRIM(RTRIM(ptcrd_cus_no COLLATE Latin1_General_CI_AS))+LTRIM(RTRIM(CONVERT(CHAR(10),ptcrd_rev_dt)))+LTRIM(RTRIM(CONVERT(CHAR(3),ptcrd_seq_no)))			
			WHERE ptcrd_type  in ('P','U') 
									
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
				
		--UPDATE Tax Total		
			UPDATE tblARInvoice  SET tblARInvoice.dblTax = Tax
			FROM (SELECT ID.intInvoiceId,SUM(ID.dblTotal) as Tax FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			where I.intInvoiceId > @maxInvoiceId AND ID.dblPrice = 0 
			GROUP BY ID.intInvoiceId) GRP WHERE GRP.intInvoiceId = tblARInvoice.intInvoiceId				

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1 AND @Posted = 1)
	BEGIN
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		 BEGIN
		 --Check first on agivcmst
			SELECT @Total = COUNT(agivc_ivc_no)  
				FROM agivcmst
			LEFT JOIN tblARInvoice ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND tblARInvoice.[dtmDate] = CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112)
				AND tblARInvoice.[dblInvoiceTotal] = ROUND(ISNULL(agivc_slsmn_tot, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(tblARInvoice.[ysnImportedFromOrigin],0) = 1 AND ISNULL(tblARInvoice.[ysnImportedAsPosted],0) = 1
			WHERE 
				tblARInvoice.strInvoiceOriginId IS NULL 
				AND agivc_type NOT IN ('O','X')
				AND (
						((CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
				and agivc_bal_due <> 0
				
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
		--Check first on ptivcmst
			SELECT @Total = COUNT(ptivc_invc_no)  
				FROM ptivcmst
			LEFT JOIN tblARInvoice Inv 
				ON ptivcmst.ptivc_invc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112)
				AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptivc_sold_by_tot, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptivc_cus_no COLLATE Latin1_General_CI_AS
			WHERE 
				Inv.strInvoiceNumber IS NULL 
				AND Cus.ysnActive = 1
				AND (
						((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
				AND ptivc_type NOT IN ('O','X')
				and ptivc_bal_due <> 0
				
			--Add Count of Prepayment	
			SELECT  @Total  +=  COUNT(1) 
			FROM ptcrdmst CRD
				INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptcrd_cus_no COLLATE Latin1_General_CI_AS
				LEFT JOIN tblARInvoice Inv 
					ON LTRIM(RTRIM(CRD.ptcrd_invc_no))+'_'+CONVERT(CHAR(3),CRD.ptcrd_seq_no) COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
					AND Inv.[dtmDate] = CONVERT(DATE, CAST(CRD.ptcrd_rev_dt AS CHAR(12)), 112)
					--AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptcrd_amt, 0), [dbo].[fnARGetDefaultDecimal]())
					AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1 AND Inv.strTransactionType = 'Customer Prepayment'
				INNER JOIN tblSMCompanyLocation LOC ON strLocationNumber  COLLATE Latin1_General_CI_AS = CRD.ptcrd_loc_no COLLATE Latin1_General_CI_AS
				LEFT OUTER JOIN [tblSMPaymentMethod] PM	ON CRD.ptcrd_pay_type COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
			WHERE Inv.strInvoiceNumber IS NULL 
				AND Cus.ysnActive = 1 
				AND  CRD.ptcrd_type IN ( 'P','U') --AND ISNULL(CRD.ptcrd_note,'') <> 'xfer PPD to REG'
				AND ROUND(ISNULL((ptcrd_amt-ptcrd_amt_used), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) <> 0 --[dblAmountDue] NOT EQUAL TO ZERO			
		 END		 
		
	END

	IF(@Checking = 1 AND @Posted = 0)
	BEGIN
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agordmst')
		 BEGIN
		 --Check first on agivcmst
			SELECT @Total = COUNT(agord_ivc_no)  
				FROM agordmst
			LEFT JOIN tblARInvoice ON agordmst.agord_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND tblARInvoice.[dtmDate] = CONVERT(DATE, CAST(agord_ord_rev_dt AS CHAR(12)), 112)
				AND tblARInvoice.[dblInvoiceTotal] = ROUND(ISNULL(agord_order_total, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(tblARInvoice.[ysnImportedFromOrigin],0) = 1 AND ISNULL(tblARInvoice.[ysnImportedAsPosted],0) = 0
			WHERE 
				tblARInvoice.strInvoiceOriginId IS NULL 
				AND agord_type NOT IN ('O','X')
				AND (
						((CASE WHEN ISDATE(agord_ord_rev_dt) = 1 THEN CONVERT(DATE, CAST(agord_ord_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
		 END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		BEGIN	
			SELECT  COUNT(pttic_ivc_no)  
				FROM ptticmst
			LEFT JOIN tblARInvoice Inv 
				ON ptticmst.pttic_ivc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
				AND Inv.[dtmDate] = CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112)
				AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(pttic_actual_total, 0), [dbo].[fnARGetDefaultDecimal]())
				AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 0
			INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = pttic_bill_to_cus_no COLLATE Latin1_General_CI_AS
			WHERE 
			Inv.strInvoiceNumber IS NULL 
				AND Cus.ysnActive = 1
				AND (
						((CASE WHEN ISDATE(pttic_rev_dt) = 1 THEN CONVERT(DATE, CAST(pttic_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
						OR
						((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
					)
				AND pttic_type NOT IN ('O','X')

			--Check first on ptivcmst	
			-- SELECT @Total = COUNT(ptivc_invc_no)  
			-- 	FROM ptivcmst
			-- LEFT JOIN tblARInvoice Inv 
			-- 	ON ptivcmst.ptivc_invc_no COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			-- 	AND Inv.[dtmDate] = CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112)
			-- 	AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptivc_sold_by_tot, 0), [dbo].[fnARGetDefaultDecimal]())
			-- 	AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 0
			-- INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptivc_cus_no COLLATE Latin1_General_CI_AS
			-- WHERE 
			-- Inv.strInvoiceNumber IS NULL 
			-- 	AND Cus.ysnActive = 1
			-- 	AND (
			-- 			((CASE WHEN ISDATE(ptivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(ptivc_rev_dt AS CHAR(12)), 112) ELSE @current_date END) BETWEEN @StartDate AND @EndDate)
			-- 			OR
			-- 			((@StartDate IS NULL OR ISDATE(@StartDate) = 0) OR (@EndDate IS NULL OR ISDATE(@EndDate) = 0))
			-- 		)
			-- 	AND ptivc_type NOT IN ('O','X')
			-- 	and ptivc_bal_due <> 0
			--Add Count of Prepayment
			-- SELECT  @Total  +=  COUNT(1) 
			-- FROM ptcrdmst CRD
			-- 	INNER JOIN tblARCustomer Cus ON  strCustomerNumber COLLATE Latin1_General_CI_AS = ptcrd_cus_no COLLATE Latin1_General_CI_AS
			-- 	LEFT JOIN tblARInvoice Inv 
			-- 		ON LTRIM(RTRIM(CRD.ptcrd_invc_no))+'_'+CONVERT(CHAR(3),CRD.ptcrd_seq_no) COLLATE Latin1_General_CI_AS = Inv.strInvoiceOriginId COLLATE Latin1_General_CI_AS
			-- 		AND Inv.[dtmDate] = CONVERT(DATE, CAST(CRD.ptcrd_rev_dt AS CHAR(12)), 112)
			-- 		--AND Inv.[dblInvoiceTotal] = ROUND(ISNULL(ptcrd_amt, 0), [dbo].[fnARGetDefaultDecimal]())
			-- 		AND ISNULL(Inv.[ysnImportedFromOrigin],0) = 1 AND ISNULL(Inv.[ysnImportedAsPosted],0) = 1 AND Inv.strTransactionType = 'Customer Prepayment'
			-- 	INNER JOIN tblSMCompanyLocation LOC ON strLocationNumber  COLLATE Latin1_General_CI_AS = CRD.ptcrd_loc_no COLLATE Latin1_General_CI_AS
			-- 	LEFT OUTER JOIN [tblSMPaymentMethod] PM	ON CRD.ptcrd_pay_type COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
			-- WHERE Inv.strInvoiceNumber IS NULL 
			-- 	AND Cus.ysnActive = 1 
			-- 	AND  CRD.ptcrd_type IN ( 'P','U') --AND ISNULL(CRD.ptcrd_note,'') <> 'xfer PPD to REG'
			-- 	AND ROUND(ISNULL((ptcrd_amt-ptcrd_amt_used), @ZeroDecimal), [dbo].[fnARGetDefaultDecimal]()) <> 0 --[dblAmountDue] NOT EQUAL TO ZERO	
		 END		 
		
	END
		
END	



