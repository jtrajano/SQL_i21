CREATE PROCEDURE [dbo].[uspCTGetOfferList]
	@intContractTypeId INT = NULL
	, @intEntityId INT = NULL
	, @IntCommodityId INT = NULL
	, @dtmEndDate DATE = NULL
	, @intCompanyLocationId INT = NULL
	, @IntFutureMarketId INT = NULL
	, @IntFutureMonthId INT = NULL
	, @strPositionIncludes NVARCHAR(MAX) = NULL
	, @strCallingApp NVARCHAR(MAX) = NULL
	, @strPrintOption NVARCHAR(MAX) = NULL
	, @IntLocalTimeOffset int  = null	
	, @StrProductType NVARCHAR(MAX)  = null	
	, @StrOrigin NVARCHAR(MAX)  = null	
	, @YsnyAllocated BIT = 0
	, @IntUnitMeasureId INT = NULL
	, @IntCurrencyId INT = NULL
	, @YsnPartialAllocated BIT = 0

AS

BEGIN 

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@blbHeaderLogo			VARBINARY(MAX),
			@intContractDetailId	INT,
			@intShipmentKey			INT,
			@intReceiptKey			INT,
			@intPriceFixationKey	INT,
			@dblShipQtyToAllocate	NUMERIC(38,20),
			@dblAllocatedQty		NUMERIC(38,20),
			@dblPriceQtyToAllocate  NUMERIC(38,20),
			@strCompanyName			NVARCHAR(500),
			@intPricingDecimals		INT,
			@strAllocationStatus	NVARCHAR(MAX),
			@dblCurrencyRate		NUMERIC(38,20),
			@ysnSubCurrency			BIT = 0,
			@intCent				INT = 1,
			@fd						date = convert(date,'1900-01-01'),
			@td						date = getdate();

	declare @realized table (
		RowNum int null
		,strMonthOrder nvarchar(50) 
		,dblNetPL numeric(38,20) null
		,dblGrossPL numeric(38,20) null
		,intMatchFuturesPSHeaderId int null
		,intMatchFuturesPSDetailId int null
		,intFutOptTransactionId int null
		,intLFutOptTransactionId int null
		,intSFutOptTransactionId int null
		,dblMatchQty numeric(38,20) null
		,dtmLTransDate datetime null
		,dtmSTransDate datetime null
		,dblLPrice numeric(38,20) null
		,dblSPrice numeric(38,20) null
		,strLBrokerTradeNo nvarchar(50) 
		,strSBrokerTradeNo nvarchar(50) 
		,dblContractSize numeric(38,20) null
		,dblFutCommission numeric(38,20) null
		,strFutureMarket nvarchar(50) 
		,strFutureMonth nvarchar(50) 
		,intMatchNo int null
		,dtmMatchDate datetime null
		,strName nvarchar(50) 
		,strBrokerAccount nvarchar(50) 
		,strCommodityCode nvarchar(50) 
		,strLocationName nvarchar(50) 
		,intFutureMarketId int null
		,intCommodityId int null
		,ysnExpired bit null
		,intFutureMonthId int null
		,strLInternalTradeNo nvarchar(50) 
		,strSInternalTradeNo nvarchar(50) 
		,strLRollingMonth nvarchar(50) 
		,strSRollingMonth nvarchar(50) 
		,intLFutOptTransactionHeaderId int null
		,intSFutOptTransactionHeaderId int null
		,strBook nvarchar(50) 
		,strSubBook nvarchar(50) 
		,intSelectedInstrumentTypeId int null
	);

	insert into @realized
	exec uspRKRealizedPnL
		@dtmFromDate= @fd
		, @dtmToDate = @td
		, @intCommodityId = @IntCommodityId
		, @ysnExpired = 1
		, @intFutureMarketId = default
		, @intEntityId = default
		, @intBrokerageAccountId = default
		, @intFutureMonthId = default
		, @strBuySell = default
		, @intBookId = default
		, @intSubBookId = default
		, @intSelectedInstrumentTypeId = 1
	
	DECLARE @AllocatedContracts AS TABLE ( intContractHeaderId INT NOT NULL,intContractDetailId INT NULL, strContractNumber  NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL);
	--DECLARE @UnAllocatedContracts AS TABLE ( intContractHeaderId INT NOT NULL, strContractNumber  NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL);

	--SHOW ALL ALLOCATED
	IF @YsnyAllocated = 1
	BEGIN 
		INSERT INTO @AllocatedContracts (intContractHeaderId,strContractNumber)
		SELECT DISTINCT B.intContractHeaderId,B.strContractNumber FROM vyuLGAllocationStatus A
		INNER JOIN tblCTContractHeader B ON A.strPurchaseContractNumber = B.strContractNumber
		WHERE strAllocationStatus IN( 'Unallocated','Reserved', 'Partially Allocated','Allocated');
	END
	ELSE IF @YsnPartialAllocated = 1
	BEGIN 
		INSERT INTO @AllocatedContracts (intContractHeaderId,strContractNumber)
		SELECT DISTINCT B.intContractHeaderId,B.strContractNumber FROM vyuLGAllocationStatus A
		INNER JOIN tblCTContractHeader B ON A.strPurchaseContractNumber = B.strContractNumber
		WHERE strAllocationStatus IN( 'Partially Allocated', 'Reserved');
	END 
	ELSE
	BEGIN 
		INSERT INTO @AllocatedContracts (intContractHeaderId,strContractNumber)
		SELECT DISTINCT B.intContractHeaderId,B.strContractNumber FROM vyuLGAllocationStatus A
		INNER JOIN tblCTContractHeader B ON A.strPurchaseContractNumber = B.strContractNumber
		WHERE strAllocationStatus IN( 'Unallocated','Reserved', 'Partially Allocated');

		
		--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
		INSERT INTO @AllocatedContracts (intContractHeaderId,intContractDetailId, strContractNumber)
		SELECT intContractHeaderId 
			  , intContractDetailId
			  , strContractNumber
		FROM(
				SELECT DISTINCT
				CH.intContractHeaderId 
			  , CTD.intContractDetailId
			  , CH.strContractNumber
			  ,dblQuantity = CTD.dblQuantity - ISNULL(TAQ.dblTotalAllocatedQuantity,0) 
							/*CASE WHEN LGAS.strAllocationStatus = 'Unallocated' THEN CTD.dblQuantity --ALLOCATED QTY
								  WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  CTD.dblQuantity -  LGAS.dblAllocatedQuantity-- PARTIALLY ALLOCATED QTY
								  WHEN LGAS.strAllocationStatus = 'Allocated' THEN  LGAS.dblAllocatedQuantity - CTD.dblQuantity --ALLOCATED QTY
								  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN CTD.dblQuantity -  TQ.dblTotalQty --IN STORE IR QTY
								  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN CTD.dblQuantity - TAQ.dblTotalAllocatedQuantity --SHIPPED LS QTY AND IR QTY
							 ELSE CTD.dblQuantity  END*/ --OPEN CT QTY 
		FROM tblCTContractHeader CH
		INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
		LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
		LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
		OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
		OUTER APPLY tblCTCompanyPreference	CP  
		LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intContractDetailId = CTD.intContractDetailId
		OUTER APPLY(
			SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
			FROM tblLGLoadDetail LGL
			LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
			LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
			WHERE CTD1.intContractDetailId = CTD.intContractDetailId
			GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
		) TQ
		OUTER APPLY(
			SELECT SUM(dblAllocatedQuantity) + SUM(dblReservedQuantity) as dblTotalAllocatedQuantity 
			from vyuLGAllocationStatus 
			where strPurchaseContractNumber = CH.strContractNumber
		) TAQ
		WHERE
		CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
		) a WHERE dblQuantity < 1 OR dblQuantity = 0
	END

	

	--GET CURRENCY RATE
	SELECT @ysnSubCurrency = ysnSubCurrency, @intCent = intCent FROM tblSMCurrency where intCurrencyID = @IntCurrencyId and ysnSubCurrency = 1
	
	BEGIN
	with CTECert as
	(
		select
			cr.intContractDetailId
			,ce.strCertificationName
		from
			tblCTContractCertification cr
			left JOIN tblICCertification ce ON ce.intCertificationId = cr.intCertificationId
	),
	hedge as (
		select top 1 with ties
			s.intContractDetailId
			,fm.strFutureMonth
			,e.strName
			,a.strAccountNumber
		from
			tblRKAssignFuturesToContractSummary s
			join tblRKFutOptTransaction t on t.intFutOptTransactionId = s.intFutOptTransactionId
			left join tblRKBrokerageAccount a on a.intBrokerageAccountId = t.intBrokerageAccountId
			left join tblEMEntity e on e.intEntityId = t.intEntityId
			left join tblRKFuturesMonth fm on fm.intFutureMonthId = t.intFutureMonthId
		where
			s.ysnIsHedged = 1
		order by
			row_number() over (
				partition by s.intContractDetailId order by t.dtmCreateDateTime desc
			)
	), 
	realize as (
		select
			ftc.intContractDetailId
			,dblNetPL = sum(
				dbo.fnCTConvertQtyToTargetCommodityUOM( @IntCommodityId,fm.intUnitMeasureId,@IntUnitMeasureId,isnull(rp.dblNetPL,0.00))
				*
				dbo.fnCMGetForexRateFromCurrency(fm.intCurrencyId,@IntCurrencyId,1,getdate())
			)
		from
			tblRKFutOptTransaction ftc
			join @realized rp on rp.intFutOptTransactionId = ftc.intFutOptTransactionId
			join tblRKFutureMarket fm on fm.intFutureMarketId = rp.intFutureMarketId
		group by
			ftc.intContractDetailId
			,rp.dblContractSize
	),
	Allhedge as (
		select 
					s.intContractDetailId
					,fm.strFutureMonth
				from
					tblRKAssignFuturesToContractSummary s
					join tblRKFutOptTransaction t on t.intFutOptTransactionId = s.intFutOptTransactionId
					left join tblRKBrokerageAccount a on a.intBrokerageAccountId = t.intBrokerageAccountId
					left join tblEMEntity e on e.intEntityId = t.intEntityId
					left join tblRKFuturesMonth fm on fm.intFutureMonthId = t.intFutureMonthId
				where
					s.ysnIsHedged = 1
			)
	--SORTING LABELS
	--0 VIEW FOR STATIC CONTRACT 235
	--1 VIEW FOR PICK LOTS 439
	--2 VIEW FOR ALLOCATION ROWS  620
	--3 VIEW FOR RESERVE 826
	--4 VIEW FOR SECONDARY CONTRACT 1081
	--5 VIEW FOR SI PARTIAL LINE 1234
	--6 VIEW FOR LS PARTIAL LINE 1431
	--7 VIEW FOR IR PARTIAL 1706
	--8 VIEW FOR FULL CT/IR/LS/SI 1948
	--9 VIEW FOR AVAILABLE BALANCE LINE 2214

	--VIEW FOR STATIC CONTRACT  235
	SELECT 
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT DISTINCT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'Purchased'
		  ,strStatus =  CASE WHEN LGAS.strAllocationStatus = 'Reserved' THEN 'Partially Allocated' ELSE LGAS.strAllocationStatus END 
		  ,strShipmentStatus = ''
		  ,strReferencePrimary = 'Primary '+CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,strReference = CH.strContractNumber
		  ,dblQuantity = CTD.dblQuantity
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END	
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END		
							)
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth =  (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE '' END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem = ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101) 
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LGL.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LGL.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff =  --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblRate ELSE 0.00 END,0.00))  --FreightCost of LS cost Tab
							 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) 
																			THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) 
																			ELSE CTD.intCurrencyId
																	  END,@IntCurrencyId,CTD.intRateTypeId,getdate())
		,dblFreightFRM = dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId )
		--dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,dbo.--[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId ))																												
		,dblCIFInStore = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,  ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount))  --CIF Item setup in Company Config CIF Charge from IR
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMStorage =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(ISC.dblStorageCharge,0.00)) 
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMFinancing = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,   ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0)) --IR Line value * (Current date - Payment Date) * Interest rate
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblSwitchCost = isnull(r.dblNetPL,0.00)--For Future Column N/A
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 0
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	--LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId AND LGL.ysnPosted = 1
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.strPurchaseContractNumber = CH.strContractNumber  AND LGAS.intContractDetailId = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblICStorageChargeDetail  ISC  WITH (NOLOCK) ON ISC.intTransactionDetailId = IRI.intInventoryReceiptItemId AND intTransactionTypeId = 4
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ
	OUTER APPLY ( 
		SELECT DISTINCT ISNULL(SUM(IRC2.dblAmount),SUM(LGCInStore.dblAmount)) AS dblAmount FROM tblICInventoryReceiptCharge IRC2
		LEFT JOIN tblLGLoadCost	LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId 
		WHERE (IR.intInventoryReceiptId = IRC2.intInventoryReceiptId)
	) IRC
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)

	UNION ALL
	--VIEW FOR PICK LOTS
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus 
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = NULL
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId 
	FROM
	(
	SELECT DISTINCT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,0 AS intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'Sold'
		  ,strStatus =  'Picked w/ Allocation'
		  ,strShipmentStatus = ''--ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') 
		  ,strReferencePrimary = PLD2.strAllocationDetailRefNo
		  ,strReference = PLH.strPickLotNumber
		  ,dblQuantity = -ISNULL(PLD2.dblPAllocatedQty,PLD.dblLotPickedQty)
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,strHedgeMonth =(
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,FMO.strFutureMonth
		  ,dblBasis =   --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
							 (CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice  END)
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
						 )
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,dblLastSettlementPrice =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
									 dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) 
									 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									 --Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
										   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
										   ELSE 100 END	
									 )
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem = CQI.strItemNo
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)
		,dtmEndDate  = CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)
		,dtmETAPOL = NULL
		,dtmETAPOD = NULL
		,strLoadingPort = NULL
		,strDestinationPort = NULL
		,dtmShippedDate = NULL 
		,dtmReceiptDate = NULL    
		,strStorageLocation = NULL 
		,dblBasisDiff =  --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = 0.00
		,dblFreightFRM  = 0.00
		,dblCIFInStore =  0.00
		,dblCUMStorage = 0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = 0
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 1
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intPContractDetailId,AD.intSContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.strPurchaseContractNumber = CH.strContractNumber  AND LGAS.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblLGPickLotDetail		PLD  WITH (NOLOCK)ON PLD.intAllocationDetailId = AD.intAllocationDetailId
	LEFT JOIN tblLGPickLotHeader		PLH  WITH (NOLOCK)ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
	LEFT JOIN vyuLGShipmentOpenAllocationDetails PLD2  WITH (NOLOCK)ON PLD2.intPContractDetailId = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	WHERE
	--CH.intPositionId = 1 --ALL SHIPMENT CONTRACT ONLY	
	CH.intContractTypeId = 1
	AND PLH.intPickLotHeaderId <> 0
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)

	UNION ALL
	--VIEW FOR ALLOCATION ROWS ('Allocated', 'Partially Allocated','Unallocated')
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus 
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = NULL
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT
		  CTD.intContractDetailId
		  ,CH.intCommodityId
		  ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'Sold'
		  ,strStatus =  LGAS.strAllocationStatus
		  ,strShipmentStatus = ''
		  ,strReferencePrimary = CASE 
									WHEN LGAS.strAllocationStatus = 'Reserved' AND LGAS.strAllocationNumber IS NULL THEN 'R-'+CH.strContractNumber 
									ELSE ISNULL(ISNULL(LGAS.strAllocationNumber,AH.strAllocationNumber),'A- '+ CH.strContractNumber) + ' '+ CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
								END
		 ,strReference = CASE WHEN LGAS.strAllocationStatus = 'Reserved' AND LGAS.strAllocationNumber IS NULL THEN 'RS-' + ' '+ CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
								ELSE ISNULL(ISNULL(LGAS.strAllocationNumber,AH.strAllocationNumber),NULL) END
		  ,dblQuantity = CASE WHEN LGAS.strAllocationStatus in ( 'Reserved') THEN  -LGAS.dblReservedQuantity
							  WHEN LGAS.strAllocationStatus in ( 'Unallocated') THEN  CTD.dblQuantity
							  WHEN LGAS.strAllocationStatus in ( 'Partially Allocated', 'Allocated') THEN  -LGAS.dblAllocatedQuantity --ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN LGD.dblQuantity 		--SHIPPED LS QTY
							  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN IRI.dblNet --IN STORE IR QTY
						 ELSE CTD.dblQuantity - ISNULL(CTD.dblScheduleQty,0) END
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = NULL		
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =   --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice  END )
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							  --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
							)
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth= (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem = CQI.strItemNo
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101)  
		,strLoadingPort = LGL.strOriginPort
		,strDestinationPort = LGL.strDestinationPort
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff = --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = 0.00 
		,dblFreightFRM  = 0.00
		,dblCIFInStore =  0.00
		,dblCUMStorage = 0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 2
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intPContractDetailId,AD.intSContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	--LEFT JOIN tblLGAllocationDetail		AHDR WITH (NOLOCK) ON AHDR.intPContractDetailId = LGR.intContractDetailId
	--LEFT JOIN tblLGAllocationHeader		AHR WITH (NOLOCK) ON AHR.intAllocationHeaderId = AHDR.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId)
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.strPurchaseContractNumber = CH.strContractNumber  AND LGAS.intContractDetailId = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	OUTER APPLY(
		SELECT SUM(CTD2.dblQuantity) dblTotalQty
		FROM tblCTContractDetail CTD2
		WHERE CTD2.intContractHeaderId = CTD.intContractHeaderId
		GROUP BY dblQuantity
	) CTQ
	WHERE	
	CH.intContractTypeId = 1
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated','Unallocated', 'Reserved') 
	AND LGAS.dblAllocatedQuantity <> 0 
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)
	
	UNION ALL
	
	--VIEW FOR RESERVE 906
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus 
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = NULL
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT
		  CTD.intContractDetailId
		  ,CH.intCommodityId
		  ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'Sold'
		  ,strStatus =  LGAS.strAllocationStatus
		  ,strShipmentStatus = ''
		  ,strReferencePrimary = CASE 
									WHEN LGAS.strAllocationStatus = 'Reserved' AND LGAS.strAllocationNumber IS NULL THEN 'R-'+CH.strContractNumber 									
								END
		  ,strReference = ''
		  ,dblQuantity = -LGAS.dblReservedQuantity
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = NULL		
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =   --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice  END )
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							  --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
							)
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth= (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem = CQI.strItemNo
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101)  
		,strLoadingPort = LGL.strOriginPort
		,strDestinationPort = LGL.strDestinationPort
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff = --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = 0.00 
		,dblFreightFRM = 0.00
		,dblCIFInStore =  0.00
		,dblCUMStorage = 0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 3
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON AD.intPContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	--LEFT JOIN tblLGAllocationDetail		AHDR WITH (NOLOCK) ON AHDR.intPContractDetailId = LGR.intContractDetailId
	--LEFT JOIN tblLGAllocationHeader		AHR WITH (NOLOCK) ON AHR.intAllocationHeaderId = AHDR.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = LGD.intPContractDetailId
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
	--LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	--LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.strPurchaseContractNumber = CH.strContractNumber  AND LGAS.intContractDetailId = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	WHERE	
	CH.intContractTypeId = 1
	AND LGAS.strAllocationStatus IN ('Reserved') 
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)
	
	UNION ALL
	--VIEW FOR SECONDARY CONTRACT 1081
	SELECT 
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = NULL
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT DISTINCT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory =  'On Order'
		  ,strStatus =  'Open' 
		  ,strShipmentStatus = 'Open'
		  ,strReferencePrimary = 'Secondary '+CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,strReference = CH.strContractNumber
		  ,dblQuantity = CASE WHEN (LSI.strLoadNumber IS NOT NULL OR LGL.strLoadNumber IS NOT NULL) THEN CTD.dblQuantity - ISNULL(TQL.dblTotalQty,TQS.dblTotalQty)  ELSE CTD.dblQuantity END
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
							)
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth = (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem = ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101) 
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LGL.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LGL.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff =  --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = 0.00--ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblAmount ELSE 0.00 END,0.00) --FreightCost of LS cost Tab
		,dblFreightFRM = 0.00
		,dblCIFInStore = 0.00--ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount) --CIF Item setup in Company Config CIF Charge from IR
		,dblCUMStorage = 0.00 --FOR CLARIFICATION TO IR IC-10764
		,dblCUMFinancing = 0.00--ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0) --IR Line value * (Current date - Payment Date) * Interest rate
		,dblSwitchCost = isnull(r.dblNetPL,0.00)--For Future Column N/A
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 4
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = LGD.intPContractDetailId--CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblLGLoadDetail			LSID WITH (NOLOCK) ON CTD.intContractDetailId =  LSID.intPContractDetailId
	LEFT JOIN tblLGLoad					LSI  WITH (NOLOCK) ON LSI.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intContractDetailId  = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGD.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGD 
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGD.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		LEFT JOIN tblLGLoad LGL ON LGL.intLoadId = LGD.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND LGL.intShipmentType = 1
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQL
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGD.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGD 
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGD.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		LEFT JOIN tblLGLoad LGL ON LGL.intLoadId = LGD.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND LGL.intShipmentType = 2
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQS
	OUTER APPLY (
		SELECT SUM(dblAmount) AS dblAmount FROM tblICInventoryReceiptCharge IRC
		WHERE  IRC.intLoadShipmentId = LGL.intLoadId
	) IRC
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY	
	AND 1 = (CASE WHEN  (CTD.dblQuantity - ISNULL(TQL.dblTotalQty,TQS.dblTotalQty) = 0) THEN 0
				  WHEN  (IR.intInventoryReceiptId IS NULL AND  CTD.dblQuantity = ISNULL(TQL.dblTotalQty,TQS.dblTotalQty)) THEN 1  
				  WHEN  (IR.intInventoryReceiptId <> 0 AND  CTD.dblQuantity - ISNULL(TQL.dblTotalQty,TQS.dblTotalQty) > 0) THEN 1
				  WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' AND CTD.intContractStatusId != 5 THEN 1
			 ELSE 0 END
			)
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)
	UNION ALL

	--VIEW FOR SI PARTIAL 1234
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT DISTINCT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LSI.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'In Transit'
		  ,strStatus =  (CASE  WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 							  
							   WHEN LSI.strLoadNumber LIKE '%SI%' AND LGS.strShipmentType = 'Shipment' 				 THEN 'Shipping Instruction'
							   WHEN LSI.strLoadNumber LIKE '%LS%'  THEN 'Shipped'
							   WHEN LSI.strLoadNumber LIKE '%Load%'  THEN 'Shipped'
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction'
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipment' THEN 'Shipped' 
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Shipping Instruction Created' THEN 'Shipping Instruction'
						 ELSE 'Open'  END)
		  ,strShipmentStatus = ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open')
		  ,strReferencePrimary = 'Partial ' + CASE 
							   WHEN LSI.intLoadId <> 0 THEN LSI.strLoadNumber  +' '+ CAST (CTD.intContractSeq AS VARCHAR(MAX)) + ' ' + CAST (LSID.dblQuantity AS VARCHAR(MAX)) 
						  ELSE CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX))  END
		  ,strReference = LSI.strLoadNumber
		  ,dblQuantity = LSID.dblQuantity
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       --WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 2 END	
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
						  * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						  --Check if need to consider the sub currency
						  / CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END	
						  )
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth = (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
										   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
										   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem =  ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LSI.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LSI.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LSI.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LSI.dtmETAPOD, 101)  
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LSI.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LSI.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LSI.dtmBLDate, 101)   
		,dtmReceiptDate = NULL--CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff =   --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END	
		,dblFreightOffer = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblRate ELSE 0.00 END,0.00))  --FreightCost of LS cost Tab
							 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) 
																			THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) 
																			ELSE CTD.intCurrencyId
																	  END,@IntCurrencyId,CTD.intRateTypeId,getdate())
		,dblFreightFRM = dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId )
		--dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId ))
		,dblCIFInStore = 0.00 
		,dblCUMStorage =  0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR =NULL
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 5
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.ysnPosted = 1
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId AND LGL.ysnPosted = 1 AND LGL.intShipmentType  = 1
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON  LGL.intLoadId = LGD.intLoadId	
	LEFT JOIN tblLGLoad					LSI  WITH (NOLOCK) ON  LSI.intContractDetailId = CTD.intContractDetailId AND LSI.intShipmentType  = 2											 
	LEFT JOIN tblLGLoadDetail			LSID WITH (NOLOCK) ON LSI.intLoadId = LSID.intLoadId
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LSI.intLoadId
--	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LSID.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LSI.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LSI.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LSI.intLoadId
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intAllocationHeaderId = AD.intAllocationHeaderId OR ISNULL(LGAS.strPurchaseContractNumber,LGAS.strSalesContractNumber) = CH.strContractNumber  
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
--	LEFT JOIN tblICStorageChargeDetail  ISC  WITH (NOLOCK) ON ISC.intTransactionDetailId = IRI.intInventoryReceiptItemId AND intTransactionTypeId = 4
	/*OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ*/
	/*OUTER APPLY(
		SELECT DISTINCT SUM(IRI.dblOrderQty)  dblTotalQty
		FROM tblICInventoryReceiptItem IRI
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON IRI.intLineNo = CTD1.intContractDetailId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	) TQIR */
	--OUTER APPLY ( 
	--	SELECT DISTINCT ISNULL(SUM(IRC2.dblAmount),SUM(LGCInStore.dblAmount)) AS dblAmount FROM tblICInventoryReceiptCharge IRC2
	--	LEFT JOIN tblLGLoadCost	LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId 
	--	WHERE (IR.intInventoryReceiptId = IRC2.intInventoryReceiptId)
	--) IRC

	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated', 'Unallocated')
	AND LSID.dblQuantity < CTD.dblQuantity
	AND IR.intInventoryReceiptId IS NULL AND LGL.intLoadId IS NULL
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)

	UNION ALL

	--VIEW FOR LS PARTIAL 
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer	
		  ,dblFreightFRM 
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT DISTINCT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LSI.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'In Transit'
		  ,strStatus =  (CASE  WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 							  
							   WHEN LSI.strLoadNumber LIKE '%SI%' AND LGS.strShipmentType = 'Shipment' 				 THEN 'Shipping Instruction'
							   WHEN LSI.strLoadNumber LIKE '%LS%'  THEN 'Shipped'
							   WHEN LSI.strLoadNumber LIKE '%Load%'  THEN 'Shipped'
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction'
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipment' THEN 'Shipped' 
							   WHEN LSI.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Shipping Instruction Created' THEN 'Shipping Instruction'
						 ELSE 'Open'  END)
		  ,strShipmentStatus = ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open')
		  ,strReferencePrimary = 'Partial ' + CASE 
							   WHEN LSI.intLoadId <> 0 THEN LSI.strLoadNumber  +' '+ CAST (CTD.intContractSeq AS VARCHAR(MAX)) + ' ' + CAST (LSID.dblQuantity AS VARCHAR(MAX)) 
						  ELSE CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX))  END
		  ,strReference = LSI.strLoadNumber
		  ,dblQuantity = LSID.dblQuantity
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
						  * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						  --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
						  )
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth = (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem =  ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LSI.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LSI.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LSI.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LSI.dtmETAPOD, 101)  
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LSI.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LSI.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LSI.dtmBLDate, 101)   
		,dtmReceiptDate = NULL--CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								 
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff =  --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(CASE WHEN LGS.intLoadId <> 0 THEN LGC.dblRate ELSE 0.00 END,0.00))  --FreightCost of LS cost Tab
								   * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) 
																			THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) 
																			ELSE CTD.intCurrencyId 
																	   END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 	
		,dblFreightFRM = dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId )
		--dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId ))	
		,dblCIFInStore = 0.00 
		,dblCUMStorage =  0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR =NULL
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 6
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.ysnPosted = 1
	--INNER JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId AND LGL.ysnPosted = 1
	--INNER JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON  LGL.intLoadId = LGD.intLoadId	
	LEFT JOIN tblLGLoad					LSI  WITH (NOLOCK) ON  LSI.intContractDetailId = CTD.intContractDetailId AND LSI.intShipmentType  = 1 AND LSI.ysnPosted = 1										 
	LEFT JOIN tblLGLoadDetail			LSID WITH (NOLOCK) ON LSI.intLoadId = LSID.intLoadId
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LSI.intLoadId
--	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LSID.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LSI.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LSI.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LSI.intLoadId
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intAllocationHeaderId = AD.intAllocationHeaderId OR ISNULL(LGAS.strPurchaseContractNumber,LGAS.strSalesContractNumber) = CH.strContractNumber  
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
--	LEFT JOIN tblICStorageChargeDetail  ISC  WITH (NOLOCK) ON ISC.intTransactionDetailId = IRI.intInventoryReceiptItemId AND intTransactionTypeId = 4
	/*OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ*/
	/*OUTER APPLY(
		SELECT DISTINCT SUM(IRI.dblOrderQty)  dblTotalQty
		FROM tblICInventoryReceiptItem IRI
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON IRI.intLineNo = CTD1.intContractDetailId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	) TQIR */
	--OUTER APPLY ( 
	--	SELECT DISTINCT ISNULL(SUM(IRC2.dblAmount),SUM(LGCInStore.dblAmount)) AS dblAmount FROM tblICInventoryReceiptCharge IRC2
	--	LEFT JOIN tblLGLoadCost	LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId 
	--	WHERE (IR.intInventoryReceiptId = IRC2.intInventoryReceiptId)
	--) IRC

	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated', 'Unallocated')
	AND LSID.dblQuantity < CTD.dblQuantity
	AND IR.intInventoryReceiptId IS NULL
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)
	

	UNION ALL
	--VIEW FOR IR PARTIAL
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer
		  ,dblFreightFRM
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = 'Inventory'
		  ,strStatus =  (CASE  WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1								 THEN 'In Store'   
						 ELSE 'Open'  END)
		  ,strShipmentStatus = CASE WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1 THEN 'Spot' ELSE ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') END
		  ,strReferencePrimary = 'Partial ' +  IR.strReceiptNumber
		  ,strReference = IR.strReceiptNumber
		  ,dblQuantity = TQIR.dblTotalQty
						 /*CASE WHEN IR.ysnPosted = 1 THEN TQIR.dblTotalQty ELSE ( --UNSOLD QTY 
						 CASE WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  LGAS.dblAllocatedQuantity --ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN LGD.dblQuantity	--SHIPPED LS QTY
							  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN TQ.dblTotalQty --IN STORE IR QTY
						 ELSE CTD.dblQuantity - ISNULL(CTD.dblScheduleQty,0) END ) --OPEN CT QTY  
						 END*/
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END	
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
						  * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						  --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
						  )
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth = (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem =  ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101)  
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LGL.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LGL.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff = --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END	
		,dblFreightOffer = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblRate ELSE 0.00 END,0.00))  --FreightCost of LS cost Tab
							 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) 
																			THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) 
																			ELSE CTD.intCurrencyId
																	  END,@IntCurrencyId,CTD.intRateTypeId,getdate())
		,dblFreightFRM = dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId )
		--dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId ))	
		,dblCIFInStore = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,  ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount))  --CIF Item setup in Company Config CIF Charge from IR
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMStorage =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(ISC.dblStorageCharge,0.00)) 
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMFinancing = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,   ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0)) --IR Line value * (Current date - Payment Date) * Interest rate
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 7
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.ysnPosted = 1
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId AND LGL.ysnPosted = 1
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intAllocationHeaderId = AD.intAllocationHeaderId OR ISNULL(LGAS.strPurchaseContractNumber,LGAS.strSalesContractNumber) = CH.strContractNumber  
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
	LEFT JOIN tblICStorageChargeDetail  ISC  WITH (NOLOCK) ON ISC.intTransactionDetailId = IRI.intInventoryReceiptItemId AND intTransactionTypeId = 4
	/*OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ */
	OUTER APPLY(
		SELECT DISTINCT SUM(IRI.dblOrderQty)  dblTotalQty
		FROM tblICInventoryReceiptItem IRI
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON IRI.intLineNo = CTD1.intContractDetailId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	) TQIR 
	OUTER APPLY ( 
		SELECT DISTINCT ISNULL(SUM(IRC2.dblAmount),SUM(LGCInStore.dblAmount)) AS dblAmount FROM tblICInventoryReceiptCharge IRC2
		LEFT JOIN tblLGLoadCost	LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId 
		WHERE (IR.intInventoryReceiptId = IRC2.intInventoryReceiptId)
	) IRC
	/*OUTER APPLY(
		SELECT SUM(dblAllocatedQuantity) + SUM(dblReservedQuantity) as dblTotalAllocatedQuantity 
		from vyuLGAllocationStatus 
		where strPurchaseContractNumber = CH.strContractNumber
	) TAQ*/
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated', 'Unallocated')
	AND IR.ysnPosted = 1 
	AND IRI.dblOrderQty < CTD.dblQuantity
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)

	UNION ALL 

	--VIEW FOR FULL CT/IR/LS/SI
	SELECT DISTINCT
		   intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer
		  ,dblFreightFRM
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT
		 CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = CONVERT(VARCHAR(20),CH.dtmContractDate, 101) 
		  ,EY.strEntityName	
		  ,strCategory = (CASE /*WHEN LGAS.strAllocationStatus = 'Unallocated' THEN 'Purchased' 
							   WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Allocated' AND LGD.intLoadId IS NULL THEN 'Sold' */
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN 'On Order' 
							   WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1		   THEN 'Inventory'
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Shipping%' THEN 'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Transit%' THEN  'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Scheduled%' THEN  'In Transit' 
						 ELSE '' END)
		  ,strStatus =  (CASE  WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1								 THEN 'In Store'
							   WHEN LSI.strLoadNumber LIKE '%SI%' AND LGS.strShipmentType = 'Shipment' 				 THEN 'Shipping Instruction'
							   WHEN LSI.strLoadNumber LIKE '%LS%'  THEN 'Shipped'
							   WHEN LSI.strLoadNumber LIKE '%Load%'  THEN 'Shipped'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipment' THEN 'Shipped' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Shipping Instruction Created' THEN 'Shipping Instruction'
						 ELSE 'Open'  END)
		  ,strShipmentStatus = CASE WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1 THEN 'Spot' ELSE ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') END
		  ,strReferencePrimary = CASE WHEN  IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1 THEN IR.strReceiptNumber
							   WHEN IRI.intLoadShipmentId <> 0 THEN IR.strReceiptNumber 
							   WHEN LSI.intLoadId <> 0 THEN LSI.strLoadNumber
							   WHEN LGL.intLoadId <> 0 THEN LGL.strLoadNumber
						  ELSE CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX))  END
		  ,strReference = --ALWAYS GET THE LAST LATEST TRANSACTION CT> SI > LS > IR
						  CASE  WHEN IR.intInventoryReceiptId <> 0 AND IR.ysnPosted = 1 THEN IR.strReceiptNumber
							   WHEN IRI.intLoadShipmentId <> 0 AND IR.ysnPosted = 1 THEN IR.strReceiptNumber 
							   WHEN LSI.intLoadId <> 0 THEN LSI.strLoadNumber
							   WHEN LGL.intLoadId <> 0 THEN LGL.strLoadNumber
						  ELSE CH.strContractNumber END
		  ,dblQuantity = CASE WHEN IR.ysnPosted = 1 THEN TQIR.dblTotalQty ELSE ( --UNSOLD QTY 
						 CASE WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  LGAS.dblAllocatedQuantity --ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN LGD.dblQuantity	--SHIPPED LS QTY
							  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN TQ.dblTotalQty --IN STORE IR QTY
						 ELSE CTD.dblQuantity - ISNULL(CTD.dblScheduleQty,0) END ) --OPEN CT QTY  
						 END
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =    --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,
							(CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
						  * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						  --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
						  )
		  ,strCurrentHedge = h.strFutureMonth
		  ,strBroker = h.strName
		  ,strBrokerAccount = h.strAccountNumber
		  ,strHedgeMonth = (
						select DISTINCT
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strFutureMonth)) AS 'data()'
						FROM
							Allhedge 
						where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					) 
		  ,dblLastSettlementPrice = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId, 
									dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
									--Check if need to consider the sub currency
									/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
									)
		  ,strSalesContract = SCTH.strContractNumber
		  ,strCustomer = CASE WHEN SCD.intContractDetailId IS NOT NULL THEN SE.strName ELSE LGR.strComments END
		  ,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		  ,strProductType = IPT.strProductType
		  ,strProductLine = IPT.strProductLine
		  ,strCertificateName = (
						select
							STUFF(REPLACE((SELECT '#!' + LTRIM(RTRIM(strCertificationName)) AS 'data()'
						FROM
							CTECert where intContractDetailId = CTD.intContractDetailId
						FOR XML PATH('')),' #!',', '), 1, 2, '')
					)
		,strQualityItem =  ISNULL(CQI.strItemNo,ICI.strItemNo)
		,strCropYear = CY.strCropYear
		,strINCOTerm = FT.strFreightTerm
		,dtmStartDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmStartDate, 101)  ELSE CONVERT(VARCHAR(20),LGL.dtmStartDate, 101)  END
		,dtmEndDate  = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN  CONVERT(VARCHAR(20),CTD.dtmEndDate, 101)  ELSE CONVERT(VARCHAR(20), LGL.dtmEndDate, 101) END
		,dtmETAPOL = CONVERT(VARCHAR(20),LGL.dtmETAPOL, 101) 
		,dtmETAPOD = CONVERT(VARCHAR(20),LGL.dtmETAPOD, 101)  
		,strLoadingPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN LP.strCity ELSE LGL.strOriginPort END
		,strDestinationPort = CASE WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN DP.strCity ELSE LGL.strDestinationPort END
		,dtmShippedDate = CONVERT(VARCHAR(20),LGL.dtmBLDate, 101)   
		,dtmReceiptDate = CONVERT(VARCHAR(20),IR.dtmReceiptDate, 101)    
		,strStorageLocation = CASE WHEN  ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN CSL.strSubLocationName		
								   WHEN	 IRI.intLoadShipmentId <> 0 THEN IRSL.strSubLocationName
								   ELSE  CLSL.strSubLocationName END
		,dblBasisDiff =  --(OfferlistFilter UOM to Sequence UOM) Basis of the Sequence
						dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),(SELECT TOP 1 intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId = CTD.intBasisUOMId AND intItemId = CTD.intItemId),ISNULL(CTD.dblBasis,0.00))
						--Currency exchange rate of sequence currency  to filter currency 
						* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 					
						--Check if need to consider the sub currency
						/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
						       WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
							   ELSE 100 END
		,dblFreightOffer = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblRate ELSE 0.00 END,0.00))  --FreightCost of LS cost Tab
							 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) 
																			THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) 
																			ELSE CTD.intCurrencyId
																	  END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
		,dblFreightFRM = dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId )
		--dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,dbo.[fnCTGetFreightRateMatrixFromCommodity](CTD.intLoadingPortId,CTD.intDestinationPortId,CH.intCommodityId ))	
		,dblCIFInStore = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,  ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount))  --CIF Item setup in Company Config CIF Charge from IR
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMStorage =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId),CTD.intUnitMeasureId,ISNULL(ISC.dblStorageCharge,0.00)) 
						 * dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
						 --Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblCUMFinancing = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),CTD.intUnitMeasureId,   ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0)) --IR Line value * (Current date - Payment Date) * Interest rate
							* dbo.fnCMGetForexRateFromCurrency( CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 1 ) THEN (SELECT intMainCurrencyId FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId ) ELSE CTD.intCurrencyId END,@IntCurrencyId,CTD.intRateTypeId,getdate()) 
							--Check if need to consider the sub currency
							/ CASE WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  @IntCurrencyId and ysnSubCurrency = 1) THEN 1
								   WHEN EXISTS(SELECT 1 FROM tblSMCurrency where intCurrencyID =  CTD.intCurrencyId and ysnSubCurrency = 0) THEN 1
								   ELSE 100 END	
		,dblSwitchCost = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 8
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblSMCity					LP  WITH (NOLOCK) ON CTD.intLoadingPortId = LP.intCityId 
	LEFT JOIN tblSMCity					DP  WITH (NOLOCK) ON CTD.intDestinationPortId = DP.intCityId 
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblCTPricingType			PT   WITH (NOLOCK) ON PT.intPricingTypeId  = CTD.intPricingTypeId
	LEFT JOIN tblRKFutureMarket			FMA	 WITH (NOLOCK) ON FMA.intFutureMarketId	=CTD.intFutureMarketId		
	LEFT JOIN tblRKFuturesMonth			FMO	 WITH (NOLOCK) ON FMO.intFutureMonthId = CTD.intFutureMonthId	
	LEFT JOIN vyuCTSearchPriceContract	VPC  WITH (NOLOCK) ON VPC.intContractHeaderId =	CH.intContractHeaderId	
	LEFT JOIN tblLGAllocationDetail		AD	 WITH (NOLOCK) ON ISNULL(AD.intSContractDetailId,AD.intPContractDetailId) = CTD.intContractDetailId
	LEFT JOIN tblLGAllocationHeader		AH	 WITH (NOLOCK) ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
	LEFT JOIN tblCTContractDetail		SCTD WITH (NOLOCK) ON SCTD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCTH WITH (NOLOCK) ON SCTH.intContractHeaderId = SCTD.intContractHeaderId
	LEFT JOIN tblLGReservation			LGR  WITH (NOLOCK) ON LGR.intContractDetailId = CTD.intContractDetailId 
	LEFT JOIN tblCTContractDetail		SCD  WITH (NOLOCK) ON SCD.intContractDetailId = AD.intSContractDetailId
	LEFT JOIN tblCTContractHeader		SCH  WITH (NOLOCK) ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblEMEntity				SE   WITH (NOLOCK) ON SE.intEntityId = SCH.intEntityId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLineNo = CTD.intContractDetailId --IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.ysnPosted = 1
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId AND LGL.ysnPosted = 1
	LEFT JOIN tblLGLoadDetail			LSID WITH (NOLOCK) ON CTD.intContractDetailId =  LSID.intPContractDetailId
	LEFT JOIN tblLGLoad					LSI  WITH (NOLOCK) ON LSI.intContractDetailId = CTD.intContractDetailId AND ISNULL(LGL.ysnPosted,0) = 0
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblSMCompanyLocationSubLocation IRSL ON IRSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CSL  WITH (NOLOCK) ON CSL.intCompanyLocationSubLocationId = CTD.intSubLocationId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId
	--LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intAllocationHeaderId = AD.intAllocationHeaderId OR ISNULL(LGAS.strPurchaseContractNumber,LGAS.strSalesContractNumber) = CH.strContractNumber  
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
	LEFT JOIN tblICStorageChargeDetail  ISC  WITH (NOLOCK) ON ISC.intTransactionDetailId = IRI.intInventoryReceiptItemId AND intTransactionTypeId = 4
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ
	OUTER APPLY(
		SELECT DISTINCT SUM(IRI.dblOrderQty)  dblTotalQty
		FROM tblICInventoryReceiptItem IRI
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON IRI.intLineNo = CTD1.intContractDetailId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId AND IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	) TQIR
	OUTER APPLY ( 
		SELECT DISTINCT ISNULL(SUM(IRC2.dblAmount),SUM(LGCInStore.dblAmount)) AS dblAmount FROM tblICInventoryReceiptCharge IRC2
		LEFT JOIN tblLGLoadCost	LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId 
		WHERE (IR.intInventoryReceiptId = IRC2.intInventoryReceiptId)
	) IRC
	OUTER APPLY(
		SELECT SUM(dblAllocatedQuantity) + SUM(dblReservedQuantity) as dblTotalAllocatedQuantity 
		from vyuLGAllocationStatus 
		where strPurchaseContractNumber = CH.strContractNumber
	) TAQ
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated', 'Unallocated')
	AND LSID.dblQuantity = CTD.dblQuantity OR TQIR.dblTotalQty = CTD.dblQuantity
	--AND IR.ysnPosted = 1 
	--OR LGL.ysnPosted = 1
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	--If Available = 0 shouldn't come up in the initial load when Include Fully Allocated is checked
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN NOT EXISTS (SELECT 1 FROM @AllocatedContracts where intContractDetailId = a.intContractDetailId) THEN 1 ELSE 0 END ) END)

	--VIEW FOR AVAILABLE BALANCE LINE
	UNION ALL 
	SELECT DISTINCT
		    intContractDetailId
		  ,intCompanyLocationId
		  ,intCommodityId
		  ,intLoadId
	      ,strContractSequence
		  ,dtmContractDate
		  ,strEntityName	
		  ,strCategory  
		  ,strStatus 
		  ,strShipmentStatus 
		  ,strReferencePrimary
		  ,strReference
		  ,dblQuantity 
		  ,strPacking
		  ,dblOfferCost = dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost 
		  ,strPricingType
		  ,strFutureMonth
		  ,dblBasis	
		  ,strPricingStatus
		  ,dblCashPrice
		  ,strCurrentHedge
		  ,strBroker
		  ,strBrokerAccount
		  ,strHedgeMonth
		  ,dblLastSettlementPrice
		  ,strSalesContract
		  ,strCustomer
		  ,strOrigin
		  ,strProductType
		  ,strProductLine
		  ,strCertificateName
		  ,strQualityItem
		  ,strCropYear
		  ,strINCOTerm
		  ,dtmStartDate
		  ,dtmEndDate
		  ,dtmETAPOL
		  ,dtmETAPOD
		  ,strLoadingPort
		  ,strDestinationPort
		  ,dtmShippedDate
		  ,dtmReceiptDate
		  ,strStorageLocation 
		  ,dblBasisDiff     
		  ,dblFreightOffer
		  ,dblFreightFRM
		  ,dblCIFInStore 	
		  ,dblCUMStorage	
		  ,dblCUMFinancing 	
		  ,dblSwitchCost 	
		  ,dblTotalCost =   dblBasis + dblFreightOffer + dblCIFInStore + dblCUMStorage + dblCUMFinancing + dblSwitchCost
		  ,intSortId
	FROM(
	SELECT
		   CTD.intContractDetailId
		   ,CH.intCommodityId
		   ,LGL.intLoadId
	      ,strContractSequence = CH.strContractNumber + ' - ' + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,dtmContractDate = ''
		  ,EY.strEntityName	
		  ,strCategory = 'Available'
		  ,strStatus = 'Unsold' /*(CASE  WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Unsold%' THEN  'Unsold' 			
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN LGAS.dblAllocatedQuantity = CTD.dblQuantity THEN 'Sold'
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Received' THEN 'Sold' 
						 ELSE 'Unsold'  END)*/
						
		  ,strShipmentStatus = ''-- LD.strShipmentStatus
		  ,strReferencePrimary ='Unsold- '+ CH.strContractNumber + CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,strReference = NULL
		  ,dblQuantity = CTD.dblQuantity - ISNULL(TAQ.dblTotalAllocatedQuantity,0) /*CASE WHEN LGAS.strAllocationStatus = 'Unallocated' THEN   CTD.dblQuantity --ALLOCATED QTY
							  --WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN CTD.dblQuantity -  TQ.dblTotalQty --IN STORE IR QTY
							  WHEN LGAS.strAllocationStatus = 'Allocated' THEN  LGAS.dblAllocatedQuantity - CTD.dblQuantity --ALLOCATED QTY
							  WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  CTD.dblQuantity -  LGAS.dblAllocatedQuantity-- PARTIALLY ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN CTD.dblQuantity - TAQ.dblTotalAllocatedQuantity --SHIPPED LS QTY AND IR QTY
						 ELSE CTD.dblQuantity - TAQ.dblTotalAllocatedQuantity  END --OPEN CT QTY */
		,strPacking = UM.strUnitMeasure
		,dblOfferCost = NULL		
		,strPricingType = ''
		,strFutureMonth = ''
		,dblBasis =  NULL
		,strPricingStatus = ''
		,dblCashPrice = NULL
		,strCurrentHedge = ''
		,strBroker =''
		,strBrokerAccount = ''
		,strHedgeMonth = ''
		,dblLastSettlementPrice = NULL
		,strSalesContract = ''
		,strCustomer = ''
		,strOrigin =  dbo.[fnCTGetSeqDisplayField](CTD.intContractDetailId, 'Origin')
		,strProductType = IPT.strProductType
		,strProductLine = ''
		,strCertificateName = ''
		,strQualityItem = ''
		,strCropYear = ''
		,strINCOTerm = ''
		,dtmStartDate  = ''  
		,dtmEndDate  = ''
		,dtmETAPOL = ''
		,dtmETAPOD = ''  
		,strLoadingPort = ''
		,strDestinationPort = ''
		,dtmShippedDate = ''
		,dtmReceiptDate = ''  
		,strStorageLocation = ''
		,dblBasisDiff	 = NULL
		,dblFreightOffer = NULL
		,dblFreightFRM	 = NULL
		,dblCIFInStore	 = NULL
		,dblCUMStorage	 = NULL
		,dblCUMFinancing = NULL
		,dblSwitchCost	 = isnull(r.dblNetPL,0.00)
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 9
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
	left join hedge						h with (nolock)    on h.intContractDetailId = CTD.intContractDetailId
	left join realize					r with (nolock)    on r.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblICItemUOM				UOM  WITH (NOLOCK) ON UOM.intItemUOMId = CTD.intItemUOMId
	LEFT JOIN tblICUnitMeasure		    UM   WITH (NOLOCK) ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblICItem					ICI  WITH (NOLOCK) ON ICI.intItemId = CTD.intItemId
	LEFT JOIN vyuICGetCompactItem		IPT  WITH (NOLOCK) ON IPT.intItemId	= CTD.intItemId
	INNER JOIN vyuCTEntity				EY   WITH (NOLOCK) ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) AND ISNULL(EY.ysnDefaultLocation, 0) = 1
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId)
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblLGLoadDetailLot		LDL	 WITH (NOLOCK)ON LDL.intLoadDetailId = LGD.intLoadDetailId
	LEFT JOIN tblICLot					LOT	 WITH (NOLOCK)ON LOT.intLotId = LDL.intLotId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN vyuLGLoadViewSearch		LGS  WITH (NOLOCK)ON LGS.intLoadId = LGL.intLoadId
	OUTER APPLY dbo.fnCTGetShipmentStatus(CTD.intContractDetailId) LD
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intContractDetailId = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ
	OUTER APPLY(
		SELECT SUM(dblAllocatedQuantity) + SUM(dblReservedQuantity) as dblTotalAllocatedQuantity 
		from vyuLGAllocationStatus 
		where strPurchaseContractNumber = CH.strContractNumber
	) TAQ
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	AND 1 = (CASE WHEN @YsnyAllocated = 1 THEN 1 ELSE ( CASE WHEN dblQuantity > 1 THEN 1 ELSE 0 END ) END)
	ORDER BY a.strContractSequence DESC ,a.intSortId
	END
	
END