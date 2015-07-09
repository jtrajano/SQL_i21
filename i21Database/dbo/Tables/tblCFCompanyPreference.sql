CREATE TABLE [dbo].[tblCFCompanyPreference] (
    [intCompanyPreferenceId]            INT            IDENTITY (1, 1) NOT NULL,
    [strCFServiceReminderMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnCFUseSpecialPrices]             BIT            NULL,
    [strCFUsePrice]                     NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [ysnCFUseContracts]                 BIT            NULL,
    [ysnCFSummarizeInvoice]             BIT            NULL,
    [strCFInvoiceSummarizationLocation] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                  INT            CONSTRAINT [DF_tblCFCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCompanyPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC)
);

