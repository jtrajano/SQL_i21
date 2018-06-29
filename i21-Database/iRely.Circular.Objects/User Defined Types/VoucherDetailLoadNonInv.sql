CREATE TYPE [dbo].[VoucherDetailLoadNonInv] AS TABLE
(
	intContractHeaderId INT NOT NULL,
	intContractDetailId INT NOT NULL,
	intItemId			INT NOT NULL,
	intItemUOMId		INT NOT NULL,
	intCostUOMId		INT NULL,
	intAccountId		INT NOT NULL,
	intLoadDetailId		INT NOT NULL,
	dblQtyReceived		DECIMAL(18,6) NOT NULL DEFAULT 0,
	dblCost				DECIMAL(38,20) NOT NULL DEFAULT 0
)