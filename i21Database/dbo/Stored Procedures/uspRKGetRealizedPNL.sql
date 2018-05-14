CREATE PROCEDURE [dbo].[uspRKGetRealizedPNL]
	 @inBookId		   INT	
	,@intCurrencyId    INT 
	
AS
BEGIN TRY

DECLARE @ErrMsg NVARCHAR(MAX)


	 DECLARE @tblRealizedPNL AS TABLE 
	 (
		 intRealizedPNL                         INT IDENTITY(1,1)
		,intContractTypeId						INT
		,intContractDetailId					INT		
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
		,dblQuantity							NUMERIC(24, 10)
		,intQuantityUOMId						INT							---ItemUOM
		,intQuantityUnitMeasureId				INT							---UnitMeasure
		,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblWeight								NUMERIC(24, 10)
		,intWeightUOMId							INT							---ItemUOM		
		,strWeightUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intOriginId							INT
		,strOrigin								NVARCHAR(100)
		,strItemDescription						NVARCHAR(100)
		,strCropYear							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strProductionLine						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCertification						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strTerms								NVARCHAR(200) COLLATE Latin1_General_CI_AS	
		,strPosition							NVARCHAR(100)
		,dtmStartDate							DATETIME
		,dtmEndDate								DATETIME
		,strPriceTerms							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strIncoTermLocation					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblContractDifferential				NUMERIC(24, 10)
		,strContractDifferentialUOM				NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFuturesPrice						NUMERIC(24, 10)
		,strFuturesPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice							NUMERIC(24, 10)
		,intPriceUOMId							INT							---ItemUOM
		,intPriceUnitMeasureId					INT							---UnitMeasure
		,strContractPriceUOM					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strFixationDetails						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblFixedLots							NUMERIC(24, 10)
		,dblUnFixedLots							NUMERIC(24, 10)
		,dblContractInvoiceValue				NUMERIC(24, 10)
		,dblSecondaryCosts						NUMERIC(24, 10)
		,dblCOGSOrNetSaleValue					NUMERIC(24, 10)
		,intFutureMarketId						INT
		,strFutureMarket						NVARCHAR(100)
		,intFutureMarketUOMId					INT
		,intFutureMarketUnitMeasureId			INT
		,strFutureMarketUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intMarketCurrencyId					INT
		,intFutureMonthId						INT
		,strFutureMonth							NVARCHAR(100)
		,dtmRealizedDate						DATETIME
		,dblRealizedQty							NUMERIC(24, 10)
		,dblRealizedPNLValue					NUMERIC(24, 10)
		,dblPNLPreDayValue						NUMERIC(24, 10)
		,dblProfitOrLossValue					NUMERIC(24, 10)
		,dblPNLChange							NUMERIC(24, 10)
		,strFixedBy								NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingType							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strInvoiceStatus						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblNetFuturesValue					    NUMERIC(24, 10)
		,dblRealizedFuturesPNLValue			    NUMERIC(24, 10)
		,dblNetPNLValue						    NUMERIC(24, 10)
		,dblFXValue							    NUMERIC(24, 10)
		,dblFXConvertedValue				    NUMERIC(24, 10)
		,strSalesReturnAdjustment				NVARCHAR(200) COLLATE Latin1_General_CI_AS
	    )  

		INSERT INTO @tblRealizedPNL
		(
			 intContractTypeId
			,intContractDetailId
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
		)
		 SELECT
		 intContractTypeId							= CH.intContractTypeId 
		,intContractDetailId						= CD.intContractDetailId
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
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)
		,intQuantityUOMId							= InvoiceDetail.intOrderUOMId
		,intQuantityUnitMeasureId					= OrderUOM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		
		,dblWeight									= InvoiceDetail.dblShipmentNetWt
		,intWeightUOMId								= LoadDetail.intWeightItemUOMId 
		
		,strWeightUOM								= WUM.strUnitMeasure
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
		,strPriceTerms								= NULL
		,strIncoTermLocation						= CASE WHEN CB.strINCOLocationType IN('City','Port') THEN CT.strCity+','+CO.strCountry ELSE SL.strSubLocationName END
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
		,dblUnFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL((CD.[dblNoOfLots] -PF.dblLotsFixed),0) ELSE 0 END
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
		,dtmRealizedDate							= Invoice.dtmPostDate	
		,dblRealizedQty								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)
		,dblRealizedPNLValue						= NULL
		,dblPNLPreDayValue							= NULL
		,dblProfitOrLossValue						= NULL
		,dblPNLChange								= NULL
		,strFixedBy									= CD.strFixationBy
		,strPricingType								= PT.strPricingType
		,strInvoiceStatus							= NULL
		,dblNetFuturesValue							= NetFutures.dblTotalNetFutures
		,dblRealizedFuturesPNLValue					= NULL
		,dblNetPNLValue								= NULL
		,dblFXValue									= NULL
		,dblFXConvertedValue						= NULL
		,strSalesReturnAdjustment					= NULL	

		FROM tblARInvoiceDetail InvoiceDetail
		JOIN tblARInvoice Invoice					ON Invoice.intInvoiceId= InvoiceDetail.intInvoiceId
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
		JOIN tblCTPricingType					PT				 ON PT.intPricingTypeId				 = CD.intPricingTypeId
		LEFT JOIN tblCTPosition					PO				 ON PO.intPositionId				 = CH.intPositionId
		LEFT JOIN tblICCommodityAttribute		CA				 ON CA.intCommodityAttributeId		 = Item.intOriginId
																	AND	CA.strType						 = 'Origin'
		LEFT JOIN tblICCommodityAttribute		CA1				 ON CA1.intCommodityAttributeId		 = Item.intProductTypeId
		AND	CA1.strType						 = 'ProductType'
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
		LEFT JOIN tblICItemUOM					BillUOM		 ON BillUOM.intItemUOMId		     = BillDetail.intUnitOfMeasureId
		LEFT JOIN	tblSMCity					CT				 ON	CT.intCityId					=	CH.intINCOLocationTypeId	
		LEFT JOIN	tblSMCompanyLocationSubLocation		SL		 ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId
		LEFT JOIN	tblSMCountry				CO				 ON	CO.intCountryID					=	CT.intCountryId
		LEFT JOIN (SELECT  
					 intContractDetailId 
					,intItemId
					,SUM(dblTotal) dblTotal
					FROM tblAPBillDetail 
					GROUP BY intContractDetailId,intItemId
		          )BillCost ON BillCost.intContractDetailId = CD.intContractDetailId 
				AND   BillCost.intItemId     <> CD.intItemId
		LEFT JOIN
		(
			SELECT Summary.intContractDetailId
			,SUM((
					Summary.intHedgedLots * Market.dblContractSize * FutOpt.dblPrice / CASE 
						WHEN Currency.ysnSubCurrency = 1
							THEN Currency.intCent
						ELSE 1
						END
					) * (
					CASE 
						WHEN FutOpt.strBuySell = 'Sell'
							THEN - 1
						ELSE 1
						END
					)) AS dblTotalNetFutures
		FROM tblRKAssignFuturesToContractSummary Summary
		JOIN tblRKFutOptTransaction FutOpt ON FutOpt.intFutOptTransactionId = Summary.intFutOptTransactionId
		JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = FutOpt.intFutureMarketId
		JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Market.intCurrencyId
		GROUP BY Summary.intContractDetailId
		) NetFutures ON NetFutures.intContractDetailId = CD.intContractDetailId
	
	UNION
	
		 SELECT 
		  intContractTypeId							= CH.intContractTypeId 
		,intContractDetailId						= CD.intContractDetailId
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
		,strInternalCompany							= CASE WHEN ISNULL(BVE.intEntityId,0) >0 THEN 'Y' ELSE 'N' END
		,dblQuantity								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)
		,intQuantityUOMId							= InvoiceDetail.intOrderUOMId
		,intQuantityUnitMeasureId					= OrderUOM.intUnitMeasureId
		,strQuantityUOM								= IUM.strUnitMeasure
		
		,dblWeight									= InvoiceDetail.dblShipmentNetWt
		,intWeightUOMId								= LoadDetail.intWeightItemUOMId 
		
		,strWeightUOM								= WUM.strUnitMeasure
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
		,strPriceTerms								= NULL
		,strIncoTermLocation						= CASE WHEN CB.strINCOLocationType IN('City','Port') THEN CT.strCity+','+CO.strCountry ELSE SL.strSubLocationName END
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
		,dblUnFixedLots								= CASE WHEN CH.intPricingTypeId =2 THEN ISNULL((CD.[dblNoOfLots] -PF.dblLotsFixed),0) ELSE 0 END
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
		,dtmRealizedDate							= Invoice.dtmPostDate	
		,dblRealizedQty								= dbo.fnCTConvertQuantityToTargetItemUOM(InvoiceDetail.intItemId,ShipUOM.intUnitMeasureId,OrderUOM.intUnitMeasureId,InvoiceDetail.dblQtyShipped)
		,dblRealizedPNLValue						= NULL
		,dblPNLPreDayValue							= NULL
		,dblProfitOrLossValue						= NULL
		,dblPNLChange								= NULL
		,strFixedBy									= CD.strFixationBy
		,strPricingType								= PT.strPricingType
		,strInvoiceStatus							= NULL
		,dblNetFuturesValue							= NetFutures.dblTotalNetFutures
		,dblRealizedFuturesPNLValue					= NULL
		,dblNetPNLValue								= NULL
		,dblFXValue									= NULL
		,dblFXConvertedValue						= NULL
		,strSalesReturnAdjustment					= NULL	

		FROM tblARInvoiceDetail InvoiceDetail
		JOIN tblARInvoice Invoice					ON Invoice.intInvoiceId= InvoiceDetail.intInvoiceId
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
					 intContractDetailId 
					,intItemId
					,SUM(dblTotal) dblTotal
					FROM tblAPBillDetail 
					GROUP BY intContractDetailId,intItemId
		          )BillCost ON BillCost.intContractDetailId = CD.intContractDetailId 
				AND   BillCost.intItemId     <> CD.intItemId
		LEFT JOIN
		(
			SELECT Summary.intContractDetailId
			,SUM((
					Summary.intHedgedLots * Market.dblContractSize * FutOpt.dblPrice / CASE 
						WHEN Currency.ysnSubCurrency = 1
							THEN Currency.intCent
						ELSE 1
						END
					) * (
					CASE 
						WHEN FutOpt.strBuySell = 'Sell'
							THEN - 1
						ELSE 1
						END
					)) AS dblTotalNetFutures
		FROM tblRKAssignFuturesToContractSummary Summary
		JOIN tblRKFutOptTransaction FutOpt ON FutOpt.intFutOptTransactionId = Summary.intFutOptTransactionId
		JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = FutOpt.intFutureMarketId
		JOIN tblSMCurrency Currency ON Currency.intCurrencyID = Market.intCurrencyId
		GROUP BY Summary.intContractDetailId
		) NetFutures ON NetFutures.intContractDetailId = CD.intContractDetailId

		-----------------------------------------------------dblCOGSOrNetSaleValue Updation--------------------------------------------
		
		UPDATE @tblRealizedPNL SET dblCOGSOrNetSaleValue = (ISNULL(dblContractInvoiceValue,0) + ISNULL(dblCOGSOrNetSaleValue,0) + ISNULL(dblNetFuturesValue,0)) *
														   CASE WHEN intContractTypeId =1 THEN 1 ELSE -1 END

		UPDATE tblRealized 
		SET tblRealized.dblRealizedPNLValue = - t.dblCOGSOrNetSaleValue
		FROM @tblRealizedPNL tblRealized
		JOIN (
				SELECT 
				strAllocationRefNo
				,SUM(dblCOGSOrNetSaleValue) dblCOGSOrNetSaleValue 
				FROM  @tblRealizedPNL
				GROUP BY strAllocationRefNo
			 )t ON t.strAllocationRefNo = tblRealized.strAllocationRefNo

		SELECT strAllocationRefNo,dblCOGSOrNetSaleValue,dblRealizedPNLValue,* FROM @tblRealizedPNL --order by strAllocationRefNo, intContractTypeId

					  
END TRY  
  
BEGIN CATCH  
 
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    

END CATCH
		
		