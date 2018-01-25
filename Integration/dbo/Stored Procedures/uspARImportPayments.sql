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
	

	--MARK #CHANGES AR-5195
	
	DECLARE @MissingGLAccount TABLE (
		strGLAccount NVARCHAR(100)
	)	
	--GET ALL THE INVALID GL ACCOUNT BEFORE THE IMPORTING EVEN STARTS

	INSERT INTO @MissingGLAccount ( strGLAccount )
	
	SELECT
		DISTINCT P1.[agpay_acct_no]
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
		GL.[strExternalId] IS NULL AND 
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
	UNION

	SELECT DISTINCT P1.[agpye_acct_no]
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
		GL.[strExternalId] IS NULL AND 
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
	UNION
	SELECT DISTINCT P1.[agcrd_acct_no]
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
			GL.[strExternalId] IS NULL AND 			
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
	--SELECT * FROM @MissingGLAccount
	IF EXISTS( SELECT TOP 1 1 FROM @MissingGLAccount)
	BEGIN
		DECLARE @EAccountError NVARCHAR(MAX)
		select @EAccountError = COALESCE(@EAccountError + '', '', '''') + strGLAccount  FROM @MissingGLAccount	
		set @EAccountError = ''Missing GL account numbers.  Please create the following missing accounts. '' +  @EAccountError
		RAISERROR (@EAccountError, 16, 1);
		RETURN
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
		,CASE WHEN P1.agpay_chk_no = ''ADJUST'' 
			  THEN Sum(agpay_amt) * -1 
			  ELSE Sum(agpay_amt) END						AS [dblAmountPaid]
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
		,P1.[agpay_chk_no]
		,GL.[inti21Id]
		,CL.[intCompanyLocationId]
		,CUR.[intCurrencyID]	
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	ORDER BY 
		I.[intEntityCustomerId]
		,P1.[agpay_ivc_no]
		,P1.[agpay_rev_dt]
	--MARK #CHANGES AR-5195 DONE
	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON
	
	--INSERT PAYMENT DETAIL

	select agpay_cus_no	,[agpay_ivc_no],[agpay_rev_dt],[agpay_ref_no],agpay_acct_no,
			CASE WHEN P1.agpay_chk_no = ''ADJUST'' THEN Sum(agpay_amt) * -1 ELSE Sum(agpay_amt) END as agpay_amt,agpay_currency
			,agpay_loc_no,[agpay_chk_no],[agpay_cred_origin] into #tmppaydet from agpaymst P1 where RTRIM(LTRIM([agpay_chk_no])) <> ''DISC'' 
		GROUP BY agpay_cus_no,[agpay_ivc_no],[agpay_rev_dt],[agpay_ref_no],agpay_acct_no,agpay_loc_no,agpay_currency,[agpay_chk_no],agpay_cred_origin
				
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
		,SUM(P1.[agpay_amt])     	AS [dblPayment]
		,0							AS [intConcurrencyId]				
	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		#tmppaydet P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS
			AND P.dblAmountPaid = P1.agpay_amt
			AND P.[dtmDatePaid] = (CASE WHEN ISDATE(P1.[agpay_rev_dt]) = 1 THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
									ELSE NULL END)			
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
	--LEFT OUTER JOIN
	--	[tblSMPaymentMethod] PM
	--		ON P.[intPaymentId] = PM.[intPaymentMethodID]
	--		AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
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
		,SUM(P1.[agpay_amt]) * -1  	AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		#tmppaydet P1
			ON P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS
			AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[agpay_ref_no] COLLATE Latin1_General_CI_AS
			AND P.dblAmountPaid = P1.agpay_amt
			AND P.[dtmDatePaid] = (CASE WHEN ISDATE(P1.[agpay_rev_dt]) = 1 THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
									ELSE NULL END)							
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.agpay_cred_origin = ''C''			
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
	--LEFT OUTER JOIN
	--	[tblSMPaymentMethod] PM
	--		ON P.[intPaymentId] = PM.[intPaymentMethodID]
	--		AND  P1.[agpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
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
		,P1.[agpay_chk_no]
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

	--MARK #CHANGES AR-5195 DONE
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
		
	--MARK #CHANGES AR-5195 DONE					
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
								@PaymentId = @PaymentID,
								@Post = 1,
								@BatchId = NULL,
								@UserId = @UserId
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

DECLARE @SC_AccountID int
SET @SC_AccountID = (SELECT TOP 1 intServiceChargeAccountId from tblARCompanyPreference)

DECLARE @MaxPaymentID int, @OriginalMaxPaymentID int, @DefaultPaymenMethodtId int, @DefaultTermId int, @TotalCount int
SET @TotalCount = 0

DECLARE @ysnSrvChrgOnCus BIT = 0
SET @ysnSrvChrgOnCus = CASE WHEN (select pt3cf_serv_chrg_per from ptctlmst where ptctl_key = 3) = ''C'' Then 1
							ELSE 0 END	
							
DECLARE @CRDPaymentMethodID int	
SELECT @CRDPaymentMethodID = intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethodCode = ''CRD''													

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
	
--ORIGIN DATA FIX--

--UPDATE THE ORIGIN PAYMENTS WITH INVALID LOCATION 
update P set ptpay_loc_no = ptivc_loc_no
from ptpaymst P
inner join ptivcmst I on I.ptivc_invc_no = P.ptpay_invc_no
and I.ptivc_cus_no = P.ptpay_cus_no
where ptpay_loc_no is null

--UPDATE THE ORIGIN PAYMENTS WITH INVALID CHECK-NO.
Update ptpaymst set ptpay_check_no = ''CREDIT''
where ptpay_check_no is null and ptpay_pay_type = ''CRD''

Update ptpaymst set ptpay_ref_no = ptpay_check_no
where ptpay_ref_no is null and ptpay_pay_type = ''CRD''

--FIX THE CREDIT MEMO PAY TYPE
 Update pay set pay.ptpay_orig_crd_pay_type = ''CRM'' from ptpaymst pay
 inner join ptivcmst ivc on  ptivc_invc_no = ptpay_ref_no
 where [ptpay_orig_crd_pay_type] is NULL and ptivc_type = ''C''
 and ptpay_pay_type <> ''SRV''
 
 select * INTO #tempadj from ptpaymst where ptpay_pay_type = ''ADJ''and ptpay_invc_no in 
 (select ptcrd_invc_no from ptcrdmst where ptcrd_cus_no = ptpay_cus_no and ptcrd_type in (''P'',''U''))

IF(@Checking = 1)   
	BEGIN 
		IF (SELECT COUNT(*) FROM tblARPayment WHERE ysnImportedFromOrigin = 1) > 0
		BEGIN RETURN @Total END

		--POSTED PAYMENTS 
		SELECT NULL	
		FROM
			[ptpaymst] P1				--Origin Posted Payments Table
		INNER JOIN ptcusmst CUS ON P1.ptpay_cus_no = CUS.ptcus_bill_to
		INNER JOIN
			[tblARCustomer] C
				ON  CUS.[ptcus_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS
		INNER JOIN
			[tblSMCompanyLocation] IL
				ON P1.[ptpay_ivc_loc_no] COLLATE Latin1_General_CI_AS = IL.[strLocationNumber] COLLATE Latin1_General_CI_AS	
		INNER JOIN
			[tblARInvoice] I
				ON I.[ysnPosted] = 1
				AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
				AND I.[intEntityCustomerId] = C.[intEntityId] AND I.intCompanyLocationId = IL.intCompanyLocationId				 						
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
			RTRIM(LTRIM(P1.ptpay_pay_type)) NOT IN (''DSC'',''SRV'') --AND P1.[ptpay_pay_type] <> ''SRV'' AND P1.[ptpay_pay_type] <> ''RSV''
			AND P1.ptpay_invc_no NOT in (select ptpay_invc_no from #tempadj where  P1.ptpay_cus_no = ptpay_cus_no)
			--AND NOT EXISTS
			--	(	SELECT NULL 
			--		FROM tblARPayment a
			--		INNER JOIN tblARPaymentDetail ad
			--			ON a.[intPaymentId] = ad.[intPaymentId] 
			--		WHERE
			--			a.[ysnPosted] = 1
			--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
			--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
			--			AND a.[dtmDatePaid] = (CASE 
			--										WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
			--											THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
			--										ELSE
			--											NULL 
			--									END)
			--			AND a.[intAccountId] = CASE WHEN P1.ptpay_pay_type = ''SRV''THEN @SC_AccountID ELSE ISNULL(GL.[inti21Id],0)END
			--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
			--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
			--	)
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
			RTRIM(LTRIM(P1.[ptpye_pay_type])) <> ''DISC''
			--AND NOT EXISTS
			--	(	SELECT NULL 
			--		FROM tblARPayment a
			--		INNER JOIN tblARPaymentDetail ad
			--			ON a.[intPaymentId] = ad.[intPaymentId] 
			--		WHERE
			--			a.[ysnPosted] = 0
			--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
			--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
			--			AND a.[dtmDatePaid] = (CASE 
			--										WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
			--											THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
			--										ELSE
			--											NULL 
			--									END)
			--			AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
			--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
			--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS				
			--	)
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
			AND P1.ptcrd_type IN (''P'',''U'')
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
						AND a.[intAccountId] = ISNULL(GL.[inti21Id],@CR_AccounID)
						AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
						AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptcrd_invc_no] COLLATE Latin1_General_CI_AS					
						AND a.dblUnappliedAmount <> 0
				)		
		
		SET @TotalCount = @TotalCount + @@ROWCOUNT 
		SET @Total = @TotalCount 

		RETURN @Total  
	END   
	
	--MARK #CHANGES AR-5195
	
	DECLARE @MissingGLAccount TABLE (
		strGLAccount NVARCHAR(100)
	)	
	--GET ALL THE INVALID GL ACCOUNT BEFORE THE IMPORTING EVEN STARTS

	INSERT INTO @MissingGLAccount ( strGLAccount )
	SELECT DISTINCT P1.[ptpay_acct_no] 
	FROM
		[ptpaymst] P1				
	INNER JOIN
		[tblARCustomer] C
			--ON  CUS.[ptcus_bill_to] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS
			on  P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
		 						
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	left  JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		GL.[strExternalId] IS NULL AND 				
		ptpay_pay_type NOT IN (''DSC'', ''SRV'') 
		and ptpay_no <> 0 and ptpay_amt <> 0
	UNION
	SELECT DISTINCT P1.[ptcrd_acct_no] 
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
		GL.[strExternalId] IS NULL AND P1.ptcrd_type NOT IN (''C'')
	UNION
	SELECT DISTINCT P1.[ptpay_acct_no] 
	FROM
		[ptpaymst] P1				--Origin Posted Payments Table
	--left JOIN ptcusmst CUS ON P1.ptpay_cus_no = CUS.ptcus_cus_no
	--few customer master data is missing in origin. So less records with this join.
	INNER JOIN
		[tblARCustomer] C
			--ON  CUS.[ptcus_bill_to] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS
			on  P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCompanyLocation] IL
			ON P1.[ptpay_ivc_loc_no] COLLATE Latin1_General_CI_AS = IL.[strLocationNumber] COLLATE Latin1_General_CI_AS	
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
			AND I.[intEntityCustomerId] = C.[intEntityId] AND I.intCompanyLocationId = IL.intCompanyLocationId	
			AND I.strComments = ''SERVICE CHARGES''			 						
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	left  JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE   
		GL.[strExternalId] IS NULL AND 
		ptpay_pay_type IN (''DSC'') 
		and ptpay_no <> 0 and ptpay_amt <> 0	
	UNION
	SELECT DISTINCT P1.[ptpye_acct_no]
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
		GL.[strExternalId] IS NULL AND 
		RTRIM(LTRIM(P1.[ptpye_check_no])) <> ''DISC''
		--AND NOT EXISTS
		--	(	SELECT NULL 
		--		FROM tblARPayment a
		--		INNER JOIN tblARPaymentDetail ad
		--			ON a.[intPaymentId] = ad.[intPaymentId] 
		--		WHERE
		--			a.[ysnPosted] = 0
		--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
		--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
		--			AND a.[dtmDatePaid] = (CASE 
		--										WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
		--											THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
		--										ELSE
		--											NULL 
		--									END)
		--			AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
		--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
		--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS					
		--	)	


	--SELECT * FROM @MissingGLAccount
	IF EXISTS( SELECT TOP 1 1 FROM @MissingGLAccount)
	BEGIN
		DECLARE @EAccountError NVARCHAR(MAX)
		select @EAccountError = COALESCE(@EAccountError + '', '', '''') + strGLAccount  FROM @MissingGLAccount	
		set @EAccountError = ''Missing GL account numbers.  Please create the following missing accounts. '' +  @EAccountError
		RAISERROR (@EAccountError, 16, 1);
		RETURN
	END




	--POSTED PAYMENTS
	--INSERT PAYMENT HEADER for all types
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
		C.[intEntityId] 									AS [intEntityCustomerId]
	,(select intCurrencyId from tblARCustomer C where P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber]) AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		--,CASE WHEN P1.ptpay_pay_type = ''SRV''THEN 0 ELSE ISNULL(GL.[inti21Id],0)	END	AS [intAccountId]
		,ISNULL(GL.[inti21Id],0)								AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		--,CASE WHEN P1.ptpay_pay_type = ''ADJ'' THEN P1.ptpay_amt * -1 ELSE P1.ptpay_amt END AS [dblAmountPaid]
	--	,P1.ptpay_amt										AS [dblAmountPaid]
		,0										AS [dblAmountPaid] -- update this later
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
	--	,ltrim(rtrim(P1.[ptpay_invc_no]))+''_''+CONVERT(CHAR(3),ptpay_no)+''_''+CONVERT(CHAR(3),ptpay_orig_cr_seq_no)						AS [strPaymentInfo]
		,ltrim(rtrim(P1.[ptpay_invc_no]))					AS [strPaymentInfo]
		--,P1.[ptpay_ref_no]									AS [strNotes]
		,ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no)									AS [strNotes]
		,0													AS [ysnApplytoBudget]						
		,1													AS [ysnPosted]	
		,1											AS [intEntityId]										
		,0
		,1
		,1

	FROM
		[ptpaymst] P1				--Origin Posted Payments Table
	--left JOIN ptcusmst CUS ON P1.ptpay_cus_no = CUS.ptcus_cus_no
	--few customer master data is missing in origin. So less records with this join.
	INNER JOIN
		[tblARCustomer] C
			--ON  CUS.[ptcus_bill_to] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS
			on  P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
		 						
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	left  JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		--RTRIM(LTRIM(P1.ptpay_pay_type)) NOT IN (''DSC'',''SRV'') --AND P1.[ptpay_pay_type] <> ''SRV'' AND P1.[ptpay_pay_type] <> ''RSV''
		ptpay_pay_type NOT IN (''DSC'', ''SRV'') 
		and ptpay_no <> 0 and ptpay_amt <> 0
		--AND NOT EXISTS
		--	(	SELECT NULL 
		--		FROM tblARPayment a
		--		INNER JOIN tblARPaymentDetail ad
		--			ON a.[intPaymentId] = ad.[intPaymentId] 
		--		WHERE
		--			a.[ysnPosted] = 1
		--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
		--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
		--			AND a.[dtmDatePaid] = (CASE 
		--										WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
		--											THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt] AS CHAR(12)), 112) 
		--										ELSE
		--											NULL 
		--									END)
		--			AND a.[intAccountId] = CASE WHEN P1.ptpay_pay_type = ''SRV''THEN @SC_AccountID ELSE ISNULL(GL.[inti21Id],0)END
		--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
		--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS					
		--	)		
	--GROUP BY
	--	I.[intEntityCustomerId]
	--	,P1.[ptpay_invc_no]
	--	,P1.[ptpay_rev_dt]
	--	,P1.[ptpay_ref_no]
	--	,GL.[inti21Id]
	--	,CL.[intCompanyLocationId]
	--	,I.[intCurrencyId]	
	--	,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)				
	--	,P1.[ptpay_pay_type]
	--ORDER BY 
	--	I.[intEntityCustomerId]
	--	,P1.[ptpay_invc_no]
	--	,P1.[ptpay_rev_dt]


	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON


	-- INSERT PREPAY/REGULAR CREDIT PAYMENTS (i21 requires a payment record for all prepays. Origin does not have this.
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
			,[ysnImportedFromOrigin]
			,[intEntityId] 
			,ysnInvoicePrepayment
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
			,(P1.ptcrd_amt)	* -1								AS [dblAmountPaid]
			,0									   				AS [dblUnappliedAmount]
			,0													AS [dblOverpayment]
			,0													AS [dblBalance]
			,LTRIM(RTRIM(P1.ptcrd_invc_no))+''_''+CONVERT(CHAR(3),ptcrd_seq_no) AS [strPaymentInfo]
			,''ORIGIN''               							AS [strNotes] 
			,0													AS [ysnApplytoBudget]						
			,1													AS [ysnPosted]	
			,1													AS [ysnImportedFromOrigin]
			,@UserId											AS [intEntityId]										
			,1
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
		WHERE  P1.ptcrd_type NOT IN (''C'')

 	--INSERT PAYMENT HEADER for Service Charge invoice that have DISCOUNTS
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
		C.[intEntityId] 									AS [intEntityCustomerId]
	--case C.intEntityId when null then (select intEntityId from tblARCustomer C where P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber])
	--else C.intEntityId end AS [intEntityCustomerId]
	--	,C.[intCurrencyId]									AS [intCurrencyId]
	,(select intCurrencyId from tblARCustomer C where P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber]) AS [intCurrencyId]
		,(CASE 
			WHEN ISDATE(P1.[ptpay_rev_dt]) = 1 
				THEN CONVERT(DATE, CAST(P1.[ptpay_rev_dt]	AS CHAR(12)), 112) 
			ELSE
				NULL 
		END)												AS [dtmDatePaid]
		--,CASE WHEN P1.ptpay_pay_type = ''SRV''THEN 0 ELSE ISNULL(GL.[inti21Id],0)	END	AS [intAccountId]
		,ISNULL(GL.[inti21Id],0)								AS [intAccountId]
		,ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	AS [intPaymentMethodId] 
		,CL.[intCompanyLocationId] 							AS [intLocationId]
		--,CASE WHEN P1.ptpay_pay_type = ''ADJ'' THEN P1.ptpay_amt * -1 ELSE P1.ptpay_amt END AS [dblAmountPaid]
	--	,P1.ptpay_amt										AS [dblAmountPaid]
		,0										AS [dblAmountPaid] -- update this later
		,0													AS [dblUnappliedAmount]
		,0													AS [dblOverpayment]
		,0													AS [dblBalance]
	--	,ltrim(rtrim(P1.[ptpay_invc_no]))+''_''+CONVERT(CHAR(3),ptpay_no)+''_''+CONVERT(CHAR(3),ptpay_orig_cr_seq_no)						AS [strPaymentInfo]
		,ltrim(rtrim(P1.[ptpay_invc_no]))					AS [strPaymentInfo]
		--,P1.[ptpay_ref_no]									AS [strNotes]
		,ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no)									AS [strNotes]
		,0													AS [ysnApplytoBudget]						
		,1													AS [ysnPosted]	
		,1											AS [intEntityId]										
		,0
		,1
		,1

	FROM
		[ptpaymst] P1				--Origin Posted Payments Table
	--left JOIN ptcusmst CUS ON P1.ptpay_cus_no = CUS.ptcus_cus_no
	--few customer master data is missing in origin. So less records with this join.
	INNER JOIN
		[tblARCustomer] C
			--ON  CUS.[ptcus_bill_to] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS
			on  P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	INNER JOIN
		[tblSMCompanyLocation] IL
			ON P1.[ptpay_ivc_loc_no] COLLATE Latin1_General_CI_AS = IL.[strLocationNumber] COLLATE Latin1_General_CI_AS	
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
			AND I.[intEntityCustomerId] = C.[intEntityId] AND I.intCompanyLocationId = IL.intCompanyLocationId	
			AND I.strComments = ''SERVICE CHARGES''			 						
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	left  JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = P.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	WHERE 
		ptpay_pay_type IN (''DSC'') 
		and ptpay_no <> 0 and ptpay_amt <> 0	

--INSERT PAYMENT DETAIL	for Invoice, DM, Cash and Cash Refund
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
		,CASE WHEN P1.ptpay_pay_type = ''ADJ'' THEN P1.ptpay_amt * -1 ELSE P1.ptpay_amt END AS [dblPayment]
		--,P1.ptpay_amt				AS [dblPayment]
		,0							AS [intConcurrencyId]		
	FROM
	ptpaymst P1
		join ptivcmst on ptpay_invc_no = ptivc_invc_no and ptpay_cus_no = ptivc_cus_no and ptpay_ivc_loc_no = ptivc_loc_no
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptpay_ivc_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on P1.ptpay_invc_no collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId 
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId
		join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS
		--	and P.[strNotes]  = ptpay_ref_no collate SQL_Latin1_General_CP1_CS_AS 
		and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 

	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
		where ptpay_pay_type NOT IN (''DSC'',''SRV'',''ADJ'') and ptpay_no <> 0 and ptpay_amt <> 0
			and ptivc_type in (''I'',''D'',''S'',''R'')


--INSERT ADJUST PAYMENT DETAIL	for Invoice, DM, Cash and Cash Refund
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
		,CASE WHEN P1.ptpay_pay_type = ''ADJ'' THEN P1.ptpay_amt * -1 ELSE P1.ptpay_amt END AS [dblPayment]
		--,P1.ptpay_amt				AS [dblPayment]
		,0							AS [intConcurrencyId]		
	FROM
	ptpaymst P1
		join ptivcmst on ptpay_invc_no = ptivc_invc_no and ptpay_cus_no = ptivc_cus_no and ptpay_ivc_loc_no = ptivc_loc_no
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptpay_ivc_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on P1.ptpay_invc_no collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId 
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId
	join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS
			and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
		where ptpay_pay_type IN (''ADJ'') and ptpay_no <> 0 and ptpay_amt <> 0 AND ptpay_cred_origin is null
			and ptivc_type in (''I'',''D'',''S'',''R'')
	
	--INSERT CREDIT MEMO DETAIL	-- payments applied by credit memos. Creates a negative payment record.		
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
		,P1.[ptpay_amt] * -1	AS [dblPayment]
		,0							AS [intConcurrencyId]		

	FROM
		ptpaymst P1				--Origin Posted Payments Table
		join ptcrdmst on ptpay_cus_no = ptcrd_cus_no and ptpay_ref_no = ptcrd_invc_no and ptcrd_seq_no = ptpay_orig_cr_seq_no and ptcrd_rev_dt = ptpay_orig_rev_dt
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptcrd_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on P1.ptpay_ref_no collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId 
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId 
			join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS
			and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P.[intAccountId] = GL.[inti21Id]
				AND  P1.[ptpay_acct_no] = GL.[strExternalId]	
		where ptpay_pay_type NOT IN (''DSC'',''SRV'') and ptpay_no <> 0 and ptpay_amt <> 0
		and ptcrd_type = ''C''

	--INSERT PREPAID/REGULAR CREDIT DETAIL	- A payment is required for prepayment in i21. creates a negative payment record
	INSERT INTO [tblARPaymentDetail]
			([intPaymentId]
			,[intInvoiceId]
			,[strTransactionNumber]
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
			,I.strInvoiceNumber
			,(CASE WHEN I.[intTermId] IS NULL OR I.[intAccountId] = 0 
				THEN @DefaultTermId 
				ELSE I.[intTermId] 
			END)				AS [intTermId]
			,(CASE WHEN I.[intAccountId] IS NULL OR	I.[intAccountId] = 0 
				THEN P.[intAccountId] 
				ELSE I.[intAccountId] 
			END)						AS [intAccountId] 
			,I.[dblInvoiceTotal] * -1	AS [dblInvoiceTotal]  
			,0			 				AS [dblDiscount]
			,0			 				AS [dblDiscountAvailable]
			,0							AS [dblAmountDue]
			,I.[dblInvoiceTotal] * -1	AS [dblPayment]
			,0							AS [intConcurrencyId]	
			FROM
				[ptcrdmst] P1				--Origin Credits Table
			INNER JOIN
				[tblARCustomer] C
					ON P1.[ptcrd_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			INNER JOIN
				[tblARPayment] P
					ON  P.intEntityCustomerId = C.intEntityId
					AND P.strPaymentInfo COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(P1.ptcrd_invc_no)) COLLATE Latin1_General_CI_AS+''_''+CONVERT(CHAR(3),ptcrd_seq_no)
					AND P.dtmDatePaid = (CASE 
													WHEN ISDATE(P1.[ptcrd_rev_dt]) = 1 
														THEN CONVERT(DATE, CAST(P1.[ptcrd_rev_dt] AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
--					CONVERT(DATE, CAST(P1.[ptcrd_rev_dt] AS CHAR(12)), 112)
					--AND P.dblAmountPaid = P1.ptcrd_amt * -1
			INNER JOIN
				[tblARInvoice] I
					ON  P.intEntityCustomerId = I.intEntityCustomerId
					AND P.strPaymentInfo COLLATE Latin1_General_CI_AS = I.strInvoiceOriginId
					AND P.dtmDatePaid = I.dtmDate
					--AND P.dblAmountPaid = I.dblInvoiceTotal * -1
			LEFT OUTER JOIN
				[tblGLCOACrossReference] GL
					ON P1.[ptcrd_acct_no] = GL.[strExternalId]
			INNER JOIN
				[tblSMCompanyLocation] CL
					ON P1.[ptcrd_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
			WHERE P1.ptcrd_type in (''P'',''U'')

				
	--INSERT PREPAID/REGULAR CREDIT DETAIL-APPLIED			
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
		,P1.[ptpay_amt] * -1		AS [dblPayment]
		,0							AS [intConcurrencyId]		
	FROM
		ptpaymst P1				--Origin Posted Payments Table
		join ptcrdmst on ptpay_cus_no = ptcrd_cus_no and ptpay_ref_no = ptcrd_invc_no and ptcrd_seq_no = ptpay_orig_cr_seq_no and ptcrd_rev_dt = ptpay_orig_rev_dt
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptcrd_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on LTRIM(RTRIM(ptcrd_invc_no))+''_''+CONVERT(CHAR(3),ptcrd_seq_no) collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId
			and I.dtmDate = (CASE 
													WHEN ISDATE(ptpay_orig_rev_dt) = 1 
														THEN CONVERT(DATE, CAST(ptpay_orig_rev_dt AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
			join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS
			and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P.[intAccountId] = GL.[inti21Id]
				AND  P1.[ptpay_acct_no] = GL.[strExternalId]	
		where ptpay_pay_type NOT IN (''DSC'',''SRV'',''ADJ'') and ptpay_no <> 0 and ptpay_amt <> 0
		and ptcrd_type in (''P'',''U'')

	--INSERT ADJUSTMENTS PREPAID/REGULAR CREDIT DETAIL-APPLIED			
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
		,P1.[ptpay_amt] * -1		AS [dblPayment] --adj is adding to prepay
		,0							AS [intConcurrencyId]		
	FROM
		ptpaymst P1				--Origin Posted Payments Table
		join ptcrdmst on ptpay_cus_no = ptcrd_cus_no and ptpay_ref_no = ptcrd_invc_no and ptcrd_seq_no = ptpay_orig_cr_seq_no and ptcrd_rev_dt = ptpay_orig_rev_dt
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptpay_ivc_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on LTRIM(RTRIM(ptcrd_invc_no))+''_''+CONVERT(CHAR(3),ptcrd_seq_no) collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId 
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId 
			and I.dtmDate = (CASE 
													WHEN ISDATE(ptpay_orig_rev_dt) = 1 
														THEN CONVERT(DATE, CAST(ptpay_orig_rev_dt AS CHAR(12)), 112) 
													ELSE
														NULL 
												END)
			join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS 
			and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 

		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P.[intAccountId] = GL.[inti21Id]
				AND  P1.[ptpay_acct_no] = GL.[strExternalId]	
		where ptpay_pay_type = ''ADJ'' and ptpay_no <> 0 and ptpay_amt <> 0
		and ptcrd_type in (''P'',''U'')

--	INSERT PAYMENT DETAILS FOR SERVICE CHARGE INVOICE that have DISCOUNTS
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
		, P1.ptpay_amt				AS [dblPayment]
		--,P1.ptpay_amt				AS [dblPayment]
		,0							AS [intConcurrencyId]		
	FROM
	ptpaymst P1
		join ptivcmst on ptpay_invc_no = ptivc_invc_no and ptpay_cus_no = ptivc_cus_no and ptpay_ivc_loc_no = ptivc_loc_no
		join tblARCustomer c on P1.ptpay_cus_no collate SQL_Latin1_General_CP1_CS_AS = strCustomerNumber
		join tblSMCompanyLocation L on L.strLocationNumber = ptpay_ivc_loc_no collate SQL_Latin1_General_CP1_CS_AS 
		join tblARInvoice I on P1.ptpay_invc_no collate SQL_Latin1_General_CP1_CS_AS = I.strInvoiceOriginId 
			and I.intEntityCustomerId = c.intEntityId and I.intCompanyLocationId = L.intCompanyLocationId
			AND I.strComments = ''SERVICE CHARGES''	
		join tblARPayment P on [strPaymentInfo] = ltrim(rtrim(P1.[ptpay_invc_no])) COLLATE Latin1_General_CI_AS
		and P.[strNotes]  = ptpay_cus_no+CONVERT(CHAR(3),ptpay_loc_no)+CONVERT(CHAR(3),ptpay_no) collate SQL_Latin1_General_CP1_CS_AS 
		LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
		where ptpay_pay_type IN (''DSC'') and ptpay_no <> 0 and ptpay_amt <> 0
			and ptivc_type in (''I'',''D'',''S'',''R'')

	-- UPDATE PREPAYMENT INVOICES WITH PAYMENT ID  										
	update I SET I.intPaymentId = PD.intPaymentId from tblARPaymentDetail PD
	INNER JOIN tblARInvoice I ON I.intInvoiceId = PD.intInvoiceId
	where PD.intPaymentId in (select intPaymentId from tblARPayment where ysnInvoicePrepayment = 1 and ysnImportedFromOrigin = 1)			

	--UPDATE DETAIL DISCOUNT
	UPDATE 
		tblARPaymentDetail 
	SET
		[dblDiscount] = P1.[ptpay_amt]			
	FROM
		[tblARPayment] P				--Origin Posted Payments Table
	INNER JOIN	
		[ptpaymst] P1
			ON  P1.ptpay_pay_type = ''DSC    ''
			AND P.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
			--AND P.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS				
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
	--UPDATE
	--	tblARPayment 
	--SET	
	--	[strNotes] = NULL
	--WHERE
	--	[intPaymentId] > @MaxPaymentID 
		
	--UPDATE 
	--	tblARPayment 
	--SET
	--	[strNotes] = P1.[ptpay_note] 			
	--FROM
	--	[ptpaymst] P1				--Origin Posted Payments Table															
	--INNER JOIN
	--	[tblARInvoice] I
	--		ON I.[ysnPosted] = 1
	--		AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	--INNER JOIN
	--	[tblARCustomer] C
	--		ON  I.[intEntityCustomerId] = C.[intEntityId] 
	--		AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	--LEFT OUTER JOIN
	--	[tblGLCOACrossReference] GL
	--		ON P1.[ptpay_acct_no] = GL.[strExternalId]
	--LEFT OUTER JOIN
	--	[tblSMPaymentMethod] PM
	--		ON P1.[ptpay_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	--WHERE
	--	(P1.[ptpay_note] IS NOT NULL OR P1.[ptpay_note] = '''')
	--	AND tblARPayment.[intPaymentId] > @MaxPaymentID
	--	AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
	--	AND tblARPayment.[intCurrencyId] = I.[intCurrencyId]
	--	AND tblARPayment.[intAccountId] = GL.[inti21Id]
	--	AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
	--	AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS
	--	AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpay_ref_no] COLLATE Latin1_General_CI_AS	
	
	
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
		--AND NOT EXISTS
		--	(	SELECT NULL 
		--		FROM tblARPayment a
		--		INNER JOIN tblARPaymentDetail ad
		--			ON a.[intPaymentId] = ad.[intPaymentId] 
		--		WHERE
		--			a.[ysnPosted] = 0
		--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
		--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
		--			AND a.[dtmDatePaid] = (CASE 
		--										WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
		--											THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
		--										ELSE
		--											NULL 
		--									END)
		--			AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
		--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodID],@DefaultPaymenMethodtId)	
		--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS					
		--	)		
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
	--MARK #CHANGES AR-5195 DONE

	SET @TotalCount = @TotalCount + @@ROWCOUNT
	SET @Total = @TotalCount 
	SET NOCOUNT ON
	
	--INSERT UNPOSTED PAYMENT DETAIL
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
		--AND NOT EXISTS
		--	(	SELECT NULL 
		--		FROM tblARPayment a
		--		INNER JOIN tblARPaymentDetail ad
		--			ON a.[intPaymentId] = ad.[intPaymentId] 
		--		WHERE
		--			a.[ysnPosted] = 0
		--			AND a.[intEntityCustomerId] = I.[intEntityCustomerId] 
		--			AND ad.[intInvoiceId] = I.[intInvoiceId] 
		--			AND a.[dtmDatePaid] = (CASE 
		--										WHEN ISDATE(P1.[ptpye_rev_dt]) = 1 
		--											THEN CONVERT(DATE, CAST(P1.[ptpye_rev_dt] AS CHAR(12)), 112) 
		--										ELSE
		--											NULL 
		--									END)
		--			AND a.[intAccountId] = ISNULL(GL.[inti21Id],0)
		--			AND a.[intPaymentMethodId] = ISNULL(P.[intPaymentMethodId],@DefaultPaymenMethodtId)	
		--			AND a.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS					
		--	)			
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
	--UPDATE
	--	tblARPayment 
	--SET	
	--	[strNotes] = NULL
	--WHERE
	--	[intPaymentId] > @MaxPaymentID 
		
	--UPDATE 
	--	tblARPayment 
	--SET
	--	[strNotes] = P1.[ptpye_note] 			
	--FROM
	--	[ptpyemst] P1				--Origin UnPosted Payments Table															
	--INNER JOIN
	--	[tblARInvoice] I
	--		ON I.[ysnPosted] = 1
	--		AND P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	--INNER JOIN
	--	[tblARCustomer] C
	--		ON  I.[intEntityCustomerId] = C.[intEntityId] 
	--		AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	--LEFT OUTER JOIN
	--	[tblGLCOACrossReference] GL
	--		ON P1.[ptpye_acct_no] = GL.[strExternalId]
	--LEFT OUTER JOIN
	--	[tblSMPaymentMethod] PM
	--		ON P1.[ptpye_pay_type] COLLATE Latin1_General_CI_AS = PM.strPaymentMethodCode COLLATE Latin1_General_CI_AS
	--WHERE
	--	(P1.[ptpye_note] IS NOT NULL OR P1.[ptpye_note] = '''')
	--	AND tblARPayment.[intPaymentId] > @MaxPaymentID
	--	AND tblARPayment.[intEntityCustomerId] = C.[intEntityId]
	--	AND tblARPayment.[intCurrencyId] = I.[intCurrencyId]
	--	AND tblARPayment.[intAccountId] = GL.[inti21Id]
	--	AND tblARPayment.[intPaymentId] = PM.[intPaymentMethodID]
	--	AND tblARPayment.[strNotes] COLLATE Latin1_General_CI_AS = P1.[ptpye_inc_ref] COLLATE Latin1_General_CI_AS
	--	AND tblARPayment.[strPaymentInfo] COLLATE Latin1_General_CI_AS = P1.[ptpye_ref_no] COLLATE Latin1_General_CI_AS	


--this updating is mutiplying amount for few incoices. ptpay_cus_no = ''0000002017'' and ptpay_invc_no = ''000196''		
	----UPDATE HEADER AMOUNT PAID 		
	--UPDATE
	--	tblARPayment 
	--SET
	--	[dblAmountPaid] = dtl.[dblPayment] 
	--FROM
	--	(
	--	SELECT
	--		COUNT([intPaymentId])	AS [IDCount]
	--		,SUM([dblPayment])		AS [dblPayment]
	--		,[intPaymentId]
	--	FROM
	--		tblARPaymentDetail 		
	--	GROUP BY [intPaymentId]
	--	) dtl
	--WHERE
	--	tblARPayment.[intPaymentId] > @OriginalMaxPaymentID	
	--	AND dtl.[IDCount] > 1
	--	AND tblARPayment.[intPaymentId] = dtl.[intPaymentId] 

	
	
	--FIX IMPORTED INVOICES MISSING TERM
	UPDATE
		tblARInvoice 
	SET
		intTermId = @DefaultTermId 
	WHERE
		(intTermId IS NULL OR intTermId = 0)
		AND strInvoiceOriginId IS NOT NULL
		AND LTRIM(RTRIM(strInvoiceOriginId)) <> ''''						  				  			

		--UPDATE PAYMENT DISCOUNTS	
		DECLARE @ptpay_cus_no AS char(10),@ptpay_invc_no char(6), @ptpay_ivc_loc_no char(3)
				,@ptpay_pay_type char(3), @ptpay_amt [decimal](11, 2)
				
		DECLARE dsc_cursor CURSOR
		FOR
			select ptpay_cus_no, ptpay_invc_no,[ptpay_ivc_loc_no], ptpay_pay_type, sum(ptpay_amt) as ptpay_amt
		    from ptpaymst where ptpay_pay_type = ''DSC'' group by ptpay_cus_no, ptpay_invc_no, [ptpay_ivc_loc_no], ptpay_pay_type
		OPEN dsc_cursor
		FETCH NEXT
		FROM dsc_cursor
		INTO @ptpay_cus_no ,@ptpay_invc_no, @ptpay_ivc_loc_no,@ptpay_pay_type, @ptpay_amt
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE TOP (1) PD SET PD.dblDiscount = @ptpay_amt
				FROM
					[tblARPayment] P				--Origin Posted Payments Table
				INNER JOIN
					[tblARCustomer] C
						ON P.[intEntityCustomerId] = C.[intEntityId]
						AND C.strCustomerNumber = @ptpay_cus_no COLLATE Latin1_General_CI_AS
				INNER JOIN
					[tblSMCompanyLocation] CL
						ON  CL.[strLocationNumber] COLLATE Latin1_General_CI_AS = @ptpay_ivc_loc_no COLLATE Latin1_General_CI_AS 
				INNER JOIN tblARPaymentDetail PD ON PD.[intPaymentId] = P.[intPaymentId] 
				INNER JOIN
					[tblARInvoice] I
						ON I.[ysnPosted] = 1
						AND PD.[intInvoiceId] = I.[intInvoiceId]
						AND @ptpay_invc_no COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
						AND I.[intEntityCustomerId] = C.[intEntityId] AND I.intCompanyLocationId = CL.intCompanyLocationId
						AND ISNULL(I.strComments,'''') <> ''SERVICE CHARGES''
				WHERE
					P.[ysnPosted] = 1
--					AND P.[intPaymentId] > @MaxPaymentID 
		
				FETCH NEXT
		FROM dsc_cursor
		INTO  @ptpay_cus_no ,@ptpay_invc_no, @ptpay_ivc_loc_no,@ptpay_pay_type, @ptpay_amt				
		END	
		CLOSE dsc_cursor
		DEALLOCATE dsc_cursor		

			
			
	--UPDATE ORIGIN SERVICE CHARGES IN PAYMENT DETAILS
		DECLARE @intInvoiceId  AS INT, @dblInterest  AS NUMERIC (18, 6)
		DECLARE srv_cursor CURSOR
		FOR
			select intInvoiceId,dblInterest  from tblARInvoice where dblInterest <>0 and ysnImportedFromOrigin = 1
			AND ysnPaid = 1
		OPEN srv_cursor
		FETCH NEXT
		FROM srv_cursor
		INTO  @intInvoiceId, @dblInterest
		WHILE @@FETCH_STATUS = 0
		BEGIN
				UPDATE TOP (1) PD SET PD.dblInterest = @dblInterest FROM  tblARPaymentDetail PD 
				WHERE PD.intInvoiceId = @intInvoiceId			
		FETCH NEXT
		FROM srv_cursor
		INTO @intInvoiceId, @dblInterest				
		END	
		CLOSE srv_cursor
		DEALLOCATE srv_cursor		
		
--update payment header with total amount paid		
	UPDATE
		tblARPayment 
	SET
		[dblAmountPaid] = dtl.[dblPayment] 
	FROM
		(
		SELECT
			SUM([dblPayment])+sum(isnull(dblDiscount,0))		AS [dblPayment]
			,[intPaymentId]
		FROM
			tblARPaymentDetail 		
		GROUP BY [intPaymentId]
		) dtl
	WHERE
		tblARPayment.[intPaymentId] = dtl.[intPaymentId] 	
END
			')
END