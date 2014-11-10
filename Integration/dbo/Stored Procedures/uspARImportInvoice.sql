IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportInvoice')
	DROP PROCEDURE uspARImportInvoice
GO

CREATE PROCEDURE uspARImportInvoice
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================
	IF(@Checking = 0) 
	BEGIN
	
		--1 Time synchronization here
		PRINT '1 Time Accounts Synchronization'

		DECLARE @originInvoiceNumber	CHAR(8)
		DECLARE @originCustomerNumber	CHAR(10)
		--Variables for Invoice
		DECLARE @strInvoiceNumber		NVARCHAR(25)
		DECLARE @intCustomerId			INT
		DECLARE @dtmDate				DATETIME
		DECLARE @dtmDueDate				DATETIME
		DECLARE @intCurrencyId			INT
		DECLARE @intCompanyLocationId	INT
		DECLARE @intSalespersonId		INT
		DECLARE @dtmShipDate			DATETIME
		DECLARE @intShipViaId			INT
		DECLARE @strPONumber			NVARCHAR(25)
		DECLARE @intTermId				INT
		DECLARE @dblInvoiceSubtotal		NUMERIC(18,6)
		DECLARE @dblShipping			NUMERIC(18,6)
		DECLARE @dblTax					NUMERIC(18,6)
		DECLARE @dblInvoiceTotal		NUMERIC(18,6)
		DECLARE @dblDiscount			NUMERIC(18,6)
		DECLARE @dblAmountDue			NUMERIC(18,6)
		DECLARE @dblPayment				NUMERIC(18,6)
		DECLARE @strTransactionType		NVARCHAR(25)
		DECLARE @intPaymentMethodId		INT
		DECLARE @strComments			NVARCHAR(250)
		DECLARE @intAccountId			INT
		DECLARE @ysnPosted				BIT
		DECLARE	@ysnPaid				BIT
		
		--Varialbles for Invoice Detail
		DECLARE @intInvoiceId		INT
		DECLARE @intItemId			INT
		DECLARE @strItemDescription NVARCHAR(250)
		DECLARE @dblQtyOrdered		NUMERIC(18,6)
		DECLARE @dblQtyShipped		NUMERIC(18,6)
		DECLARE @dblPrice			NUMERIC(18,6)
		DECLARE @dblTotal			NUMERIC(18,6)
		
		DECLARE @Counter INT = 0
		DECLARE @lineNo INT
		
		--Import only those are not yet imported
		SELECT agivc_ivc_no, agivc_bill_to_cus INTO #tmpagivcmst 
			FROM agivcmst
		LEFT JOIN tblARInvoice ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceNumber COLLATE Latin1_General_CI_AS
		WHERE tblARInvoice.strInvoiceNumber IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
		ORDER BY agivc_ivc_no
		
		--------------------------------------------------
		-- Insert posted records that are from agivcmst --
		--------------------------------------------------
		WHILE (EXISTS(SELECT 1 FROM #tmpagivcmst))
		BEGIN
		
			SELECT TOP 1 
				@originInvoiceNumber	= agivc_ivc_no,
				@originCustomerNumber	= agivc_bill_to_cus
			FROM #tmpagivcmst

			SELECT TOP 1	
				@strInvoiceNumber		= agivc_ivc_no,		
				@intCustomerId			= (SELECT intCustomerId FROM tblARCustomer WHERE strCustomerNumber COLLATE Latin1_General_CI_AS = agivc_bill_to_cus COLLATE Latin1_General_CI_AS),		
				@dtmDate				= (CASE WHEN ISDATE(agivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
				@dtmDueDate				= (CASE WHEN ISDATE(agivc_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agivc_net_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END),
				@intCurrencyId			= 0,--to do
				@intCompanyLocationId	= NULL,--agivc_loc_no to do
				@intSalespersonId		= 0,--to do
				@dtmShipDate			= NULL,
				@intShipViaId			= 0, --to do
				@strPONumber			= agivc_po_no, 
				@intTermId				= 0,
				@dblInvoiceSubtotal		= NULL,
				@dblShipping			= NULL,
				@dblTax					= NULL,
				@dblInvoiceTotal		= agivc_slsmn_tot,
				@dblDiscount			= agivc_disc_amt,
				@dblAmountDue			= agivc_bal_due,
				@dblPayment				= agivc_amt_paid,
				@strTransactionType		= agivc_type,
				@intPaymentMethodId		= 0, --agivc_pay_type
				@strComments			= agivc_comment,
				@intAccountId			= 0, --to do
				@ysnPosted				= 0, --"If Invoice exists in the agivcmst, that means it is posted" -Joe 
				@ysnPaid				= (CASE WHEN agivc_bal_due = 0 THEN 1 ELSE 0 END)--"If the agivc-bal-due equals zero, then it is paid." -Joe
			FROM agivcmst
			WHERE agivc_ivc_no = @originInvoiceNumber AND agivc_bill_to_cus = @originCustomerNumber
			
			SELECT 
				agstm_bill_to_cus,
				agstm_ivc_no,
				agstm_itm_no,
				agstm_un,
				agstm_un_prc,
				agstm_sls ,
				agstm_line_no
			INTO #tmpInvoiceDetail
			FROM agstmmst
			WHERE agstm_ivc_no = @strInvoiceNumber AND agstm_bill_to_cus = @originCustomerNumber
			ORDER BY agstm_line_no
		
			--Insert into tblARInvoice
			INSERT INTO [dbo].[tblARInvoice]
			   ([strInvoiceNumber]
			   ,[intCustomerId]
			   ,[dtmDate]
			   ,[dtmDueDate]
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
			   --,[strShipToAddress]
			   --,[strShipToCity]
			   --,[strShipToState]
			   --,[strShipToZipCode]
			   --,[strShipToCountry]
			   --,[strBillToAddress]
			   --,[strBillToCity]
			   --,[strBillToState]
			   --,[strBillToZipCode]
			   --,[strBillToCountry]
			   --,[intConcurrencyId]
			   )
			VALUES
			   (@strInvoiceNumber		
			   ,@intCustomerId			
			   ,@dtmDate				
			   ,@dtmDueDate				
			   ,@intCurrencyId			
			   ,@intCompanyLocationId	
			   ,@intSalespersonId		
			   ,@dtmShipDate			
			   ,@intShipViaId			
			   ,@strPONumber			
			   ,@intTermId				
			   ,@dblInvoiceSubtotal		
			   ,@dblShipping			
			   ,@dblTax					
			   ,@dblInvoiceTotal		
			   ,@dblDiscount			
			   ,@dblAmountDue			
			   ,@dblPayment				
			   ,@strTransactionType		
			   ,@intPaymentMethodId		
			   ,@strComments			
			   ,@intAccountId			
			   ,@ysnPosted				
			   ,@ysnPaid				
			   --,<strShipToAddress, nvarchar(100),>
			   --,<strShipToCity, nvarchar(30),>
			   --,<strShipToState, nvarchar(50),>
			   --,<strShipToZipCode, nvarchar(12),>
			   --,<strShipToCountry, nvarchar(25),>
			   --,<strBillToAddress, nvarchar(100),>
			   --,<strBillToCity, nvarchar(30),>
			   --,<strBillToState, nvarchar(50),>
			   --,<strBillToZipCode, nvarchar(12),>
			   --,<strBillToCountry, nvarchar(25),>
			   --,<intConcurrencyId, int,>
			   )
			   
			SET @intInvoiceId = SCOPE_IDENTITY()
			
			--Insert on tblARInvoiceDetail
			WHILE (EXISTS(SELECT 1 FROM #tmpInvoiceDetail))
			BEGIN	
				
				SELECT TOP 1
					@lineNo				= agstm_line_no, --agstm_line_no is unique in detail, use this as an identifier for deletion after insertion of invoice detail
					@intItemId			= NULL,
					@strItemDescription = agstm_itm_no,	
					@dblQtyOrdered		= 0,
					@dblQtyShipped		= agstm_un,
					@dblPrice			= agstm_un_prc,
					@dblTotal			= agstm_sls	
				FROM #tmpInvoiceDetail
				
				INSERT INTO [dbo].[tblARInvoiceDetail]
					   ([intInvoiceId]
					   ,[intItemId]
					   ,[strItemDescription]
					   ,[dblQtyOrdered]
					   ,[dblQtyShipped]
					   ,[dblPrice]
					   ,[dblTotal])
				 VALUES
					   (@intInvoiceId
					   ,@intItemId
					   ,@strItemDescription
					   ,@dblQtyOrdered
					   ,@dblQtyShipped
					   ,@dblPrice
					   ,@dblTotal)
					   
				DELETE FROM #tmpInvoiceDetail WHERE agstm_line_no = @lineNo AND agstm_ivc_no = @strInvoiceNumber AND agstm_bill_to_cus = @originCustomerNumber
			
			END				
	
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpagivcmst WHERE agivc_ivc_no = @originInvoiceNumber AND agivc_bill_to_cus = @originCustomerNumber
		
		
			SET @Counter += 1
		END
		

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
		LEFT JOIN tblARInvoice ON agivcmst.agivc_ivc_no COLLATE Latin1_General_CI_AS = tblARInvoice.strInvoiceNumber COLLATE Latin1_General_CI_AS
		WHERE tblARInvoice.strInvoiceNumber IS NULL AND agivcmst.agivc_ivc_no = UPPER(agivcmst.agivc_ivc_no) COLLATE Latin1_General_CS_AS
		
	END
		
	