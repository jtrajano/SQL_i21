GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportPayments')
	DROP PROCEDURE uspARImportPayments
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('
CREATE PROCEDURE uspARImportPayments 
	 @Checking	BIT = 0  
	,@UserId	INT = 0 
	,@Total		INT = 0		OUTPUT  
AS  
BEGIN  

DECLARE @MaxPaymentID int, @DefaultPaymentId int, @DefaultTermId int, @TotalCount int
SET @TotalCount = 0

SELECT @MaxPaymentID = MAX(intPaymentId) FROM tblARPayment
IF @MaxPaymentID IS NULL
	SET @MaxPaymentID = 0
	
SELECT TOP 1 @DefaultPaymentId = [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethodCode] IS NOT NULL AND RTRIM(LTRIM([strPaymentMethodCode])) <> '''' ORDER BY [strPaymentMethodCode]
IF @DefaultPaymentId IS NULL
	SET @DefaultPaymentId = 0
	
SELECT TOP 1 @DefaultTermId = intTermID  FROM tblSMTerm WHERE dblDiscountEP = 0 ORDER BY strType DESC
IF @DefaultTermId IS NULL
	SET @DefaultTermId = 0

IF(@Checking = 1)   
	BEGIN 
		--POSTED PAYMENTS 
		SELECT NULL	
		FROM
			[agpaymst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intCustomerId] = C.[intCustomerId] 
		INNER JOIN
			[tblSMCurrency] CUR
				ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agpay_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agpay_pay_type] = CAST(P.strPaymentMethodCode AS int)
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[agpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		WHERE 
			RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					INNER JOIN tblARPaymentDetail ad
						ON a.[intPaymentId] = ad.[intPaymentId] 
					WHERE
						a.[ysnPosted] = 1
						AND a.[intCustomerId] = I.[intCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intCustomerId]
			,P1.[agpay_ivc_no]
			,P1.[agpay_rev_dt]
			,P1.[agpay_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,CUR.[intCurrencyID]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
		
		--UNPOSTED PAYMENTS
		SELECT NULL	
		FROM
			[agpyemst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intCustomerId] = C.[intCustomerId] 
		INNER JOIN
			[tblSMCurrency] CUR
				ON P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agpye_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agpye_pay_type] = CAST(P.strPaymentMethodCode AS int)
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[agpye_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		WHERE 
			RTRIM(LTRIM(P1.[agpye_chk_no])) <> ''DISC''
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					INNER JOIN tblARPaymentDetail ad
						ON a.[intPaymentId] = ad.[intPaymentId] 
					WHERE
						a.[ysnPosted] = 1
						AND a.[intCustomerId] = I.[intCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intCustomerId]
			,P1.[agpye_inc_ref]
			,P1.[agpye_rev_dt]
			,P1.[agpye_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,CUR.[intCurrencyID]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
    
		RETURN @Total  
	END   
	
	--POSTED PAYMENTS
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intCustomerId]
		,[intCurrencyId]
		,[dtmDatePaid]
		,[intAccountId]
		,[intPaymentMethodId]
		,[intLocationId]
		,[dblAmountPaid]
		,[dblUnappliedAmount]
		,[dblOverpayment]
		,[dblBalance]
		,[strPaymentInfo]
		,[strNotes]
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		)
	SELECT
		I.[intCustomerId] 									AS [intCustomerId]
		,CUR.[intCurrencyID]								AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[agpay_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[agpay_ref_no]									AS [strPaymentInfo]
		,P1.[agpay_ivc_no]									AS [strNotes] 
		,1													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0

	FROM
		[agpaymst] P1				--Origin Posted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intCustomerId] = C.[intCustomerId] 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpay_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[agpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[agpay_pay_type] = CAST(P.[strPaymentMethodCode] AS int)			
	WHERE 
		RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intCustomerId] = I.[intCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intCustomerId]
		,P1.[agpay_ivc_no]
		,P1.[agpay_rev_dt]
		,P1.[agpay_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,CUR.[intCurrencyID]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)				
	ORDER BY 
		I.[intCustomerId]
		,P1.[agpay_ivc_no]
		,P1.[agpay_rev_dt]

	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON
	
	--INSERT PAYMENT DETAIL
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId] 
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[intConcurrencyId]
		)							
	SELECT
		P.[intPaymentId]			AS [intPaymentId] 
		,I.[intInvoiceId]			AS [intInvoiceId]
		,(CASE WHEN I.[intTermId] IS NULL OR I.[intAccountId] = 0 
			THEN @DefaultTermId 
			ELSE I.[intTermId] 
		END)				AS [intTermId]
		,(CASE WHEN I.[intAccountId] IS NULL OR	I.[intAccountId] = 0 
			THEN P.[intAccountId] 
			ELSE I.[intAccountId] 
		END)						AS [intAccountId] 
		,I.[dblInvoiceTotal]		AS [dblInvoiceTotal]  
		,0			 				AS [dblDiscount]
		,0							AS [dblAmountDue]
		,SUM(P1.[agpay_amt])		AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[agpaymst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intCustomerId] = C.[intCustomerId]
			AND I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P.[intCurrencyId] = CUR.[intCurrencyID]
			AND  P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[agpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[agpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[intCustomerId] = I.[intCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymentId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intCustomerId]
		,I.[intInvoiceId]
		,P1.[agpay_rev_dt]
		,P.[strNotes] 
		,P.[strPaymentInfo]	
		,P.[intAccountId]
		,I.[intAccountId] 
		,I.[intTermId]
		,P.[intPaymentId]							
		,I.[dblInvoiceTotal]
	ORDER BY 
		P.[intCustomerId]
		,I.[intInvoiceId]
		,P1.[agpay_rev_dt]	

	--UPDATE DETAIL DISCOUNT
	UPDATE 
		tblARPaymentDetail 
	SET
		[dblDiscount] = P1.[agpay_amt]			
	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[agpaymst] P1
			ON P1.[agpay_chk_no] = ''DISC    ''
			AND P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intCustomerId] = C.[intCustomerId]
			AND I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P.[intCurrencyId] = CUR.[intCurrencyID]
			AND  P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[agpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[agpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		--AND P1.[agpay_chk_no] = ''DISC''		
		AND tblARPaymentDetail.[intPaymentId] = P.[intPaymentId] 
		AND tblARPaymentDetail.[intInvoiceId] = I.[intInvoiceId] 
						
	--RESET/UPDATE HEADER NOTE
	UPDATE
		tblARPayment 
	SET	
		[strNotes] = NULL
	WHERE
		[intPaymentId] > @MaxPaymentID 
		
	UPDATE 
		tblARPayment 
	SET
		[strNotes] = P1.[agpay_note] 			
	FROM
		[agpaymst] P1				--Origin Posted Payments Table															
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[agpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		(P1.[agpay_note] IS NOT NULL OR P1.[agpay_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intCustomerId] = C.[intCustomerId]
		AND tblARPayment.[intCurrencyId] = CUR.[intCurrencyID]
		AND tblARPayment.[intAccountId] = GL.[inti21Id]
		AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
		AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
		AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS	
	
	
	--UNPOSTED PAYMENTS
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intCustomerId]
		,[intCurrencyId]
		,[dtmDatePaid]
		,[intAccountId]
		,[intPaymentMethodId]
		,[intLocationId]
		,[dblAmountPaid]
		,[dblUnappliedAmount]
		,[dblOverpayment]
		,[dblBalance]
		,[strPaymentInfo]
		,[strNotes]
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		)
	SELECT
		I.[intCustomerId] 									AS [intCustomerId]
		,CUR.[intCurrencyID]								AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[agpye_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[agpye_ref_no]									AS [strPaymentInfo]
		,P1.[agpye_inc_ref]									AS [strNotes] 
		,0													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0

	FROM
		[agpyemst] P1				--Origin UnPosted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intCustomerId] = C.[intCustomerId] 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpye_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[agpye_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[agpye_pay_type] = CAST(P.[strPaymentMethodCode] AS int)			
	WHERE 
		RTRIM(LTRIM(P1.[agpye_chk_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 0
					AND a.[intCustomerId] = I.[intCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intCustomerId]
		,P1.[agpye_inc_ref]
		,P1.[agpye_rev_dt]
		,P1.[agpye_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,CUR.[intCurrencyID]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymentId)				
	ORDER BY 
		I.[intCustomerId]
		,P1.[agpye_inc_ref]
		,P1.[agpye_rev_dt]

	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON
	
	--INSERT PAYMENT DETAIL
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId] 
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblAmountDue]
		,[dblPayment]
		,[intConcurrencyId]
		)							
	SELECT
		P.[intPaymentId]			AS [intPaymentId] 
		,I.[intInvoiceId]			AS [intInvoiceId]
		,(CASE WHEN I.[intTermId] IS NULL OR I.[intAccountId] = 0 
			THEN @DefaultTermId 
			ELSE I.[intTermId] 
		END)				AS [intTermId]
		,(CASE WHEN I.[intAccountId] IS NULL OR	I.[intAccountId] = 0 
			THEN P.[intAccountId] 
			ELSE I.[intAccountId] 
		END)						AS [intAccountId] 
		,I.[dblInvoiceTotal]		AS [dblInvoiceTotal]  
		,0			 				AS [dblDiscount]
		,0							AS [dblAmountDue]
		,SUM(P1.[agpye_amt])		AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin UnPosted Payments Table
	INNER JOIN	
		[agpyemst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intCustomerId] = C.[intCustomerId]
			AND I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P.[intCurrencyId] = CUR.[intCurrencyID]
			AND  P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[agpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[agpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpye_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[intCustomerId] = I.[intCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymentId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intCustomerId]
		,I.[intInvoiceId]
		,P1.[agpye_rev_dt]
		,P.[strNotes] 
		,P.[strPaymentInfo]	
		,P.[intAccountId]
		,I.[intAccountId] 
		,I.[intTermId]
		,P.[intPaymentId]							
		,I.[dblInvoiceTotal]
	ORDER BY 
		P.[intCustomerId]
		,I.[intInvoiceId]
		,P1.[agpye_rev_dt]	

	--UPDATE DETAIL DISCOUNT
	UPDATE 
		tblARPaymentDetail 
	SET
		[dblDiscount] = P1.[agpye_amt]			
	FROM
		[tblARPayment] P				--Origin UnPosted Payments Table
	INNER JOIN	
		[agpyemst] P1
			ON P1.[agpye_chk_no] = ''DISC    ''
			AND P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intCustomerId] = C.[intCustomerId]
			AND I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P.[intCurrencyId] = CUR.[intCurrencyID]
			AND  P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[agpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[agpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		--AND P1.[agpye_chk_no] = ''DISC''		
		AND tblARPaymentDetail.[intPaymentId] = P.[intPaymentId] 
		AND tblARPaymentDetail.[intInvoiceId] = I.[intInvoiceId] 
							
	--RESET/UPDATE HEADER NOTE
	UPDATE
		tblARPayment 
	SET	
		[strNotes] = NULL
	WHERE
		[intPaymentId] > @MaxPaymentID 
		
	UPDATE 
		tblARPayment 
	SET
		[strNotes] = P1.[agpye_note] 			
	FROM
		[agpyemst] P1				--Origin UnPosted Payments Table															
	INNER JOIN
		[tblARInvoice] I
			ON P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intCustomerId] = C.[intCustomerId] 
			AND P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[agpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		(P1.[agpye_note] IS NOT NULL OR P1.[agpye_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intCustomerId] = C.[intCustomerId]
		AND tblARPayment.[intCurrencyId] = CUR.[intCurrencyID]
		AND tblARPayment.[intAccountId] = GL.[inti21Id]
		AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
		AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS
		AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS	
		
	--UPDATE HEADER AMOUNT PAID 		
	UPDATE
		tblARPayment 
	SET
		[dblAmountPaid] = dtl.[dblPayment] 
	FROM
		(
		SELECT
			COUNT([intPaymentId])	AS [IDCount]
			,SUM([dblPayment])		AS [dblPayment]
			,[intPaymentId]
		FROM
			tblARPaymentDetail 		
		GROUP BY [intPaymentId]
		) dtl
	WHERE
		tblARPayment.[intPaymentId] > @MaxPaymentID	
		AND dtl.[IDCount] > 1
		AND tblARPayment.[intPaymentId] = dtl.[intPaymentId] 						  
				  
END
			')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE uspARImportPayments 
			@Checking BIT = 0,  
			@UserId INT = 0,  
			@Total INT = 0 OUTPUT  

		AS  
		BEGIN  
			SET @Total = 0
			RETURN @Total 
		END')
END