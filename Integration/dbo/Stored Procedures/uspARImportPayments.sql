GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportPayments')
	DROP PROCEDURE uspARImportPayments
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE uspARImportPayments 
				@Checking BIT = 0,  
				@UserId INT = 0,  
				@Total INT = 0 OUTPUT  

			AS  
			BEGIN  
			 

			IF(@Checking = 1)   
				BEGIN  
					SELECT 1	
					FROM
						[agpaymst] P1				--Origin Posted Payments Table
					INNER JOIN
						[tblARInvoice] I
							ON P1.agpay_ivc_no COLLATE Latin1_General_CI_AS  = I.strInvoiceOriginId COLLATE Latin1_General_CI_AS 	
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
									a.intCustomerId = C.[intCustomerId] 
									AND ad.[intInvoiceId] = I.[intInvoiceId] 
									AND a.[dtmDatePaid] = (CASE 
																WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
																	THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
																ELSE
																	NULL 
															END)
									AND a.intAccountId = GL.inti21Id 				
							)
					GROUP BY
						C.[intCustomerId]
						,P1.[agpay_ivc_no]
						,P1.[agpay_rev_dt]
						,GL.[inti21Id]
						,CL.[intCompanyLocationId]
						,CUR.[intCurrencyID]		
						,P.[intPaymentMethodID]	
				
					SET @Total = @@ROWCOUNT 
					    
					RETURN @Total  
				END   
			  

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
					,[intConcurrencyId]
					)
				SELECT
					C.[intCustomerId] 						--[intCustomerId]
					,CUR.[intCurrencyID]					--[intCurrencyId]
					,(CASE 
						WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
							THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
						ELSE
							NULL 
					END)									--[dtmDatePaid]
					,ISNULL(GL.[inti21Id],0)				--[intAccountId]
					,ISNULL(P.[intPaymentMethodID],0)		--[intPaymentMethodId]
					,CL.[intCompanyLocationId] 				--[intLocationId]
					,SUM(P1.[agpay_amt])					--[dblAmountPaid]
					,0										--[dblUnappliedAmount]
					,0										--[dblOverpayment]
					,0										--[dblBalance]
					,P1.[agpay_ivc_no]						--[strPaymentInfo]
					,''''										--[strNotes]
					,1										--[ysnPosted]
					,0
					
				FROM
					[agpaymst] P1				--Origin Posted Payments Table
				INNER JOIN
					[tblARInvoice] I
						ON P1.agpay_ivc_no COLLATE Latin1_General_CI_AS  = I.strInvoiceOriginId COLLATE Latin1_General_CI_AS 	
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
								a.intCustomerId = C.[intCustomerId] 
								AND ad.[intInvoiceId] = I.[intInvoiceId] 
								AND a.[dtmDatePaid] = (CASE 
															WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
																THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
															ELSE
																NULL 
														END)
								AND a.intAccountId = GL.inti21Id 				
						)		
				GROUP BY
					C.[intCustomerId]
					,P1.[agpay_ivc_no]
					,P1.[agpay_rev_dt]
					,GL.[inti21Id]
					,CL.[intCompanyLocationId]
					,CUR.[intCurrencyID]		
					,P.[intPaymentMethodID]	
				ORDER BY 
					P1.[agpay_ivc_no]
					,C.[intCustomerId]
					,P1.[agpay_rev_dt]	
					
				SET @Total = @@ROWCOUNT 		


				INSERT INTO [tblARPaymentDetail]
					([intPaymentId]
					,[intInvoiceId]
					,[intAccountId]
					,[dblInvoiceTotal]
					,[dblDiscount]
					,[dblAmountDue]
					,[dblPayment]
					,[intConcurrencyId]
					)
				SELECT 
					AP.[intPaymentId] 
					,I.[intInvoiceId] 
					,I.[intAccountId] 
					,SUM(I.[dblInvoiceTotal])
					,0 
					,0 
					,SUM(P1.[agpay_amt])
					,0			
				FROM
					[agpaymst] P1				--Origin Posted Payments Table
				INNER JOIN
					[tblARInvoice] I
						ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 
				INNER JOIN
					[tblARPayment] AP
						ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS = AP.[strPaymentInfo] COLLATE Latin1_General_CI_AS 
						AND (CASE 
								WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
									THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
								ELSE
									NULL 
							END) = AP.[dtmDatePaid] 
				INNER JOIN
					[tblARCustomer] C
						ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
						AND I.[intCustomerId] = C.[intCustomerId] 
				INNER JOIN
					[tblSMCurrency] CUR
						ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
						AND AP.[intCurrencyId] = CUR.[intCurrencyID] 
				LEFT OUTER JOIN
					[tblGLCOACrossReference] GL
						ON P1.[agpay_acct_no] = GL.[strExternalId]
						AND AP.[intAccountId] = GL.[inti21Id] 
				LEFT OUTER JOIN
					[tblSMPaymentMethod] P
						ON P1.[agpay_pay_type] = CAST(P.strPaymentMethodCode AS int)
						AND AP.[intPaymentId] = P.[intPaymentMethodID] 
				INNER JOIN
					[tblSMCompanyLocation] CL
						ON P1.[agpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
						AND AP.[intLocationId] = CL.[intCompanyLocationId] 
				WHERE 
					RTRIM(LTRIM(P1.[agpay_chk_no])) <> ''DISC''
					AND AP.[intCustomerId] = C.[intCustomerId] 	
						
				GROUP BY
					AP.[intPaymentId] 
					,I.[intInvoiceId]
					,I.[intAccountId] 
					,I.[intCustomerId] 
					
					
				UPDATE [tblARPaymentDetail]
				SET
					[dblDiscount] = (CASE WHEN RTRIM(LTRIM(P1.[agpay_chk_no])) = ''DISC'' THEN P1.[agpay_amt] ELSE [tblARPaymentDetail].[dblDiscount] END)
					,[dblInvoiceTotal] = I.[dblInvoiceTotal]
					,[intAccountId] = (CASE WHEN [tblARPaymentDetail].[intAccountId] IS NULL OR [tblARPaymentDetail].[intAccountId] = 0 THEN AP.[intAccountId] ELSE [tblARPaymentDetail].[intAccountId] END)
				FROM
					[agpaymst] P1				--Origin Posted Payments Table
				INNER JOIN
					[tblARInvoice] I
						ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 
				INNER JOIN
					[tblARPayment] AP
						ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS = AP.[strPaymentInfo] COLLATE Latin1_General_CI_AS 
						AND (CASE 
								WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
									THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
								ELSE
									NULL 
							END) = AP.[dtmDatePaid] 		
				INNER JOIN
					[tblARCustomer] C
						ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 
						AND C.[intCustomerId] = AP.[intCustomerId]
				INNER JOIN
					[tblSMCurrency] CUR
						ON P1.[agpay_currency] COLLATE Latin1_General_CI_AS = CUR.[strCurrency] COLLATE Latin1_General_CI_AS
						AND AP.[intCurrencyId] = CUR.[intCurrencyID] 
				LEFT OUTER JOIN
					[tblGLCOACrossReference] GL
						ON P1.[agpay_acct_no] = GL.[strExternalId]
						AND AP.[intAccountId] = GL.[inti21Id] 
				LEFT OUTER JOIN
					[tblSMPaymentMethod] P
						ON P1.[agpay_pay_type] = CAST(P.[strPaymentMethodCode] AS int)
						AND AP.[intPaymentId] = P.[intPaymentMethodID]
				INNER JOIN
					[tblSMCompanyLocation] CL
						ON P1.[agpay_loc_no] COLLATE Latin1_General_CI_AS = CL.[strLocationNumber] COLLATE Latin1_General_CI_AS
						AND AP.[intLocationId] = CL.[intCompanyLocationId]
				WHERE 	
					[tblARPaymentDetail].[intPaymentId] = AP.[intPaymentId] 
					AND [tblARPaymentDetail].[intInvoiceId] = I.[intInvoiceId] 
					AND [tblARPaymentDetail].[intAccountId] = I.[intAccountId] 	
					
					
					
				UPDATE [tblARPayment]
				SET
					[strNotes] = P1.[agpay_note] 
					,[strPaymentInfo] = P1.[agpay_ref_no]
				FROM
					[agpaymst] P1				--Origin Posted Payments Table
				INNER JOIN
					[tblARInvoice] I
						ON P1.[agpay_ivc_no] COLLATE Latin1_General_CI_AS  = I.[strInvoiceOriginId] COLLATE Latin1_General_CI_AS 	
				INNER JOIN
					[tblARCustomer] C
						ON P1.[agpay_cus_no] COLLATE Latin1_General_CI_AS = C.[strCustomerNumber] COLLATE Latin1_General_CI_AS 		
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
					[tblARPayment].[intCustomerId] = C.[intCustomerId]
					AND [tblARPayment].[intAccountId] = GL.[inti21Id]
					AND [tblARPayment].[dtmDatePaid] = (CASE 
															WHEN ISDATE(P1.[agpay_rev_dt]) = 1 
																THEN CONVERT(DATE, CAST(P1.[agpay_rev_dt] AS CHAR(12)), 112) 
															ELSE
																NULL 
														END)
					AND [tblARPayment].[intLocationId] = CL.[intCompanyLocationId]
					AND [tblARPayment].[intCurrencyId] = CUR.[intCurrencyID]
					AND [tblARPayment].[intPaymentMethodId] = P.[intPaymentMethodID]

			  
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
ÉND')
END