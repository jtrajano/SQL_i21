﻿CREATE TABLE [dbo].[tblARCompanyPreference]
(
	[intCompanyPreferenceId]				INT NOT NULL PRIMARY KEY IDENTITY, 
    [intARAccountId]						INT NULL, 
    [intDiscountAccountId]					INT NULL,
	[intWriteOffAccountId]					INT NULL,
	[intInterestIncomeAccountId]			INT NULL,
	[intDeferredRevenueAccountId]			INT NULL,
	[intCommissionExpenseAccountId]			INT NULL,
	[intServiceChargeAccountId]				INT NULL,
	[intServiceChargeTermId]				INT NULL,
	[strServiceChargeCalculation]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strServiceChargeFrequency]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strReportGroupName]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strInvoiceReportName]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strCreditMemoReportName]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOtherChargeReportGroupName]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOtherChargeInvoiceReportName]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strOtherChargeCreditMemoReportName]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTankDeliveryInvoiceFormat]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strTransportsInvoiceFormat]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strGrainInvoiceFormat]					NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strMeterBillingInvoiceFormat]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConversionAccountId]				INT NULL,
	[ysnLineItemAccountUpdate]				BIT NULL DEFAULT 0,
	[ysnImpactForProvisional]				BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnImpactForProvisional] DEFAULT ((0)),
	[ysnExcludePaymentInFinalInvoice]		BIT NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnExcludePaymentInFinalInvoice] DEFAULT ((0)),
	[ysnAutoApplyPrepaids]					BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnAutoApplyPrepaids] DEFAULT ((0)),
	[ysnPromptPastDue]                		BIT NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnPromptPastDue] DEFAULT ((1)),
	[ysnChargeonCharge]						BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnChargeonCharge] DEFAULT ((1)),
	[ysnPrintInvoicePaymentDetail]			BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnPrintInvoicePaymentDetail] DEFAULT ((0)),	
	[ysnStretchLogo]						BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnStretchLogo] DEFAULT ((0)),
	[ysnPOSBatchProcess]					BIT NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnPOSBatchProcess] DEFAULT ((1)),
	[ysnIncludeInvoiceAttachments]			BIT	NOT NULL CONSTRAINT [DF_tblARCompanyPreference_ysnIncludeInvoiceAttachments] DEFAULT ((0)),
	[strCreditOverridePassword] 			NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]						INT NOT NULL DEFAULT 1,
	[strServiceChargeFormat]				NVARCHAR (100) NULL,
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intARAccountId] FOREIGN KEY ([intARAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intDiscountAccountId] FOREIGN KEY ([intDiscountAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intWriteOffAccountId] FOREIGN KEY ([intWriteOffAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intInterestIncomeAccountId] FOREIGN KEY ([intInterestIncomeAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intDeferredRevenueAccountId] FOREIGN KEY ([intDeferredRevenueAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intServiceChargeAccountId] FOREIGN KEY ([intServiceChargeAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblGLAccount_intConversionAccountId] FOREIGN KEY ([intConversionAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARCompanyPreference_tblSMTerm_intServiceChargeTermId] FOREIGN KEY ([intServiceChargeTermId]) REFERENCES [dbo].[tblSMTerm] ([intTermID])
)
