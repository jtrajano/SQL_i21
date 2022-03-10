CREATE TABLE [dbo].[tblCTDefaultTradeFinance]
(
	[intDefaultTradeFinanceId] [int] IDENTITY(1,1) NOT NULL,
	[intLoadingPortId] INT NOT NULL,
	[intDestinationPortId] INT NOT NULL,
	[intProductTypeId] INT NULL,
	[intExtensionId] INT NULL,
	[intBankId] INT not NULL,
	[dblInterestRate] numeric(18,6) not NULL,
	[dtmValidFrom] datetime not NULL,
	[dtmValidTo] datetime not NULL,
	[intCreatedById] int NOT null,
	[dtmCreatedDate] datetime NOT NULL default getdate(),
	[intUpdatedById] int null,
	[dtmLastUpdatedDate] datetime NULL ,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCTDefaultTradeFinance_intDefaultTradeFinanceId] PRIMARY KEY CLUSTERED ([intDefaultTradeFinanceId] ASC),
	CONSTRAINT [FK_tblCTDefaultTradeFinance_tblSMCity_intLoadingPortId_intCityId] FOREIGN KEY ([intLoadingPortId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTDefaultTradeFinance_tblSMCity_intDestinationPortId_intCityId] FOREIGN KEY ([intDestinationPortId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTDefaultTradeFinance_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES tblCMBank([intBankId]),
	CONSTRAINT [UK_tblCTDefaultTradeFinance_intLoadingPortId_intDestinationPortId_intBankId_dtmValidFrom_dtmValidTo] UNIQUE ([intLoadingPortId],[intDestinationPortId],[intBankId],[dtmValidFrom],[dtmValidTo])
)