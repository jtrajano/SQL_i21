﻿CREATE TABLE [dbo].[tblARCustomer] (
    [intEntityId]                     INT             NOT NULL,
    [intCustomerId]                   INT             IDENTITY (1, 1) NOT NULL,
    [strCustomerNumber]               NVARCHAR (15)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]                         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]                  DECIMAL (18, 2) NOT NULL,
    [dblARBalance]                    DECIMAL (18, 2) NOT NULL,
    [strAccountNumber]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxNumber]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCurrency]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intAccountStatusId]              INT             NULL,
    [intSalespersonId]                INT             NULL,
    [strPricing]                      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLevel]                        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTimeZone]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]                       BIT             CONSTRAINT [DF_tblARCustomer_ysnActive] DEFAULT ((1)) NOT NULL,
    [intDefaultContactId]             INT             NULL,
    [intDefaultLocationId]            INT             NULL,
    [intBillToId]                     INT             NULL,
    [intShipToId]                     INT             NULL,
    [strTaxState]                     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnPORequired]                   BIT             NULL,
    [ysnCreditHold]                   BIT             NULL,
    [ysnStatementDetail]              BIT             NULL,
    [strStatementFormat]              NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intCreditStopDays]               INT             NULL,
    [strTaxAuthority1]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxAuthority2]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPrintPriceOnPrintTicket]      BIT             NULL,
    [intServiceChargeId]              INT             NULL,
    [ysnApplySalesTax]                BIT             NULL,
    [ysnApplyPrepaidTax]              BIT             NULL,
    [dblBudgetAmountForBudgetBilling] NUMERIC (18, 6) NULL,
    [strBudgetBillingBeginMonth]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBudgetBillingEndMonth]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnCalcAutoFreight]              BIT             NULL,
    [strUpdateQuote]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCreditCode]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strDiscSchedule]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPrintInvoice]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnSpecialPriceGroup]            BIT             NULL,
    [ysnExcludeDunningLetter]         BIT             NULL,
    [strLinkCustomerNumber]           NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [intReferredByCustomer]           INT             NULL,
    [ysnReceivedSignedLiscense]       BIT             NULL,
    [strDPAContract]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDPADate]                      DATETIME        NULL,
    [strGBReceiptNumber]              NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCheckoffExempt]               BIT             NULL,
    [ysnVoluntaryCheckoff]            BIT             NULL,
    [strCheckoffState]                NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnMarketAgreementSigned]        BIT             NULL,
    [intMarketZoneId]                 INT             NULL,
    [ysnHoldBatchGrainPayment]        BIT             NULL,
    [strAEBNumber]                    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAgrimineId]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strHarvestPartnerCustomerId]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strComments]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnTransmittedCustomer]          BIT             NULL,
    [dtmMembershipDate]               DATETIME        NULL,
    [dtmBirthDate]                    DATETIME        NULL,
    [strStockStatus]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPatronClass]                  CHAR (1)        COLLATE Latin1_General_CI_AS NULL,
    [dtmDeceasedDate]                 DATETIME        NULL,
    [ysnSubjectToFWT]                 BIT             NULL,
    [intConcurrencyId]                INT             CONSTRAINT [DF_tblARCustomer_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.tblARCustomer] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_tblARCustomer_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [FK_tblARCustomer_tblEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]) ON DELETE SET DEFAULT,
    CONSTRAINT [FK_tblARCustomer_tblEntityToContact] FOREIGN KEY ([intDefaultContactId]) REFERENCES [dbo].[tblEntityToContact] ([intEntityToContactId]) ON DELETE SET DEFAULT
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblARCustomer]
    ON [dbo].[tblARCustomer]([strCustomerNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_intEntityId]
    ON [dbo].[tblARCustomer]([intEntityId] ASC);

