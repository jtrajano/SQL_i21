CREATE TYPE [dbo].[VoucherDetailClaim] AS TABLE
(
	dblNetShippedWeight			DECIMAL(18,6) NULL DEFAULT 0,
	dblWeightLoss				DECIMAL(18,6) NULL DEFAULT 0,
	dblFranchiseWeight			DECIMAL(18,6) NULL DEFAULT 0,
	dblFranchiseAmount			DECIMAL(18,6) NULL DEFAULT 0,
	dblQtyReceived				DECIMAL(18,6) NULL DEFAULT 0,
	dblCost						DECIMAL(38,20) NULL DEFAULT 0,
	dblCostUnitQty				DECIMAL(38,20) NULL DEFAULT 0,
	dblWeightUnitQty			DECIMAL(18,6) NULL DEFAULT 0,
	dblUnitQty					DECIMAL(18,6) NULL DEFAULT 0,
	intWeightUOMId				INT NULL,
	intUOMId					INT NOT NULL,
	intCostUOMId				INT NULL,
	intItemId					INT	NULL,
	intContractHeaderId			INT	NULL,
	intInventoryReceiptItemId	INT NULL,
	intContractDetailId			INT	NULL
)
