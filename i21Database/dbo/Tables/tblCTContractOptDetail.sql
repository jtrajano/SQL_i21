CREATE TABLE [dbo].[tblCTContractOptDetail](
	[intContractOptDetailId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractOptHeaderId] [int] NOT NULL,
	[intBuySellId] [int] NOT NULL,
	[intPutCallId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTContractOptDetail_intContractOptDetailId] PRIMARY KEY CLUSTERED ([intContractOptDetailId] ASC),
	CONSTRAINT [FK_tblCTContractOptDetail_tblCTContractOptHeader_intContractOptHeaderId] FOREIGN KEY([intContractOptHeaderId]) REFERENCES [dbo].[tblCTContractOptHeader] ([intContractOptHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractOptDetail_tblCTBuySell_intBuySellId] FOREIGN KEY([intBuySellId]) REFERENCES [dbo].[tblCTBuySell] ([intBuySellId]),
	CONSTRAINT [FK_tblCTContractOptDetail_tblCTPutCall_intPutCallId] FOREIGN KEY([intBuySellId]) REFERENCES [dbo].[tblCTPutCall] ([intPutCallId])
)

