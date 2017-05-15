GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportPayments')
	DROP PROCEDURE uspARImportPayments
GO

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	


IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agpaymst')
BEGIN

	EXEC('
CREATE PROCEDURE uspARImportPayments 
	 @Checking	BIT = 0  
	,@UserId	INT = 0 
	,@Total		INT = 0		OUTPUT  
AS  
BEGIN  

DECLARE @MaxPaymentID int, @OriginalMaxPaymentID int, @DefaultPaymenMethodtId int, @DefaultTermId int, @TotalCount int
SET @TotalCount = 0

SELECT @MaxPaymentID = MAX(intPaymentId) FROM tblARPayment
IF @MaxPaymentID IS NULL
	SET @MaxPaymentID = 0
SET @OriginalMaxPaymentID = @MaxPaymentID
	
SELECT TOP 1 @DefaultPaymenMethodtId = [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethodCode] IS NOT NULL AND RTRIM(LTRIM([strPaymentMethodCode])) <> '''' ORDER BY [strPaymentMethodCode]
IF @DefaultPaymenMethodtId IS NULL
	SET @DefaultPaymenMethodtId = 0
	
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
				ON I.[ysnPosted] = 1
				AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intEntityCustomerId] = C.[intEntityId] 
		INNER JOIN
			[tblSMCurrency] CUR
				ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agpay_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
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
						AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intEntityCustomerId]
			,P1.[agpay_ivc_no]
			,P1.[agpay_rev_dt]
			,P1.[agpay_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,CUR.[intCurrencyID]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
		
		--UNPOSTED PAYMENTS
		SELECT NULL	
		FROM
			[agpyemst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON I.[ysnPosted] = 1
				AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intEntityCustomerId] = C.[intEntityId] 
		INNER JOIN
			[tblSMCurrency] CUR
				ON P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agpye_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agpye_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
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
						a.[ysnPosted] = 0
						AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intEntityCustomerId]
			,P1.[agpye_inc_ref]
			,P1.[agpye_rev_dt]
			,P1.[agpye_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,CUR.[intCurrencyID]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
    
		--UNAPPLIED CREDITS
		SELECT NULL
		FROM
			[agcrdmst] P1				--Origin Credits Table
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agcrd_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agcrd_acct_no] = GL.[strExternalId]
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[agcrd_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agcrd_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		WHERE 
			(P1.agcrd_amt - P1.agcrd_amt_used) <> 0
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					WHERE
						a.[ysnPosted] = 1
						AND a.[intEntityCustomerId] = C.[intEntityId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agcrd_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agcrd_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agcrd_ref_no] COLLATE Latin1_General_CI_AS					
						AND a.dblUnappliedAmount <> 0
				)		
		
		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
	
		RETURN @Total  
	END   
	
	--POSTED PAYMENTS
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intEntityCustomerId]
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
		,[ysnApplytoBudget]
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		)
	SELECT
		I.[intEntityCustomerId] 									AS [intEntityCustomerId]
		,CUR.[intCurrencyID]								AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[agpay_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[agpay_ref_no]									AS [strPaymentInfo]
		,P1.[agpay_ivc_no]									AS [strNotes] 
		,0													AS [ysnApplytoBudget]		
		,1													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0
		,1
		,1

	FROM
		[agpaymst] P1				--Origin Posted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			ON P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intEntityCustomerId]
		,P1.[agpay_ivc_no]
		,P1.[agpay_rev_dt]
		,P1.[agpay_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,CUR.[intCurrencyID]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	ORDER BY 
		I.[intEntityCustomerId]
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
		,[dblDiscountAvailable]
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
		,0			 				AS [dblDiscountAvailable]		
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
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
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
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[agpay_rev_dt]	
		
	--INSERT CREDIT MEMO PAYMENT DETAIL
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId] 
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblDiscountAvailable]
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
		,0			 				AS [dblDiscountAvailable]		
		,0							AS [dblAmountDue]
		,SUM(P1.[agpay_amt]) * -1	AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[agpaymst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.agpay_chk_no = ''CREDIT'' 
			AND P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
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
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[agpay_rev_dt]	
		

	--INSERT CREDIT MEMO PAYMENT DETAIL
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId] 
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblDiscountAvailable]
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
		,0			 				AS [dblDiscountAvailable]		
		,0							AS [dblAmountDue]
		,SUM(P1.[agpay_amt]) * -1	AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[agpaymst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.agpay_chk_no = ''CREDIT'' 
			AND P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
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
		P.[intEntityCustomerId]
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
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[ysnPosted] = 1
		AND P.[intPaymentId] > @MaxPaymentID 
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
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		(P1.[agpay_note] IS NOT NULL OR P1.[agpay_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
		AND tblARPayment.[intCurrencyId] = CUR.[intCurrencyID]
		AND tblARPayment.[intAccountId] = GL.[inti21Id]
		AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
		AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
		AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS	
	
	
	--UNPOSTED PAYMENTS
	SELECT @MaxPaymentID = MAX(intPaymentId) FROM tblARPayment
	IF @MaxPaymentID IS NULL
		SET @MaxPaymentID = 0
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intEntityCustomerId]
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
		,[ysnApplytoBudget]		
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		)
	SELECT
		I.[intEntityCustomerId] 									AS [intEntityCustomerId]
		,CUR.[intCurrencyID]								AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[agpye_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[agpye_ref_no]									AS [strPaymentInfo]
		,P1.[agpye_inc_ref]									AS [strNotes] 
		,0													AS [ysnApplytoBudget]						
		,0													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0
		,1
		,0

	FROM
		[agpyemst] P1				--Origin UnPosted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			ON P1.[agpye_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		RTRIM(LTRIM(P1.[agpye_chk_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 0
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intEntityCustomerId]
		,P1.[agpye_inc_ref]
		,P1.[agpye_rev_dt]
		,P1.[agpye_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,CUR.[intCurrencyID]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	ORDER BY 
		I.[intEntityCustomerId]
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
		,[dblDiscountAvailable]		
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
		,0			 				AS [dblDiscountAvailable]		
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
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[agpye_chk_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 0
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[agpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[agpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpye_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
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
		P.[intEntityCustomerId]
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
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
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
			AND  P1.[agpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
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
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[agpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCurrency] CUR
			ON P1.[agpye_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[agpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[agpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		(P1.[agpye_note] IS NOT NULL OR P1.[agpye_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
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
		tblARPayment.[intPaymentId] > @OriginalMaxPaymentID	
		AND dtl.[IDCount] > 1
		AND tblARPayment.[intPaymentId] = dtl.[intPaymentId] 
		
	
	--FIX IMPORTED INVOICES MISSING TERM
	UPDATE
		tblARInvoice 
	SET
		intTermId = @DefaultTermId 
	WHERE
		(intTermId IS NULL OR intTermId = 0)
		AND strInvoiceOriginId IS NOT NULL
		AND LTRIM(RTRIM(strInvoiceOriginId)) <> ''''	

	-- INSERT UNAPPLIED PAYMENTS
		INSERT INTO [tblARPayment]
			([intEntityCustomerId]
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
			,[ysnApplytoBudget]				
			,[ysnPosted]
			,[intEntityId] 
			,[intConcurrencyId]
			,[ysnImportedFromOrigin]
			,[ysnImportedAsPosted]
			)
		SELECT
			 C.[intEntityId] 							AS [intEntityCustomerId]
			,(select intDefaultCurrencyId from tblSMCompanyPreference) AS [intCurrencyId]
			,(CASE 
				WHEN ISDATE(P1.[agcrd_rev_dt]) = 1 
					THEN CONVERT(DATE, CAST(P1.[agcrd_rev_dt]	AS CHAR(12)), 112) 
				ELSE
					NULL 
			END)												AS [dtmDatePaid]
			,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
			,CL.[intCompanyLocationId] 							AS [intLocationId]
			,(P1.[agcrd_amt])    								AS [dblAmountPaid]
			,(P1.agcrd_amt - P1.agcrd_amt_used)   				AS [dblUnappliedAmount]
			,(P1.agcrd_amt - P1.agcrd_amt_used)					AS [dblOverpayment]
			,0													AS [dblBalance]
			,P1.[agcrd_ref_no]									AS [strPaymentInfo]
			,''ORIGIN''               							AS [strNotes] 
			,0													AS [ysnApplytoBudget]						
			,1													AS [ysnPosted]	
			,@UserId											AS [intEntityId]										
			,0
			,1
			,1

		FROM
			[agcrdmst] P1				--Origin Credits Table
		INNER JOIN
			[tblARCustomer] C
				ON P1.[agcrd_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[agcrd_acct_no] = GL.[strExternalId]
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[agcrd_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[agcrd_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		WHERE 
			(P1.agcrd_amt - P1.agcrd_amt_used) <> 0
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					WHERE
						a.[ysnPosted] = 1
						AND a.[intEntityCustomerId] = C.[intEntityId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[agcrd_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[agcrd_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agcrd_ref_no] COLLATE Latin1_General_CI_AS					
						AND a.dblUnappliedAmount <> 0)
						
	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON

	--CREATE INVOICES FOR UNAPPLIED CREDITS
		DECLARE @PaymentID int, @return_value int, @NewInvoiceId int
		SET @return_value = 0
		SELECT intPaymentId INTO #tmpagcrd FROM tblARPayment WHERE strNotes = ''ORIGIN''
			WHILE (EXISTS(SELECT 1 FROM #tmpagcrd))
			BEGIN
				BEGIN TRY
					SELECT @PaymentID = intPaymentId FROM #tmpagcrd
						EXEC	@return_value = [dbo].[uspARCreatePrePayment]
								@PaymentID = @PaymentID,
								@UserId = @UserId,
								@NewInvoiceId = @NewInvoiceId OUTPUT					
				END TRY								
							
				BEGIN CATCH
					PRINT @@ERROR;
					DELETE FROM tblARPayment WHERE intPaymentId = @PaymentID					
					GOTO CONTINUELOOP;
				END CATCH
				
				CONTINUELOOP:
				PRINT @PaymentID
				DELETE FROM #tmpagcrd WHERE intPaymentId = @PaymentID
				UPDATE tblARPayment SET strNotes = NULL WHERE intPaymentId = @PaymentID
			END 		
END
			')
END

IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptpaymst')
BEGIN
	EXEC('
CREATE PROCEDURE uspARImportPayments 
	 @Checking	BIT = 0  
	,@UserId	INT = 0 
	,@Total		INT = 0		OUTPUT  
AS  
BEGIN 

DECLARE @CR_Account NVARCHAR(100),@CR_AccounID int
SET @CR_Account = (select ptmgl_cash from ptmglmst)
SET @CR_AccounID = (SELECT GL.inti21Id from [tblGLCOACrossReference] GL WHERE @CR_Account = GL.[strExternalId]) 

DECLARE @MaxPaymentID int, @OriginalMaxPaymentID int, @DefaultPaymenMethodtId int, @DefaultTermId int, @TotalCount int
SET @TotalCount = 0

SELECT @MaxPaymentID = MAX(intPaymentId) FROM tblARPayment
IF @MaxPaymentID IS NULL
	SET @MaxPaymentID = 0
SET @OriginalMaxPaymentID = @MaxPaymentID
	
SELECT TOP 1 @DefaultPaymenMethodtId = [intPaymentMethodID] FROM tblSMPaymentMethod WHERE [strPaymentMethodCode] IS NOT NULL AND RTRIM(LTRIM([strPaymentMethodCode])) <> '''' ORDER BY [strPaymentMethodCode]
IF @DefaultPaymenMethodtId IS NULL
	SET @DefaultPaymenMethodtId = 0
	
SELECT TOP 1 @DefaultTermId = intTermID  FROM tblSMTerm WHERE dblDiscountEP = 0 ORDER BY strType DESC
IF @DefaultTermId IS NULL
	SET @DefaultTermId = 0

IF(@Checking = 1)   
	BEGIN 
		--POSTED PAYMENTS 
		SELECT NULL	
		FROM
			[ptpaymst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON I.[ysnPosted] = 1
				AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intEntityCustomerId] = C.[intEntityId] 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptpay_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		WHERE 
			RTRIM(LTRIM(P1.[ptpay_check_no])) <> ''DISC''
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					INNER JOIN tblARPaymentDetail ad
						ON a.[intPaymentId] = ad.[intPaymentId] 
					WHERE
						a.[ysnPosted] = 1
						AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intEntityCustomerId]
			,P1.[ptpay_invc_no]
			,P1.[ptpay_rev_dt]
			,P1.[ptpay_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,I.[intCurrencyId]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
		
		--UNPOSTED PAYMENTS
		SELECT NULL	
		FROM
			[ptpyemst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON I.[ysnPosted] = 1
				AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intEntityCustomerId] = C.[intEntityId] 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptpye_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[ptpye_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		WHERE 
			RTRIM(LTRIM(P1.[ptpye_check_no])) <> ''DISC''
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					INNER JOIN tblARPaymentDetail ad
						ON a.[intPaymentId] = ad.[intPaymentId] 
					WHERE
						a.[ysnPosted] = 0
						AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
						AND ad.[intInvoiceId] = I.[intInvoiceId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS				
				)
		GROUP BY
			I.[intEntityCustomerId]
			,P1.[ptpye_inc_ref]
			,P1.[ptpye_rev_dt]
			,P1.[ptpye_ref_no]
			,GL.[inti21Id]
			,CL.[intCompanyLocationId]
			,I.[intCurrencyId]	
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)			

		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 
    
		--UNAPPLIED CREDITS
		SELECT NULL
		FROM
			[ptcrdmst] P1				--Origin Credits Table
		INNER JOIN
			[tblARCustomer] C
				ON P1.[ptcrd_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptcrd_acct_no] = GL.[strExternalId]
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[ptcrd_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptcrd_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		WHERE 
			(P1.ptcrd_amt - P1.ptcrd_amt_used) <> 0
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					WHERE
						a.[ysnPosted] = 1
						AND a.[intEntityCustomerId] = C.[intEntityId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[ptcrd_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[ptcrd_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptcrd_invc_no] COLLATE Latin1_General_CI_AS					
						AND a.dblUnappliedAmount <> 0
				)		
		
		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 

		RETURN @Total  
	END   
	
	--POSTED PAYMENTS
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intEntityCustomerId]
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
		,[ysnApplytoBudget]				
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		)
	SELECT
		I.[intEntityCustomerId] 									AS [intEntityCustomerId]
		,I.[intCurrencyId]									AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[ptpay_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[ptpay_ref_no]									AS [strPaymentInfo]
		,P1.[ptpay_invc_no]									AS [strNotes] 
		,0													AS [ysnApplytoBudget]						
		,1													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0
		,1
		,1

	FROM
		[ptpaymst] P1				--Origin Posted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityId] 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		RTRIM(LTRIM(P1.[ptpay_check_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intEntityCustomerId]
		,P1.[ptpay_invc_no]
		,P1.[ptpay_rev_dt]
		,P1.[ptpay_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,I.[intCurrencyId]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	ORDER BY 
		I.[intEntityCustomerId]
		,P1.[ptpay_invc_no]
		,P1.[ptpay_rev_dt]

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
		,[dblDiscountAvailable]		
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
		,0			 				AS [dblDiscountAvailable]		
		,0							AS [dblAmountDue]
		,SUM(P1.[ptpay_amt])		AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[ptpaymst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[ptpay_check_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpay_rev_dt]
		,P.[strNotes] 
		,P.[strPaymentInfo]	
		,P.[intAccountId]
		,I.[intAccountId] 
		,I.[intTermId]
		,P.[intPaymentId]							
		,I.[dblInvoiceTotal]
	ORDER BY 
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpay_rev_dt]	

	--INSERT CREDIT MEMO PAYMENT DETAIL
	INSERT INTO [tblARPaymentDetail]
		([intPaymentId]
		,[intInvoiceId]
		,[intTermId] 
		,[intAccountId]
		,[dblInvoiceTotal]
		,[dblDiscount]
		,[dblDiscountAvailable]		
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
		,0			 				AS [dblDiscountAvailable]		
		,0							AS [dblAmountDue]
		,SUM(P1.[ptpay_amt]) * -1	AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[ptpaymst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1. [ptpay_orig_crd_pay_type] = ''CRM''
			AND P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[ptpay_check_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 1
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpay_rev_dt]
		,P.[strNotes] 
		,P.[strPaymentInfo]	
		,P.[intAccountId]
		,I.[intAccountId] 
		,I.[intTermId]
		,P.[intPaymentId]							
		,I.[dblInvoiceTotal]
	ORDER BY 
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpay_rev_dt]			
		
	--UPDATE DETAIL DISCOUNT
	UPDATE 
		tblARPaymentDetail 
	SET
		[dblDiscount] = P1.[ptpay_amt]			
	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[ptpaymst] P1
			ON P1.[ptpay_check_no] = ''DISC    ''
			AND P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[ysnPosted] = 1
		AND P.[intPaymentId] > @MaxPaymentID 
		--AND P1.[ptpay_check_no] = ''DISC''		
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
		[strNotes] = P1.[ptpay_note] 			
	FROM
		[ptpaymst] P1				--Origin Posted Payments Table															
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		(P1.[ptpay_note] IS NOT NULL OR P1.[ptpay_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
		AND tblARPayment.[intCurrencyId] = I.[intCurrencyId]
		AND tblARPayment.[intAccountId] = GL.[inti21Id]
		AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
		AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
		AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS	
	
	
	--UNPOSTED PAYMENTS
	SELECT @MaxPaymentID = MAX(intPaymentId) FROM tblARPayment
	IF @MaxPaymentID IS NULL
		SET @MaxPaymentID = 0
	--INSERT PAYMENT HEADER
	INSERT INTO [tblARPayment]
		([intEntityCustomerId]
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
		,[ysnApplytoBudget]				
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
		,[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]
		)
	SELECT
		I.[intEntityCustomerId] 									AS [intEntityCustomerId]
		,I.[intCurrencyId]									AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		,ISNULL(GL.[inti21Id],0)							AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		,SUM(P1.[ptpye_amt])								AS [dblAmountPaid]
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
		,P1.[ptpye_ref_no]									AS [strPaymentInfo]
		,P1.[ptpye_inc_ref]									AS [strNotes] 
		,0													AS [ysnApplytoBudget]				
		,0													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0
		,1
		,0

	FROM
		[ptpyemst] P1				--Origin UnPosted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityId] 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpye_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpye_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		RTRIM(LTRIM(P1.[ptpye_check_no])) <> ''DISC''
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 0
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS					
			)		
	GROUP BY
		I.[intEntityCustomerId]
		,P1.[ptpye_inc_ref]
		,P1.[ptpye_rev_dt]
		,P1.[ptpye_ref_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,I.[intCurrencyId]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	ORDER BY 
		I.[intEntityCustomerId]
		,P1.[ptpye_inc_ref]
		,P1.[ptpye_rev_dt]

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
		,[dblDiscountAvailable]		
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
		,0			 				AS [dblDiscountAvailable]
		,0							AS [dblAmountDue]
		,SUM(P1.[ptpye_amt])		AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin UnPosted Payments Table
	INNER JOIN	
		[ptpyemst] P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		AND RTRIM(LTRIM(P1.[ptpye_check_no])) <> ''DISC''	
		AND NOT EXISTS
			(	SELECT NULL 
				FROM tblARPayment a
				INNER JOIN tblARPaymentDetail ad
					ON a.[intPaymentId] = ad.[intPaymentId] 
				WHERE
					a.[ysnPosted] = 0
					AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
					AND ad.[intInvoiceId] = I.[intInvoiceId] 
					AND a.[dtmDatePaid] = (CASE 
												WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
													THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
												ELSE
													NULL 
											END)
					AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
					AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
					AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS					
			)			
	GROUP BY
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpye_rev_dt]
		,P.[strNotes] 
		,P.[strPaymentInfo]	
		,P.[intAccountId]
		,I.[intAccountId] 
		,I.[intTermId]
		,P.[intPaymentId]							
		,I.[dblInvoiceTotal]
	ORDER BY 
		P.[intEntityCustomerId]
		,I.[intInvoiceId]
		,P1.[ptpye_rev_dt]	

	--UPDATE DETAIL DISCOUNT
	UPDATE 
		tblARPaymentDetail 
	SET
		[dblDiscount] = P1.[ptpye_amt]			
	FROM
		[tblARPayment] P				--Origin UnPosted Payments Table
	INNER JOIN	
		[ptpyemst] P1
			ON P1.[ptpye_check_no] = ''DISC    ''
			AND P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS				
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityId]
			AND I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		P.[intPaymentId] > @MaxPaymentID 
		--AND P1.[ptpye_check_no] = ''DISC''		
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
		[strNotes] = P1.[ptpye_note] 			
	FROM
		[ptpyemst] P1				--Origin UnPosted Payments Table															
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intEntityCustomerId] = C.[intEntityId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE
		(P1.[ptpye_note] IS NOT NULL OR P1.[ptpye_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
		AND tblARPayment.[intCurrencyId] = I.[intCurrencyId]
		AND tblARPayment.[intAccountId] = GL.[inti21Id]
		AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
		AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS
		AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS	
		
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
		tblARPayment.[intPaymentId] > @OriginalMaxPaymentID	
		AND dtl.[IDCount] > 1
		AND tblARPayment.[intPaymentId] = dtl.[intPaymentId] 
		
	
	--FIX IMPORTED INVOICES MISSING TERM
	UPDATE
		tblARInvoice 
	SET
		intTermId = @DefaultTermId 
	WHERE
		(intTermId IS NULL OR intTermId = 0)
		AND strInvoiceOriginId IS NOT NULL
		AND LTRIM(RTRIM(strInvoiceOriginId)) <> ''''						  				  

	-- INSERT UNAPPLIED PAYMENTS
		INSERT INTO [tblARPayment]
			([intEntityCustomerId]
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
			,[ysnApplytoBudget]				
			,[ysnPosted]
			,[intEntityId] 
			,[intConcurrencyId]
			)
		SELECT
			 C.[intEntityId] 							AS [intEntityCustomerId]
			,(select intDefaultCurrencyId from tblSMCompanyPreference) AS [intCurrencyId]
			,(CASE 
				WHEN ISDATE(P1.[ptcrd_rev_dt]) = 1 
					THEN CONVERT(DATE, CAST(P1.[ptcrd_rev_dt]	AS CHAR(12)), 112) 
				ELSE
					NULL 
			END)												AS [dtmDatePaid]
			,ISNULL(GL.[inti21Id],@CR_AccounID)							AS [intAccountId]
			,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
			,CL.[intCompanyLocationId] 							AS [intLocationId]
			,(P1.[ptcrd_amt])    								AS [dblAmountPaid]
			,(P1.ptcrd_amt - P1.ptcrd_amt_used)   				AS [dblUnappliedAmount]
			,(P1.ptcrd_amt - P1.ptcrd_amt_used)					AS [dblOverpayment]
			,0													AS [dblBalance]
			,P1.[ptcrd_invc_no]									AS [strPaymentInfo]
			,''ORIGIN''               							AS [strNotes] 
			,0													AS [ysnApplytoBudget]						
			,1													AS [ysnPosted]	
			,@UserId											AS [intEntityId]										
			,0

		FROM
			[ptcrdmst] P1				--Origin Credits Table
		INNER JOIN
			[tblARCustomer] C
				ON P1.[ptcrd_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptcrd_acct_no] = GL.[strExternalId]
		INNER JOIN
			[tblSMCompanyLocation] CL
				ON P1.[ptcrd_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptcrd_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
		WHERE 
			(P1.ptcrd_amt - P1.ptcrd_amt_used) <> 0
			AND NOT EXISTS
				(	SELECT NULL 
					FROM tblARPayment a
					WHERE
						a.[ysnPosted] = 1
						AND a.[intEntityCustomerId] = C.[intEntityId] 
						AND a.[dtmDatePaid] = (CASE 
													WHEN ISDATE(P1.[ptcrd_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[ptcrd_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptcrd_invc_no] COLLATE Latin1_General_CI_AS					
						AND a.dblUnappliedAmount <> 0)
						
	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON

	--CREATE INVOICES FOR UNAPPLIED CREDITS
		DECLARE @PaymentID int, @return_value int, @NewInvoiceId int
		SET @return_value = 0
		SELECT intPaymentId INTO #tmpptcrd FROM tblARPayment WHERE strNotes = ''ORIGIN''
			WHILE (EXISTS(SELECT 1 FROM #tmpptcrd))
			BEGIN
				BEGIN TRY
					SELECT @PaymentID = intPaymentId FROM #tmpptcrd
						EXEC	@return_value = [dbo].[uspARCreatePrePayment]
								@PaymentID = @PaymentID,
								@UserId = @UserId,
								@NewInvoiceId = @NewInvoiceId OUTPUT					
				END TRY								
							
				BEGIN CATCH
					PRINT @@ERROR;
					DELETE FROM tblARPayment WHERE intPaymentId = @PaymentID					
					GOTO CONTINUELOOP;
				END CATCH
				
				CONTINUELOOP:
				PRINT @PaymentID
				DELETE FROM #tmpptcrd WHERE intPaymentId = @PaymentID
				UPDATE tblARPayment SET strNotes = NULL WHERE intPaymentId = @PaymentID
			END 
END
			')
END