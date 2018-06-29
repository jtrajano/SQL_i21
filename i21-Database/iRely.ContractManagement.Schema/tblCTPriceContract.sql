CREATE TABLE [dbo].[tblCTPriceContract]
(
	intPriceContractId INT IDENTITY (1, 1) NOT NULL,
	strPriceContractNo NVARCHAR(50) NOT NULL,
	intCommodityId INT,
	intFinalPriceUOMId INT NOT NULL,
	intFinalCurrencyId INT,
	intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	intConcurrencyId INT NOT NULL,
	intCompanyId INT,
	intPriceContractRefId INT,

	CONSTRAINT [PK_tblCTPriceContract_intPriceContractId] PRIMARY KEY CLUSTERED (intPriceContractId ASC),
	CONSTRAINT [UQ_tblCTPriceContract_strPriceContractNo] UNIQUE (strPriceContractNo), 
	CONSTRAINT [FK_tblCTPriceContract_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTPriceContract_tblSMCurrency_intFinalCurrencyId_intCurrencyId] FOREIGN KEY (intFinalCurrencyId) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTPriceContract_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [tblICCommodity] ([intCommodityId])
)
