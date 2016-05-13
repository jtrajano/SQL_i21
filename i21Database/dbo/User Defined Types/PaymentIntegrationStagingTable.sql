/*
	This is a user-defined table type used in creating/updating invoices for integration. 
*/
CREATE TYPE [dbo].[PaymentIntegrationStagingTable] AS TABLE
(	 
	 [intId]								INT				IDENTITY PRIMARY KEY CLUSTERED                        
	 --Header
	,[strSourceTransaction]					NVARCHAR(250)									NOT NULL	-- Valid values 
																											-- 0. "Direct"
																											-- 1. "Invoice"
	,[intSourceId]							INT												NULL		-- Id of the source transaction
	,[strSourceId]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL	-- Transaction number source transaction
	,[intPaymentId]							INT												NULL		-- Payment Id(Insert new Invoice if NULL, else Update existing) 
	,[intEntityCustomerId]					INT												NOT NULL	-- Entity Id of Customer (tblARCustomer.intEntityCustomerId)	
	,[intCurrencyId]						INT												NOT NULL	-- Currency Id		
	,[dtmDatePaid]							DATETIME										NOT NULL	-- Payment Date
	,[intAccountId]							INT												NULL		-- Account Id ([tblGLAccount].[intAccountId])
	,[intBankAccountId]						INT												NULL		-- Bank Account Id ([tblCMBankAccount].[intBankAccountId])	
	,[intPaymentMethodId]					INT												NOT NULL	-- Payment Method Id([tblSMPaymentMethod].[intPaymentMethodID])	
	,[intLocationId]						INT												NOT NULL	-- Company Location Id (tblSMCompanyLocation.intCompanyLocationId)
	,[intHeaderInvoiceId]					INT												NULL		-- Key Value from tblARInvoice (Prepayment/Overpayment) for Prepayment and OverPayment
	,[dblAmountPaid]						NUMERIC(18, 6)									NULL		-- Amount Paid
	,[dblUnappliedAmount]					NUMERIC(18, 6)									NULL		-- Unapplied Paid
	,[strRecordNumber]						NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL		-- Record/Payment Number	
	,[strPaymentInfo]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL		-- Payment Info / Check Number
	,[strNotes]								NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL		-- Notes
	,[ysnApplytoBudget]						BIT												NULL		-- 	
	,[ysnPost]								BIT												NULL		-- If [ysnPost] = 1 > New and Existing unposted Payments will be posted
																										-- If [ysnPost] = 0 > Existing posted Invoices will be unposted
																										-- If [ysnPost] IS NULL > No action will be made
	,[ysnRecap]								BIT												NULL		-- If [ysnRecap] = 1 > Recap Payments
	,[intEntityId]							INT												NOT NULL	-- Key Value from tblEMEntity			

	

	--Detail																																															
	,[intPaymentDetailId]					INT												NULL		-- Payment Detail Id(Insert new Payment Detail if NULL, else Update existing)
    ,[intInvoiceId]							INT												NOT NULL	-- Key Value from tblARInvoice ([tblARInvoice].[intInvoiceId])
	,[intTermId]							INT												NOT NULL	-- Term Id(Term used in Invoice)	
	,[intInvoiceAccountId]					INT												NOT NULL	-- Invoice Account Id ([tblGLAccount].[intAccountId])
	,[dblInvoiceTotal]						NUMERIC(18, 6)									NULL		-- Invoice Total
	,[dblDiscount]							NUMERIC(18, 6)									NULL		-- Discount
	,[dblDiscountAvailable]					NUMERIC(18, 6)									NULL		-- Discount Available
	,[dblInterest]							NUMERIC(18, 6)									NULL		-- Interest
	,[dblAmountDue]							NUMERIC(18, 6)									NULL		-- Amount Due
	,[dblPayment]							NUMERIC(18, 6)									NULL		-- Payment	

)
