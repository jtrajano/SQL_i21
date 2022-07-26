CREATE PROCEDURE [dbo].[uspRKGenerateDPRRecon]
	@intDPRReconHeaderId INT = NULL
	, @dtmFromDate  DATETIME 
	, @dtmToDate DATETIME 
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
	SET @dtmFromDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), @dtmFromDate)
	SET @dtmToDate = DATEADD(hh, DATEDIFF(hh, GETDATE(), GETUTCDATE()), @dtmToDate)

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
		[intLoadId] INT NULL
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
		[strBrokerTradeNo] NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
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
		intSort = 4
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
	AND strAction = 'Created Price'
	AND CBL.intContractTypeId = 1 --Purchase
	AND CBL.intPricingTypeId = 1

	--Deletion of price Fixation not yet catered
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
	AND strAction IN('Updated Contract','Re-opened Sequence')
	AND CBL.intContractTypeId = 1 --Purchase

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
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblVariance  = ABS(SL.dblOrigQty) - ABS(CH.dblQuantityPerLoad)
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+/- Purchase Load Variance'
		,strAction
		,strPricingType = NULL
		,T.strTicketNumber
		,T.strLoadNumber
		,dblLoadQty = CH.dblQuantityPerLoad
		,dblReceivedQty  = SL.dblOrigQty
		,dblCash = NULL
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = T.intLoadId
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
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate 
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
	AND SL.strAction = 'Shipment on Spot Priced'

	UNION ALL

	SELECT
		intSort = 14
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
	AND strAction = 'Created Price'
	AND CBL.intContractTypeId = 2 --Sales
	AND CBL.intPricingTypeId = 1

	--Deletion of price Fixation not yet catered
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
	AND strAction IN('Updated Contract','Re-opened Sequence')
	AND CBL.intContractTypeId = 2 --Sales

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
		,SL.dtmCreatedDate
		,SL.dtmTransactionDate
		,dblVariance  = ABS(SL.dblOrigQty) - ABS(CH.dblQuantityPerLoad)
		,UM.strUnitMeasure
		,EC.strUserName
		,strBucketName = '+/- Sales Load Variance'
		,strAction
		,strPricingType = NULL
		,T.strTicketNumber
		,T.strLoadNumber
		,dblLoadQty = CH.dblQuantityPerLoad
		,dblReceivedQty  = SL.dblOrigQty
		,dblCash = NULL
		,CH.intContractHeaderId
		,intTicketId = T.intTicketId
		,intLoadId = T.intLoadId
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
	WHERE dtmCreatedDate BETWEEN @dtmFromDate AND @dtmToDate 
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