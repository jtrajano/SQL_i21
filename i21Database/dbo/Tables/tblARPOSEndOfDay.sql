CREATE TABLE [dbo].[tblARPOSEndOfDay]
(
	[intPOSEndOfDayId] INT NOT NULL PRIMARY KEY IDENTITY,
	[strEODNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblOpeningBalance] NUMERIC(18,6) NULL,
	[dblExpectedEndingBalance] NUMERIC(18,6) NULL,
	[dblFinalEndingBalance] NUMERIC(18,6) NULL,
	[intCompanyLocationPOSDrawerId] INT NOT NULL,
	[intStoreId] INT NULL,
	[intBankDepositId] INT NULL,
	[intEntityId] INT NOT NULL,
	[ysnClosed] BIT NOT NULL,
	[intConcurrencyId] INT NOT NULL DEFAULT 1,
	CONSTRAINT [FK_tblARPOSEndOfDay_tblSMCompanyLocationPOSDrawer] FOREIGN KEY (intCompanyLocationPOSDrawerId) REFERENCES tblSMCompanyLocationPOSDrawer(intCompanyLocationPOSDrawerId),
	CONSTRAINT [FK_tblARPOSEndOfDay_tblSTStore] FOREIGN KEY(intStoreId) REFERENCES tblSTStore(intStoreId),
	CONSTRAINT [FK_tblARPOSEndOfDay_tblEMEntity] FOREIGN KEY (intEntityId) REFERENCES tblEMEntity(intEntityId),
	CONSTRAINT [FK_tblARPOSEndOfDay_tblCMBankTransaction] FOREIGN KEY (intBankDepositId) REFERENCES tblCMBankTransaction (intTransactionId)
)
