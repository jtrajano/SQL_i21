﻿GO

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
				AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
				AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
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
		,1													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0

	FROM
		[agpaymst] P1				--Origin Posted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON I.[ysnPosted] = 1
			AND P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON  I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityCustomerId]
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
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
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
		,0													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
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
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
			ON I.[ysnPosted] = 1
			AND P1.[agpye_inc_ref] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS  						
	INNER JOIN
		[tblARCustomer] C
			ON  I.[intEntityCustomerId] = C.[intEntityCustomerId] 
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
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityCustomerId]
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
END
			')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
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
			[ptpaymst] P1				--Origin Posted Payments Table
		INNER JOIN
			[tblARInvoice] I
				ON I.[ysnPosted] = 1
				AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
		INNER JOIN
			[tblARCustomer] C
				ON P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
				AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptpay_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptpay_pay_type] = CAST(P.strPaymentMethodCode AS int)
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
				AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
		LEFT OUTER JOIN
			[tblGLCOACrossReference] GL
				ON P1.[ptpye_acct_no] = GL.[strExternalId]
		LEFT OUTER JOIN
			[tblSMPaymentMethod] P
				ON P1.[ptpye_pay_type] = CAST(P.strPaymentMethodCode AS int)
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
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
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
		,1													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
		,0

	FROM
		[ptpaymst] P1				--Origin Posted Payments Table
	INNER JOIN
		[tblARInvoice] I
			ON I.[ysnPosted] = 1
			AND P1.[ptpay_invc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
	INNER JOIN
		[tblARCustomer] C
			ON P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpay_pay_type] = CAST(P.[strPaymentMethodCode] AS int)			
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
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
			ON  I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpay_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[ptpay_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		(P1.[ptpay_note] IS NOT NULL OR P1.[ptpay_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityCustomerId]
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
		,[ysnPosted]
		,[intEntityId] 
		,[intConcurrencyId]
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
		,0													AS [ysnPosted]	
		,@UserId											AS [intEntityId]										
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
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpye_acct_no] = GL.[strExternalId]
	INNER JOIN
		[tblSMCompanyLocation] CL
			ON P1.[ptpye_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
	LEFT OUTER JOIN
		[tblSMPaymentMethod] P
			ON P1.[ptpye_pay_type] = CAST(P.[strPaymentMethodCode] AS int)			
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
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
			ON P.[intEntityCustomerId] = C.[intEntityCustomerId]
			AND I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P.[intAccountId] = GL.[inti21Id]
			AND  P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P.[intPaymentId] = PM.[intPaymentMethodID]
			AND  P1.[ptpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
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
			ON  I.[intEntityCustomerId] = C.[intEntityCustomerId] 
			AND P1.[ptpye_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
	LEFT OUTER JOIN
		[tblGLCOACrossReference] GL
			ON P1.[ptpye_acct_no] = GL.[strExternalId]
	LEFT OUTER JOIN
		[tblSMPaymentMethod] PM
			ON P1.[ptpye_pay_type] = CAST(PM.strPaymentMethodCode AS int)					
	WHERE
		(P1.[ptpye_note] IS NOT NULL OR P1.[ptpye_note] = '''')
		AND tblARPayment.[intPaymentId] > @MaxPaymentID
		AND tblARPayment.[intEntityCustomerId] = C.[intEntityCustomerId]
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
END
			')
END