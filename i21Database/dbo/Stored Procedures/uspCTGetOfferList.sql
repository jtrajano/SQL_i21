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
			@intCent				INT = 1
	
	DECLARE @AllocatedContracts AS TABLE ( intContractHeaderId INT NOT NULL, strContractNumber  NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL);
	DECLARE @UnAllocatedContracts AS TABLE ( intContractHeaderId INT NOT NULL, strContractNumber  NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL);

	--SHOW ALL ALLOCATED
	IF @YsnyAllocated = 1
	BEGIN 
		INSERT INTO @AllocatedContracts (intContractHeaderId,strContractNumber)
		SELECT DISTINCT B.intContractHeaderId,B.strContractNumber FROM vyuLGAllocationStatus A
		INNER JOIN tblCTContractHeader B ON A.strPurchaseContractNumber = B.strContractNumber
		WHERE strAllocationStatus IN( 'Unallocated','Reserved', 'Partially Allocated','Allocated');
	END
	ELSE
	BEGIN 
		INSERT INTO @AllocatedContracts (intContractHeaderId,strContractNumber)
		SELECT DISTINCT B.intContractHeaderId,B.strContractNumber FROM vyuLGAllocationStatus A
		INNER JOIN tblCTContractHeader B ON A.strPurchaseContractNumber = B.strContractNumber
		WHERE strAllocationStatus IN( 'Unallocated','Reserved', 'Partially Allocated');
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
	)

	
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
		  ,strHedgeMonth =''
		  ,FMO.strFutureMonth
		  ,dblBasis =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
					   * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  (CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice  END)
							* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		  ,dblLastSettlementPrice =  dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) 
									 * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
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
		,dblBasisDiff = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(@IntUnitMeasureId,CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 					    				
						* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		,dblFreightOffer = 0.00
		,dblCIFInStore =  0.00
		,dblCUMStorage = 0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = 0.00
		,ysnPostedIR = 0
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 1
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
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
	LEFT JOIN tblLGPickLotDetail		PLD  WITH (NOLOCK)ON PLD.intAllocationDetailId = AH.intAllocationHeaderId
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

	UNION ALL
	--VIEW FOR ALLOCATION ROWS ('Allocated', 'Partially Allocated','Unallocated', 'Reserved')
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
		  ,strCategory = (CASE WHEN LGAS.strAllocationStatus = 'Reserved' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Unallocated' THEN 'Purchased' 
							   WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Allocated' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Allocated' AND LGD.intLoadId IS NULL THEN 'Sold' 
						 ELSE '' END)
		  ,strStatus =  (CASE  WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Unsold%' THEN  'Unsold' 							   
							   --WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN  'Inventory'		
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
						 ELSE LGAS.strAllocationStatus  END)
		  ,strShipmentStatus = ''
		  ,strReferencePrimary = CASE 
									WHEN LGAS.strAllocationStatus = 'Reserved' AND LGAS.strAllocationNumber IS NULL THEN 'R-'+CH.strContractNumber 
									ELSE ISNULL(ISNULL(LGAS.strAllocationNumber,AH.strAllocationNumber),'A- '+ CH.strContractNumber) + ' '+ CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
								END
		  ,strReference = CASE WHEN LGAS.strAllocationStatus = 'Reserved' AND LGAS.strAllocationNumber IS NULL THEN NULL
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
		  ,dblBasis =  dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
					   * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  (CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice  END )
							* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		  ,strHedgeMonth= ''
		  ,dblLastSettlementPrice =  dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())	/ (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
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
		,dblBasisDiff = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
						* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		,dblFreightOffer = 0.00 
		,dblCIFInStore =  0.00
		,dblCUMStorage = 0.00
		,dblCUMFinancing = 0.00
		,dblSwitchCost = 0.00
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 2
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
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
	--LEFT JOIN tblICCommodityProductLine IPL  WITH (NOLOCK) ON IPL.intCommodityProductLineId = CTD.intItemId
	LEFT JOIN tblCTContractQuality		CQ	 WITH (NOLOCK) ON CQ.intItemId = CTD.intItemId
	LEFT JOIN tblICItem					CQI  WITH (NOLOCK) ON CQI.intItemId = CQ.intItemId
	LEFT JOIN tblCTCropYear				CY   WITH (NOLOCK) ON CY.intCropYearId = CH.intCropYearId
	LEFT JOIN tblSMFreightTerms			FT   WITH (NOLOCK) ON FT.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId)
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblLGLoadStorageCost		LSC  WITH (NOLOCK) ON LSC.intLoadId = LGL.intLoadId
	--LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON LGL.intLoadId = LGD.intLoadId
	LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceipt		IR   WITH (NOLOCK) ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
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
	LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
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
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END

	UNION ALL
	--VIEW FOR CT/LS/IR/SI 
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
		  ,strCategory = (CASE WHEN LGAS.strAllocationStatus = 'Unallocated' THEN 'Purchased' 
							   WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Allocated' AND LGD.intLoadId IS NULL THEN 'Sold' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN 'On Order' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Shipping%' THEN 'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Transit%' THEN  'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Scheduled%' THEN  'In Transit' 
						 ELSE '' END)
						 
		  ,strStatus =  (CASE 		
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND ISNULL(LGS.strShipmentType,'Shipment') = 'Shipment' THEN 'Shipment'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipment' THEN 'Shipped' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Shipping Instructions Created' THEN 'Shipping Instruction'
						 ELSE LGAS.strAllocationStatus  END)
		  ,strShipmentStatus = ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') 
		  ,strReferencePrimary = CASE WHEN IRI.intLoadShipmentId <> 0 THEN IR.strReceiptNumber 
							   WHEN LGL.intLoadId <> 0 THEN LGL.strLoadNumber
						  ELSE CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX))  END
		  ,strReference = --ALWAYS GET THE LAST LATEST TRANSACTION CT> SI > LS > IR
						  CASE WHEN IRI.intLoadShipmentId <> 0 THEN IR.strReceiptNumber 
							   WHEN LGL.intLoadId <> 0 THEN LGL.strLoadNumber
						  ELSE '' END
		  ,dblQuantity = CASE WHEN IR.ysnPosted = 1 THEN TQ.dblTotalQty ELSE ( --UNSOLD QTY 
						 CASE WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  LGAS.dblAllocatedQuantity --ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN TQ.dblTotalQty	--SHIPPED LS QTY
							  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN TQ.dblTotalQty --IN STORE IR QTY
						 ELSE CTD.dblQuantity - ISNULL(CTD.dblScheduleQty,0) END ) --OPEN CT QTY  
						 END
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =   dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00))  
						* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice = (CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
						  * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							
		  ,strHedgeMonth = HM.strFutureMonth
		  ,dblLastSettlementPrice =  dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							
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
		,dblBasisDiff = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
						* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							 
		,dblFreightOffer = CASE WHEN  dbo.[fnCTGetFreightRateMatrixFromCommodity](LGL.strOriginPort,LGL.strDestinationPort,CH.intCommodityId ) > 0 THEN dbo.[fnCTGetFreightRateMatrixFromCommodity](LGL.strOriginPort,LGL.strDestinationPort,CH.intCommodityId )
							ELSE dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblAmount ELSE 0.00 END,0.00)) END  --FreightCost of LS cost Tab
							* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)												
		,dblCIFInStore = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),  ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount))  --CIF Item setup in Company Config CIF Charge from IR
						 * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							
		,dblCUMStorage = ISNULL(ISC.dblStorageCharge,0.00) --FOR CLARIFICATION TO IR IC-10764
		,dblCUMFinancing = dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId),   ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0)) --IR Line value * (Current date - Payment Date) * Interest rate
							* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							
		,dblSwitchCost = 0.00--For Future Column N/A
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId  = 3
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
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
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
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
	OUTER APPLY (
		SELECT SUM(dblAmount) AS dblAmount FROM tblICInventoryReceiptCharge IRC
		WHERE  IRC.intLoadShipmentId = LGL.intLoadId
	) IRC
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	AND LGAS.strAllocationStatus IN ('Allocated', 'Partially Allocated', 'Unallocated')
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	
	UNION ALL
	--VIEW FOR CONTRACT
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
		  ,strCategory = (CASE WHEN LGAS.strAllocationStatus = 'Unallocated' THEN 'Purchased' 
							   WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN 'Sold' 
							   WHEN LGAS.strAllocationStatus = 'Allocated' AND LGD.intLoadId IS NULL THEN 'Sold' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open'  THEN 'On Order' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Shipping%' THEN 'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Transit%' THEN  'In Transit' 
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Scheduled%' THEN  'In Transit' 
							    WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Received%' THEN  'Sold' 
						 ELSE 'Purchased' END)
		  ,strStatus =  (CASE 		
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND ISNULL(LGS.strShipmentType,'Shipment') = 'Shipment' THEN 'Shipment'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Scheduled' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction'
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipment' THEN 'Shipped' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Inbound Transit' AND LGS.strShipmentType = 'Shipping Instructions' THEN 'Shipping Instruction' 
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') =  'Shipping Instructions Created' THEN 'Shipping Instruction'
						 ELSE LGAS.strAllocationStatus  END)
		  ,strShipmentStatus = ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') 
		  ,strReferencePrimary = CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,strReference = CH.strContractNumber 
		  ,dblQuantity = CTD.dblQuantity
		  ,strPacking = UM.strUnitMeasure
		  ,dblOfferCost = CTD.dblCashPrice			
		  ,PT.strPricingType
		  ,FMO.strFutureMonth
		  ,dblBasis =   dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
						* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())
		  ,strPricingStatus = VPC.strStatus
		  ,dblCashPrice =  (CASE WHEN VPC.strStatus = 'Fully Price' THEN CTD.dblCashPrice
							   WHEN VPC.strStatus = 'Unprice' 	THEN dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   WHEN VPC.strStatus = 'Partially Price' THEN VPC.dblFinalPrice + dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE()) + CTD.dblBasis
							   ELSE CTD.dblCashPrice END )
							* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())
		  ,strHedgeMonth = HM.strFutureMonth
		  ,dblLastSettlementPrice =  dbo.fnRKGetLatestClosingPrice(CTD.intFutureMarketId,CTD.intFutureMonthId,GETDATE())
									* dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate()) / (CASE WHEN @ysnSubCurrency = 1 THEN @intCent ELSE 1 END)							
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
		,dblBasisDiff =   dbo.fnCTConvertQtyToTargetCommodityUOM( CH.intCommodityId,CTD.intUnitMeasureId,ISNULL(NULLIF(@IntUnitMeasureId,0),CTD.intUnitMeasureId), ISNULL(CTD.dblBasis,0.00)) 
						  * dbo.fnCMGetForexRateFromCurrency(CTD.intCurrencyId,@IntCurrencyId,CTD.intRateTypeId,getdate())
		,dblFreightOffer = 0.00--ISNULL(CASE WHEN LGL.intLoadId <> 0 THEN LGC.dblAmount ELSE 0.00 END,0.00) --FreightCost of LS cost Tab
		,dblCIFInStore = 0.00--ISNULL(CASE WHEN IRI.intInventoryReceiptId <> 0 THEN IRC.dblAmount ELSE 0.00 END,IRC.dblAmount) --CIF Item setup in Company Config CIF Charge from IR
		,dblCUMStorage = 0.00 --FOR CLARIFICATION TO IR IC-10764
		,dblCUMFinancing = 0.00--ISNULL(IR.dblGrandTotal * (DATEPART(DAY,GETDATE()) - DATEPART(DAY, IR.dtmReceiptDate)) *  CTD.dblInterestRate,0) --IR Line value * (Current date - Payment Date) * Interest rate
		,dblSwitchCost = 0.00--For Future Column N/A
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 4
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId 
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
	LEFT JOIN tblLGLoadDetail			LGD  WITH (NOLOCK) ON CTD.intContractDetailId = CASE WHEN IRI.intInventoryReceiptId <> 0 THEN NULL ELSE ISNULL(LGD.intPContractDetailId,LGD.intSContractDetailId) END
	LEFT JOIN tblLGLoad					LGL  WITH (NOLOCK) ON LGL.intContractDetailId = CTD.intContractDetailId
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
	LEFT JOIN vyuLGAllocationStatus     LGAS WITH (NOLOCK)ON LGAS.intContractDetailId  = CTD.intContractDetailId
	INNER JOIN @AllocatedContracts		AC	 ON AC.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblCTContractFutures		CF	 WITH (NOLOCK)ON  CF.intContractDetailId = CTD.intContractDetailId
	LEFT JOIN tblRKFuturesMonth			HM	 WITH (NOLOCK) ON HM.intFutureMonthId = CF.intHedgeFutureMonthId	
	OUTER APPLY(
		SELECT DISTINCT CASE WHEN IRI.intInventoryReceiptId <> 0 THEN SUM(dblOrderQty) ELSE SUM(LGL.dblQuantity) END dblTotalQty
		FROM tblLGLoadDetail LGL
		LEFT JOIN tblCTContractDetail CTD1  WITH (NOLOCK) ON LGL.intPContractDetailId = CTD1.intContractDetailId
		LEFT JOIN tblICInventoryReceiptItem IRI  WITH (NOLOCK) ON IRI.intLoadShipmentId = LGL.intLoadId
		WHERE CTD1.intContractDetailId = CTD.intContractDetailId
		GROUP BY intInventoryReceiptId,dblOrderQty,LGL.dblQuantity
	) TQ
	OUTER APPLY (
		SELECT SUM(dblAmount) AS dblAmount FROM tblICInventoryReceiptCharge IRC
		WHERE  IRC.intLoadShipmentId = LGL.intLoadId
	) IRC
	WHERE
	CH.intContractTypeId = 1 --ALL PURCHASE CONTRACT ONLY
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END

	--VIEW FOR AVAILABLE BALANCE
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
		  ,strStatus =  (CASE  WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') LIKE '%Unsold%' THEN  'Unsold' 			
							   WHEN LGL.intLoadId <> 0 AND ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Open' THEN 'Open' 
							   WHEN LGAS.dblAllocatedQuantity = CTD.dblQuantity THEN 'Sold'
							   WHEN ISNULL(NULLIF(LD.strShipmentStatus, ''), 'Open') = 'Received' THEN 'Sold' 
						 ELSE 'Unsold'  END)
						
		  ,strShipmentStatus = LD.strShipmentStatus
		  ,strReferencePrimary ='Unsold- '+ CH.strContractNumber + CH.strContractNumber + CAST (CTD.intContractSeq AS VARCHAR(MAX)) 
		  ,strReference = NULL
		  ,dblQuantity = CASE WHEN LGAS.strAllocationStatus = 'Unallocated' THEN   CTD.dblQuantity --ALLOCATED QTY
							  WHEN IRI.intLoadShipmentId <> 0  OR IRI.intLoadShipmentId IS NOT NULL THEN CTD.dblQuantity -  TQ.dblTotalQty --IN STORE IR QTY
							  WHEN LGAS.strAllocationStatus = 'Allocated' THEN  LGAS.dblAllocatedQuantity - CTD.dblQuantity --ALLOCATED QTY
							  WHEN LGAS.strAllocationStatus = 'Partially Allocated' THEN  CTD.dblQuantity -  TQ.dblTotalQty-- PARTIALLY ALLOCATED QTY
							  WHEN LGL.intLoadId <> 0 AND IRI.intLoadShipmentId IS NULL THEN CTD.dblQuantity - TAQ.dblTotalAllocatedQuantity --SHIPPED LS QTY AND IR QTY
						 ELSE CTD.dblQuantity  END --OPEN CT QTY 
		,strPacking = UM.strUnitMeasure
		,dblOfferCost = NULL		
		,strPricingType = ''
		,strFutureMonth = ''
		,dblBasis =  NULL
		,strPricingStatus = ''
		,dblCashPrice = NULL
		,strHedgeMonth = ''
		,dblLastSettlementPrice = NULL
		,strSalesContract = SCTH.strContractNumber
		,strCustomer = ''
		,strOrigin = ''
		,strProductType = ''
		,strProductLine = ''
		,strCertificateName = ''
		,strQualityItem = CQI.strItemNo
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
		,dblCIFInStore	 = NULL
		,dblCUMStorage	 = NULL
		,dblCUMFinancing = NULL
		,dblSwitchCost	 = NULL
		,ysnPostedIR = IR.ysnPosted
		,intCompanyLocationId = CTD.intCompanyLocationId
		,intSortId = 5
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail		CTD  WITH (NOLOCK) ON CH.intContractHeaderId = CTD.intContractHeaderId
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
	OUTER APPLY tblCTCompanyPreference	CP  
	LEFT JOIN tblICItem					IFC  WITH (NOLOCK)ON IFC.intItemId = CP.intDefaultFreightItemId
	LEFT JOIN tblLGLoadCost				LGC  WITH (NOLOCK)ON LGC.intItemId =  CP.intDefaultFreightItemId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblLGLoadCost				LGCInStore  WITH (NOLOCK)ON LGCInStore.intItemId =  CP.intCIFInstoreId AND LGC.intLoadId = LGL.intLoadId
	LEFT JOIN tblICInventoryReceiptCharge IRC WITH (NOLOCK)ON IRC.intLoadShipmentId = LGL.intLoadId AND IRC.intLoadShipmentCostId = LGCInStore.intLoadCostId
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
	--AND CH.intPositionId = 1 --ALL SHIPMENT CONTRACT ONLY
	) a
	WHERE a.intCommodityId = CASE WHEN ISNULL(@IntCommodityId , 0) > 0	THEN @IntCommodityId ELSE a.intCommodityId	END
	AND a.strProductType = CASE WHEN @StrProductType = '' THEN a.strProductType ELSE @StrProductType END
	AND a.strOrigin = CASE WHEN @StrOrigin = '' THEN a.strOrigin ELSE @StrOrigin END
	AND a.intCompanyLocationId = CASE WHEN @intCompanyLocationId = '' THEN a.intCompanyLocationId ELSE @intCompanyLocationId END
	ORDER BY a.strContractSequence DESC ,a.intSortId
	END
	
END