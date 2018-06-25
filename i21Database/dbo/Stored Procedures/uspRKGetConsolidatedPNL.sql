CREATE PROCEDURE [dbo].[uspRKGetConsolidatedPNL]
	@strType NVARCHAR(20)
AS
BEGIN TRY

		DECLARE @ErrMsg NVARCHAR(MAX)

		DECLARE @tblGLSaleCogs AS TABLE
		(
		   intCompanyId			INT
		  ,strCompany			NVARCHAR(200) COLLATE Latin1_General_CI_AS
		  ,intBookId			INT
		  ,strBook				NVARCHAR(200) COLLATE Latin1_General_CI_AS
		  ,dblSaleAmount		NUMERIC(38,20)
		  ,dblCogs				NUMERIC(38,20)  
		)

		 DECLARE @tblConsolidatedPNL AS TABLE 
		(
			 intConsolidatedPNL INT IDENTITY(1, 1)
			,strPNL				NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strType			NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,intBookId			INT
			,strBook			NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,intCompanyId		INT
			,strCompany			NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strPurchaseSale	NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblBookValue		NUMERIC(38,20)
			,dblMarketValue		NUMERIC(38,20)
			,dblAmount			NUMERIC(38,20)
			,strBookValue		NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strMarketValue		NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strTotalAmount		NVARCHAR(200) COLLATE Latin1_General_CI_AS
		)
		
		DECLARE @tblUnRealizedPNL AS TABLE 
		 (
			 intUnRealizedPNL                       INT
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
			,intBookId								INT
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
			,dblQuantity							NUMERIC(38,20)
			,intQuantityUOMId						INT							
			,intQuantityUnitMeasureId				INT							
			,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblWeight								NUMERIC(38,20)
			,intWeightUOMId							INT							
			,intWeightUnitMeasureId					INT							
			,strWeightUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblBasis								NUMERIC(38,20)
			,intBasisUOMId							INT							
			,intBasisUnitMeasureId					INT							
			,strBasisUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblFutures								NUMERIC(38,20)
			,dblCashPrice							NUMERIC(38,20)
			,intPriceUOMId							INT							
			,intPriceUnitMeasureId					INT							
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
			,dblContractDifferential				NUMERIC(38,20)
			,strContractDifferentialUOM				NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblFuturesPrice						NUMERIC(38,20)
			,strFuturesPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,strFixationDetails						NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblFixedLots							NUMERIC(38,20)
			,dblUnFixedLots							NUMERIC(38,20)
			,dblContractInvoiceValue				NUMERIC(38,20)
			,dblSecondaryCosts						NUMERIC(38,20)
			,dblCOGSOrNetSaleValue					NUMERIC(38,20)
			,dblInvoicePrice						NUMERIC(38,20)
			,dblInvoicePaymentPrice					NUMERIC(38,20)
			,strInvoicePriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblInvoiceValue						NUMERIC(38,20)
			,strInvoiceCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblNetMarketValue						NUMERIC(38,20)
			,dtmRealizedDate						DATETIME
			,dblRealizedQty							NUMERIC(38,20)
			,dblProfitOrLossValue					NUMERIC(38,20)
			,dblPAndLinMarketUOM					NUMERIC(38,20)
			,dblPAndLChangeinMarketUOM				NUMERIC(38,20)
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
			,dblMarketDifferential					NUMERIC(38,20)
			,dblNetM2MPrice							NUMERIC(38,20)
			,dblSettlementPrice						NUMERIC(38,20)
			,intCompanyId							INT
			,strCompanyName							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		)
		 
	  DECLARE @tblRealizedPNL AS TABLE 
	  (
		 intRealizedPNL                         INT
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
			,intCompanyId	
			,strCompany				
		)
		EXEC uspRKGetRealizedPNL 0,1

		INSERT INTO @tblUnRealizedPNL
		(
			 intUnRealizedPNL                   
			,strType							
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
			,intBookId							
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
			,dblMarketDifferential				
			,dblNetM2MPrice						
			,dblSettlementPrice
			,intCompanyId					
			,strCompanyName		
		)
		 EXEC uspRKGetUnRealizedPNL 
		 @intFutureSettlementPriceId = NULL
		,@intCurrencyUOMId			 = NULL
		,@intCommodityId			 = NULL
		,@intLocationId				 = NULL
		,@intCompanyId				 = NULL
		,@intM2MBasisId				 = NULL

		UPDATE t SET t.intBookId = Book.intBookId ,t.strBook = Book.strBook
		FROM @tblUnRealizedPNL t
		LEFT JOIN tblCTBookVsEntity BVS ON BVS.intMultiCompanyId = t.intCompanyId
		LEFT JOIN tblCTBook Book ON  Book.intBookId =  BVS.intBookId
		WHERE t.intBookId IS NULL
		
		
		
		INSERT INTO @tblGLSaleCogs
		(
			 intCompanyId
			,strCompany
			,intBookId
			,strBook	
			,dblSaleAmount
			,dblCogs		
		)
		SELECT   intCompanyId  = Invoice.intCompanyId
				,strCompany   = Company.strCompanyName
				,intBookId    = Book.intBookId
				,strBook	  = Book.strBook
			    ,dblSaleAmount = SUM(Sales.dblSaleAmount)
			    ,dblCogs       = SUM(Cogs.dblCogs)
		FROM tblARInvoice Invoice
		JOIN(
			   SELECT 
			   GLDetail.strBatchId
			  ,GLDetail.dblCredit AS dblSaleAmount	 
			   FROM tblGLDetail GLDetail
			   JOIN vyuGLAccountDetail AccountDetail ON AccountDetail.intAccountId = GLDetail.intAccountId AND AccountDetail.strAccountCategory = 'Sales Account'
			 )Sales ON Sales.strBatchId = Invoice.strBatchId
	    
		JOIN(
			   SELECT 
			    GLDetail.strBatchId
			   ,GLDetail.dblDebit AS dblCogs	 
				FROM tblGLDetail GLDetail
				JOIN vyuGLAccountDetail AccountDetail ON AccountDetail.intAccountId = GLDetail.intAccountId AND AccountDetail.strAccountCategory = 'Cost of Goods'
			 )Cogs ON Cogs.strBatchId = Invoice.strBatchId

		JOIN tblCTBookVsEntity BVS ON BVS.intMultiCompanyId = Invoice.intCompanyId
		JOIN tblCTBook Book ON  Book.intBookId =  BVS.intBookId
		JOIN tblSMMultiCompany				Company			 ON Company.intMultiCompanyId		 = Invoice.intCompanyId
		WHERE ISNULL(Invoice.ysnPosted, 0) = 1
		GROUP BY Invoice.intCompanyId,Company.strCompanyName,Book.intBookId,Book.strBook

		
	
			INSERT INTO @tblConsolidatedPNL 
			(
				 strPNL
				,strType		
				,intBookId		
				,strBook
				,intCompanyId	
				,strCompany		
				,strPurchaseSale
				,dblBookValue	
				,dblMarketValue	
				,dblAmount
				,strBookValue	
				,strMarketValue
				,strTotalAmount
			)

			SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'COGS'
				,dblBookValue	 = 0
				,dblMarketValue	 = 0
				,dblAmount       =  - SUM(dblCOGSOrNetSaleValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblRealizedPNL 
				WHERE intContractTypeId  = 1
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany
			UNION     
			SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Sales'
				,dblBookValue	 = 0
				,dblMarketValue	 = 0
				,dblAmount       = -SUM(dblCOGSOrNetSaleValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblRealizedPNL 
				WHERE intContractTypeId  = 2
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany
		UNION
		 SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Purchase'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 1 
				AND intTransactionType = 1
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
			
		UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Sale'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 2
				AND intTransactionType = 1
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
		UNION
		 SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'In-transit(P)'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 1 
				AND intTransactionType = 2
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
			
		UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'In-transit(S)'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 2
				AND intTransactionType = 2
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
        UNION
		 SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'In-transit(P)'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 1 
				AND intTransactionType = 2
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
			
		UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Inventory (P)'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intTransactionType = 3
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName	
        UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Inventory (FG)'
				,dblBookValue	 = SUM(dblCOGSOrNetSaleValue)
				,dblMarketValue	 = SUM(dblNetMarketValue)
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intTransactionType = 4
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
		UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook			
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'COGS'
				,dblBookValue	 = 0
				,dblMarketValue	 = 0
				,dblAmount       = -SUM(dblCogs)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblGLSaleCogs 
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany
			
		UNION
		SELECT 
				 strPNL			 = 'P&L'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Sales'
				,dblBookValue	 = 0
				,dblMarketValue	 = 0
				,dblAmount       = SUM(dblSaleAmount)
				,strBookValue	 = 'TotalBookvalue'
				,strMarketValue  = 'TotalMarketValue'
				,strTotalAmount  = 'Total'
				FROM @tblGLSaleCogs 
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany		
	
		IF @strType ='- All -'
				
				SELECT 
				 intConsolidatedPNL			= intConsolidatedPNL 
				,strPNL						= strPNL				
				,strType					= strType			
				,intBookId					= intBookId			
				,strBook					= strBook			
				,intCompanyId				= intCompanyId		
				,strCompany					= strCompany			
				,strPurchaseSale			= strPurchaseSale	
				,dblBookValue				= CAST(dblBookValue AS NUMERIC(38,10))	
				,dblMarketValue				= CAST(dblMarketValue AS NUMERIC(38,10))		
				,dblAmount					= CAST(dblAmount AS NUMERIC(38,10))			
				,strBookValue				= strBookValue		
				,strMarketValue				= strMarketValue		
				,strTotalAmount		 		= strTotalAmount		
				FROM @tblConsolidatedPNL
					 
		ELSE 
				
				SELECT 
				 intConsolidatedPNL			= intConsolidatedPNL 
				,strPNL						= strPNL				
				,strType					= strType			
				,intBookId					= intBookId			
				,strBook					= strBook			
				,intCompanyId				= intCompanyId		
				,strCompany					= strCompany			
				,strPurchaseSale			= strPurchaseSale	
				,dblBookValue				= CAST(dblBookValue AS NUMERIC(38,10))	
				,dblMarketValue				= CAST(dblMarketValue AS NUMERIC(38,10))		
				,dblAmount					= CAST(dblAmount AS NUMERIC(38,10))			
				,strBookValue				= strBookValue		
				,strMarketValue				= strMarketValue		
				,strTotalAmount		 		= strTotalAmount		
				FROM @tblConsolidatedPNL 
				WHERE strType = @strType  
	

END TRY  
  
BEGIN CATCH  
 
 
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    

END CATCH
