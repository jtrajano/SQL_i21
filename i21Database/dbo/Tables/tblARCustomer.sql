CREATE TABLE [dbo].[tblARCustomer] (
    [intEntityId]                     INT             NOT NULL,
    [intCustomerId]                   INT             IDENTITY (1, 1) NOT NULL,
    [strCustomerNumber]               NVARCHAR (15)   COLLATE Latin1_General_CI_AS NOT NULL,
    [strType]                         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]                  NUMERIC (18, 6) NOT NULL,
    [dblARBalance]                    NUMERIC (18, 6) NOT NULL,
    [strAccountNumber]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxNumber]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCurrency]                     NVARCHAR (3)    COLLATE Latin1_General_CI_AS NULL,
    [intAccountStatusId]              INT             NULL,
    [intSalespersonId]                INT             NULL,
    [strPricing]                      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strLevel]                        NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblPercent]                      NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
    [strTimeZone]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnActive]                       BIT             CONSTRAINT [DF_tblARCustomer_ysnActive] DEFAULT ((1)) NOT NULL,
    [intDefaultContactId]             INT             NULL,
    [intDefaultLocationId]            INT             NULL,
    [intBillToId]                     INT             NULL,
    [intShipToId]                     INT             NULL,
    [strTaxState]                     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnPORequired]                   BIT             DEFAULT ((0)) NOT NULL,
    [ysnCreditHold]                   BIT             DEFAULT ((0)) NOT NULL,
    [ysnStatementDetail]              BIT             DEFAULT ((0)) NOT NULL,
    [strStatementFormat]              NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [intCreditStopDays]               INT             NULL,
    [strTaxAuthority1]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxAuthority2]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPrintPriceOnPrintTicket]      BIT             NULL,
    [intServiceChargeId]              INT             NULL,
    [ysnApplySalesTax]                BIT             DEFAULT ((0)) NOT NULL,
    [ysnApplyPrepaidTax]              BIT             DEFAULT ((0)) NOT NULL,
    [dblBudgetAmountForBudgetBilling] NUMERIC (18, 6) NULL,
    [strBudgetBillingBeginMonth]      NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strBudgetBillingEndMonth]        NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnCalcAutoFreight]              BIT             DEFAULT ((0)) NOT NULL,
    [strUpdateQuote]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strCreditCode]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strDiscSchedule]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPrintInvoice]                 NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [ysnSpecialPriceGroup]            BIT             DEFAULT ((0)) NOT NULL,
    [ysnExcludeDunningLetter]         BIT             DEFAULT ((0)) NOT NULL,
    [strLinkCustomerNumber]           NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [intReferredByCustomer]           INT             NULL,
    [ysnReceivedSignedLiscense]       BIT             DEFAULT ((0)) NOT NULL,
    [strDPAContract]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [dtmDPADate]                      DATETIME        NULL,
    [strGBReceiptNumber]              NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCheckoffExempt]               BIT             DEFAULT ((0)) NOT NULL,
    [ysnVoluntaryCheckoff]            BIT             DEFAULT ((0)) NOT NULL,
    [strCheckoffState]                NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnMarketAgreementSigned]        BIT             DEFAULT ((0)) NOT NULL,
    [intMarketZoneId]                 INT             NULL,
    [ysnHoldBatchGrainPayment]        BIT             DEFAULT ((0)) NOT NULL,
    [ysnFederalWithholding]           BIT             DEFAULT ((0)) NOT NULL,
    [strAEBNumber]                    NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strAgrimineId]                   NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strHarvestPartnerCustomerId]     NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strComments]                     NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnTransmittedCustomer]          BIT             DEFAULT ((0)) NOT NULL,
    [dtmMembershipDate]               DATETIME        NULL,
    [dtmBirthDate]                    DATETIME        NULL,
    [strStockStatus]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPatronClass]                  CHAR (1)        COLLATE Latin1_General_CI_AS NULL,
    [dtmDeceasedDate]                 DATETIME        NULL,
    [ysnSubjectToFWT]                 BIT             DEFAULT ((0)) NOT NULL,
    [intConcurrencyId]                INT             CONSTRAINT [DF_tblARCustomer_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomer] PRIMARY KEY CLUSTERED ([intEntityId] ASC),
    CONSTRAINT [FK_tblARCustomer_tblARAccountStatus] FOREIGN KEY ([intAccountStatusId]) REFERENCES [dbo].[tblARAccountStatus] ([intAccountStatusId]),
    CONSTRAINT [FK_tblARCustomer_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [dbo].[tblARMarketZone] ([intMarketZoneId]),
    CONSTRAINT [FK_tblARCustomer_tblARSalesperson_intSalespersonId] FOREIGN KEY ([intSalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intSalespersonId]),
    CONSTRAINT [FK_tblARCustomer_tblARServiceCharge] FOREIGN KEY ([intServiceChargeId]) REFERENCES [dbo].[tblARServiceCharge] ([intServiceChargeId]),
    CONSTRAINT [FK_tblARCustomer_tblEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].[tblEntity] ([intEntityId]),
    CONSTRAINT [FK_tblARCustomer_tblEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [dbo].[tblEntityLocation] ([intEntityLocationId]),
    CONSTRAINT [UK_intCustomerId] UNIQUE NONCLUSTERED ([intCustomerId] ASC),
    CONSTRAINT [UKstrCusomerNumber] UNIQUE NONCLUSTERED ([strCustomerNumber] ASC)
);












GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblARCustomer]
    ON [dbo].[tblARCustomer]([strCustomerNumber] ASC);


GO


