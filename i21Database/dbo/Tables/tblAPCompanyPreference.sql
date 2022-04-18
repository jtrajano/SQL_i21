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
    [dblWithholdPercent]            DECIMAL (18, 6) NULL,
    [strReportGroupName]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strSetPostDate]                NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strClaimReportName]            NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strDebitMemoReportName]        NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strVoucherReportName]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
    [strPurchaseOrderReportName]    NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL, 
	[intVoucherInvoiceNoOption]     TINYINT NULL,
	[intDebitMemoInvoiceNoOption]   TINYINT NULL,
    [intPaymentMethodID]            INT NULL DEFAULT 7,
    [strVoucherImportTemplate]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Standard', 
    [intImportTypeId]               INT NOT NULL DEFAULT 5,
    [intInstructionCode]            INT NOT NULL DEFAULT 1,
    [strCompanyOrLocation]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Location', 
    [intConcurrencyId]              INT NOT NULL DEFAULT 0,
    [ysnAllowIntraCompanyEntries]	BIT NOT NULL DEFAULT(0),
	[ysnAllowIntraLocationEntries]	BIT NOT NULL DEFAULT(0),
	[ysnAllowSingleLocationEntries]	BIT NOT NULL DEFAULT(0),
	[intDueToAccountId]				INT NULL DEFAULT(0), 
    [intDueFromAccountId]			INT NULL DEFAULT(0),
    [intFreightTermId]              INT NULL,
    PRIMARY KEY CLUSTERED (intCompanyPreferenceId ASC)
);