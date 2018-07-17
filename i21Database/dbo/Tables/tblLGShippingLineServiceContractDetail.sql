CREATE TABLE [dbo].[tblLGShippingLineServiceContractDetail]
(
	[intShippingLineServiceContractDetailId] INT NOT NULL PRIMARY KEY IDENTITY (1, 1),
	[intShippingLineServiceContractId] INT NOT NULL,
	[strServiceContractNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intOriginId] INT NULL,
	[strOrigin] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dtmContractDate] DATETIME NOT NULL,
	[strAmendmentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	[dtmAmendmentDate] DATETIME,
	[dtmValidFrom] DATETIME,
	[dtmValidTo] DATETIME,
	[intConcurrencyId] INT NOT NULL, 

	CONSTRAINT [FK_tblLGShippingLineServiceContractDetail_tblLGShippingLineServiceContract_intShippingLineServiceContractId] FOREIGN KEY ([intShippingLineServiceContractId]) REFERENCES [tblLGShippingLineServiceContract]([intShippingLineServiceContractId]),
	CONSTRAINT [FK_tblLGShippingLineServiceContractDetail_tblICCommodityAttribute_intOriginId] FOREIGN KEY ([intOriginId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId])

)