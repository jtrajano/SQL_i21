CREATE TABLE [dbo].[tblCTApprovedContract]
(
	[intApprovedContractId] [int] IDENTITY(1,1) NOT NULL,
	[intContractHeaderId] [int]  NOT NULL,
	[intContractDetailId] [int] NOT NULL, 

	[intEntityId] [int],
	[intGradeId] [int],
	[intWeightId] [int],
	[intTermId] INT, 
	[intPositionId] [INT],
	[intContractBasisId] [INT],
	
	[intContractStatusId] [int],
	[dtmStartDate] [datetime],
	[dtmEndDate] [datetime],
	[dtmPlannedAvailabilityDate] [datetime],
	[intItemId] [int],
	[dblQuantity] [numeric](18, 6),
	[intQtyUOMId] [int], -- From tblICUnitMeasure not tblICItemUOM
	[intFutureMarketId] [int],
	[intFutureMonthId] INT,
	[dblFutures] [numeric](18, 6),
	[dblBasis] [numeric](18, 6),	
	[dblCashPrice] [numeric](18, 6),
	[intCurrencyId] [int],
	[intPriceUOMId]  INT, -- From tblICUnitMeasure not tblICItemUOM
	[intSubLocationId] INT,
	[intStorageLocationId] INT,
	[intPurchasingGroupId] INT,

	[intApprovedById]	INT,
	[dtmApproved]	DATETIME
)