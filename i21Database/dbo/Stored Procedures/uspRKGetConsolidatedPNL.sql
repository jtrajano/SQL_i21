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
		  ,strBook			NVARCHAR(200) COLLATE Latin1_General_CI_AS
		  ,dblSaleAmount    NUMERIC(24,10)
		  ,dblCogs			NUMERIC(24,10)  
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
			,dblAmount			NUMERIC(24, 10)
			,dblPNL				NUMERIC(24, 10)
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
			,dblQuantity							NUMERIC(24, 10)
			,intQuantityUOMId						INT							
			,intQuantityUnitMeasureId				INT							
			,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblWeight								NUMERIC(24, 10)
			,intWeightUOMId							INT							
			,intWeightUnitMeasureId					INT							
			,strWeightUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblBasis								NUMERIC(24, 10)
			,intBasisUOMId							INT							
			,intBasisUnitMeasureId					INT							
			,strBasisUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
			,dblFutures								NUMERIC(24, 10)
			,dblCashPrice							NUMERIC(24, 10)
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
			,dblNetM2MPrice							NUMERIC(24, 10)
			,dblSettlementPrice						NUMERIC(24, 10)
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
		,dblQuantity							NUMERIC(24, 10)
		,intQuantityUOMId						INT							
		,intQuantityUnitMeasureId				INT							
		,strQuantityUOM							NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblWeight								NUMERIC(24, 10)
		,intWeightUOMId							INT							
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
		,intPriceUOMId							INT							
		,intPriceUnitMeasureId					INT							
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
		SELECT  intCompanyId  = Invoice.intCompanyId
				,strCompany   = Company.strCompanyName
				,intBookId    = Book.intBookId
				,strBook	  = Book.strBook
			   ,dblSaleAmount = SUM(
									CASE 
										WHEN AccountCategory.strAccountCategory = 'Sales Account' THEN dblCredit
										ELSE 0
									END
								   )

			  ,dblCogs        = SUM(
									 CASE 
											WHEN AccountCategory.strAccountCategory = 'Cost of Goods' THEN dblDebit
											ELSE 0
									 END
									)
		FROM tblARInvoice Invoice
		JOIN tblGLDetail GLDetail ON GLDetail.strBatchId = Invoice.strBatchId
		JOIN tblGLAccount Account ON Account.intAccountId = GLDetail.intAccountId
		JOIN tblGLAccountGroup AccountGroup ON AccountGroup.intAccountCategoryId = Account.intAccountGroupId
		JOIN tblGLAccountCategory AccountCategory ON AccountCategory.intAccountCategoryId = AccountGroup.intAccountCategoryId
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
				,dblAmount
				,strTotalAmount
			)

			SELECT 
				 strPNL			 = 'PNL'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Purchase'
				,dblAmount       = SUM(dblNetPNLValue)
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
				 strPNL			 = 'PNL'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Sale'
				,dblAmount       = SUM(dblNetPNLValue)
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
				 strPNL			 = 'PNL'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook				
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Purchase'
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 1
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName
			
		UNION
		SELECT 
				 strPNL			 = 'PNL'
				,strType		 = 'Unrealized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompanyName
				,strPurchaseSale = 'Sale'
				,dblAmount       = SUM(dblProfitOrLossValue)
				,strTotalAmount  = 'Total'
				FROM @tblUnRealizedPNL 
				WHERE intContractTypeId  = 2
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompanyName	
		UNION
		SELECT 
				 strPNL			 = 'PNL'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook			
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Purchase'
				,dblAmount       = SUM(dblCogs)
				,strTotalAmount  = 'Total'
				FROM @tblGLSaleCogs 
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany
			
		UNION
		SELECT 
				 strPNL			 = 'PNL'
				,strType		 = 'Realized'
				,intBookId		 = intBookId
				,strBook		 = strBook
				,intCompanyId	 = intCompanyId
				,strCompany		 = strCompany
				,strPurchaseSale = 'Sale'
				,dblAmount       = SUM(dblSaleAmount)
				,strTotalAmount  = 'Total'
				FROM @tblGLSaleCogs 
				GROUP BY 
				 intBookId
				,strBook
				,intCompanyId
				,strCompany		
	
		IF @strType ='- All -'
				SELECT * FROM @tblConsolidatedPNL
		ELSE 
				SELECT * FROM @tblConsolidatedPNL WHERE strType = @strType  
	

END TRY  
  
BEGIN CATCH  
 
 
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')    

END CATCH
