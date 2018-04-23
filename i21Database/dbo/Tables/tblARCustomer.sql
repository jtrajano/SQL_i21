﻿CREATE TABLE [dbo].[tblARCustomer] (
    [intEntityId]                     INT             NOT NULL,
    --[intEntityCustomerId]                   INT             IDENTITY (1, 1) NOT NULL,
    [strCustomerNumber]               NVARCHAR (15)   COLLATE Latin1_General_CI_AS NULL,
    [strType]                         NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dblCreditLimit]                  NUMERIC (18, 6) NOT NULL,
    [dblARBalance]                    NUMERIC (18, 6) NOT NULL,
    [strAccountNumber]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strTaxNumber]                    NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strCurrency]                     NVARCHAR (3)    COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]					  INT             NULL,
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
	[ysnStatementCreditLimit]		  BIT             DEFAULT ((0)) NOT NULL,
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
	[dtmLastActivityDate]               DATETIME        NULL,
    [strStockStatus]                  NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
    [strPatronClass]                  CHAR (1)        COLLATE Latin1_General_CI_AS NULL,
    [dtmDeceasedDate]                 DATETIME        NULL,
    --[ysnSubjectToFWT]                 BIT             DEFAULT ((0)) NOT NULL,
	[ysnHDBillableSupport]			  BIT             DEFAULT ((0)) NOT NULL,
	[intTaxCodeId]					  INT			  NULL,
	[intContractGroupId]			  INT			  NULL,
	[intBuybackGroupId]				  INT			  NULL,
	[intPriceGroupId]				  INT			  NULL,
	[ysnTaxExempt]					  BIT             DEFAULT ((0)) NOT NULL,
	[ysnProspect]					  BIT             DEFAULT ((0)) NOT NULL,
	[strJiraCustomer]				  NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,	
	[strVatNumber]					  NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,	
	[dblMonthlyBudget]                NUMERIC (18, 6) DEFAULT ((0)) NOT NULL,
	[intNoOfPeriods]				  INT			  NULL,
	[dtmBudgetBeginDate]			  DATETIME			NULL,
	[strFLOId]						  NVARCHAR (100)   COLLATE Latin1_General_CI_AS NULL,	
	[intCompanyLocationPricingLevelId]		INT	NULL,
	[intEntityTariffTypeId]					INT	NULL,
	[dblRevenue]							NUMERIC (18, 6) NULL DEFAULT(0),
	[intEmployeeCount]						INT	NULL  DEFAULT(0),
	[ysnIncludeEntityName]					BIT DEFAULT ((0)) NOT NULL,
    [ysnCustomerBudgetTieBudget]            BIT DEFAULT ((0)) NOT NULL,
	[intInvoicePostingApprovalId]			INT NULL,
	[intOverCreditLimitApprovalId]			INT NULL,
	[intOrderApprovalApprovalId]			INT NULL,
	[intQuoteApprovalApprovalId]			INT NULL,
	[intOrderQuantityShortageApprovalId]	INT NULL,
	[intReceivePaymentPostingApprovalId]	INT NULL,
	[intCommisionsApprovalId]				INT NULL,
	[intPastDueApprovalId]					INT NULL,
	[intPriceChangeApprovalId]				INT NULL,
	[ysnApprovalsNotRequired]				BIT DEFAULT(0),
	[intTermsId]							INT NULL,
    [intPaymentMethodId]					INT NULL,
	[dtmLastServiceCharge]					DATETIME NULL,
	[intCompanyId]							INT NULL ,
    [intConcurrencyId]						INT CONSTRAINT [DF_tblARCustomer_intConcurrencyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblARCustomer] PRIMARY KEY CLUSTERED ([intEntityId] ASC),	
    CONSTRAINT [FK_tblARCustomer_tblARAccountStatus] FOREIGN KEY ([intAccountStatusId]) REFERENCES [dbo].[tblARAccountStatus] ([intAccountStatusId]),
    CONSTRAINT [FK_tblARCustomer_tblARMarketZone] FOREIGN KEY ([intMarketZoneId]) REFERENCES [dbo].[tblARMarketZone] ([intMarketZoneId]),
    CONSTRAINT [FK_tblARCustomer_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intSalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
    CONSTRAINT [FK_tblARCustomer_tblARServiceCharge] FOREIGN KEY ([intServiceChargeId]) REFERENCES [dbo].[tblARServiceCharge] ([intServiceChargeId]),    
    CONSTRAINT [FK_tblARCustomer_tblEMEntityLocation] FOREIGN KEY ([intDefaultLocationId]) REFERENCES [dbo].[tblEMEntityLocation] ([intEntityLocationId]),
	CONSTRAINT [FK_tblARCustomer_tblSMTaxCode] FOREIGN KEY([intTaxCodeId]) REFERENCES [dbo].[tblSMTaxCode] ([intTaxCodeId]),
    CONSTRAINT [UK_intCustomerId] UNIQUE NONCLUSTERED ([intEntityId] ASC),
	CONSTRAINT [FK_tblARCustomer_tblARCustomerGroup_ContractGroup] FOREIGN KEY([intContractGroupId]) REFERENCES [dbo].[tblARCustomerGroup] ([intCustomerGroupId]),
	CONSTRAINT [FK_tblARCustomer_tblARCustomerGroup_BuybackGroup] FOREIGN KEY([intBuybackGroupId]) REFERENCES [dbo].[tblARCustomerGroup] ([intCustomerGroupId]),
	CONSTRAINT [FK_tblARCustomer_tblARCustomerGroup_PriceGroup] FOREIGN KEY([intPriceGroupId]) REFERENCES [dbo].[tblARCustomerGroup] ([intCustomerGroupId]),
	CONSTRAINT [FK_tblARCustomer_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES [dbo].tblEMEntity ([intEntityId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARCustomer_tblSMCompanyLocationPricingLevel] FOREIGN KEY ([intCompanyLocationPricingLevelId]) REFERENCES [dbo].[tblSMCompanyLocationPricingLevel] ([intCompanyLocationPricingLevelId]),
	CONSTRAINT [FK_tblARCustomer_tblEMEntityTariffType_intEntityTariffTypeId] FOREIGN KEY ([intEntityTariffTypeId]) REFERENCES [dbo].[tblEMEntityTariffType] ([intEntityTariffTypeId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intInvoicePostingApprovalId] FOREIGN KEY ([intInvoicePostingApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intOverCreditLimitApprovalId] FOREIGN KEY ([intOverCreditLimitApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intOrderApprovalApprovalId] FOREIGN KEY ([intOrderApprovalApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intQuoteApprovalApprovalId] FOREIGN KEY ([intQuoteApprovalApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intOrderQuantityShortageApprovalId] FOREIGN KEY ([intOrderQuantityShortageApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intReceivePaymentPostingApprovalId] FOREIGN KEY ([intReceivePaymentPostingApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intCommisionsApprovalId] FOREIGN KEY ([intCommisionsApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intPastDueApprovalId] FOREIGN KEY ([intPastDueApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),
	CONSTRAINT [FK_tblARCustomer_tblSMApprovalList_intPriceChangeApprovalId] FOREIGN KEY ([intPriceChangeApprovalId]) REFERENCES [tblSMApprovalList]([intApprovalListId]),	
	CONSTRAINT [FK_tblARCustomer_tblSMTerm_intTermId] FOREIGN KEY ([intTermsId]) REFERENCES [dbo].[tblSMTerm] ([intTermID]),
	CONSTRAINT [FK_tblARCustomer_tblSMPaymentMethod_intPaymentMethodId] FOREIGN KEY ([intPaymentMethodId]) REFERENCES [dbo].[tblSMPaymentMethod] ([intPaymentMethodID]),

	
    --CONSTRAINT [UKstrCusomerNumber] UNIQUE NONCLUSTERED ([strCustomerNumber] ASC)
);

GO
--CREATE UNIQUE NONCLUSTERED INDEX [IX_tblARCustomer]
--    ON [dbo].[tblARCustomer]([strCustomerNumber] ASC);


--GO



EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Used for Origin link to agcus_key or ptcus_key',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblARCustomer',
    @level2type = N'COLUMN',
    @level2name = N'strCustomerNumber'
