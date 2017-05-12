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
	[intItemContractId] [int],
	[intItemId] [int],
	strOrigin	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[dblQuantity] [numeric](18, 6),
	[intQtyUOMId] [int], -- From tblICUnitMeasure not tblICItemUOM
	[dblNetWeight] [numeric](18, 6),
	[intNetWeightUOMId] [int], -- From tblICUnitMeasure not tblICItemUOM
	[intFutureMarketId] [int],
	[intFutureMonthId] INT,
	[dblFutures] [numeric](18, 6),
	[dblBasis] [numeric](18, 6),	
	[dblCashPrice] [numeric](18, 6),
	[dblNoOfLots] [numeric](18, 6),
	[intCurrencyId] [int],
	[intPriceUOMId]  INT, -- From tblICUnitMeasure not tblICItemUOM
	[intSubLocationId] INT,
	[intStorageLocationId] INT,
	[intPurchasingGroupId] INT,
	[strVendorLotID] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intCertificationId] INT,

	[strApprovalType]	NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	[intLoadingPortId] INT,
	[intApprovedById]	INT,
	[dtmApproved]	DATETIME,
	[ysnApproved]	BIT,
	strPackingDescription	NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblCTApprovedContract_intApprovedContractId] PRIMARY KEY CLUSTERED (intApprovedContractId ASC)
)