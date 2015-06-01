CREATE TABLE [dbo].[tblCTContractOption](
	[intContractOptionId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intBuySellId] [int] NOT NULL,
	[intPutCallId] [int] NOT NULL,
	[dblStrike] [numeric](8, 4) NOT NULL,
	[dblPremium] [numeric](8, 4) NOT NULL,
	[dblServiceFee] [numeric](6, 4) NOT NULL,
	[dtmExpiration] [datetime] NOT NULL,
	[dblTargetPrice] [numeric](8, 4) NULL,
	[intPremFeeId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTContractOption_intContractOptionId] PRIMARY KEY CLUSTERED ([intContractOptionId] ASC),
	CONSTRAINT [FK_tblCTContractOption_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTContractOption_tblCTPremFee_intPremFee] FOREIGN KEY ([intPremFeeId]) REFERENCES [tblCTPremFee]([intPremFeeId]),
	CONSTRAINT [FK_tblCTContractOption_tblCTPutCall_intPutCall] FOREIGN KEY ([intPutCallId]) REFERENCES [tblCTPutCall]([intPutCallId]),
	CONSTRAINT [FK_tblCTContractOption_tblCTBuySell_intBuySell] FOREIGN KEY ([intBuySellId]) REFERENCES [tblCTBuySell]([intBuySellId])
)