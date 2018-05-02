CREATE TABLE [dbo].[tblCFCompanyPreference] (
    [intCompanyPreferenceId]            INT             IDENTITY (1, 1) NOT NULL,
    [strCFServiceReminderMessage]       NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strEnvelopeType]                   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCFUseSpecialPrices]             BIT             NULL,
    [strCFUsePrice]                     NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [ysnCFUseContracts]                 BIT             NULL,
    [ysnCFSummarizeInvoice]             BIT             NULL,
    [strCFInvoiceSummarizationLocation] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intGLAccountId]                    INT             NULL,
    [intARLocationId]                   INT             NULL,
    [intTermsCode]                      INT             NULL,
    [intFreightTermId]                  INT             NULL,
    [intLogoTopOffset]                  NUMERIC (18, 6) NULL,
    [intLogoLeftOffset]                 NUMERIC (18, 6) NULL,
    [ysnLogoShowBorder]                 BIT             NULL,
    [intCustomerAddressTopOffset]       NUMERIC (18, 6) NULL,
    [intCustomerAddressLeftOffset]      NUMERIC (18, 6) NULL,
    [ysnCustomerAddressShowBorder]      BIT             NULL,
    [intCompanyAddressTopOffset]        NUMERIC (18, 6) NULL,
    [intCompanyAddressLeftOffset]       NUMERIC (18, 6) NULL,
    [ysnCompanyAddressShowBorder]       BIT             NULL,
    [intConcurrencyId]                  INT             CONSTRAINT [DF_tblCFCompanyPreference_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCompanyPreference] PRIMARY KEY CLUSTERED ([intCompanyPreferenceId] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [FK_tblCFCompanyPreference_tblGLAccount] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblCFCompanyPreference_tblSMCompanyLocation] FOREIGN KEY ([intARLocationId]) REFERENCES [dbo].[tblSMCompanyLocation] ([intCompanyLocationId]),
    CONSTRAINT [FK_tblCFCompanyPreference_tblSMTerm] FOREIGN KEY ([intTermsCode]) REFERENCES [dbo].[tblSMTerm] ([intTermID])
);







