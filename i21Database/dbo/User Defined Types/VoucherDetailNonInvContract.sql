CREATE TYPE [dbo].[VoucherDetailNonInvContract] AS TABLE
(
	intContractHeaderId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	intItemId			INT NOT NULL,
	intAccountId		INT NOT NULL,
	dblQtyReceived		INT NOT NULL DEFAULT 0,
	dblCost				INT NOT NULL DEFAULT 0
)
