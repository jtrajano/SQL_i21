CREATE PROCEDURE [dbo].[uspRKGetRealizedPNL]
	 @inBookId		   INT = 0	
	,@intCurrencyId    INT = 0
	
AS
BEGIN TRY

DECLARE @ErrMsg NVARCHAR(MAX)

DECLARE @DefaultCompanyId	 INT
DECLARE @DefaultCompanyName	 NVARCHAR(200)
  
  IF NOT EXISTS(SELECT 1 FROM tblSMMultiCompany WHERE ISNULL(intMultiCompanyParentId,0) <> 0)
  BEGIN
		 SELECT 
		 @DefaultCompanyId = intMultiCompanyId
		,@DefaultCompanyName = strCompanyName 
		 FROM tblSMMultiCompany

  END

	 DECLARE @tblRealizedPNL AS TABLE 
	 (
		 intRealizedPNL                         INT IDENTITY(1,1)
		,intContractTypeId						INT
		,intContractDetailId					INT	
		,intBookId								INT
		,strBook								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strSubBook								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intCommodityId							INT
		,strCommodity							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strProductType							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strRealizedType						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmContractDate						DATETIME
		,strTransactionType						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmInvoicePostedDate					DATETIME
		,strContract							NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strAllocationRefNo						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strEntityName							NVARCHAR(100)
		,strInternalCompany						NVARCHAR(20)
		,dblQuantity							NUMERIC(38,20)
		,intQuantityUOMId						INT							---ItemUOM
		,intQuantityUnitMeasureId				INT							---UnitMeasure
		,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblWeight								NUMERIC(38,20)
		,intWeightUOMId							INT							---ItemUOM		
		,strWeightUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intOriginId							INT
		,strOrigin								NVARCHAR(100)
		,strItemDescription						NVARCHAR(100)
		,strGrade								NVARCHAR(100)
		,strCropYear							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strProductionLine						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCertification						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strTerms								NVARCHAR(200) COLLATE Latin1_General_CI_AS	
		,strPosition							NVARCHAR(100)
		,dtmStartDate							DATETIME
		,dtmEndDate								DATETIME
		,strPriceTerms							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strIncoTermLocation					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblContractDifferential				NUMERIC(38,20)
		,strContractDifferentialUOM				NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFuturesPrice						NUMERIC(38,20)
		,strFuturesPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice							NUMERIC(38,20)
		,intPriceUOMId							INT							---ItemUOM
		,intPriceUnitMeasureId					INT							---UnitMeasure
		,strContractPriceUOM					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strFixationDetails						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFixedLots							NUMERIC(38,20)
		,dblUnFixedLots							NUMERIC(38,20)
		,dblContractInvoiceValue				NUMERIC(38,20)
		,dblSecondaryCosts						NUMERIC(38,20)
		,dblCOGSOrNetSaleValue					NUMERIC(38,20)
		,intFutureMarketId						INT
		,strFutureMarket						NVARCHAR(100)
		,intFutureMarketUOMId					INT
		,intFutureMarketUnitMeasureId			INT
		,strFutureMarketUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intMarketCurrencyId					INT
		,intFutureMonthId						INT
		,strFutureMonth							NVARCHAR(100)
		,dtmRealizedDate						DATETIME
		,dblRealizedQty							NUMERIC(38,20)
		,dblRealizedPNLValue					NUMERIC(38,20)
		,dblPNLPreDayValue						NUMERIC(38,20)
		,dblProfitOrLossValue					NUMERIC(38,20)
		,dblPNLChange							NUMERIC(38,20)
		,strFixedBy								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingType							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strInvoiceStatus						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblNetFuturesValue					    NUMERIC(38,20)
		,dblRealizedFuturesPNLValue			    NUMERIC(38,20)
		,dblNetPNLValue						    NUMERIC(38,20)
		,dblFXValue							    NUMERIC(38,20)
		,dblFXConvertedValue				    NUMERIC(38,20)
		,strSalesReturnAdjustment				NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intCompanyId							INT
		,strCompany								NVARCHAR(200) COLLATE Latin1_General_CI_AS
	    )  

		INSERT INTO @tblRealizedPNL
		(
			 intContractTypeId
			,intContractDetailId
			,intBookId
			,strBook						
			,strSubBook						
			,intCommodityId					
			,strCommodity					
			,strProductType					
			,strRealizedType				
			,dtmContractDate				
			,strTransactionType				
			,dtmInvoicePostedDate			
			,strContract					
			,strAllocationRefNo				
			,strEntityName					
			,intQuantityUOMId				
			,strInternalCompany				
			,dblQuantity					
			,intQuantityUnitMeasureId		
			,strQuantityUOM					
			,dblWeight						
			,intWeightUOMId					
			,strWeightUOM					
			,intOriginId					
			,strOrigin
			,strItemDescription
			,strGrade						
			,strCropYear					
			,strProductionLine				
			,strCertification				
			,strTerms						
			,strPosition					
			,dtmStartDate					
			,dtmEndDate						
			,strPriceTerms					
			,strIncoTermLocation			
			,dblContractDifferential		
			,strContractDifferentialUOM		
			,dblFuturesPrice				
			,strFuturesPriceUOM				
			,dblCashPrice					
			,intPriceUOMId					
			,intPriceUnitMeasureId			
			,strContractPriceUOM			
			,strFixationDetails				
			,dblFixedLots					
			,dblUnFixedLots					
			,dblContractInvoiceValue		
			,dblSecondaryCosts				
			,dblCOGSOrNetSaleValue			
			,intFutureMarketId				
			,strFutureMarket				
			,intFutureMarketUOMId			
			,intFutureMarketUnitMeasureId	
			,strFutureMarketUOM				
			,intMarketCurrencyId			
			,intFutureMonthId				
			,strFutureMonth					
			,dtmRealizedDate				
			,dblRealizedQty
			,dblRealizedPNLValue					
			,dblPNLPreDayValue				
			,dblProfitOrLossValue			
			,dblPNLChange					
			,strFixedBy						
			,strPricingType					
			,strInvoiceStatus				
			,dblNetFuturesValue				
			,dblRealizedFuturesPNLValue		
			,dblNetPNLValue					
			,dblFXValue						
			,dblFXConvertedValue			
			,strSalesReturnAdjustment
			,intCompanyId	
			,strCompany				
		)
		  SELECT
		  intContractTypeId					
		 ,intContractDetailId				
		 ,intBookId							
		 ,strBook							
		 ,strSubBook							
		 ,intCommodityId						
		 ,strCommodity						
		 ,strProductType						
		 ,strRealizedType					
		 ,dtmContractDate					
		 ,strTransactionType				
		 ,dtmInvoicePostedDate				
		 ,strContract						
		 ,strAllocationRefNo					
		 ,strEntityName						
		 ,intQuantityUOMId					
		 ,strInternalCompany					
		 ,dblQuantity = SUM(dblQuantity)						
		 ,intQuantityUnitMeasureId			
		 ,strQuantityUOM
		 ,dblWeight	  = SUM(dblQuantity)							
		 ,intWeightUOMId
		 ,strWeightUOM						
		 ,intOriginId						
		 ,strOrigin							
		 ,strItemDescription					
		 ,strGrade							
		 ,strCropYear						
		 ,strProductionLine					
		 ,strCertification					
		 ,strTerms							
		 ,strPosition						
		 ,dtmStartDate						
		 ,dtmEndDate							
		 ,strPriceTerms						
		 ,strIncoTermLocation				
		 ,dblContractDifferential			
		 ,strContractDifferentialUOM			
		 ,dblFuturesPrice					
		 ,strFuturesPriceUOM					
		 ,dblCashPrice						
		 ,intPriceUOMId						
		 ,intPriceUnitMeasureId				
		 ,strContractPriceUOM				
		 ,strFixationDetails					
		 ,dblFixedLots						
		 ,dblUnFixedLots						
		 ,dblContractInvoiceValue = SUM(dblContractInvoiceValue)	
		 ,dblSecondaryCosts			
		 ,dblCOGSOrNetSaleValue				
		 ,intFutureMarketId					
		 ,strFutureMarket					
		 ,intFutureMarketUOMId				
		 ,intFutureMarketUnitMeasureId		
		 ,strFutureMarketUOM					
		 ,intMarketCurrencyId				
		 ,intFutureMonthId					
		 ,strFutureMonth						
		 ,dtmRealizedDate					
		 ,dblRealizedQty		 = SUM(dblRealizedQty)			
		 ,dblRealizedPNLValue				
		 ,dblPNLPreDayValue					
		 ,dblProfitOrLossValue				
		 ,dblPNLChange						
		 ,strFixedBy							
		 ,strPricingType						
		 ,strInvoiceStatus					
		 ,dblNetFuturesValue	= SUM(CASE WHEN intContractTypeId = 1 THEN dblNetFuturesValue ELSE - dblNetFuturesValue END)				
		 ,dblRealizedFuturesPNLValue			
		 ,dblNetPNLValue						
		 ,dblFXValue							
		 ,dblFXConvertedValue		= SUM(dblFXConvertedValue)		
		 ,strSalesReturnAdjustment			
		 ,intCompanyId						
		 ,strCompany							
		  FROM
	   (
		 SELECT
		 intContractTypeId							= CH.intContractTypeId 
		,intContractDetailId						= CD.intContractDetailId
		,intBookId									= Book.intBookId
		,strBook									= Book.strBook
		,strSubBook									= SubBook.strSubBook
		,intCommodityId								= Commodity.intCommodityId
		,strCommodity								= Commodity.strDescription
		,strProductType								= CA1.strDescription
		,strRealizedType							= 'Realized'							
		,dtmContractDate							= CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
		,strTransactionType							= 'Contract('+CASE 
																	  WHEN CH.intContractTypeId=1 THEN 'P'
																	  WHEN CH.intContractTypeId=2 THEN 'S'
																  END
															 +')'
		,dtmInvoicePostedDate						= Invoice.dtmPostDate			
		,strContract								= CH.strContractNumber+ '-' + LTRIM(CD.intContractSeq)
		,strAllocationRefNo							= AllocationDetail.strAllocationDetailRefNo
		,strEntityName								= Entity.strEntityName
		,intQuantityUOMId							= InvoiceDetail.intOrderUOMId
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)		
		,intQuantityUnitMeasureId					= OrderUOM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		
		,dblWeight									= InvoiceDetail.dblShipmentNetWt
		,intWeightUOMId								= LoadDetail.intWeightItemUOMId 
		
		,strWeightUOM								= WUM.strUnitMeasure
		,intOriginId								= Item.intOriginId
		,strOrigin									= ISNULL(RY.strCountry, OG.strCountry)
		,strItemDescription							= Item.strDescription
		,strGrade									= CA2.strDescription
		,strCropYear								= CropYear.strCropYear
		,strProductionLine							= CPL.strDescription
		,strCertification							= NULL
		,strTerms									= ISNULL(CB.strContractBasis,'')+','+ISNULL(Term.strTerm,'')+','+ISNULL(WG.strWeightGradeDesc,'') 
		,strPosition								= PO.strPosition
		,dtmStartDate								= CD.dtmStartDate
		,dtmEndDate									= CD.dtmEndDate
		,strPriceTerms								= CASE 
															WHEN CD.intPricingTypeId =2 THEN 'Unfixed: '+Market.strFutMarketName+' '+FMonth.strFutureMonth
																									+' '+[dbo].[fnRemoveTrailingZeroes](CD.dblBasis)+' '+ BCY.strCurrency+' / '+BUOM.strUnitMeasure

															ELSE 'Fixed: '+Market.strFutMarketName+' '+FMonth.strFutureMonth+' '+[dbo].[fnRemoveTrailingZeroes](CD.dblFutures)
															+' '+ BCY.strCurrency+' / '+BUOM.strUnitMeasure+' '
															+[dbo].[fnRemoveTrailingZeroes](CD.dblFutures)+' '+ BCY.strCurrency+' / '+BUOM.strUnitMeasure
													  END
		,strIncoTermLocation						= CB.strContractBasis + ISNULL(CASE WHEN CB.strINCOLocationType IN('City','Port') THEN CT.strCity+','+CO.strCountry ELSE SL.strSubLocationName END,'')
		,dblContractDifferential					= CD.dblBasis
		,strContractDifferentialUOM					= BCY.strCurrency+'/'+BUOM.strUnitMeasure
		,dblFuturesPrice							= CD.dblFutures
		,strFuturesPriceUOM							= MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
		,dblCashPrice								= CD.dblCashPrice
		,intPriceUOMId								= CD.intPriceItemUOMId
		,intPriceUnitMeasureId						= PriceUOM.intUnitMeasureId
		,strContractPriceUOM						= PUOM.strUnitMeasure	
		,strFixationDetails							= NULL
		,dblFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL(PF.dblLotsFixed,0) ELSE 0 END
		,dblUnFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL((ISNULL(CD.[dblNoOfLots],0) -ISNULL(PF.dblLotsFixed,0)),0) ELSE 0 END
		,dblContractInvoiceValue					= (BillDetail.dblTotal)*
													  (InvoiceDetail.dblQtyShipped
													  /dbo.fnCTConvertQuantityToTargetItemUOM(BillDetail.intItemId,BillUOM.intUnitMeasureId,ShipUOM.intUnitMeasureId,BillDetail.dblQtyReceived))
		
		,dblSecondaryCosts							= ISNULL((BillCost.dblTotal)*
													  (InvoiceDetail.dblQtyShipped
													  /dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,ItemUOM.intUnitMeasureId,ShipUOM.intUnitMeasureId,CD.dblQuantity)),0)
		
		,dblCOGSOrNetSaleValue						= NULL---dblContractInvoiceValue+dblCOGSOrNetSaleValue		
		,intFutureMarketId							= CD.intFutureMarketId
		,strFutureMarket							= Market.strFutMarketName
		,intFutureMarketUOMId						= NULL
		,intFutureMarketUnitMeasureId				= Market.intUnitMeasureId
		,strFutureMarketUOM							= MarketUOM.strUnitMeasure
		,intMarketCurrencyId						= Market.intCurrencyId
		,intFutureMonthId							= FMonth.intFutureMonthId
		,strFutureMonth								= FMonth.strFutureMonth
		,dtmRealizedDate							= CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)	
		,dblRealizedQty								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)		
		,dblRealizedPNLValue						= NULL
		,dblPNLPreDayValue							= NULL
		,dblProfitOrLossValue						= NULL
		,dblPNLChange								= NULL
		,strFixedBy									= CD.strFixationBy
		,strPricingType								= PT.strPricingType
		,strInvoiceStatus							= Invoice.strType
		,dblNetFuturesValue							= dbo.fnCTConvertQuantityToTargetItemUOM
																							(
																							 InvoiceDetail.intItemId
																							,ShipUOM.intUnitMeasureId
																							,Market.intUnitMeasureId
																							,InvoiceDetail.dblQtyShipped
																							)
													  * CD.dblFutures /(CASE WHEN MarketCY.ysnSubCurrency = 1 THEN MarketCY.intCent ELSE 1 END)
		,dblRealizedFuturesPNLValue					= 0
		,dblNetPNLValue								= 0
		,dblFXValue									= NULL
		,dblFXConvertedValue						= InvoiceDetail.dblTotal * InvoiceDetail.dblCurrencyExchangeRate
		,strSalesReturnAdjustment					= NULL
		,intCompanyId								= Company.intMultiCompanyId
		,strCompany									= Company.strCompanyName

		FROM tblARInvoiceDetail InvoiceDetail
		JOIN tblARInvoice Invoice					ON Invoice.intInvoiceId= InvoiceDetail.intInvoiceId AND Invoice.strType = 'Standard'
		JOIN tblLGLoadDetail LoadDetail			    ON LoadDetail.intLoadDetailId = InvoiceDetail.intLoadDetailId
		JOIN tblLGAllocationDetail AllocationDetail ON AllocationDetail.intAllocationDetailId = LoadDetail.intAllocationDetailId
		JOIN tblCTContractDetail	CD				ON CD.intContractDetailId = AllocationDetail.intPContractDetailId
		
		JOIN tblCTContractHeader				CH			     ON  CH.intContractHeaderId			 = CD.intContractHeaderId		
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
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CH.intPricingTypeId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType						 = 'Origin'
		LEFT JOIN tblICCommodityAttribute		CA1				 ON CA1.intCommodityAttributeId		 = Item.intProductTypeId
		AND	CA1.strType						 = 'ProductType'
		LEFT JOIN tblICCommodityAttribute		CA2				 ON CA2.intCommodityAttributeId		 = Item.intGradeId
		AND	CA2.strType						 = 'Grade'
		LEFT JOIN tblAPBillDetail BillDetail					 ON BillDetail.intContractDetailId = CD.intContractDetailId 
																	AND   BillDetail.intItemId     = CD.intItemId
		
        LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID						=	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON  SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblCTContractBasis			CB				 ON  CB.intContractBasisId			 = CH.intContractBasisId
		LEFT JOIN tblSMTerm						Term			 ON  Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON  WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		     = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		     = LoadDetail.intWeightItemUOMId		
		
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		     = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId
		LEFT JOIN tblICItemUOM					ShipUOM			 ON ShipUOM.intItemUOMId		     = InvoiceDetail.intItemUOMId
		LEFT JOIN tblICItemUOM					OrderUOM		 ON OrderUOM.intItemUOMId		     = InvoiceDetail.intOrderUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = OrderUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					BillUOM			 ON BillUOM.intItemUOMId		     = BillDetail.intUnitOfMeasureId
		LEFT JOIN	tblSMCity					CT				 ON	CT.intCityId					=	CH.intINCOLocationTypeId	
		LEFT JOIN	tblSMCompanyLocationSubLocation		SL		 ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId
		LEFT JOIN	tblSMCountry				CO				 ON	CO.intCountryID					=	CT.intCountryId
		LEFT JOIN (SELECT  
					  BillDetail.intContractDetailId
					,SUM( BillDetail.dblTotal) dblTotal
					FROM tblAPBillDetail BillDetail
					JOIN tblICItem Item ON Item.intItemId = BillDetail.intItemId
					WHERE Item.strType='Other Charge'
					GROUP BY intContractDetailId
		          )BillCost ON BillCost.intContractDetailId = CD.intContractDetailId
		WHERE ISNULL(Book.intBookId,0) = CASE WHEN @inBookId > 0 THEN @inBookId ELSE  ISNULL(Book.intBookId,0) END
	
	UNION ALL
	
		 SELECT 
		  intContractTypeId							= CH.intContractTypeId 
		,intContractDetailId						= CD.intContractDetailId
		,intBookId									= Book.intBookId
		,strBook									= Book.strBook
		,strSubBook									= SubBook.strSubBook
		,intCommodityId								= Commodity.intCommodityId
		,strCommodity								= Commodity.strDescription
		,strProductType								= CA1.strDescription
		,strRealizedType							= 'Realized'							
		,dtmContractDate							= CONVERT(DATETIME, CONVERT(VARCHAR, CH.dtmContractDate, 101), 101)
		,strTransactionType							= 'Contract('+CASE 
																	  WHEN CH.intContractTypeId=1 THEN 'P'
																	  WHEN CH.intContractTypeId=2 THEN 'S'
																  END
															 +')'
		,dtmInvoicePostedDate						= Invoice.dtmPostDate			
		,strContract								= CH.strContractNumber+ '-' + LTRIM(CD.intContractSeq)
		,strAllocationRefNo							= AllocationDetail.strAllocationDetailRefNo
		,strEntityName								= Entity.strEntityName
		,intQuantityUOMId							= InvoiceDetail.intOrderUOMId
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)		
		,intQuantityUnitMeasureId					= OrderUOM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		
		,dblWeight									= InvoiceDetail.dblShipmentNetWt
		,intWeightUOMId								= LoadDetail.intWeightItemUOMId 
		
		,strWeightUOM								= WUM.strUnitMeasure
		,intOriginId								= Item.intOriginId
		,strOrigin									= ISNULL(RY.strCountry, OG.strCountry)
		,strItemDescription							= Item.strDescription
		,strGrade									= CA2.strDescription
		,strCropYear								= CropYear.strCropYear
		,strProductionLine							= CPL.strDescription
		,strCertification							= NULL
		,strTerms									= ISNULL(CB.strContractBasis,'')+','+ISNULL(Term.strTerm,'')+','+ISNULL(WG.strWeightGradeDesc,'') 
		,strPosition								= PO.strPosition
		,dtmStartDate								= CD.dtmStartDate
		,dtmEndDate									= CD.dtmEndDate
		,strPriceTerms								= CASE 
															WHEN CD.intPricingTypeId =2 THEN 'Unfixed: '+Market.strFutMarketName+' '+FMonth.strFutureMonth
																									+' '+[dbo].[fnRemoveTrailingZeroes](CD.dblBasis)+' '+ BCY.strCurrency+' / '+BUOM.strUnitMeasure

															ELSE 'Fixed: '+Market.strFutMarketName+' '+FMonth.strFutureMonth+' '+[dbo].[fnRemoveTrailingZeroes](CD.dblFutures)
															+' '+ BCY.strCurrency+' / '+BUOM.strUnitMeasure+' '
															+[dbo].[fnRemoveTrailingZeroes](CD.dblFutures)+' '+ MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
													  END
		,strIncoTermLocation						= CB.strContractBasis + ISNULL(CASE WHEN CB.strINCOLocationType IN('City','Port') THEN CT.strCity+','+CO.strCountry ELSE SL.strSubLocationName END,'')
		,dblContractDifferential					= CD.dblBasis
		,strContractDifferentialUOM					= BCY.strCurrency+'/'+BUOM.strUnitMeasure
		,dblFuturesPrice							= CD.dblFutures
		,strFuturesPriceUOM							= MarketCY.strCurrency+'/'+MarketUOM.strUnitMeasure
		,dblCashPrice								= CD.dblCashPrice
		,intPriceUOMId								= CD.intPriceItemUOMId
		,intPriceUnitMeasureId						= PriceUOM.intUnitMeasureId
		,strContractPriceUOM						= PUOM.strUnitMeasure	
		,strFixationDetails							= NULL
		,dblFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL(PF.dblLotsFixed,0) ELSE 0 END
		,dblUnFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL((ISNULL(CD.[dblNoOfLots],0) -ISNULL(PF.dblLotsFixed,0)),0) ELSE 0 END
		,dblContractInvoiceValue					= InvoiceDetail.dblTotal
		,dblSecondaryCosts							= ISNULL((BillCost.dblTotal)*
													  (InvoiceDetail.dblQtyShipped
													  /dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,ItemUOM.intUnitMeasureId,ShipUOM.intUnitMeasureId,CD.dblQuantity)),0)
		,dblCOGSOrNetSaleValue						= NULL
		,intFutureMarketId							= CD.intFutureMarketId
		,strFutureMarket							= Market.strFutMarketName
		,intFutureMarketUOMId						= NULL
		,intFutureMarketUnitMeasureId				= Market.intUnitMeasureId
		,strFutureMarketUOM							= MarketUOM.strUnitMeasure
		,intMarketCurrencyId						= Market.intCurrencyId
		,intFutureMonthId							= FMonth.intFutureMonthId
		,strFutureMonth								= FMonth.strFutureMonth
		,dtmRealizedDate							= CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)	
		,dblRealizedQty								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)
		,dblRealizedPNLValue						= NULL
		,dblPNLPreDayValue							= NULL
		,dblProfitOrLossValue						= NULL
		,dblPNLChange								= NULL
		,strFixedBy									= CD.strFixationBy
		,strPricingType								= PT.strPricingType
		,strInvoiceStatus							= Invoice.strType
		,dblNetFuturesValue							= dbo.fnCTConvertQuantityToTargetItemUOM
																							(
																							 InvoiceDetail.intItemId
																							,ShipUOM.intUnitMeasureId
																							,Market.intUnitMeasureId
																							,InvoiceDetail.dblQtyShipped
																							)
													   * CD.dblFutures/(CASE WHEN MarketCY.ysnSubCurrency = 1 THEN MarketCY.intCent ELSE 1 END) 
		,dblRealizedFuturesPNLValue					= 0
		,dblNetPNLValue								= 0
		,dblFXValue									= NULL
		,dblFXConvertedValue						= InvoiceDetail.dblTotal * InvoiceDetail.dblCurrencyExchangeRate
		,strSalesReturnAdjustment					= NULL
		,intCompanyId								= Company.intMultiCompanyId
		,strCompany									= Company.strCompanyName	

		FROM tblARInvoiceDetail InvoiceDetail
		JOIN tblARInvoice Invoice					ON Invoice.intInvoiceId= InvoiceDetail.intInvoiceId AND Invoice.strType = 'Standard'
		JOIN tblLGLoadDetail LoadDetail			    ON LoadDetail.intLoadDetailId = InvoiceDetail.intLoadDetailId
		JOIN tblLGAllocationDetail AllocationDetail ON AllocationDetail.intAllocationDetailId = LoadDetail.intAllocationDetailId
		JOIN tblCTContractDetail	CD				ON CD.intContractDetailId = AllocationDetail.intSContractDetailId
		
		JOIN tblCTContractHeader				CH			     ON  CH.intContractHeaderId			 = CD.intContractHeaderId		
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
		LEFT JOIN tblICCommodityAttribute		CA1				 ON CA1.intCommodityAttributeId		 = Item.intProductTypeId
																 AND	CA1.strType						 = 'ProductType'
		LEFT JOIN tblICCommodityAttribute		CA2				 ON CA2.intCommodityAttributeId		 = Item.intGradeId
		AND	CA2.strType						 = 'Grade'
        LEFT JOIN 	tblSMCountry				OG				 ON	OG.intCountryID						=	CA.intCountryID
		LEFT JOIN tblARMarketZone				MZ				 ON MZ.intMarketZoneId				 = CD.intMarketZoneId
		LEFT JOIN tblCTPriceFixation			PF				 ON PF.intContractDetailId			 = CD.intContractDetailId
		LEFT JOIN tblCTBook						Book			 ON Book.intBookId					 = CD.intBookId
		LEFT JOIN tblCTSubBook					SubBook			 ON SubBook.intSubBookId			 = CD.intSubBookId
		LEFT JOIN tblCTBookVsEntity				BVE				 ON BVE.intBookId					 = Book.intBookId	AND BVE.intEntityId = CH.intEntityId
		LEFT JOIN tblCTCropYear					CropYear		 ON CropYear.intCropYearId			 = CH.intCropYearId		
		LEFT JOIN tblICCommodityProductLine		CPL				 ON	CPL.intCommodityProductLineId	 = Item.intProductLineId 
		LEFT JOIN tblSMCurrency					BCY				 ON	BCY.intCurrencyID				 = CD.intBasisCurrencyId
		LEFT JOIN tblICItemUOM					BASISUOM		 ON	BASISUOM.intItemUOMId			 = CD.intBasisUOMId
		LEFT JOIN tblICUnitMeasure				BUOM			 ON	BUOM.intUnitMeasureId			 = BASISUOM.intUnitMeasureId
		LEFT JOIN tblEMEntity					SP				 ON  SP.intEntityId					 = CH.intSalespersonId
		LEFT JOIN tblCTContractBasis			CB				 ON  CB.intContractBasisId			 = CH.intContractBasisId
		LEFT JOIN tblSMTerm						Term			 ON  Term.intTermID					 = CH.intTermId
		LEFT JOIN tblCTWeightGrade				WG				 ON  WG.intWeightGradeId			 = CH.intWeightId
		JOIN tblICItemUOM						ItemUOM			 ON ItemUOM.intItemUOMId		     = CD.intItemUOMId
		JOIN tblICItemUOM						WeightUOM		 ON WeightUOM.intItemUOMId		     = LoadDetail.intWeightItemUOMId		
		
		LEFT JOIN tblICUnitMeasure				WUM				 ON	WUM.intUnitMeasureId			 = WeightUOM.intUnitMeasureId
		LEFT JOIN tblICItemUOM					PriceUOM		 ON PriceUOM.intItemUOMId		     = CD.intPriceItemUOMId
		LEFT JOIN tblICUnitMeasure				PUOM			 ON	PUOM.intUnitMeasureId			 = PriceUOM.intUnitMeasureId
		LEFT JOIN	tblICItemContract			IC				 ON	IC.intItemContractId			 = CD.intItemContractId		
		LEFT JOIN	tblSMCountry				RY				 ON	RY.intCountryID					 = IC.intCountryId
		LEFT JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = CH.intCompanyId
		LEFT JOIN tblICItemUOM					ShipUOM			 ON ShipUOM.intItemUOMId		     = InvoiceDetail.intItemUOMId
		LEFT JOIN tblICItemUOM					OrderUOM		 ON OrderUOM.intItemUOMId		     = InvoiceDetail.intOrderUOMId
		LEFT JOIN tblICUnitMeasure				IUM				 ON	IUM.intUnitMeasureId			 = OrderUOM.intUnitMeasureId
		LEFT JOIN	tblSMCity					CT				 ON	CT.intCityId					=	CH.intINCOLocationTypeId	
		LEFT JOIN	tblSMCompanyLocationSubLocation		SL		 ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId
		LEFT JOIN	tblSMCountry				CO				 ON	CO.intCountryID					=	CT.intCountryId
		LEFT JOIN (SELECT  
					  BillDetail.intContractDetailId
					,SUM( BillDetail.dblTotal) dblTotal
					FROM tblAPBillDetail BillDetail
					JOIN tblICItem Item ON Item.intItemId = BillDetail.intItemId
					WHERE Item.strType='Other Charge'
					GROUP BY intContractDetailId
		          )BillCost ON BillCost.intContractDetailId = CD.intContractDetailId

		WHERE ISNULL(Book.intBookId,0) = CASE WHEN @inBookId > 0 THEN @inBookId ELSE  ISNULL(Book.intBookId,0) END
       )t
	   GROUP BY
	    intContractTypeId					
	   ,intContractDetailId				
	   ,intBookId							
	   ,strBook							
	   ,strSubBook						
	   ,intCommodityId					
	   ,strCommodity						
	   ,strProductType					
	   ,strRealizedType					
	   ,dtmContractDate					
	   ,strTransactionType				
	   ,dtmInvoicePostedDate				
	   ,strContract						
	   ,strAllocationRefNo				
	   ,strEntityName						
	   ,intQuantityUOMId					
	   ,strInternalCompany
	   ,intQuantityUnitMeasureId			
	   ,strQuantityUOM	   
	   ,intWeightUOMId
	   ,strWeightUOM						
	   ,intOriginId						
	   ,strOrigin							
	   ,strItemDescription				
	   ,strGrade							
	   ,strCropYear						
	   ,strProductionLine					
	   ,strCertification					
	   ,strTerms							
	   ,strPosition						
	   ,dtmStartDate						
	   ,dtmEndDate						
	   ,strPriceTerms						
	   ,strIncoTermLocation				
	   ,dblContractDifferential			
	   ,strContractDifferentialUOM		
	   ,dblFuturesPrice					
	   ,strFuturesPriceUOM				
	   ,dblCashPrice						
	   ,intPriceUOMId						
	   ,intPriceUnitMeasureId				
	   ,strContractPriceUOM				
	   ,strFixationDetails				
	   ,dblFixedLots						
	   ,dblUnFixedLots
	   ,dblSecondaryCosts			
	   ,dblCOGSOrNetSaleValue				
	   ,intFutureMarketId					
	   ,strFutureMarket					
	   ,intFutureMarketUOMId				
	   ,intFutureMarketUnitMeasureId		
	   ,strFutureMarketUOM				
	   ,intMarketCurrencyId				
	   ,intFutureMonthId					
	   ,strFutureMonth					
	   ,dtmRealizedDate	
	   ,dblRealizedPNLValue				
	   ,dblPNLPreDayValue					
	   ,dblProfitOrLossValue				
	   ,dblPNLChange						
	   ,strFixedBy						
	   ,strPricingType					
	   ,strInvoiceStatus
	   ,dblRealizedFuturesPNLValue		
	   ,dblNetPNLValue					
	   ,dblFXValue
	   ,strSalesReturnAdjustment			
	   ,intCompanyId						
	   ,strCompany						
		-----------------------------------------------------dblCOGSOrNetSaleValue Updation--------------------------------------------
		
		UPDATE @tblRealizedPNL SET dblCOGSOrNetSaleValue = (
															  ISNULL(dblContractInvoiceValue,0) 
															+ ISNULL(dblSecondaryCosts,0) * (CASE WHEN intContractTypeId = 1 THEN 1 ELSE -1 END)
															) *
														   CASE WHEN intContractTypeId =1 THEN 1 ELSE -1 END

		UPDATE  g 
		SET 
			--dblNetFuturesValue = (CASE WHEN t.intHedgedLots > t1.intHedgedLots THEN t1.intHedgedLots ELSE t.intHedgedLots END) 
			--					 * t.dblContractSize 
			--					 *CASE WHEN g.intContractTypeId=1 THEN t.dblWeightedValue ELSE t1.dblWeightedValue END

			--,
			dblFixedLots =     CASE WHEN t.intHedgedLots > t1.intHedgedLots THEN t1.intHedgedLots ELSE t.intHedgedLots END
		FROM @tblRealizedPNL g
		JOIN @tblRealizedPNL gp on gp.strAllocationRefNo = g.strAllocationRefNo AND gp.intContractTypeId = 1
		JOIN @tblRealizedPNL gs on gs.strAllocationRefNo = g.strAllocationRefNo AND gs.intContractTypeId = 2
		JOIN (
			SELECT Summary.intContractDetailId,Market.dblContractSize
				,SUM(Summary.intHedgedLots) intHedgedLots
				,(SUM(Summary.intHedgedLots*FutOpt.dblPrice)/SUM(Summary.intHedgedLots))
				/(CASE WHEN Currency.ysnSubCurrency = 1 THEN Currency.intCent ELSE 1 END
				* CASE WHEN FutOpt.strBuySell = 'Sell' THEN - 1 ELSE 1 END )  dblWeightedValue
				FROM tblRKAssignFuturesToContractSummary Summary
				JOIN tblRKFutOptTransaction FutOpt ON FutOpt.intFutOptTransactionId = Summary.intFutOptTransactionId
				JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = FutOpt.intFutureMarketId
				JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Market.intCurrencyId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = Summary.intContractDetailId
				GROUP BY Summary.intContractDetailId,Market.dblContractSize,ysnSubCurrency,Currency.intCent,FutOpt.strBuySell
		)t on t.intContractDetailId = gp.intContractDetailId
		JOIN (
			SELECT Summary.intContractDetailId,Market.dblContractSize
				,SUM(Summary.intHedgedLots) intHedgedLots
				,(SUM(Summary.intHedgedLots*FutOpt.dblPrice)/SUM(Summary.intHedgedLots))
				/(CASE WHEN Currency.ysnSubCurrency = 1 THEN Currency.intCent ELSE 1 END
				 * CASE WHEN FutOpt.strBuySell = 'Sell' THEN - 1 ELSE 1 END ) dblWeightedValue
				FROM tblRKAssignFuturesToContractSummary Summary
				JOIN tblRKFutOptTransaction FutOpt ON FutOpt.intFutOptTransactionId = Summary.intFutOptTransactionId
				JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = FutOpt.intFutureMarketId
				JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Market.intCurrencyId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = Summary.intContractDetailId
				GROUP BY Summary.intContractDetailId,Market.dblContractSize,ysnSubCurrency,Currency.intCent,FutOpt.strBuySell
		)t1 on t1.intContractDetailId = gs.intContractDetailId

			UPDATE tblRealized 
					SET  tblRealized.dblRealizedPNLValue = t.dblCOGSOrNetSaleValue * 
																					CASE 
																					  WHEN t.dblCOGSOrNetSaleValue > 0 THEN CASE WHEN intContractTypeId = 2 THEN  1  ELSE 0 END
																					  WHEN t.dblCOGSOrNetSaleValue <= 0 THEN CASE WHEN intContractTypeId = 1 THEN 1 ELSE 0 END
																					 END            
     
			FROM @tblRealizedPNL tblRealized
			JOIN (
					 SELECT 
					  strAllocationRefNo
					 ,SUM(dblCOGSOrNetSaleValue) * -1 dblCOGSOrNetSaleValue    
					 FROM  @tblRealizedPNL
					 GROUP BY strAllocationRefNo
				  )t ON t.strAllocationRefNo = tblRealized.strAllocationRefNo
											 
	
		UPDATE tblRealized 
		SET  tblRealized.dblRealizedFuturesPNLValue = (tblRealized.dblNetFuturesValue + t.dblNetFuturesValue) 
													 *
													 CASE 
														 WHEN (tblRealized.dblNetFuturesValue + t.dblNetFuturesValue) > 0  THEN CASE WHEN t.intContractTypeId = 1 THEN  1  ELSE 0 END
														 WHEN (tblRealized.dblNetFuturesValue + t.dblNetFuturesValue) <= 0 THEN CASE WHEN t.intContractTypeId = 2 THEN  1 ELSE 0 END
													 END
		FROM @tblRealizedPNL tblRealized
		JOIN (
				SELECT
				 intContractTypeId, 
				 strAllocationRefNo
				,SUM(dblNetFuturesValue) dblNetFuturesValue 
				FROM  @tblRealizedPNL
				GROUP BY 
				intContractTypeId,
				strAllocationRefNo
			 )t ON t.strAllocationRefNo = tblRealized.strAllocationRefNo AND  t.intContractTypeId <> tblRealized.intContractTypeId

		
		
		UPDATE tblRealized 
		SET  tblRealized.dblNetPNLValue = (t.dblRealizedPNLValue + t.dblRealizedFuturesPNLValue) * 
													CASE 
														 WHEN (t.dblRealizedPNLValue + t.dblRealizedFuturesPNLValue) > 0 THEN CASE WHEN intContractTypeId = 2 THEN  1  ELSE 0 END
														 WHEN (t.dblRealizedPNLValue + t.dblRealizedFuturesPNLValue) <= 0 THEN CASE WHEN intContractTypeId = 1 THEN 1 ELSE 0 END
													 END
		FROM @tblRealizedPNL tblRealized
		JOIN (
				SELECT 
				 strAllocationRefNo
				,SUM(dblRealizedPNLValue) dblRealizedPNLValue 
				,SUM(dblRealizedFuturesPNLValue) dblRealizedFuturesPNLValue 
				FROM  @tblRealizedPNL
				GROUP BY strAllocationRefNo
			 )t ON t.strAllocationRefNo = tblRealized.strAllocationRefNo	

		SELECT
		 intRealizedPNL                     
		,intContractTypeId					
		,intContractDetailId				
		,intBookId							
		,strBook							
		,strSubBook							
		,intCommodityId						
		,strCommodity						
		,strProductType						
		,strRealizedType					
		,dtmContractDate					
		,strTransactionType					
		,dtmInvoicePostedDate				
		,strContract						
		,strAllocationRefNo					
		,strEntityName						
		,strInternalCompany					
		,dblQuantity						
		,intQuantityUOMId					
		,intQuantityUnitMeasureId			
		,strQuantityUOM						
		,dblWeight							
		,intWeightUOMId						
		,strWeightUOM						
		,intOriginId						
		,strOrigin							
		,strItemDescription					
		,strGrade							
		,strCropYear						
		,strProductionLine					
		,strCertification					
		,strTerms							
		,strPosition						
		,dtmStartDate						
		,dtmEndDate							
		,strPriceTerms						
		,strIncoTermLocation				
		,dblContractDifferential			
		,strContractDifferentialUOM			
		,dblFuturesPrice					
		,strFuturesPriceUOM					
		,dblCashPrice						
		,intPriceUOMId						
		,intPriceUnitMeasureId				
		,strContractPriceUOM				
		,strFixationDetails					
		,dblFixedLots						
		,dblUnFixedLots						
		,dblContractInvoiceValue			
		,dblSecondaryCosts					
		,dblCOGSOrNetSaleValue				
		,intFutureMarketId					
		,strFutureMarket					
		,intFutureMarketUOMId				
		,intFutureMarketUnitMeasureId		
		,strFutureMarketUOM					
		,intMarketCurrencyId				
		,intFutureMonthId					
		,strFutureMonth						
		,dtmRealizedDate					
		,dblRealizedQty						
		,dblRealizedPNLValue				
		,dblPNLPreDayValue					
		,dblProfitOrLossValue				
		,dblPNLChange						
		,strFixedBy							
		,strPricingType						
		,strInvoiceStatus					
		,dblNetFuturesValue					
		,dblRealizedFuturesPNLValue			
		,dblNetPNLValue						
		,dblFXValue							
		,dblFXConvertedValue				
		,strSalesReturnAdjustment			
		,ISNULL(intCompanyId,@DefaultCompanyId) intCompanyId						
		,ISNULL(strCompany,@DefaultCompanyName)	strCompany						 
		FROM @tblRealizedPNL 
		ORDER BY strAllocationRefNo, intContractTypeId

					  
END TRY  
  
BEGIN CATCH  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    
END CATCH
		
		