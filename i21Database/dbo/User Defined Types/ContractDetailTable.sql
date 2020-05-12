CREATE TYPE [dbo].[ContractDetailTable] AS TABLE
(
	[intContractDetailId] INT, 
	[intContractHeaderId] INT,
	[dtmCreated] DATETIME,
	[intContractSeq] INT,
	[intBasisCurrencyId] INT,
	[intBasisUOMId] INT
)   