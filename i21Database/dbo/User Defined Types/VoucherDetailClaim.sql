CREATE TYPE [dbo].[VoucherDetailClaim] AS TABLE
(
	dblNetShippedWeight		DECIMAL(18,6),
	dblWeightLoss			DECIMAL(18,6),
	dblFranchiseWeight		DECIMAL(18,6),
	dblClaim				DECIMAL(18,6),
	dblCost					DECIMAL(18,6),
	intItemId				INT,
	intContractHeaderId		INT,
	intContractDetailId		INT
)
