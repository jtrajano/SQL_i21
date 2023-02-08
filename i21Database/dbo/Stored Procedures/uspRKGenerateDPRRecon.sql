CREATE PROCEDURE [dbo].[uspRKGenerateDPRRecon]
	@intDPRReconHeaderId INT = NULL
	, @dtmFromDate  DATETIME 
	, @dtmToDate DATETIME
	, @dtmServerFromDate DATETIME
	, @dtmServerToDate DATETIME
	, @intCommodityId INT
	, @intUserId INT

AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
 
	DECLARE @ErrMsg NVARCHAR(MAX)


	--Convert Dates to UTC
	--SET @dtmFromDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()) - 1, @dtmFromDate)
	--SET @dtmToDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE())- 1, @dtmToDate)

	DECLARE @tblRKDPRReconContracts TABLE (
		[intSort] INT NOT NULL,
		[strLocationName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strCommodityCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[strContractType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[strContractStatus] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[strContractNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[intContractSeq] INT NULL,
		[strItemNo] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[dtmCreatedDate] DATETIME NOT NULL,
		[dtmTransactionDate] DATETIME NOT NULL,
		[dblQty] NUMERIC(24, 10) NOT NULL,
		[strUnitMeasure] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strUserName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strBucketName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strAction] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strPricingType] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
		[strTicketNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
		[strLoadNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
		[dblLoadQty] NUMERIC(24, 10) NULL,
		[dblReceivedQty] NUMERIC(24, 10) NULL,
		[dblCash] NUMERIC(24, 10) NULL,
		[intContractHeaderId] INT NULL,
		[intTicketId] INT NULL,
		[intLoadId] INT NULL,
		[strDistribution] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL,
		[strStorageSchedule] NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
		[strSettlementTicket] NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
		[strStatus] NVARCHAR (50) COLLATE Latin1_General_CI_AS  NULL
	)


	DECLARE @tblRKDPRReconDerivatives TABLE (
		[intSort] INT NOT NULL,
		[strTransactionNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strInstrumentType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strFutMarketName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strCurrency] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strCommodityCode] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strLocationName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strBroker] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strBrokerTradeNo] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[strBrokerAccount] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strTrader] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dblOrigNoOfLots]  NUMERIC(24, 10) NOT NULL,
		[dblOrigQty]  NUMERIC(24, 10) NOT NULL,
		[strBuySell] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strFutureMonth] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strAction] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dblPrice]  NUMERIC(24, 10) NOT NULL,
		[dtmLastTradingDate] DATETIME,
		[strStatus] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dtmFilledDate] DATETIME,
		[strNotes] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
		[dtmCreatedDate] DATETIME NOT NULL,
		[dtmTransactionDate] DATETIME NOT NULL,
		[strBucketName] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
		[intFutOptTransactionHeaderId] INT NULL
	)

	--==========================================================================================
	--				PURCHASE CONTRACT
	--==========================================================================================
	INSERT INTO @tblRKDPRReconContracts (
		intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName
		,strAction
		,strPricingType 
		,strTicketNumber 
		,strLoadNumber 
		,dblLoadQty
		,dblReceivedQty 
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution
		,strStorageSchedule
		,strSettlementTicket
		,strStatus
	)
	SELECT
		intSort = 1
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ New Priced Purchase Contract'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Created Contract'
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId = 1

	UNION ALL

	SELECT
		intSort = 2
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ New HTA Purchase Contract'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Created Contract'
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId = 3


	UNION ALL

	SELECT
		intSort = 3
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase' 
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblQty = SL.dblOrigQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Spot Purchases'
		,strAction
		,strPricingType = ''
		,strTicketNumber = T.strTicketNumber
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = SL.dblPrice
		,CH.intContractHeaderId
		,intTicketId = SL.intTicketId
		,intLoadId = NULL
		,strDistribution  = CASE WHEN SL.strInOut = 'IN' THEN 'Distributed' ELSE 'Undistributed' END
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	LEFT JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblSCTicket T ON T.intTicketId = SL.intTicketId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Company Owned' 
	AND SL.strAction = 'Receipt on Spot Priced'

	UNION ALL

	SELECT
		intSort = 3
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase' 
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblQty = SL.dblOrigQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Spot Purchases'
		,strAction
		,strPricingType = ''
		,strTicketNumber = T.strTicketNumber
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = SS.dblCashPrice
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = NULL
		,strDistribution  = CASE WHEN T.strTicketStatus = 'C'  THEN 'Distributed' ELSE 'Undistributed' END
		,strStorageSchedule  = ST.strStorageTypeDescription
		,strSettlementTicket = SL.strTransactionNumber
		,strStatus  = CASE WHEN SL.strInOut = 'IN' THEN 'Posted' ELSE 'Unposted' END
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	LEFT JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SL.intTransactionRecordId
	LEFT JOIN tblGRCustomerStorage GR ON GR.intCustomerStorageId = SL.intTransactionRecordHeaderId
	LEFT JOIN tblSCTicket T ON T.intTicketId = GR.intTicketId
	LEFT JOIN tblGRSettleContract SC ON SC.intSettleStorageId = SS.intSettleStorageId
	LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = GR.intStorageTypeId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Company Owned' 
	AND SL.strAction = 'Settle Storage - Company owned storage'
	AND SC.intContractDetailId IS NULL

	UNION ALL

	SELECT
		intSort = 3
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase' 
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblQty = SL.dblOrigQty * -1
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Spot Purchases'
		,strAction
		,strPricingType = ''
		,strTicketNumber = T.strTicketNumber
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = SS.dblCashPrice
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = NULL
		,strDistribution  = CASE WHEN SL.strInOut = 'OUT' THEN 'Distributed' ELSE 'Undistributed' END
		,strStorageSchedule  = ST.strStorageTypeDescription
		,strSettlementTicket = SL.strTransactionNumber
		,strStatus  = CASE WHEN SL.strInOut = 'OUT' THEN 'Posted' ELSE 'Unposted' END
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	LEFT JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN tblGRSettleStorage SS ON SS.intSettleStorageId = SL.intTransactionRecordId
	LEFT JOIN tblGRCustomerStorage GR ON GR.intCustomerStorageId = SL.intTransactionRecordHeaderId
	LEFT JOIN tblSCTicket T ON T.intTicketId = GR.intTicketId
	LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = GR.intStorageTypeId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Delayed Pricing' 
	AND SL.strAction = 'Settle Storage - Company owned storage'

	UNION ALL

	SELECT
		intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName 
		,strAction
		,strPricingType
		,strTicketNumber
		,strLoadNumber
		,dblLoadQty
		,dblReceivedQty
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution 
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus 
	FROM (
		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId, intTransactionReferenceDetailId, strAction ORDER BY intContractBalanceLogId DESC)
			,intSort = 4
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Purchase'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,CBL.dtmCreatedDate
			,CBL.dtmTransactionDate
			,dblQty = CASE WHEN strAction = 'Deleted Pricing' THEN CBL.dblOrigQty * -1 ELSE CBL.dblOrigQty END
			,UM.strUnitMeasure
			,EC.strUserName
			,strBucketName = '+ Purchase Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND strAction IN ('Created Price','Deleted Pricing')
		AND CBL.intContractTypeId = 1 --Purchase
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2

		UNION ALL

		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId  ORDER BY intContractDetailId DESC)
			,intSort = 4
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Purchase'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(dtmCreatedDate)
			,dtmTransactionDate = MAX(dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,EC.strUserName
			,strBucketName = '+ Purchase Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND CBL.intContractSeq = 1
		AND strAction IN ('Price Updated')
		AND CBL.intContractTypeId = 1 --Purchase
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strUserName
			,strAction
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0

		UNION ALL

		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId  ORDER BY intContractDetailId DESC)
			,intSort = 4
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Purchase'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(dtmCreatedDate)
			,dtmTransactionDate = MAX(dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,strUserName = MAX(EC.strUserName)
			,strBucketName = '+ Purchase Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND CBL.intContractSeq = 1
		AND strAction IN ('Updated Contract')
		AND CBL.intContractTypeId = 1 --Purchase
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strAction
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0

	) t WHERE intRowNum = 1

	UNION ALL

	SELECT
		intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName 
		,strAction
		,strPricingType
		,strTicketNumber
		,strLoadNumber
		,dblLoadQty
		,dblReceivedQty
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution 
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus 
	FROM (
		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intContractDetailId DESC)
			,intSort = 5
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Purchase'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(CBL.dtmCreatedDate)
			,dtmTransactionDate = MAX(CBL.dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,strUserName = MAX(EC.strUserName)
			,strBucketName = '+ Purchase Qty Adjustment'
			,strAction
			,PT.strPricingType
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND strAction IN('Updated Contract')
		AND CBL.intContractTypeId = 1 --Purchase
		AND CBL.intPricingTypeId IN (1,3) --Priced, HTA
		--AND( (CBL.dblQty != CBL.dblOrigQty  AND CBL.intPricingTypeId <> 3) OR (CBL.intPricingTypeId = 3 AND ABS(CBL.dblQty) != ABS(CBL.dblOrigQty) ))
		AND (CBL.dblQty != CBL.dblOrigQty  AND CBL.intPricingTypeId <> 3)
		AND CBL.strTransactionType = 'Contract Balance'
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strAction
			,PT.strPricingType
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0
	) t WHERE intRowNum = 1
	UNION ALL

	SELECT
		intSort = 5
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Purchase Qty Adjustment'
		,strAction
		,PT.strPricingType
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction IN('Re-opened Sequence')
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA


	UNION ALL

	SELECT
		intSort = 5
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Purchase Qty Adjustment'
		,strAction
		,PT.strPricingType
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NOT NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction IN('Created Contract')
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA

	UNION ALL

	SELECT
		intSort = 6
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,dtmCreatedDate =  DATEADD(hh, DATEDIFF(hh, @dtmServerFromDate, @dtmFromDate),B.dtmDateCreated)
		,SL.dtmTransactionDate
		,dblVariance  =  CASE WHEN SL.dblOrigQty < 0 THEN CH.dblQuantityPerLoad - ABS(SL.dblOrigQty)  ELSE  SL.dblOrigQty - CH.dblQuantityPerLoad END
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+/- Purchase Load Variance'
		,strAction = CASE WHEN SL.strInOut = 'IN' THEN 'Distributed' ELSE 'Undistributed' END
		,strPricingType = NULL
		,T.strTicketNumber
		,T.strLoadNumber
		,dblLoadQty = CH.dblQuantityPerLoad
		,dblReceivedQty  = SL.dblOrigQty
		,dblCash = NULL
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = T.intLoadId
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	INNER JOIN tblSCTicket T ON T.intTicketId = SL.intTicketId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	INNER JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblICInventoryReceiptItem R ON R.intSourceId = T.intTicketId
	INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = R.intInventoryReceiptItemId AND BD.intInventoryReceiptChargeId IS NULL AND BD.intContractDetailId = CD.intContractDetailId
	INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
	WHERE --dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate 
	B.dtmDateCreated BETWEEN @dtmServerFromDate AND @dtmServerToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Company Owned'
	AND CT.strContractType = 'Purchase' 
	AND CH.ysnLoad = 1

	UNION ALL

	SELECT
		intSort = 7
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '- Purchase Short Closed'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Short Closed Sequence'
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA

	UNION ALL

	SELECT
		intSort = 8
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Purchase'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '- Purchase Cancelled'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Canceled Sequence'
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA



	--==========================================================================================
	--				SALES CONTRACT
	--==========================================================================================
	UNION ALL

	SELECT
		intSort = 11
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ New Priced Sales Contract'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Created Contract'
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId = 1

	UNION ALL

	SELECT
		intSort = 12
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ New HTA Sales Contract'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Created Contract'
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId = 3


	UNION ALL

	SELECT
		intSort = 13
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales' 
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblQty = SL.dblOrigQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Spot Sales'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = T.strTicketNumber
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = SL.dblPrice
		,CH.intContractHeaderId
		,intTicketId = SL.intTicketId
		,intLoadId = NULL
		,strDistribution  = CASE WHEN SL.strInOut = 'IN' THEN 'Distributed' ELSE 'Undistributed' END
		,strStorageSchedule  = ST.strStorageTypeDescription
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	LEFT JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	LEFT JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId 
	LEFT JOIN tblSCTicket T ON T.intTicketId = SL.intTicketId
	LEFT JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = T.intStorageScheduleTypeId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Company Owned' 
	AND SL.strAction = 'Shipment on Spot Priced'

	UNION ALL

	SELECT
		intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName 
		,strAction
		,strPricingType
		,strTicketNumber
		,strLoadNumber
		,dblLoadQty
		,dblReceivedQty
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution 
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus 
	FROM (
		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId, intTransactionReferenceDetailId, strAction ORDER BY intContractBalanceLogId DESC)
			,intSort = 14
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Sales'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,CBL.dtmCreatedDate
			,CBL.dtmTransactionDate
			,dblQty = CASE WHEN strAction = 'Deleted Pricing' THEN CBL.dblOrigQty * -1 ELSE CBL.dblOrigQty END
			,UM.strUnitMeasure
			,EC.strUserName
			,strBucketName = '+ Sales Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND strAction IN ('Created Price','Deleted Pricing')
		AND CBL.intContractTypeId = 2 --Sales
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2

		UNION ALL

		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId  ORDER BY intContractDetailId DESC)
			,intSort = 14
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Sales'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(dtmCreatedDate)
			,dtmTransactionDate = MAX(dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,EC.strUserName
			,strBucketName = '+ Sales Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND CBL.intContractSeq = 1
		AND strAction IN ('Price Updated')
		AND CBL.intContractTypeId = 2 --Sales
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strUserName
			,strAction
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0

		UNION ALL

		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId  ORDER BY intContractDetailId DESC)
			,intSort = 14
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Sales'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(dtmCreatedDate)
			,dtmTransactionDate = MAX(dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,strUserName = MAX(EC.strUserName)
			,strBucketName = '+ Sales Basis Pricing'
			,strAction
			,strPricingType = NULL
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CBL.intContractHeaderId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND CBL.intContractSeq = 1
		AND strAction IN ('Updated Contract')
		AND CBL.intContractTypeId = 2 --Sales
		AND CBL.intPricingTypeId = 1
		AND CH.intPricingTypeId = 2
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strAction
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0

	) t WHERE intRowNum = 1

	UNION ALL
	SELECT
		intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName 
		,strAction
		,strPricingType
		,strTicketNumber
		,strLoadNumber
		,dblLoadQty
		,dblReceivedQty
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution 
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus 
	FROM (
		SELECT
			intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intContractDetailId DESC)
			,intSort = 15
			,CL.strLocationName
			,E.strName
			,C.strCommodityCode
			,strContractType = 'Sales'
			,CS.strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,I.strItemNo
			,dtmCreatedDate = MAX(CBL.dtmCreatedDate)
			,dtmTransactionDate = MAX(CBL.dtmTransactionDate)
			,dblQty = SUM(CBL.dblQty)
			,UM.strUnitMeasure
			,strUserName = MAX(EC.strUserName)
			,strBucketName = '+ Sales Qty Adjustment'
			,strAction
			,PT.strPricingType
			,strTicketNumber = NULL
			,strLoadNumber = NULL
			,dblLoadQty = NULL
			,dblReceivedQty  = NULL
			,dblCash = NULL
			,CBL.intContractHeaderId
			,intTicketId = NULL
			,intLoadId = NULL
			,strDistribution  = ''
			,strStorageSchedule  = ''
			,strSettlementTicket = ''
			,strStatus  = ''
		FROM tblCTContractBalanceLog CBL
		INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
		INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
		INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
		INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
		INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
		INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
		INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
		INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
		WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
		AND CBL.intCommodityId = @intCommodityId
		AND strAction IN('Updated Contract')
		AND CBL.intContractTypeId = 2 --Sales
		AND CBL.intPricingTypeId IN (1,3) --Priced, HTA
		--AND( (CBL.dblQty != CBL.dblOrigQty  AND CBL.intPricingTypeId <> 3) OR (CBL.intPricingTypeId = 3 AND ABS(CBL.dblQty) != ABS(CBL.dblOrigQty) ))
		AND (CBL.dblQty != CBL.dblOrigQty  AND CBL.intPricingTypeId <> 3)
		AND CBL.strTransactionType = 'Contract Balance'
		GROUP BY 
			intContractDetailId
			,strLocationName
			,strName
			,strCommodityCode
			,strContractStatus
			,CBL.strContractNumber
			,CBL.intContractSeq
			,strItemNo
			,strUnitMeasure
			,strAction
			,PT.strPricingType
			,CBL.intContractHeaderId
		HAVING SUM(CBL.dblQty) <> 0
	) t WHERE intRowNum = 1

	UNION ALL

	SELECT
		intSort = 15
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Sales Qty Adjustment'
		,strAction
		,PT.strPricingType
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction IN('Re-opened Sequence')
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA

	UNION ALL

	SELECT
		intSort = 15
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+ Sales Qty Adjustment'
		,strAction
		,PT.strPricingType
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CBL.intPricingTypeId
	INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = CBL.intContractDetailId AND CD.intParentDetailId IS NOT NULL
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction IN('Created Contract')
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA

	UNION ALL

	SELECT
		intSort = 16
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CH.strContractNumber
		,CD.intContractSeq
		,I.strItemNo
		,dtmCreatedDate = DATEADD(hh, DATEDIFF(hh, @dtmServerFromDate, @dtmFromDate),IV.dtmDateCreated)
		,SL.dtmTransactionDate
		,dblVariance  = CASE WHEN SL.dblOrigQty < 0 THEN ABS(SL.dblOrigQty) - CH.dblQuantityPerLoad ELSE CH.dblQuantityPerLoad - SL.dblOrigQty END
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+/- Sales Load Variance'
		,strAction = CASE WHEN SL.strInOut = 'IN' THEN 'Distributed' ELSE 'Undistributed' END
		,strPricingType = NULL
		,T.strTicketNumber
		,T.strLoadNumber
		,dblLoadQty = CH.dblQuantityPerLoad
		,dblReceivedQty  = SL.dblOrigQty
		,dblCash = NULL
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = T.intLoadId
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblRKSummaryLog SL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = SL.intEntityId
	INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = SL.intContractHeaderId 
	INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = SL.intContractDetailId
	INNER JOIN tblSCTicket T ON T.intTicketId = SL.intTicketId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = SL.intUserId
	INNER JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = SL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = SL.intOrigUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblICInventoryShipmentItem S ON S.intSourceId = T.intTicketId
	INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = S.intInventoryShipmentItemId AND ID.intInventoryShipmentChargeId IS NULL AND ID.intContractDetailId = CD.intContractDetailId
	INNER JOIN tblARInvoice IV ON IV.intInvoiceId = ID.intInvoiceId 
	WHERE --dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate 
	IV.dtmDateCreated BETWEEN @dtmServerFromDate AND @dtmServerToDate
	AND SL.intCommodityId = @intCommodityId
	AND SL.strBucketType = 'Company Owned'
	AND CT.strContractType = 'Sale'
	AND CH.ysnLoad = 1

	UNION ALL

	SELECT
		intSort = 17
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '- Sales Short Closed'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Short Closed Sequence'
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA

	UNION ALL

	SELECT
		intSort = 18
		,CL.strLocationName
		,E.strName
		,C.strCommodityCode
		,strContractType = 'Sales'
		,CS.strContractStatus
		,CBL.strContractNumber
		,CBL.intContractSeq
		,I.strItemNo
		,CBL.dtmCreatedDate
		,CBL.dtmTransactionDate
		,CBL.dblQty
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '- Sales Cancelled'
		,strAction
		,strPricingType = NULL
		,strTicketNumber = NULL
		,strLoadNumber = NULL
		,dblLoadQty = NULL
		,dblReceivedQty  = NULL
		,dblCash = NULL
		,CBL.intContractHeaderId
		,intTicketId = NULL
		,intLoadId = NULL
		,strDistribution  = ''
		,strStorageSchedule  = ''
		,strSettlementTicket = ''
		,strStatus  = ''
	FROM tblCTContractBalanceLog CBL
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CBL.intLocationId
	INNER JOIN tblEMEntity E ON E.intEntityId = CBL.intEntityId
	INNER JOIN tblICCommodity C ON C.intCommodityId = CBL.intCommodityId
	INNER JOIN tblCTContractStatus CS ON CS.intContractStatusId = CBL.intContractStatusId 
	INNER JOIN tblICItem I ON I.intItemId = CBL.intItemId
	INNER JOIN tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = CBL.intQtyUOMId
	INNER JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CUM.intUnitMeasureId
	INNER JOIN tblEMEntityCredential EC ON EC.intEntityId = CBL.intUserId
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate
	AND CBL.intCommodityId = @intCommodityId
	AND strAction = 'Canceled Sequence'
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId IN (1,3) --Priced, HTA




	--=============================================================
	--				DERIVATIVES
	--=============================================================

	INSERT INTO @tblRKDPRReconDerivatives (
		intSort 
		,strTransactionNumber
		,strInstrumentType
		,strFutMarketName
		,strCurrency
		,strCommodityCode
		,strLocationName
		,strBroker
		,strBrokerTradeNo
		,strBrokerAccount
		,strTrader
		,dblOrigNoOfLots
		,dblOrigQty
		,strBuySell
		,strFutureMonth
		,strAction
		,dblPrice
		,dtmLastTradingDate
		,strStatus
		,dtmFilledDate
		,strNotes
		,dtmCreatedDate
		,dtmTransactionDate
		,strBucketName 
		,intFutOptTransactionHeaderId
	)
	SELECT
		intSort = 21
		,SL.strTransactionNumber
		,SL.strInstrumentType
		,FM.strFutMarketName
		,Cur.strCurrency
		,C.strCommodityCode
		,CL.strLocationName
		,SL.strBroker
		,SL.strBrokerTradeNo
		,SL.strBrokerAccount
		,H.strTrader
		,SL.dblOrigNoOfLots
		,SL.dblOrigQty
		,SL.strBuySell
		,FMo.strFutureMonth
		,SL.strAction
		,SL.dblPrice
		,H.dtmLastTradingDate
		,H.strStatus
		,H.dtmFilledDate
		,SL.strNotes
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,strBucketName = 'Futures'
		,intFutOptTransactionHeaderId = SL.intTransactionRecordHeaderId
	FROM tblRKSummaryLog SL
	INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SL.intFutureMarketId
	INNER JOIN tblSMCurrency Cur ON Cur.intCurrencyID = FM.intCurrencyId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblRKFuturesMonth FMo ON FMo.intFutureMonthId = SL.intFutureMonthId
	CROSS APPLY (
		SELECT TOP 1 strTrader,dtmLastTradingDate,strStatus,dtmFilledDate
		FROM tblRKFutOptTransactionHistory
		WHERE intFutOptTransactionId = SL.intFutOptTransactionId
		ORDER BY intFutOptTransactionHistoryId DESC
	
	) H
	WHERE dtmCreatedDate between @dtmFromDate and @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND isnull(SL.ysnPreCrush,0) = 0
	AND SL.strInstrumentType = 'Futures'
	AND SL.strAction not in ( 'Match Derivatives','Delete Match Derivatives.')

	UNION ALL

	SELECT
		intSort = 22
		,SL.strTransactionNumber
		,SL.strInstrumentType
		,FM.strFutMarketName
		,Cur.strCurrency
		,C.strCommodityCode
		,CL.strLocationName
		,SL.strBroker
		,SL.strBrokerTradeNo
		,SL.strBrokerAccount
		,H.strTrader
		,SL.dblOrigNoOfLots
		,SL.dblOrigQty
		,SL.strBuySell
		,FMo.strFutureMonth
		,SL.strAction
		,SL.dblPrice
		,H.dtmLastTradingDate
		,H.strStatus
		,H.dtmFilledDate
		,SL.strNotes
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,strBucketName = 'Crush'
		,intFutOptTransactionHeaderId = SL.intTransactionRecordHeaderId
	FROM tblRKSummaryLog SL
	INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = SL.intFutureMarketId
	INNER JOIN tblSMCurrency Cur ON Cur.intCurrencyID = FM.intCurrencyId
	INNER JOIN tblICCommodity C ON C.intCommodityId = SL.intCommodityId
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = SL.intLocationId
	INNER JOIN tblRKFuturesMonth FMo ON FMo.intFutureMonthId = SL.intFutureMonthId
	CROSS APPLY (
		SELECT TOP 1 strTrader,dtmLastTradingDate,strStatus,dtmFilledDate
		FROM tblRKFutOptTransactionHistory
		WHERE intFutOptTransactionId = SL.intFutOptTransactionId
		ORDER BY intFutOptTransactionHistoryId DESC
	
	) H
	WHERE dtmCreatedDate between @dtmFromDate and @dtmToDate
	AND SL.intCommodityId = @intCommodityId
	AND isnull(ysnPreCrush,0) = 1
	AND strInstrumentType = 'Futures'
	AND strAction not in ( 'Match Derivatives','Delete Match Derivatives.')


	IF (ISNULL(@intDPRReconHeaderId,0) = 0)
	BEGIN

		INSERT INTO tblRKDPRReconHeader(
			dtmFromDate, 
			dtmToDate, 
			intCommodityId , 
			intUserId
		)
		VALUES(
			@dtmFromDate,
			@dtmToDate,
			@intCommodityId,
			@intUserId
		)

		SET @intDPRReconHeaderId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		DELETE FROM tblRKDPRReconContracts WHERE intDPRReconHeaderId = @intDPRReconHeaderId
		DELETE FROM tblRKDPRReconDerivatives WHERE intDPRReconHeaderId = @intDPRReconHeaderId

		UPDATE tblRKDPRReconHeader SET
			dtmFromDate = @dtmFromDate
			,dtmToDate = @dtmToDate
			,intCommodityId = @intCommodityId
		WHERE intDPRReconHeaderId = @intDPRReconHeaderId
		
	END



	INSERT INTO tblRKDPRReconContracts(
		intDPRReconHeaderId
		,intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName
		,strAction
		,strPricingType 
		,strTicketNumber 
		,strLoadNumber 
		,dblLoadQty
		,dblReceivedQty 
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus
	)
	SELECT
		@intDPRReconHeaderId
		,intSort
		,strLocationName
		,strName
		,strCommodityCode
		,strContractType 
		,strContractStatus
		,strContractNumber
		,intContractSeq
		,strItemNo
		,dtmCreatedDate
		,dtmTransactionDate
		,dblQty
		,strUnitMeasure
		,strUserName
		,strBucketName
		,strAction
		,strPricingType 
		,strTicketNumber 
		,strLoadNumber 
		,dblLoadQty
		,dblReceivedQty 
		,dblCash
		,intContractHeaderId
		,intTicketId
		,intLoadId
		,strDistribution
		,strStorageSchedule 
		,strSettlementTicket 
		,strStatus
	FROM @tblRKDPRReconContracts
	
	
	INSERT INTO tblRKDPRReconDerivatives(
		intDPRReconHeaderId
		,intSort 
		,strTransactionNumber
		,strInstrumentType
		,strFutMarketName
		,strCurrency
		,strCommodityCode
		,strLocationName
		,strBroker
		,strBrokerTradeNo
		,strBrokerAccount
		,strTrader
		,dblOrigNoOfLots
		,dblOrigQty
		,strBuySell
		,strFutureMonth
		,strAction
		,dblPrice
		,dtmLastTradingDate
		,strStatus
		,dtmFilledDate
		,strNotes
		,dtmCreatedDate
		,dtmTransactionDate
		,strBucketName 
		,intFutOptTransactionHeaderId
	)
	SELECT 
		@intDPRReconHeaderId
		,intSort 
		,strTransactionNumber
		,strInstrumentType
		,strFutMarketName
		,strCurrency
		,strCommodityCode
		,strLocationName
		,strBroker
		,strBrokerTradeNo
		,strBrokerAccount
		,strTrader
		,dblOrigNoOfLots
		,dblOrigQty
		,strBuySell
		,strFutureMonth
		,strAction
		,dblPrice
		,dtmLastTradingDate
		,strStatus
		,dtmFilledDate
		,strNotes
		,dtmCreatedDate
		,dtmTransactionDate
		,strBucketName 
		,intFutOptTransactionHeaderId
	FROM @tblRKDPRReconDerivatives

	
	select * from tblRKDPRReconHeader where intDPRReconHeaderId = @intDPRReconHeaderId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH