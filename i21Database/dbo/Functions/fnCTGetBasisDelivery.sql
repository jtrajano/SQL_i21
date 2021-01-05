-- ANY CHANGES APPLIED HERE MUST BE APPLIED ALSO IN fnCTGetBasisDeliveryAboveR2 POST SCRIPT

CREATE FUNCTION [dbo].[fnCTGetBasisDelivery]
(
	@dtmDate DATE = NULL
)
RETURNS @Transaction TABLE 
(  
	-- Filtering Values
	intUniqueId		        INT IDENTITY(1,1),
	intContractHeaderId		INT,  
	intContractDetailId		INT,        
	intTransactionId		INT,
	strTransactionType		NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	intEntityId				INT,
	intCommodityId			INT,
	intItemId				INT,
	intCompanyLocationId	INT,
	intFutureMarketId		INT,
	intFutureMonthId		INT,
	intCurrencyId			INT,
	dtmEndDate				DATETIME,
	-- Display Values
	strContractType			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	strContractNumber		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intContractSeq			INT,
	strTransactionId		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strCustomerVendor		NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
	strCommodityCode		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strItemNo				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
    strCompanyLocation		NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL, 
	dtmDate					DATETIME,
	dblQuantity				NUMERIC(38,20),
	dblRunningBalance		NUMERIC(38,20),
	ysnOpenGetBasisDelivery	bit DEFAULT(0),
	dblQtyInCommodityStockUOM NUMERIC(38,20),
	dblRunningBalanceInCommodityStockUOM NUMERIC(38,20),
	intSequenceUnitMeasureId INT,
	strSequenceUnitMeasure nvarchar(100),
	intHeaderUnitMeasureId INT,
	strHeaderUnitMeasure nvarchar(100),
	intHeaderBookId			INT NULL,
	intHeaderSubBookId		INT NULL,
	intDetailBookId			INT NULL,
	intDetailSubBookId		INT NULL
)
AS
BEGIN
	WITH OpenBasisContract	AS (
		SELECT CD.intContractDetailId
			, CH.intContractHeaderId
			, intSequenceUnitMeasureId = CDUM.intUnitMeasureId
			, strSequenceUnitMeasure = CDUM.strUnitMeasure
			, intHeaderUnitMeasureId = CHUM.intUnitMeasureId
			, strHeaderUnitMeasure = CHUM.strUnitMeasure
			, CD.intBookId
			, CD.intSubBookId
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblICUnitMeasure CDUM ON CDUM.intUnitMeasureId = CD.intUnitMeasureId
		LEFT JOIN tblICCommodityUnitMeasure CHCUM ON CHCUM.intCommodityId = CH.intCommodityId AND CHCUM.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure CHUM ON CHUM.intUnitMeasureId = CHCUM.intUnitMeasureId
		left join tblCTWeightGrade w on w.intWeightGradeId = CH.intWeightId  
		left join tblCTWeightGrade g on g.intWeightGradeId = CH.intGradeId  
		LEFT JOIN (
			SELECT intRowId = ROW_NUMBER() OVER(PARTITION BY SH.intContractHeaderId, SH.intContractDetailId ORDER BY SH.dtmHistoryCreated DESC)
				, SH.intPricingTypeId
				, SH.intContractHeaderId
				, SH.intContractDetailId
				, dtmHistoryCreated
				, intContractStatusId
			FROM tblCTSequenceHistory SH
			INNER JOIN tblCTContractHeader ET ON SH.intContractHeaderId = ET.intContractHeaderId
			WHERE dtmHistoryCreated < DATEADD(DAY, 1, @dtmDate)
		) tbl ON tbl.intContractDetailId = CD.intContractDetailId AND tbl.intContractHeaderId = CD.intContractHeaderId AND tbl.intRowId = 1
		WHERE tbl.intPricingTypeId = 2
			AND (tbl.intContractStatusId = 1 or (tbl.intContractStatusId = 5 and (g.strWhereFinalized = 'Destination' or w.strWhereFinalized = 'Destination'))))
	, CBL AS (
		SELECT CBL1.*
			, strEntityName = EM.strName
		FROM tblCTContractBalanceLog CBL1
		INNER JOIN tblEMEntityType ET ON ET.intEntityId = CBL1.intEntityId AND ET.strType = (CASE WHEN CBL1.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
		INNER JOIN tblEMEntity EM ON EM.intEntityId = ET.intEntityId
		WHERE CBL1.strTransactionType LIKE '%Basis Deliveries'
			AND CBL1.dtmTransactionDate < DATEADD(DAY, 1, @dtmDate)
			AND isnull(CBL1.dblQty,0) <> 0
	)

	INSERT INTO @Transaction (intContractHeaderId
		, intContractDetailId
		, intTransactionId
		, strTransactionId
		, strTransactionType
		, intEntityId
		, strContractType
		, strContractNumber
		, intContractSeq		
		, strCustomerVendor
		, strCommodityCode
		, intCommodityId
		, strItemNo
		, intItemId
		, strCompanyLocation
		, intCompanyLocationId
		, dtmEndDate
		, intFutureMarketId
		, intFutureMonthId
		, intCurrencyId
		, dtmDate
		, dblQuantity
		, dblRunningBalance
		, dblQtyInCommodityStockUOM
		, dblRunningBalanceInCommodityStockUOM
		, intSequenceUnitMeasureId
		, strSequenceUnitMeasure
		, intHeaderUnitMeasureId
		, strHeaderUnitMeasure
		, ysnOpenGetBasisDelivery
		, intHeaderBookId
		, intHeaderSubBookId
		, intDetailBookId
		, intDetailSubBookId)
	SELECT CBL1.intContractHeaderId
		, CBL1.intContractDetailId
		, intTransactionId = CBL1.intTransactionReferenceId
		, strTransactionId = CBL1.strTransactionReferenceNo
		, strTransactionType = CBL1.strTransactionReference
		, CBL1.intEntityId
		, strContractType = CASE WHEN CBL1.intContractTypeId = 1 THEN 'Purchase' ELSE 'Sale' END
		, CBL1.strContractNumber
		, CBL1.intContractSeq
		, strCustomerVendor = CBL1.strEntityName
		, CY.strCommodityCode
		, CBL1.intCommodityId
		, IM.strItemNo
		, CBL1.intItemId
		, strCompanyLocation = CL.strLocationName
		, intCompanyLocationId = CBL1.intLocationId
		, CBL1.dtmEndDate
		, CBL1.intFutureMarketId
		, CBL1.intFutureMonthId
		, intCurrencyId = CBL1.intBasisCurrencyId
		, dtmDate = CBL1.dtmTransactionDate
		, dblQuantity = CBL1.dblQty
		, dblRunningBalance = SUM(CBL2.dblQty)
		, dblQtyInCommodityStockUOM = dbo.fnCTConvertQtyToTargetCommodityUOM(CBL1.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),CUM.intUnitMeasureId,CBL1.dblQty)	
		, dblRunningBalanceInCommodityStockUOM = dbo.fnCTConvertQtyToTargetCommodityUOM(CBL1.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),CUM.intUnitMeasureId,SUM(CBL2.dblQty))
		, OBC.intSequenceUnitMeasureId
		, OBC.strSequenceUnitMeasure
		, OBC.intHeaderUnitMeasureId
		, OBC.strHeaderUnitMeasure
		, ysnOpenGetBasisDelivery = 1--CASE WHEN @dtmDate IS NULL OR CBL1.dtmTransactionDate <= @dtmDate AND CBL1.dblQty > 0 THEN 1 ELSE 0 END
		, CH.intBookId
		, CH.intSubBookId
		, OBC.intBookId
		, OBC.intSubBookId
	FROM CBL CBL1
	INNER JOIN CBL CBL2 ON CBL1.intContractBalanceLogId >= CBL2.intContractBalanceLogId
		AND CBL1.intContractHeaderId = CBL2.intContractHeaderId
		AND CBL1.intContractDetailId = CBL2.intContractDetailId
	INNER JOIN tblICCommodity CY ON CBL1.intCommodityId = CY.intCommodityId
	INNER JOIN tblICItem IM ON IM.intItemId = CBL1.intItemId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL1.intLocationId
	INNER JOIN tblCTContractHeader CH ON CBL1.intContractHeaderId = CH.intContractHeaderId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityId = CH.intCommodityId AND CUM.ysnStockUnit=1
	INNER JOIN OpenBasisContract OBC ON CBL1.intContractDetailId = OBC.intContractDetailId AND CBL1.intContractHeaderId = OBC.intContractHeaderId
	GROUP BY CBL1.dtmCreatedDate
		, CBL1.intContractBalanceLogId
		, CBL1.intContractHeaderId
		, CBL1.intContractDetailId
		, CBL1.intTransactionReferenceId
		, CBL1.strTransactionReference
		, CBL1.intEntityId
		, CBL1.intCommodityId
		, CBL1.intItemId
		, CBL1.intLocationId
		, CBL1.intFutureMarketId
		, CBL1.intFutureMonthId
		, CBL1.intBasisCurrencyId
		, CBL1.dtmEndDate
		, CBL1.intContractTypeId
		, CBL1.strContractNumber
		, CBL1.intContractSeq
		, CBL1.strTransactionReferenceNo
		, CBL1.strEntityName
		, CY.strCommodityCode
		, IM.strItemNo
		, CL.strLocationName
		, CBL1.dtmTransactionDate
		, CBL1.dblQty
		, CBL1.intCommodityId
		, CH.intCommodityUOMId
		, CUM.intUnitMeasureId
		, CBL1.dblQty
		, OBC.intSequenceUnitMeasureId
		, OBC.strSequenceUnitMeasure
		, OBC.intHeaderUnitMeasureId
		, OBC.strHeaderUnitMeasure
		, CH.intBookId
		, CH.intSubBookId
		, OBC.intBookId
		, OBC.intSubBookId
	ORDER BY CBL1.dtmCreatedDate, CBL1.intContractBalanceLogId ASC;
 
 	DELETE FROM @Transaction
	WHERE strTransactionType = 'Voucher'
		AND intTransactionId NOT IN (
		SELECT DISTINCT T.intTransactionId
		FROM @Transaction T
		JOIN tblAPBillDetail BD ON BD.intBillId = T.intTransactionId AND strTransactionType = 'Voucher' AND BD.intContractHeaderId = T.intContractHeaderId AND BD.intContractDetailId = T.intContractDetailId
	)
	
	DELETE FROM @Transaction
	WHERE intContractDetailId IN (
		SELECT intContractDetailId
		FROM @Transaction
		GROUP BY intContractDetailId
		HAVING SUM(dblQuantity) <= 0
	)

	RETURN
END