﻿CREATE TABLE [dbo].[tblAPCompanyPreference] (
    [intCompanyPreferenceId]        INT IDENTITY (1, 1) NOT NULL,
	[intApprovalListId]	            INT NULL,
    [intDefaultAccountId]           INT NULL,
    [intWithholdAccountId]          INT NULL,
    [intDiscountAccountId]          INT NULL,
	[intInterestAccountId]          INT NULL,
	[intCheckPrintId]               INT NULL,
    [intCheckStubTemplateId]        INT NULL,
    [ysnEnforceControlTotal]        BIT NOT NULL DEFAULT(0),
    [ysnAllowRequestedBy]           BIT NOT NULL DEFAULT(0),
    [dblWithholdPercent]            DECIMAL (18, 6) NULL,
    [strReportGroupName]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strSetPostDate]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strClaimReportName]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strDebitMemoReportName]        NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strVoucherReportName]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strPurchaseOrderReportName]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strFromServer]                 NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 
    [strArchiveServer]              NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 
    [strFolderDesktop]               NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL, 
	[intVoucherInvoiceNoOption]     TINYINT NULL,
	[intDebitMemoInvoiceNoOption]   TINYINT NULL,
    [intPaymentMethodID]            INT NULL DEFAULT 7,
    [ysnAllowMultiplePaymentProcess]        BIT NOT NULL DEFAULT(0),
    [strVoucherImportTemplate]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Standard', 
    [intImportTypeId]               INT NOT NULL DEFAULT 5,
    [intInstructionCode]            INT NOT NULL DEFAULT 1,
    [strDetailsOfCharges]           NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'SHA',
    [strCompanyOrLocation]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Location', 
    [intConcurrencyId]              INT NOT NULL DEFAULT 0,
    [ysnAllowIntraCompanyEntries]	BIT NOT NULL DEFAULT(0),
	[ysnAllowIntraLocationEntries]	BIT NOT NULL DEFAULT(0),
	[ysnAllowSingleLocationEntries]	BIT NOT NULL DEFAULT(0),
	[intDueToAccountId]				INT NULL DEFAULT(0), 
    [ysnRetrieveBillByLocationVendorCurrency] BIT NOT NULL DEFAULT(0),
    [intDueFromAccountId]			INT NULL DEFAULT(0),
    [intFreightTermId]              INT NULL,
    [ysnOverrideCompanySegment]		    BIT NOT NULL DEFAULT(0),
	[ysnOverrideLocationSegment]	    BIT NOT NULL DEFAULT(0),
	[ysnOverrideLineOfBusinessSegment]	BIT NOT NULL DEFAULT(0), 
    [ysnRemittanceAdvice_DisplayVendorAccountNumber] BIT NULL DEFAULT(1),
    [ysnAllowFinalizeVoucherWithoutReceipt] BIT NOT NULL DEFAULT(0),
    intBudgetCode int, 
    [ysnOverrideAPLineOfBusinessSegment]	BIT NOT NULL DEFAULT(0),
    PRIMARY KEY CLUSTERED (intCompanyPreferenceId ASC)
);