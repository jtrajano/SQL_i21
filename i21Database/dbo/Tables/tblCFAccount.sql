CREATE TABLE [dbo].[tblCFAccount] (
    [intAccountId]                INT             IDENTITY (1, 1) NOT NULL,
    [intCustomerId]               INT             NOT NULL,
    [intDiscountDays]             INT             NULL,
    [intDiscountScheduleId]       INT             NOT NULL,
    [intInvoiceCycle]             INT             NOT NULL,
    [intSalesPersonId]            INT             NOT NULL,
    [dtmBonusCommissionDate]      DATETIME        NULL,
    [dblBonusCommissionRate]      NUMERIC (18, 6) NULL,
    [dblRegularCommissionRate]    NUMERIC (18, 6) NULL,
    [ysnPrintTimeOnInvoices]      BIT             NULL,
    [ysnPrintTimeOnReports]       BIT             NULL,
    [intTermsCode]                INT             NOT NULL,
    [strBillingSite]              NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimarySortOptions]       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strSecondarySortOptions]     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnSummaryByCard]            BIT             NULL,
    [ysnSummaryByVehicle]         BIT             NULL,
    [ysnSummaryByMiscellaneous]   BIT             NULL,
    [ysnSummaryByProduct]         BIT             NULL,
    [ysnSummaryByDepartment]      BIT             NULL,
    [ysnVehicleRequire]           BIT             NULL,
    [intAccountStatusCodeId]      INT             NOT NULL,
    [strPrintRemittancePage]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceProgramName]       NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intPriceRuleGroup]           INT             NULL,
    [strPrintPricePerGallon]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
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
    CONSTRAINT [FK_tblCFAccount_tblCFInvoiceCycle] FOREIGN KEY ([intInvoiceCycle]) REFERENCES [dbo].[tblCFInvoiceCycle] ([intInvoiceCycleId])
);







