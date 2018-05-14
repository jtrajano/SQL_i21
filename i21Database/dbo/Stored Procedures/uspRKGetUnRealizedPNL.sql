CREATE PROCEDURE [dbo].[uspRKGetUnRealizedPNL]
	 @intFutureSettlementPriceId INT  = NULL
	,@intCurrencyUOMId			 INT  = NULL
	,@intCommodityId			 INT  = NULL
	,@intLocationId				 INT  = NULL
	,@intCompanyId				 INT  = 0
AS
BEGIN TRY
  
  DECLARE @ErrMsg NVARCHAR(MAX)
  DECLARE @dtmSettlemntPriceDate DATETIME
  /*
			intTransactionType
			1 - Contract
			2 - InTransit
			3 - Inventory

  */
  
	SELECT @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId

	  DECLARE @tblSettlementPrice TABLE 
	  (
	  	  intFutureMarketId			  INT
		 ,intFutureMonthId			  INT
	  	 ,dblSettlementPrice		  NUMERIC(24, 10)
	  )
	  
	  DECLARE @tblContractCost TABLE 
	  (
	  	 intContractDetailId	 INT
	  	,dblTotalCost		     NUMERIC(24, 10)
	  )

	 DECLARE @tblUnRealizedPNL AS TABLE 
	 (
		 intUnRealizedPNL                       INT IDENTITY(1,1)
		,strType								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intContractTypeId						INT
		,intContractHeaderId					INT
		,strContractType						NVARCHAR(100)
		,strContractNumber						NVARCHAR(100)
		,intContractBasisId						INT
		,intTransactionType					    INT
		,strTransaction							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strTransactionType						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intContractDetailId					INT
		,intCurrencyId							INT
		,intFutureMarketId						INT
		,strFutureMarket						NVARCHAR(100)
		,intFutureMarketUOMId					INT
		,intFutureMarketUnitMeasureId			INT
		,strFutureMarketUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intMarketCurrencyId					INT
		,intFutureMonthId						INT
		,strFutureMonth							NVARCHAR(100)
		,intItemId								INT
		,strBook								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strSubBook								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intCommodityId							INT
		,strCommodity							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmReceiptDate							DATETIME		
		,dtmContractDate						DATETIME
		,strContract							NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intContractSeq							INT
		,strEntityName							NVARCHAR(100)
		,strInternalCompany						NVARCHAR(20)
		,dblQuantity							NUMERIC(24, 10)
		,intQuantityUOMId						INT							---ItemUOM
		,intQuantityUnitMeasureId				INT							---UnitMeasure
		,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblWeight								NUMERIC(24, 10)
		,intWeightUOMId							INT							---ItemUOM
		,intWeightUnitMeasureId					INT							---UnitMeasure
		,strWeightUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblBasis								NUMERIC(24, 10)
		,intBasisUOMId							INT							---ItemUOM
		,intBasisUnitMeasureId					INT							---UnitMeasure
		,strBasisUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFutures								NUMERIC(24, 10)
		,dblCashPrice							NUMERIC(24, 10)
		,intPriceUOMId							INT							---ItemUOM
		,intPriceUnitMeasureId					INT							---UnitMeasure
		,strContractPriceUOM					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intOriginId							INT
		,strOrigin								NVARCHAR(100)
		,strItemDescription						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCropYear							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strProductionLine						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCertification						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strTerms								NVARCHAR(200) COLLATE Latin1_General_CI_AS	
		,strPosition							NVARCHAR(100)
		,dtmStartDate							DATETIME
		,dtmEndDate								DATETIME
		,strBLNumber							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmBLDate								DATETIME
		,strAllocationRefNo						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strAllocationStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPriceTerms							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblContractDifferential				NUMERIC(24, 10)
		,strContractDifferentialUOM				NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFuturesPrice						NUMERIC(24, 10)
		,strFuturesPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strFixationDetails						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFixedLots							NUMERIC(24, 10)
		,dblUnFixedLots							NUMERIC(24, 10)
		,dblContractInvoiceValue				NUMERIC(24, 10)
		,dblSecondaryCosts						NUMERIC(24, 10)
		,dblCOGSOrNetSaleValue					NUMERIC(24, 10)
		,dblInvoicePrice						NUMERIC(24, 10)
		,dblInvoicePaymentPrice					NUMERIC(24, 10)
		,strInvoicePriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblInvoiceValue						NUMERIC(24, 10)
		,strInvoiceCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblNetMarketValue						NUMERIC(24, 10)
		,dtmRealizedDate						DATETIME
		,dblRealizedQty							NUMERIC(24, 10)
		,dblProfitOrLossValue					NUMERIC(24, 10)
		,dblPAndLinMarketUOM					NUMERIC(24, 10)
		,dblPAndLChangeinMarketUOM				NUMERIC(24, 10)
		,strMarketCurrencyUOM					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strTrader								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strFixedBy								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strInvoiceStatus						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strWarehouse							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCPAddress							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCPCountry							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCPRefNo								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intContractStatusId					INT
		,intPricingTypeId						INT
		,strPricingType							NVARCHAR(100)
		,strPricingStatus						NVARCHAR(100)
		,dblMarketDifferential					NUMERIC(24, 10)
		,dblSettlementPrice						NUMERIC(24, 10)
		,strCompanyName							NVARCHAR(200) COLLATE Latin1_General_CI_AS
	) 

	INSERT INTO @tblUnRealizedPNL
	(
		 strType							
		,intContractTypeId					
		,intContractHeaderId				
		,strContractType					
		,strContractNumber					
		,intContractBasisId
		,intTransactionType
		,strTransaction					
		,strTransactionType					
		,intContractDetailId				
		,intCurrencyId
		,intFutureMarketId					
		,strFutureMarket					
		,intFutureMarketUOMId				
		,intFutureMarketUnitMeasureId		
		,strFutureMarketUOM					
		,intMarketCurrencyId
		,intFutureMonthId					
		,strFutureMonth						
		,intItemId							
		,strBook							
		,strSubBook
		,intCommodityId							
		,strCommodity						
		,dtmReceiptDate	
		,dtmContractDate					
		,strContract						
		,intContractSeq						
		,strEntityName						
		,strInternalCompany	
		,dblQuantity						
		,intQuantityUOMId					
		,intQuantityUnitMeasureId			
		,strQuantityUOM		
		,dblWeight							
		,intWeightUOMId						
		,intWeightUnitMeasureId				
		,strWeightUOM
		,dblBasis
		,intBasisUOMId			
		,intBasisUnitMeasureId	
		,strBasisUOM										
		,dblFutures							
		,dblCashPrice						
		,intPriceUOMId						
		,intPriceUnitMeasureId				
		,strContractPriceUOM
		,intOriginId						
		,strOrigin							
		,strItemDescription					
		,strCropYear						
		,strProductionLine					
		,strCertification					
		,strTerms							
		,strPosition						
		,dtmStartDate						
		,dtmEndDate							
		,strBLNumber						
		,dtmBLDate							
		,strAllocationRefNo					
		,strAllocationStatus				
		,strPriceTerms						
		,dblContractDifferential			
		,strContractDifferentialUOM			
		,dblFuturesPrice					
		,strFuturesPriceUOM					
		,strFixationDetails					
		,dblFixedLots						
		,dblUnFixedLots						
		,dblContractInvoiceValue			
		,dblSecondaryCosts					
		,dblCOGSOrNetSaleValue				
		,dblInvoicePrice					
		,dblInvoicePaymentPrice				
		,strInvoicePriceUOM					
		,dblInvoiceValue					
		,strInvoiceCurrency					
		,dblNetMarketValue					
		,dtmRealizedDate					
		,dblRealizedQty						
		,dblProfitOrLossValue				
		,dblPAndLinMarketUOM				
		,dblPAndLChangeinMarketUOM			
		,strMarketCurrencyUOM				
		,strTrader							
		,strFixedBy							
		,strInvoiceStatus					
		,strWarehouse						
		,strCPAddress						
		,strCPCountry						
		,strCPRefNo							
		,intContractStatusId				
		,intPricingTypeId					
		,strPricingType						
		,strPricingStatus
		,strCompanyName					
	)
		  ---Contract---
		 SELECT 
		 strType									= 'Unrealized'									
		,intContractTypeId							= CH.intContractTypeId
		,intContractHeaderId						= CH.intContractHeaderId
		,strContractType							= TP.strContractType
		,strContractNumber							= CH.strContractNumber
		,intContractBasisId							= CH.intContractBasisId
		,intTransactionType							= 1
		,strTransaction								= '1.Contract'
		,strTransactionType							= 'Contract('+CASE 
																	  WHEN CH.intContractTypeId=1 THEN 'P'
																	  WHEN CH.intContractTypeId=2 THEN 'S'
																  END
															 +')'
        ,intContractDetailId						= CD.intContractDetailId
		,intCurrencyId								= CD.intCurrencyId
		,intFutureMarketId							= CD.intFutureMarketId
		,strFutureMarket							= Market.strFutMarketName
		,intFutureMarketUOMId						= NULL
		,intFutureMarketUnitMeasureId				= Market.intUnitMeasureId
		,strFutureMarketUOM							= MarketUOM.strUnitMeasure
		,intMarketCurrencyId						= Market.intCurrencyId
		,intFutureMonthId							= FMonth.intFutureMonthId
		,strFutureMonth								= FMonth.strFutureMonth
		,intItemId									= CD.intItemId
		,strBook									= Book.strBook
		,strSubBook									= SubBook.strSubBook
		,intCommodityId								= Commodity.intCommodityId
		,strCommodity								= Commodity.strDescription
		,dtmReceiptDate								= NULL		
		,dtmContractDate							= CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
		,strContract								= CH.strContractNumber+ '-' + LTRIM(CD.intContractSeq)
		,intContractSeq								= CD.intContractSeq
		,strEntityName								= Entity.strEntityName
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)
		,intQuantityUOMId							= CD.intItemUOMId
		,intQuantityUnitMeasureId					= IUM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		,dblWeight									= CD.dblNetWeight
		,intWeightUOMId								= CD.intNetWeightUOMId
		,intWeightUnitMeasureId						= WUM.intUnitMeasureId
		,strWeightUOM								= WUM.strUnitMeasure
		,dblBasis									= CD.dblBasis
		,intBasisUOMId								= CD.intBasisUOMId
		,intBasisUnitMeasureId						= BASISUOM.intUnitMeasureId
		,strBasisUOM								= BUOM.strUnitMeasure
		,dblFutures									= CD.dblFutures
		,dblCashPrice								= CD.dblCashPrice
		,intPriceUOMId								= CD.intPriceItemUOMId
		,intPriceUnitMeasureId						= PriceUOM.intUnitMeasureId
		,strContractPriceUOM						= PUOM.strUnitMeasure
		,intOriginId								= Item.intOriginId
		,strOrigin									= ISNULL(RY.strCountry, OG.strCountry)
		,strItemDescription							= Item.strDescription
		,strCropYear								= CropYear.strCropYear
		,strProductionLine							= CPL.strDescription
		,strCertification							= NULL
		,strTerms									= ISNULL(CB.strContractBasis,'')+','+ISNULL(Term.strTerm,'')+','+ISNULL(WG.strWeightGradeDesc,'') 
		,strPosition								= PO.strPosition
		,dtmStartDate								= CD.dtmStartDate
		,dtmEndDate									= CD.dtmEndDate
		,strBLNumber								= NULL
		,dtmBLDate									= NULL
		,strAllocationRefNo							= AD.strAllocationDetailRefNo
		,strAllocationStatus						= CASE 
													  	WHEN ISNULL(AD.strAllocationDetailRefNo,'')  <> ''  THEN 'A'
													  	WHEN CH.intContractTypeId					 =   1	THEN 'L'
													  	WHEN CH.intContractTypeId					 =   2	THEN 'S'
													  END
		,strPriceTerms								= NULL
		,dblContractDifferential					= CD.dblBasis
		,strContractDifferentialUOM					= BCY.strCurrency+'/'+BUOM.strUnitMeasure
		,dblFuturesPrice							= CD.dblFutures
		,strFuturesPriceUOM							= MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
		,strFixationDetails							= NULL
		,dblFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL(PF.dblLotsFixed,0) ELSE 0 END
		,dblUnFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL((CD.[dblNoOfLots] -PF.dblLotsFixed),0) ELSE 0 END
		,dblContractInvoiceValue					= NULL
		,dblSecondaryCosts							= NULL
		,dblCOGSOrNetSaleValue						= NULL
		,dblInvoicePrice							= NULL
		,dblInvoicePaymentPrice						= NULL
		,strInvoicePriceUOM							= NULL
		,dblInvoiceValue							= NULL
		,strInvoiceCurrency							= NULL
		,dblNetMarketValue							= NULL
		,dtmRealizedDate							= NULL
		,dblRealizedQty								= NULL
		,dblProfitOrLossValue						= NULL
		,dblPAndLinMarketUOM						= NULL
		,dblPAndLChangeinMarketUOM					= NULL
		,strMarketCurrencyUOM						= NULL
		,strTrader									= SP.strName 
		,strFixedBy									= CD.strFixationBy
		,strInvoiceStatus							= NULL
		,strWarehouse								= NULL
		,strCPAddress								= Entity.strEntityAddress 
		,strCPCountry								= Entity.strEntityCountry	
		,strCPRefNo									= CH.strCustomerContract
		,intContractStatusId						= CD.intContractStatusId
		,intPricingTypeId							= CD.intPricingTypeId
		,strPricingType								= PT.strPricingType
		,strPricingStatus							= CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END
		,strCompanyName								= Company.strCompanyName

		FROM tblCTContractHeader				CH
		JOIN tblCTContractDetail				CD				 ON  CH.intContractHeaderId			 = CD.intContractHeaderId
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON  TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON  Entity.intEntityId				 = CH.intEntityId 
																	 AND Entity.strEntityType = CASE 
																								  WHEN CH.intContractTypeId=1 THEN 'Vendor'
																								  WHEN CH.intContractTypeId=2 THEN 'Customer'
																								END
		JOIN tblRKFutureMarket					Market			 ON  Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON  FMonth.intFutureMonthId		 = CD.intFutureMonthId
		
		JOIN tblICUnitMeasure					MarketUOM		 ON	MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId
		JOIN tblSMCurrency						MarketCY		 ON	MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICItem							Item			 ON Item.intItemId					 = CD.intItemId		
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType						 = 'Origin'
        LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID						=	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblLGAllocationDetail			AD				 ON CD.intContractDetailId			 = CASE WHEN CH.intContractTypeId=1 THEN AD.intPContractDetailId ELSE AD.intSContractDetailId END           
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON  SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblCTContractBasis			CB				 ON  CB.intContractBasisId			 = CH.intContractBasisId
		LEFT JOIN tblSMTerm						Term			 ON  Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON  WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		     = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		     = CD.intNetWeightUOMId		
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		     = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId	

		WHERE CH.intCommodityId = @intCommodityId
		AND   CD.dblQuantity		> ISNULL(CD.dblInvoicedQty, 0)
		AND CL.intCompanyLocationId = CASE 
										WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
										ELSE @intLocationId
								  END		
		AND intContractStatusId NOT IN (2,3,6)
		--AND dtmContractDate <= @dtmTransactionDateUpTo --@intCompanyId
		AND (ISNULL(CD.dblBalance,0)-ISNULL(CD.dblScheduleQty,0)) >0 --- Added Condition to  Check Balance minus Schedule Should be greater than Zero.
		AND CH.intCompanyId = CASE 
										WHEN ISNULL(@intCompanyId, 0) = 0 THEN CH.intCompanyId
										ELSE @intCompanyId
								  END	
	
	UNION
	---InTransit-----
		SELECT 
		 strType									= 'Unrealized'									
		,intContractTypeId							= CH.intContractTypeId
		,intContractHeaderId						= CH.intContractHeaderId
		,strContractType							= TP.strContractType
		,strContractNumber							= CH.strContractNumber
		,intContractBasisId							= CH.intContractBasisId
		,intTransactionType							= 2
		,strTransaction								= '2.In-transit'
		,strTransactionType							= 'In-transit('+CASE WHEN  L.intPurchaseSale =2 THEN 'S' ELSE 'P' END +')'
		,intContractDetailId						= CD.intContractDetailId
		,intCurrencyId								= CD.intCurrencyId	
		,intFutureMarketId							= CD.intFutureMarketId
		,strFutureMarket							= Market.strFutMarketName
		,intFutureMarketUOMId						= NULL
		,intFutureMarketUnitMeasureId				= Market.intUnitMeasureId
		,strFutureMarketUOM							= MarketUOM.strUnitMeasure
		,intMarketCurrencyId						= Market.intCurrencyId
		,intFutureMonthId							= FMonth.intFutureMonthId
		,strFutureMonth								= FMonth.strFutureMonth
		,intItemId									= CD.intItemId
		,strBook									= Book.strBook
		,strSubBook									= SubBook.strSubBook
		,intCommodityId								= Commodity.intCommodityId
		,strCommodity								= Commodity.strDescription
		,dtmReceiptDate								= NULL		
		,dtmContractDate							= CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
		,strContract								= CH.strContractNumber+ '-' + LTRIM(CD.intContractSeq)
		,intContractSeq								= CD.intContractSeq
		,strEntityName								= Entity.strEntityName
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= SUM(LD.dblQuantity)  OVER (PARTITION BY CD.intContractDetailId)
		,intQuantityUOMId							= CD.intItemUOMId
		,intQuantityUnitMeasureId					= IUM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		,dblWeight									= CD.dblNetWeight
		,intWeightUOMId								= CD.intNetWeightUOMId
		,intWeightUnitMeasureId						= WUM.intUnitMeasureId
		,strWeightUOM								= WUM.strUnitMeasure
		,dblBasis									= CD.dblBasis
		,intBasisUOMId								= CD.intBasisUOMId
		,intBasisUnitMeasureId						= BUOM.intUnitMeasureId
		,strBasisUOM								= BUOM.strUnitMeasure
		,dblFutures									= CD.dblFutures
		,dblCashPrice								= CD.dblCashPrice
		,intPriceUOMId								= CD.intPriceItemUOMId
		,intPriceUnitMeasureId						= PriceUOM.intUnitMeasureId
		,strContractPriceUOM						= PUOM.strUnitMeasure
		,intOriginId								= Item.intOriginId
		,strOrigin									= ISNULL(RY.strCountry, OG.strCountry)
		,strItemDescription							= Item.strDescription
		,strCropYear								= CropYear.strCropYear
		,strProductionLine							= CPL.strDescription
		,strCertification							= NULL
		,strTerms									= ISNULL(CB.strContractBasis,'')+','+ISNULL(Term.strTerm,'')+','+ISNULL(WG.strWeightGradeDesc,'') 
		,strPosition								= PO.strPosition
		,dtmStartDate								= CD.dtmStartDate
		,dtmEndDate									= CD.dtmEndDate
		,strBLNumber								= L.strBLNumber
		,dtmBLDate									= L.dtmBLDate
		,strAllocationRefNo							= AD.strAllocationDetailRefNo
		,strAllocationStatus						= CASE 
													  	WHEN ISNULL(AD.strAllocationDetailRefNo,'')  <> ''  THEN 'A'
													  	WHEN CH.intContractTypeId					 =   1	THEN 'L'
													  	WHEN CH.intContractTypeId					 =   2	THEN 'S'
													  END
		,strPriceTerms								= NULL
		,dblContractDifferential					= CD.dblBasis
		,strContractDifferentialUOM					= BCY.strCurrency+'/'+BUOM.strUnitMeasure
		,dblFuturesPrice							= CD.dblFutures
		,strFuturesPriceUOM							= MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
		,strFixationDetails							= NULL
		,dblFixedLots								= ISNULL(PF.dblLotsFixed,0)
		,dblUnFixedLots								= ISNULL((PF.dblTotalLots -PF.dblLotsFixed),0)
		,dblContractInvoiceValue					= NULL
		,dblSecondaryCosts							= NULL
		,dblCOGSOrNetSaleValue						= NULL
		,dblInvoicePrice							= NULL
		,dblInvoicePaymentPrice						= NULL
		,strInvoicePriceUOM							= NULL
		,dblInvoiceValue							= NULL
		,strInvoiceCurrency							= NULL
		,dblNetMarketValue							= NULL
		,dtmRealizedDate							= NULL
		,dblRealizedQty								= NULL
		,dblProfitOrLossValue						= NULL
		,dblPAndLinMarketUOM						= NULL
		,dblPAndLChangeinMarketUOM					= NULL
		,strMarketCurrencyUOM						= NULL
		,strTrader									= SP.strName 
		,strFixedBy									= CD.strFixationBy
		,strInvoiceStatus							= NULL
		,strWarehouse								= NULL
		,strCPAddress								= Entity.strEntityAddress 
		,strCPCountry								= Entity.strEntityCountry	
		,strCPRefNo									= CH.strCustomerContract
		,intContractStatusId						= CD.intContractStatusId
		,intPricingTypeId							= CD.intPricingTypeId
		,strPricingType								= PT.strPricingType
		,strPricingStatus							= CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END
		,strCompanyName								= Company.strCompanyName

		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6,3) -- 1.purchase 2.outbound
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
																		   WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId
																		   WHEN L.intPurchaseSale = 2 THEN LD.intSContractDetailId
																END
		JOIN tblCTContractHeader				CH				 ON  CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON  TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON  Entity.intEntityId				 = CH.intEntityId
																	 AND Entity.strEntityType = CASE 
																								  WHEN CH.intContractTypeId=1 THEN 'Vendor'
																								  WHEN CH.intContractTypeId=2 THEN 'Customer'
																								END
		JOIN tblRKFutureMarket					Market			 ON  Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON  FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON  Item.intItemId					 = CD.intItemId
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
        LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 =	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId	
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblLGAllocationDetail			AD				 ON CD.intContractDetailId			 = CASE WHEN CH.intContractTypeId=1 THEN AD.intPContractDetailId ELSE AD.intSContractDetailId END           
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON  SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblCTContractBasis			CB				 ON  CB.intContractBasisId			 = CH.intContractBasisId
		LEFT JOIN tblSMTerm						Term			 ON  Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON  WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		     = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		     = CD.intNetWeightUOMId		
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		     = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC	ON	IC.intItemContractId						 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY	ON	RY.intCountryID								 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = L.intCompanyId		

		WHERE CH.intCommodityId = @intCommodityId
		AND   CD.dblQuantity		> ISNULL(CD.dblInvoicedQty, 0)
		AND CL.intCompanyLocationId = CASE 
										WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
										ELSE @intLocationId
								  END
		AND L.intCompanyId		= CASE 
										WHEN ISNULL(@intCompanyId, 0) = 0 THEN L.intCompanyId
										ELSE @intCompanyId
								  END								  		
		----AND intContractStatusId NOT IN (2,3,6)
		--AND dtmContractDate <= @dtmTransactionDateUpTo
	 UNION
	--Inventory
	 SELECT 
		 strType									= 'Unrealized'									
		,intContractTypeId							= CH.intContractTypeId
		,intContractHeaderId						= CH.intContractHeaderId
		,strContractType							= TP.strContractType
		,strContractNumber							= CH.strContractNumber
		,intContractBasisId							= CH.intContractBasisId
		,intTransactionType							= 3
		,strTransaction								= '3.Inventory'
		,strTransactionType							= 'Inventory (P)'       														 
		,intContractDetailId						= CD.intContractDetailId
		,intCurrencyId								= CD.intCurrencyId	
		,intFutureMarketId							= CD.intFutureMarketId
		,strFutureMarket							= Market.strFutMarketName
		,intFutureMarketUOMId						= NULL
		,intFutureMarketUnitMeasureId				= Market.intUnitMeasureId
		,strFutureMarketUOM							= MarketUOM.strUnitMeasure
		,intMarketCurrencyId						= Market.intCurrencyId
		,intFutureMonthId							= FMonth.intFutureMonthId
		,strFutureMonth								= FMonth.strFutureMonth
		,intItemId									= CD.intItemId
		,strBook									= Book.strBook
		,strSubBook									= SubBook.strSubBook
		,intCommodityId								= Commodity.intCommodityId
		,strCommodity								= Commodity.strDescription
		,dtmReceiptDate								= NULL		
		,dtmContractDate							= CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
		,strContract								= CH.strContractNumber+ '-' + LTRIM(CD.intContractSeq)
		,intContractSeq								= CD.intContractSeq
		,strEntityName								= Entity.strEntityName
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= l.dblLotQty
		,intQuantityUOMId							= CD.intItemUOMId
		,intQuantityUnitMeasureId					= IUM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		,dblWeight									= CD.dblNetWeight
		,intWeightUOMId								= CD.intNetWeightUOMId
		,intWeightUnitMeasureId						= WUM.intUnitMeasureId
		,strWeightUOM								= WUM.strUnitMeasure
		,dblBasis									= CD.dblBasis
		,intBasisUOMId								= CD.intBasisUOMId
		,intBasisUnitMeasureId						= BUOM.intUnitMeasureId
		,strBasisUOM								= BUOM.strUnitMeasure
		,dblFutures									= CD.dblFutures
		,dblCashPrice								= CD.dblCashPrice
		,intPriceUOMId								= CD.intPriceItemUOMId
		,intPriceUnitMeasureId						= PriceUOM.intUnitMeasureId
		,strContractPriceUOM						= PUOM.strUnitMeasure
		,intOriginId								= Item.intOriginId
		,strOrigin									= ISNULL(RY.strCountry, OG.strCountry)
		,strItemDescription							= Item.strDescription
		,strCropYear								= CropYear.strCropYear
		,strProductionLine							= CPL.strDescription
		,strCertification							= NULL
		,strTerms									= ISNULL(CB.strContractBasis,'')+','+ISNULL(Term.strTerm,'')+','+ISNULL(WG.strWeightGradeDesc,'') 
		,strPosition								= PO.strPosition
		,dtmStartDate								= CD.dtmStartDate
		,dtmEndDate									= CD.dtmEndDate
		,strBLNumber								= NULL
		,dtmBLDate									= NULL
		,strAllocationRefNo							= AD.strAllocationDetailRefNo
		,strAllocationStatus						= CASE 
													  	WHEN ISNULL(AD.strAllocationDetailRefNo,'')  <> ''  THEN 'A'
													  	WHEN CH.intContractTypeId					 =   1	THEN 'L'
													  	WHEN CH.intContractTypeId					 =   2	THEN 'S'
													  END
		,strPriceTerms								= NULL
		,dblContractDifferential					= CD.dblBasis
		,strContractDifferentialUOM					= BCY.strCurrency+'/'+BUOM.strUnitMeasure
		,dblFuturesPrice							= CD.dblFutures
		,strFuturesPriceUOM							= MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
		,strFixationDetails							= NULL
		,dblFixedLots								= ISNULL(PF.dblLotsFixed,0)
		,dblUnFixedLots								= ISNULL((PF.dblTotalLots -PF.dblLotsFixed),0)
		,dblContractInvoiceValue					= NULL
		,dblSecondaryCosts							= NULL
		,dblCOGSOrNetSaleValue						= NULL
		,dblInvoicePrice							= NULL
		,dblInvoicePaymentPrice						= NULL
		,strInvoicePriceUOM							= NULL
		,dblInvoiceValue							= NULL
		,strInvoiceCurrency							= NULL
		,dblNetMarketValue							= NULL
		,dtmRealizedDate							= NULL
		,dblRealizedQty								= NULL
		,dblProfitOrLossValue						= NULL
		,dblPAndLinMarketUOM						= NULL
		,dblPAndLChangeinMarketUOM					= NULL
		,strMarketCurrencyUOM						= NULL
		,strTrader									= SP.strName 
		,strFixedBy									= CD.strFixationBy
		,strInvoiceStatus							= NULL
		,strWarehouse								= NULL
		,strCPAddress								= Entity.strEntityAddress 
		,strCPCountry								= Entity.strEntityCountry	
		,strCPRefNo									= CH.strCustomerContract
		,intContractStatusId						= CD.intContractStatusId
		,intPricingTypeId							= CD.intPricingTypeId
		,strPricingType								= PT.strPricingType
		,strPricingStatus							= CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'ELSE '' END
		,strCompanyName								= Company.strCompanyName

		FROM 
		(
		  SELECT 
				CTDetail.intContractDetailId
				,SUM(Lot.dblQty) dblLotQty
				FROM tblICLot Lot
				LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
				LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
				LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ReceiptItem.intLineNo 
				LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = ReceiptItem.intOrderId
				WHERE Lot.dblQty > 0.0
				GROUP BY CTDetail.intContractDetailId
		) l -- 1.purchase 2.outbound
		JOIN tblCTContractDetail CD ON CD.intContractDetailId	= l.intContractDetailId
		JOIN tblCTContractHeader				CH				 ON  CH.intContractHeaderId			 = CD.intContractHeaderId	
		JOIN tblICCommodity						Commodity		 ON Commodity.intCommodityId		 = CH.intCommodityId
		JOIN tblCTContractType					TP				 ON  TP.intContractTypeId			 = CH.intContractTypeId		
		JOIN vyuCTEntity						Entity			 ON  Entity.intEntityId				 = CH.intEntityId
																	 AND Entity.strEntityType = CASE 
																								  WHEN CH.intContractTypeId=1 THEN 'Vendor'
																								  WHEN CH.intContractTypeId=2 THEN 'Customer'
																								END
		JOIN tblRKFutureMarket					Market			 ON  Market.intFutureMarketId		 = CD.intFutureMarketId
		JOIN tblRKFuturesMonth					FMonth			 ON  FMonth.intFutureMonthId		 = CD.intFutureMonthId
		JOIN tblSMCurrency						MarketCY		 ON	 MarketCY.intCurrencyID			 = Market.intCurrencyId
		JOIN tblICUnitMeasure					MarketUOM		 ON	 MarketUOM.intUnitMeasureId		 = Market.intUnitMeasureId		
		JOIN tblICItem							Item			 ON  Item.intItemId					 = CD.intItemId		
		JOIN tblSMCompanyLocation				CL				 ON CL.intCompanyLocationId			 = CD.intCompanyLocationId
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType					 = 'Origin'
        LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID					 =	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblLGAllocationDetail			AD				 ON CD.intContractDetailId			 = CASE WHEN CH.intContractTypeId=1 THEN AD.intPContractDetailId ELSE AD.intSContractDetailId END           
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON  SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblCTContractBasis			CB				 ON  CB.intContractBasisId			 = CH.intContractBasisId
		LEFT JOIN tblSMTerm						Term			 ON  Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON  WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		     = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		     = CD.intNetWeightUOMId		
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = ItemUOM.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		     = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC			     ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY			     ON	RY.intCountryID					 = IC.intCountryId	
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId

		WHERE CH.intCommodityId = @intCommodityId AND Item.strLotTracking <> 'No'
		--AND   CD.dblQuantity		> ISNULL(CD.dblInvoicedQty, 0)
		AND CL.intCompanyLocationId = CASE 
										WHEN ISNULL(@intLocationId, 0) = 0 THEN CL.intCompanyLocationId
										ELSE @intLocationId
								  END		
       
	   AND CH.intCompanyId		= CASE 
										WHEN ISNULL(@intCompanyId, 0) = 0 THEN CH.intCompanyId
										ELSE @intCompanyId
								  END

	INSERT INTO @tblContractCost(intContractDetailId,dblTotalCost)
	SELECT  
			 intContractDetailId = CC.intContractDetailId
			,dblTotalCost        = SUM(CASE WHEN CC.strCostStatus ='Close' THEN ISNULL(CC.dblActualAmount,0) ELSE ISNULL(CC.dblActualAmount,0)+ISNULL(CC.dblAccruedAmount,0) END)
	FROM tblCTContractCost CC
	JOIN @tblUnRealizedPNL RealizedPNL ON RealizedPNL.intContractDetailId = CC.intContractDetailId
	GROUP BY CC.intContractDetailId

    INSERT INTO @tblSettlementPrice(intFutureMarketId,intFutureMonthId,dblSettlementPrice)
	  SELECT 
	     intFutureMarketId  = SettlementPrice.intFutureMarketId
		,intFutureMonthId	= MarketMap.intFutureMonthId
		,dblSettlementPrice	= MarketMap.dblLastSettle
		FROM tblRKFutSettlementPriceMarketMap MarketMap
		JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId =MarketMap.intFutureSettlementPriceId
		WHERE SettlementPrice.intFutureSettlementPriceId = @intFutureSettlementPriceId
   
    UNION

	SELECT 
	     intFutureMarketId  = SettlementPrice.intFutureMarketId
		,intFutureMonthId	= MarketMap.intFutureMonthId
		,dblSettlementPrice	= MarketMap.dblLastSettle
		FROM tblRKFutSettlementPriceMarketMap MarketMap
		JOIN tblRKFuturesSettlementPrice SettlementPrice ON SettlementPrice.intFutureSettlementPriceId =MarketMap.intFutureSettlementPriceId
		WHERE SettlementPrice.intFutureSettlementPriceId = (SELECT MAX(intFutureSettlementPriceId) FROM tblRKFuturesSettlementPrice)

	-----------------------------------------------------SecondaryCosts Updation--------------------------------------------
	---Contract
	UPDATE RealizedPNL
	SET  RealizedPNL.dblSecondaryCosts = ISNULL(CC.dblTotalCost,0)
	FROM @tblUnRealizedPNL RealizedPNL
	JOIN @tblContractCost CC ON CC.intContractDetailId = RealizedPNL.intContractDetailId	
	-----------------------------------------------------ContractInvoiceValue Updation--------------------------------------------
	UPDATE CD
	SET 
	 CD.dblContractInvoiceValue	= CASE 
											  WHEN ISNULL(CD.dblCashPrice,0.0)<> 0.0 THEN
													  dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intQuantityUnitMeasureId,CD.intFutureMarketUnitMeasureId,CD.dblQuantity)
													* dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intPriceUnitMeasureId,CD.intFutureMarketUnitMeasureId, CD.dblCashPrice)
													/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END

											  WHEN ISNULL(CD.dblCashPrice,0.0)= 0.0 THEN
													  dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intQuantityUnitMeasureId,CD.intFutureMarketUnitMeasureId,CD.dblQuantity)
													*(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intBasisUnitMeasureId,CD.intFutureMarketUnitMeasureId, CD.dblBasis)+
													  SP.dblSettlementPrice)
													/ CASE WHEN FCY.ysnSubCurrency = 1 THEN FCY.intCent ELSE 1 END
								  END
   ,CD.dblSettlementPrice = SP.dblSettlementPrice        
	FROM @tblUnRealizedPNL CD
	JOIN @tblSettlementPrice	SP ON SP.intFutureMarketId = CD.intFutureMarketId AND SP.intFutureMonthId = CD.intFutureMonthId
	JOIN tblSMCurrency		    FCY	     ON	FCY.intCurrencyID	    = CD.intMarketCurrencyId
	-----------------------------------------------------Net Market Updation--------------------------------------------	
	UPDATE CD
	SET CD.dblNetMarketValue	=  dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,CD.intQuantityUnitMeasureId,CD.intFutureMarketUnitMeasureId,CD.dblQuantity)*SP.dblSettlementPrice
							  	   + BasisDetail.dblBasisOrDiscount  --Market Differential
       ,CD.dblMarketDifferential = BasisDetail.dblBasisOrDiscount
	FROM @tblUnRealizedPNL CD
	JOIN @tblSettlementPrice	SP ON SP.intFutureMarketId = CD.intFutureMarketId AND SP.intFutureMonthId = CD.intFutureMonthId
	JOIN tblRKM2MBasisDetail BasisDetail ON BasisDetail.intFutureMarketId = CD.intFutureMarketId AND BasisDetail.intItemId = CD.intItemId
	AND  BasisDetail.strPeriodTo = RIGHT(CONVERT(VARCHAR(11),CD.dtmEndDate,106),8)
	----------------------------------------------------------------------------------------------------------------------------		
	UPDATE @tblUnRealizedPNL 
	SET  dblCOGSOrNetSaleValue = (ISNULL(dblContractInvoiceValue,0)+ ISNULL(dblSecondaryCosts,0))* CASE WHEN intContractTypeId =1 THEN 1 ELSE -1 END
	
	UPDATE @tblUnRealizedPNL 
	SET  dblProfitOrLossValue =  CASE 
										WHEN intContractTypeId = 1 THEN (ISNULL(dblNetMarketValue,0) - ISNULL(dblCOGSOrNetSaleValue,0))
										ELSE							(ABS(ISNULL(dblCOGSOrNetSaleValue,0)) - ISNULL(dblNetMarketValue,0) )
								  END
		
	 
	
	  SELECT 
	   strType
	  ,strCompanyName
	  ,intContractTypeId				
	  ,strContractType				
	  ,strContractNumber				
	  ,strTransaction					
	  ,strTransactionType				
	  ,intContractDetailId
	  ,strFutureMarket
	  ,strFutureMarketUOM				
	  ,strFutureMonth
	  ,strBook						
	  ,strSubBook						
	  ,strCommodity					
	  ,dtmReceiptDate					
	  ,dtmContractDate				
	  ,strContract					
	  ,intContractSeq					
	  ,strEntityName					
	  ,strInternalCompany				
	  ,dblQuantity
	  ,strQuantityUOM					
	  ,dblWeight
	  ,strWeightUOM					
	  ,dblBasis	
	  ,strBasisUOM					
	  ,dblFutures						
	  ,dblCashPrice					
	  ,strContractPriceUOM			
	  ,strOrigin						
	  ,strItemDescription				
	  ,strCropYear					
	  ,strProductionLine				
	  ,strCertification																	
	  ,strTerms						
	  ,strPosition					
	  ,dtmStartDate					
	  ,dtmEndDate						
	  ,strBLNumber					
	  ,dtmBLDate						
	  ,strAllocationRefNo				
	  ,strAllocationStatus			
	  ,strPriceTerms					
	  ,dblContractDifferential		
	  ,strContractDifferentialUOM		
	  ,dblFuturesPrice				
	  ,strFuturesPriceUOM				
	  ,strFixationDetails				
	  ,dblFixedLots					
	  ,dblUnFixedLots					
	  ,dblContractInvoiceValue		
	  ,dblSecondaryCosts				
	  ,dblCOGSOrNetSaleValue
	  ,dblSettlementPrice
	  ,dblMarketDifferential
	  ,dblNetMarketValue
	  ,dblProfitOrLossValue		
	  ,dblInvoicePrice				
	  ,dblInvoicePaymentPrice			
	  ,strInvoicePriceUOM				
	  ,dblInvoiceValue				
	  ,strInvoiceCurrency				
	  ,dtmRealizedDate				
	  ,dblRealizedQty
	  ,dblPAndLinMarketUOM			
	  ,dblPAndLChangeinMarketUOM		
	  ,strMarketCurrencyUOM			
	  ,strTrader						
	  ,strFixedBy						
	  ,strInvoiceStatus				
	  ,strWarehouse					
	  ,strCPAddress					
	  ,strCPCountry					
	  ,strCPRefNo						
	  ,intContractStatusId			
	  ,intPricingTypeId				
	  ,strPricingType					
	  ,strPricingStatus
	  FROM @tblUnRealizedPNL 
	  ORDER BY strTransaction				
	
END TRY  
  
BEGIN CATCH  
 
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    

END CATCH
