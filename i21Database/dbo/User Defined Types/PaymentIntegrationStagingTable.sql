﻿/*
	This is a user-defined table type used in creating/updating payments for integration. 
*/
CREATE TYPE [dbo].[PaymentIntegrationStagingTable] AS TABLE
(	 
	 [intId]								INT				--IDENTITY PRIMARY KEY CLUSTERED                        
	 --Header
	,[strSourceTransaction]					NVARCHAR(250)									NOT NULL	-- Valid values 
																											-- 0. "Direct"
																											-- 1. "Invoice"
	,[intSourceId]							INT												NULL		-- Id of the source transaction
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[intPaymentId]							INT												NULL		-- Payment Id(Insert new Invoice if NULL, else Update existing) 
	,[intEntityCustomerId]					INT												NOT NULL	-- Entity Id of Customer (tblARCustomer.intEntityCustomerId)	
	,[intCompanyLocationId]					INT												NOT NULL	-- Company Location Id (tblSMCompanyLocation.intCompanyLocationId)
	,[intCurrencyId]						INT												NOT NULL	-- Currency Id		
	,[dtmDatePaid]							DATETIME										NOT NULL	-- Payment Date
	,[intPaymentMethodId]					INT												NOT NULL	-- Payment Method Id([tblSMPaymentMethod].[intPaymentMethodID])	
	,[strPaymentMethod]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL		-- Payment Method		
	,[strPaymentInfo]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Payment Info / Check Number
	,[strNotes]								NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Notes
	,[intAccountId]							INT												NULL		-- Account Id ([tblGLAccount].[intAccountId])
	,[intBankAccountId]						INT												NULL		-- Bank Account Id ([tblCMBankAccount].[intBankAccountId])	
	,[intWriteOffAccountId]					INT												NULL		-- Account Id ([tblGLAccount].[intAccountId])		
	,[dblAmountPaid]						NUMERIC(18, 6)									NULL		-- Amount Paid
	,[dblBaseAmountPaid]					NUMERIC(18, 6)									NULL		-- Amount Paid
	,[dblBalance]							NUMERIC(18, 6)									NULL		-- Amount Paid
	,[intExchangeRateTypeId]				INT												NULL		-- Forex Rate Type Key Value from tblSMCurrencyExchangeRateType
	,[dblExchangeRate]						NUMERIC(18, 6)									NULL
	,[strReceivePaymentType]				NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Valid values > 1. "Cash Receipts"(Default) 2. "Vendor Refund"
	,[strPaymentOriginalId]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Reference to the original/parent record
	,[ysnUseOriginalIdAsPaymentNumber]		BIT												NULL		-- Indicate whether [strInvoiceOriginId] will be used as Invoice Number
	,[ysnApplytoBudget]						BIT												NULL		-- 	
	,[ysnApplyOnAccount]					BIT												NULL		-- 	
	,[ysnInvoicePrepayment]					BIT												NULL		-- 		
	,[ysnImportedFromOrigin]				BIT												NULL		-- 	
	,[ysnImportedAsPosted]					BIT												NULL		-- 	
	,[ysnAllowPrepayment]					BIT												NULL		-- 		
	,[ysnPost]								BIT												NULL		-- If [ysnPost] = 1 > New and Existing unposted Payments will be posted
																										-- If [ysnPost] = 0 > Existing posted Invoices will be unposted
																										-- If [ysnPost] IS NULL > No action will be made
	,[ysnRecap]								BIT												NULL		-- If [ysnRecap] = 1 > Recap Payments
	,[ysnUnPostAndUpdate]					BIT												NULL		-- 
	,[intEntityId]							INT												NOT NULL	-- Key Value from tblEMEntity
	,[intEntityCardInfoId]					INT												NULL		-- Credit Card Info Id (tblEMEntityCardInformation)

	

	--Detail																																															
	,[intPaymentDetailId]					INT												NULL		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
    ,[intInvoiceId]							INT												NULL		-- Key Value from tblARInvoice ([tblARInvoice].[intInvoiceId])	
	,[strTransactionType]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		
	,[intBillId]							INT												NULL		-- Key Value from tblARInvoice ([tblAPBill].[intBillId])	
	,[strTransactionNumber]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Transaction Number	
	,[intTermId]							INT												NULL		-- Term Id(If NULL, customer's default will be used)	
	,[intInvoiceAccountId]					INT												NULL		-- Account Id ([tblGLAccount].[intAccountId])
	,[intWriteOffAccountDetailId]			INT												NULL		-- Write Off Account Id for details ([tblGLAccount].[intAccountId])
	,[dblInvoiceTotal]						NUMERIC(18, 6)									NULL		-- Invoice Total
	,[dblBaseInvoiceTotal]					NUMERIC(18, 6)									NULL		-- Base Invoice Total
	,[ysnApplyTermDiscount]					BIT												NULL		-- 	
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- Discount
	,[dblBaseDiscount]						NUMERIC(18, 6)									NULL		-- Discount
	,[dblDiscountAvailable]					NUMERIC(18, 6)									NULL		-- Discount Available
	,[dblBaseDiscountAvailable]				NUMERIC(18, 6)									NULL		-- Discount Available
	,[dblWriteOffAmount]					NUMERIC(18, 6)									NULL		-- Write Off Amount
	,[dblBaseWriteOffAmount]				NUMERIC(18, 6)									NULL		-- Base Write Off Amount
	,[dblInterest]							NUMERIC(18, 6)									NULL		-- Interest
	,[dblBaseInterest]						NUMERIC(18, 6)									NULL		-- Interest
	,[dblPayment]							NUMERIC(18, 6)									NULL		-- Payment	
	,[dblBasePayment]						NUMERIC(18, 6)									NULL		-- Payment
	,[dblCreditCardFee]						NUMERIC(18, 6)									NULL		-- CC Fee
	,[dblBaseCreditCardFee]					NUMERIC(18, 6)									NULL		-- CC Fee
	,[dblAmountDue]							NUMERIC(18, 6)									NULL		-- Invoice Total
	,[dblBaseAmountDue]						NUMERIC(18, 6)									NULL		-- Base Invoice Total
	,[strInvoiceReportNumber]				NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL		-- Transaction Number	
	,[intCurrencyExchangeRateTypeId]		INT												NULL		-- Invoice Forex Rate Type Key Value from tblARInvoicedetail.intCurrencyExchangeRateTypeId - TOP 1
	,[intCurrencyExchangeRateId]			INT												NULL		-- Invoice Detail Forex Rate Key Value from tblARInvoicedetail.intCurrencyExchangeRateId - Top 1
	,[dblCurrencyExchangeRate]				NUMERIC(18, 6)									NULL		-- Average Invoice Detail Forex Rate - tblARInvoice.dblCurrencyExchangeRate
	,[ysnAllowOverpayment]					BIT												NULL		-- 	
	,[ysnFromAP]							BIT												NULL		-- 	

)
