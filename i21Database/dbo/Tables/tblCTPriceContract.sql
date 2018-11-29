CREATE TABLE [dbo].[tblCTPriceContract]
(
	intPriceContractId INT IDENTITY (1, 1) NOT NULL,
	strPriceContractNo NVARCHAR(50)  COLLATE Latin1_General_CI_AS NOT NULL,
	intCommodityId INT,
	intFinalPriceUOMId INT NOT NULL,
	intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,
	intConcurrencyId INT NOT NULL,

	CONSTRAINT [PK_tblCTPriceContract_intPriceContractId] PRIMARY KEY CLUSTERED (intPriceContractId ASC),
	CONSTRAINT [UQ_tblCTPriceContract_strPriceContractNo] UNIQUE (strPriceContractNo), 
	CONSTRAINT [FK_tblCTPriceContract_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
	CONSTRAINT [FK_tblCTPriceContract_tblICCommodity_intCommodityId] FOREIGN KEY([intCommodityId])REFERENCES [tblICCommodity] ([intCommodityId])
)
