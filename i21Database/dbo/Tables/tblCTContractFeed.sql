CREATE TABLE [dbo].[tblCTContractFeed]
(	
	intContractFeedId		INT IDENTITY (1, 1) NOT NULL,
	intContractHeaderId		INT,
	intContractDetailId		INT,
	strCommodityCode		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strCommodityDesc		NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strContractBasis		NVARCHAR(100) COLLATE Latin1_General_CI_AS,--INCOTERMS1
	strContractBasisDesc	NVARCHAR(500) COLLATE Latin1_General_CI_AS,--INCOTERMS2
	strSubLocation			NVARCHAR(50) COLLATE Latin1_General_CI_AS, --L-Plant / PLANT 
	strCreatedBy			NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strCreatedByNo			NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strEntityNo				NVARCHAR (100) COLLATE Latin1_General_CI_AS, --VENDOR 
	strSubmittedBy			NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strSubmittedByNo		NVARCHAR(50) COLLATE Latin1_General_CI_AS, 
	strTerm					NVARCHAR (100)  COLLATE Latin1_General_CI_AS, --PMNTTRMS / VEND_PART 
	dtmContractDate			DATETIME, 
	dtmStartDate			DATETIME, 
	dtmEndDate				DATETIME,
	strPurchasingGroup		NVARCHAR(150) COLLATE Latin1_General_CI_AS, 
	strContractNumber		NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strERPPONumber			NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strERPItemNumber		NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strERPBatchNumber		NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	intContractSeq			INT, --PO_ITEM 
	strItemNo				NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
	strStorageLocation		NVARCHAR(50) COLLATE Latin1_General_CI_AS, --STGE_LOC 
	dblQuantity				NUMERIC(18,6),
	strQuantityUOM			NVARCHAR(50) COLLATE Latin1_General_CI_AS, --PO_UNIT
	dblCashPrice			NUMERIC(18,6), --NET_PRICE
	dblUnitCashPrice		NUMERIC(18,6), --PRICE_UNIT 
	dtmPlannedAvailabilityDate DATETIME, --DELIVERY_DATE 
	dblBasis				NUMERIC(18,6), --COND_VALUE,
	strCurrency				NVARCHAR(50) COLLATE Latin1_General_CI_AS,--CURRENCY 
	strPriceUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS, --COND_UNIT 
	strRowState				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strFeedStatus			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmFeedCreated			DATETIME,

	CONSTRAINT [PK_tblCTContractFeed_intContractFeedId] PRIMARY KEY CLUSTERED (intContractFeedId ASC)
)
