CREATE TABLE [dbo].[tblCTUpdatedSequencePrice]
(
	strTxnIdentifier nvarchar(36) COLLATE Latin1_General_CI_AS,
	intContractHeaderId int,
	intContractDetailId int,
	intContractSeq int,
	dblOldCashPrice numeric(38,20) null,
	dblNewCashPrice numeric(38,20) null,
	dblOldTotalCost numeric(38,20) null,
	dblNewTotalCost numeric(38,20) null,
	intValueCurrencyId int,
	ysnValue bit null
)
