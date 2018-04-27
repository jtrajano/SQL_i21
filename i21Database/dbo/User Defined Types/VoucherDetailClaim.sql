CREATE TYPE [dbo].[VoucherDetailClaim] AS TABLE
(
	dblNetShippedWeight			DECIMAL(18,6),
	dblWeightLoss				DECIMAL(18,6),
	dblFranchiseWeight			DECIMAL(18,6),
	dblQtyReceived				DECIMAL(18,6),
	dblCost						DECIMAL(38,20),
	dblCostUnitQty				DECIMAL(38,20),
	dblWeightUnitQty			DECIMAL(18,6),
	dblUnitQty					DECIMAL(18,6),
	intWeightUOMId				INT NULL,
	intUOMId					INT NOT NULL,
	intCostUOMId				INT NULL,
	intItemId					INT	NULL,
	intContractHeaderId			INT	NULL,
	intInventoryReceiptItemId	INT NULL,
	intContractDetailId			INT	NULL
)
