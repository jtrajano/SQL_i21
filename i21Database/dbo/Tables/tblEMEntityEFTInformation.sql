CREATE TABLE [dbo].[tblEMEntityEFTInformation] (
    [intEntityEFTInfoId]								INT            IDENTITY (1, 1) NOT NULL,
    [intEntityId]										INT            NOT NULL,
    [intBankId]											INT            NULL,
    [strBankName]										NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber]									NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountType]									NVARCHAR (10)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountClassification]							NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [dtmEffectiveDate]									DATETIME       NULL,
    [ysnPrintNotifications]								BIT            NULL,
    [ysnActive]											BIT            NULL,
    [strPullARBy]										NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPullTaxSeparately]								BIT            NULL,
    [ysnRefundBudgetCredits]							BIT            NULL,
    [ysnPrenoteSent]									BIT            NULL,
	[strDistributionType]								NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
	[dblAmount]											NUMERIC(18, 6) NULL,
	[intOrder]											INT			  NULL, 
	[strEFTType]										NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [intCurrencyId]										INT				NULL,
	[strCurrency]										NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strInternationalBankAccountNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strSwiftCode]										NVARCHAR (11)  COLLATE Latin1_General_CI_AS NULL,
	[strBicCode]										NVARCHAR (8)  COLLATE Latin1_General_CI_AS NULL,
	[strBranchCode]										NVARCHAR (3)  COLLATE Latin1_General_CI_AS NULL,
	[ysnDefaultAccount]									BIT            NULL,
	[strIntermediaryBank]								NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strIntermediarySwiftCode]							NVARCHAR (11) COLLATE Latin1_General_CI_AS NULL,
	[strIntermediaryBankAccountNumber]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strComment]										NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strDetailsOfCharges]								NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strFiftySevenFormat]								NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strFiftySixFormat]									NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strIntermediaryInternationalBankAccountNumber]		NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,



	[intConcurrencyId]         INT            NOT NULL,

    CONSTRAINT [PK_tblEMEntityEFTInformation] PRIMARY KEY CLUSTERED ([intEntityEFTInfoId] ASC),
	CONSTRAINT [FK_tblEMEntityEFTInformation_tblCMBank] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank]([intBankId])
);

