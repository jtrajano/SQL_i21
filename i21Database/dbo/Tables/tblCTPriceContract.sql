CREATE TABLE [dbo].[tblCTPriceContract]
(
	intPriceContractId INT IDENTITY (1, 1) NOT NULL,
	strPriceContractNo NVARCHAR(50) NOT NULL,
	intFinalPriceUOMId INT NOT NULL,
	intCreatedById INT,
	dtmCreated DATETIME,
	intLastModifiedById INT,
	dtmLastModified DATETIME,

	CONSTRAINT [PK_tblCTPriceContract_intPriceContractId] PRIMARY KEY CLUSTERED (intPriceContractId ASC),
	CONSTRAINT [UQ_tblCTPriceContract_strPriceContractNo] UNIQUE (strPriceContractNo), 
	CONSTRAINT [FK_tblCTPriceContract_tblICCommodityUnitMeasure_intFinalPriceUOMId_intCommodityUnitMeasureId] FOREIGN KEY ([intFinalPriceUOMId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]) 	
)
