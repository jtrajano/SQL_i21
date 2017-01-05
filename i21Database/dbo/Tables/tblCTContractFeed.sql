﻿CREATE TABLE [dbo].[tblCTContractFeed]
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
    strTerm					NVARCHAR (100)  COLLATE Latin1_General_CI_AS, --PMNTTRMS / VEND_PART 
    strPurchasingGroup		NVARCHAR(150), 
    strContractNumber		NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
    strERPPoNumber			NVARCHAR (100)  COLLATE Latin1_General_CI_AS,
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
    strFeedStatus			NVARCHAR(50) COLLATE Latin1_General_CI_AS
)
