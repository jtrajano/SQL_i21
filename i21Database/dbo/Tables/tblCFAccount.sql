﻿CREATE TABLE [dbo].[tblCFAccount] (
    [intAccountId]                INT             IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT             NULL,
    [intDiscountDays]             INT             NULL,
    [intDiscountScheduleId]       INT             NULL,
    [intInvoiceCycle]             INT             NULL,
    [intSalesPersonId]            INT             NULL,
    [dtmBonusCommissionDate]      DATETIME        NULL,
    [dblBonusCommissionRate]      NUMERIC (18, 6) NULL,
    [dblRegularCommissionRate]    NUMERIC (18, 6) NULL,
    [ysnPrintTimeOnInvoices]      BIT             NULL,
    [ysnPrintTimeOnReports]       BIT             NULL,
    [intTermsCode]                INT             NULL,
    [strBillingSite]              NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimarySortOptions]       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strSecondarySortOptions]     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnSummaryByCard]            BIT             NULL,
    [ysnSummaryByVehicle]         BIT             NULL,
    [ysnSummaryByMiscellaneous]   BIT             NULL,
    [ysnSummaryByProduct]         BIT             NULL,
    [ysnSummaryByDepartment]      BIT             NULL,
    [ysnVehicleRequire]           BIT             NULL,
    [strAccountStatusCode]        NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strPrintRemittancePage]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceProgramName]       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intPriceRuleGroup]           INT             NULL,
    [ysnPrintInvoiceWithTaxes]    BIT             NULL,
    [ysnPPTransferCostForRemote]  BIT             NULL,
    [ysnPPTransferCostForNetwork] BIT             NULL,
    [ysnPrintMiscellaneous]       BIT             NULL,
    [intFeeProfileId]             INT             NULL,
    [strPrintSiteAddress]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dtmLastBillingCycleDate]     DATETIME        NULL,
    [intRemotePriceProfileId]     INT             NULL,
    [intExtRemotePriceProfileId]  INT             NULL,
    [intLocalPriceProfileId]      INT             NULL,
    [intCreatedUserId]            INT             NULL,
    [dtmCreated]                  DATETIME        NULL,
    [intLastModifiedUserId]       INT             NULL,
    [dtmLastModified]             DATETIME        NULL,
    [intConcurrencyId]            INT             CONSTRAINT [DF_tblCFAccount_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFAccount] PRIMARY KEY CLUSTERED ([intAccountId] ASC),
    CONSTRAINT [FK_tblCFAccount_tblCFDiscountSchedule] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [dbo].[tblCFDiscountSchedule] ([intDiscountScheduleId]),
    CONSTRAINT [FK_tblCFAccount_tblCFFeeProfile] FOREIGN KEY ([intFeeProfileId]) REFERENCES [dbo].[tblCFFeeProfile] ([intFeeProfileId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblCFAccount_tblCFInvoiceCycle] FOREIGN KEY ([intInvoiceCycle]) REFERENCES [dbo].[tblCFInvoiceCycle] ([intInvoiceCycleId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader] FOREIGN KEY ([intRemotePriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader1] FOREIGN KEY ([intExtRemotePriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader2] FOREIGN KEY ([intLocalPriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceRuleGroup] FOREIGN KEY ([intPriceRuleGroup]) REFERENCES [dbo].[tblCFPriceRuleGroup] ([intPriceRuleGroupId])
);



