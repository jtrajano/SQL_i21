CREATE TABLE [dbo].[tblEntityEFTInformation] (
    [intEntityEFTInfoId]       INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]              INT            NOT NULL,
    [intBankId]                INT            NULL,
    [strBankName]              NVARCHAR (100) NULL,
    [strAccountNumber]         NVARCHAR (50)  NULL,
    [strAccountType]           NVARCHAR (10)  NULL,
    [strAccountClassification] NVARCHAR (50)  NULL,
    [dtmEffectiveDate]         DATETIME       NULL,
    [ysnPrintNotifications]    BIT            NULL,
    [ysnActive]                BIT            NULL,
    [strPullARBy]              NVARCHAR (50)  NULL,
    [ysnPullTaxSeparately]     BIT            NULL,
    [ysnRefundBudgetCredits]   BIT            NULL,
    [ysnPrenoteSent]           BIT            NULL,
    [intConcurrencyId]         INT            NOT NULL,
    CONSTRAINT [PK_tblEntityEFTInformation] PRIMARY KEY CLUSTERED ([intEntityEFTInfoId] ASC)
);

