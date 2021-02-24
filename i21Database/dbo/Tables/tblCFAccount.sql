﻿CREATE TABLE [dbo].[tblCFAccount] (
    [intAccountId]                    INT             IDENTITY (1, 1) NOT NULL,
    [intCustomerId]                   INT             NOT NULL,
    [intDiscountDays]                 INT             NULL,
    [intDiscountScheduleId]           INT             NOT NULL,
    [intInvoiceCycle]                 INT             NOT NULL,
    [intImportMapperId]               INT             NULL,
    [intSalesPersonId]                INT             NOT NULL,
    [dtmBonusCommissionDate]          DATETIME        NULL,
    [dblBonusCommissionRate]          NUMERIC (18, 6) NULL,
    [dblRegularCommissionRate]        NUMERIC (18, 6) NULL,
    [ysnPrintTimeOnInvoices]          BIT             NULL,
    [ysnPrintTimeOnReports]           BIT             NULL,
    [intTermsCode]                    INT             NOT NULL,
    [strBillingSite]                  NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strPrimarySortOptions]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strSecondarySortOptions]         NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnSummaryByCard]                BIT             NULL,
    [ysnSummaryByDepartmentProduct]   BIT             NULL,
    [ysnSummaryByVehicle]             BIT             NULL,
    [ysnSummaryByMiscellaneous]       BIT             NULL,
    [ysnSummaryByProduct]             BIT             NULL,
    [ysnSummaryByDepartment]          BIT             NULL,
    [ysnSummaryByDeptCardProd]        BIT             NULL,
    [ysnSummaryByDriverPin]           BIT             NULL,
    [ysnSummaryByCardProd]            BIT             NULL,
    [ysnVehicleRequire]               BIT             NULL,
    [intAccountStatusCodeId]          INT             NOT NULL,
    [strPrintRemittancePage]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strInvoiceProgramName]           NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [intPriceRuleGroup]               INT             NULL,
    [strPrintPricePerGallon]          NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPPTransferCostForRemote]      BIT             NULL,
    [ysnPPTransferCostForNetwork]     BIT             NULL,
    [ysnPrintMiscellaneous]           BIT             NULL,
    [intFeeProfileId]                 INT             NULL,
    [strPrintSiteAddress]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dtmLastBillingCycleDate]         DATETIME        NULL,
    [intRemotePriceProfileId]         INT             NULL,
    [intExtRemotePriceProfileId]      INT             NULL,
    [intLocalPriceProfileId]          INT             NULL,
    [intCreatedUserId]                INT             NULL,
    [dtmCreated]                      DATETIME        NULL,
    [intLastModifiedUserId]           INT             NULL,
    [dtmLastModified]                 DATETIME        NULL,
    [intConcurrencyId]                INT             CONSTRAINT [DF_tblCFAccount_intConcurrencyId] DEFAULT ((1)) NULL,
    [ysnDepartmentGrouping]           BIT             CONSTRAINT [DF__tblCFAcco__ysnDe__361DBC14] DEFAULT ((0)) NULL,
    [ysnSummaryByDeptVehicleProd]     BIT             CONSTRAINT [DF__tblCFAcco__ysnSu__3711E04D] DEFAULT ((0)) NULL,
    [strPrimaryDepartment]            NVARCHAR (8)    COLLATE Latin1_General_CI_AS CONSTRAINT [DF__tblCFAcco__strPr__38060486] DEFAULT (N'Card') NULL,
    [strDetailDisplay]                NVARCHAR (20)   COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblCFAccount_strPrimaryDepartment1] DEFAULT (N'Card') NULL,
    [intCustomerGroupId]              INT             NULL,
    [intQuoteProduct1Id]              INT             NULL,
    [intQuoteProduct2Id]              INT             NULL,
    [intQuoteProduct3Id]              INT             NULL,
    [intQuoteProduct4Id]              INT             NULL,
    [intQuoteProduct5Id]              INT             NULL,
    [ysnQuoteTaxExempt]               BIT             CONSTRAINT [DF__tblCFAcco__ysnQu__4DD942C7] DEFAULT ((0)) NULL,
    [ysnConvertMiscToVehicle]         BIT             CONSTRAINT [DF__tblCFAcco__ysnCo__4ECD6700] DEFAULT ((0)) NULL,
    [intDailyTransactionCount]        INT             CONSTRAINT [DF_tblCFAccount_intDailyTransactionCount] DEFAULT ((1)) NULL,
    [ysnShowVehicleDescriptionOnly]   BIT             NULL,
    [ysnShowDriverPinDescriptionOnly] BIT             NULL,
    [ysnPageBreakByPrimarySortOrder]  BIT             NULL,
    CONSTRAINT [PK_tblCFAccount] PRIMARY KEY CLUSTERED ([intAccountId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblCFAccount_tblARAccountStatus] FOREIGN KEY ([intAccountStatusCodeId]) REFERENCES [dbo].[tblARAccountStatus] ([intAccountStatusId]),
    CONSTRAINT [FK_tblCFAccount_tblARCustomer] FOREIGN KEY ([intCustomerId]) REFERENCES [dbo].[tblARCustomer] ([intEntityId]),
    CONSTRAINT [FK_tblCFAccount_tblARSalesperson] FOREIGN KEY ([intSalesPersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
    CONSTRAINT [FK_tblCFAccount_tblCFDiscountSchedule] FOREIGN KEY ([intDiscountScheduleId]) REFERENCES [dbo].[tblCFDiscountSchedule] ([intDiscountScheduleId]),
    CONSTRAINT [FK_tblCFAccount_tblCFFeeProfile] FOREIGN KEY ([intFeeProfileId]) REFERENCES [dbo].[tblCFFeeProfile] ([intFeeProfileId]),
    CONSTRAINT [FK_tblCFAccount_tblCFInvoiceCycle] FOREIGN KEY ([intInvoiceCycle]) REFERENCES [dbo].[tblCFInvoiceCycle] ([intInvoiceCycleId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader] FOREIGN KEY ([intRemotePriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader1] FOREIGN KEY ([intExtRemotePriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceProfileHeader2] FOREIGN KEY ([intLocalPriceProfileId]) REFERENCES [dbo].[tblCFPriceProfileHeader] ([intPriceProfileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblCFPriceRuleGroup] FOREIGN KEY ([intPriceRuleGroup]) REFERENCES [dbo].[tblCFPriceRuleGroup] ([intPriceRuleGroupId]),
    CONSTRAINT [FK_tblCFAccount_tblSMImportFileHeader] FOREIGN KEY ([intImportMapperId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId]),
    CONSTRAINT [FK_tblCFAccount_tblSMTerm] FOREIGN KEY ([intTermsCode]) REFERENCES [dbo].[tblSMTerm] ([intTermID])
);

GO
CREATE NONCLUSTERED INDEX [tblCFAccount_intTermsCode]
    ON [dbo].[tblCFAccount]([intTermsCode] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFAccount_intInvoiceCycle]
    ON [dbo].[tblCFAccount]([intInvoiceCycle] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFAccount_intDiscountScheduleId]
    ON [dbo].[tblCFAccount]([intDiscountScheduleId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCFAccount_intCustomerId]
    ON [dbo].[tblCFAccount]([intCustomerId] ASC);
GO
CREATE NONCLUSTERED INDEX [tblCFAccount_intAccountId]
    ON [dbo].[tblCFAccount]([intAccountId] ASC);
    
