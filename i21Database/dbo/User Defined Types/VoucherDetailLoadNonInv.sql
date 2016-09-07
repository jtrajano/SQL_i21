CREATE TYPE [dbo].[VoucherDetailLoadNonInv] AS TABLE
(
	intContractHeaderId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	intItemId			INT NOT NULL,
	intAccountId		INT NOT NULL,
	intLoadDetailId		INT NOT NULL,
	dblQtyReceived		DECIMAL(18,6) NOT NULL DEFAULT 0,
	dblCost				DECIMAL(18,6) NOT NULL DEFAULT 0
)