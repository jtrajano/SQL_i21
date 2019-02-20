CREATE PROC uspRKSaveCurrencyExposure
	@intCommodityId int,
	@dtmFutureClosingDate datetime,
	@intCurrencyId int,
	@intCurrencyExposureId int
	,@dblAP numeric(24,10)
	,@dblAR numeric(24,10)
	,@dblMoneyMarket numeric(24,10)

	--select @intWeightUOMId=19,@intCompanyId=0,@intCommodityId =1,@dtmMarketPremium='2019-02-07 00:00:00',@dtmFutureClosingDate='2019-02-07 00:00:00',@intCurrencyId=3,@intCurrencyExposureId=9
AS

BEGIN TRY
DECLARE @ErrMsg nvarchar(Max)  

DECLARE @tblRKStock TABLE (
						intRowNum   int,
						dblMarketPrice numeric(24,10) ,                        
						dblValue   numeric(24,10) ,                             
						strContractNumber nvarchar(100) ,                                                               
						strLotNumber  nvarchar(100) ,                                     
						strName  nvarchar(100),                                            
						strItemNo  nvarchar(100),                                         
						strFutMarketName  nvarchar(100),              
						strSpotMonth  nvarchar(100) ,                                                                                                                                                                                                                                                   
						dblSettlementPrice numeric(24,10),               
						dblMarketPremium   numeric(24,10), 
						strMarketPremiumUOM  nvarchar(100),                                                                        
						strMarketPriceUOM  nvarchar(100),   
						dblQty  numeric(24,10) ,                                
						strCompanyName  nvarchar(100),                                                                                                                                       
						intConcurrencyId  int,
						intContractDetailId  int,
						intStorageLocationId  int,
						intMarketPremiumUOMId int,
						intMarketPriceCurrencyId int,
						intItemId int,
						intFutureMarketId int,
						intCompanyId int)

INSERT INTO @tblRKStock (intRowNum,   
						dblMarketPrice,                         
						dblValue,                               
						strContractNumber,          
						strLotNumber,                                      
						strName,                                           
						strItemNo,                                       
						strFutMarketName,            
						strSpotMonth,                                                                                                                                                                                                                                                
						dblSettlementPrice,                
						dblMarketPremium, 
						strMarketPremiumUOM ,                                                                
						strMarketPriceUOM ,                  
						dblQty,                             
						strCompanyName ,                                                                                                                                
						intConcurrencyId,
						intContractDetailId , 
						intStorageLocationId , 
						intMarketPremiumUOMId ,
						intMarketPriceCurrencyId,
						intItemId,
						intFutureMarketId,
						intCompanyId )
EXEC uspRKCurrencyExposureForStock
					 @intCommodityId =@intCommodityId
					, @dtmClosingPrice  = @dtmFutureClosingDate
					, @intCurrencyId =@intCurrencyId

DECLARE @tblRKBankBalance TABLE (
						intRowNum int,
						strCompanyName nvarchar(100)
						,strBankName nvarchar(100)
						,strBankAccountNo nvarchar(100)
						,strCurrency nvarchar(100)
						,strGLAccountId nvarchar(100)
						,strAccountType nvarchar(100)
						,dblAmount numeric(24,10)
						,intConcurrencyId int
						,intBankId int
						,intCurrencyId int
						,intCompanyId int
						,intBankAccountId int
						)

INSERT INTO @tblRKBankBalance (intRowNum,
						strCompanyName 
						,strBankName
						,strBankAccountNo
						,strCurrency
						,strGLAccountId 
						,strAccountType 
						,dblAmount
						,intConcurrencyId 
						,intBankId 
						,intCurrencyId 
						,intCompanyId
						,intBankAccountId) 

EXEC uspRKCurExpBankBalance

DECLARE @tblRKExposureForOTC TABLE (
						intRowNum int,
						strInternalTradeNo nvarchar(100)
						,dtmFilledDate datetime
						,strBuySell nvarchar(100)
						,intBankId int
						,strBankName nvarchar(100)
						,dtmMaturityDate datetime
						,intCurrencyExchangeRateTypeId int
						,strCurrencyExchangeRateType nvarchar(100)
						,dblContractAmount numeric(24,10)
						,dblExchangeRate numeric(24,10)
						,strExchangeFromCurrency  nvarchar(100)
						,dblMatchAmount numeric(24,10)
						,strMatchedFromCurrency  nvarchar(100)
						,strCompanyName  nvarchar(100)
						,intConcurrencyId int
						,intFutOptTransactionId int
						,intExchangeRateCurrencyId int
						,intAmountCurrencyId int
						,intCompanyId int
						)
						
INSERT INTO @tblRKExposureForOTC (	intRowNum ,
						strInternalTradeNo 
						,dtmFilledDate 
						,strBuySell  
						,intBankId 
						,strBankName 
						,dtmMaturityDate 
						,intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
						,dblContractAmount 
						,dblExchangeRate 
						,strExchangeFromCurrency 
						,dblMatchAmount 
						,strMatchedFromCurrency 
						,strCompanyName  
						,intConcurrencyId 
						,intFutOptTransactionId
						,intExchangeRateCurrencyId 
						,intAmountCurrencyId 
						,intCompanyId ) 

EXEC uspRKCurrencyExposureForOTC 		 @intCommodityId =@intCommodityId

DECLARE @tblRKExposureForNonOTC TABLE (
						  intRowNum int
						 ,strContractNumber nvarchar(100)
						 ,strName  nvarchar(100)                                                                                           
						 ,dblQuantity  numeric(24,10)                           
						 ,strUnitMeasure nvarchar(100)                                      
						 ,dblOrigPrice  numeric(24,10)                          
						 ,strOrigPriceUOM  nvarchar(100)                                                                           
						 ,dtmPeriod  nvarchar(100)             
						 ,strContractType nvarchar(100)						
						 ,strCompanyName  nvarchar(100)
						 ,intConcurrencyId int
						 ,intContractDetailId int
						 ,intEntityId int
						 ,intUnitMeasureId int
						 ,intCurrencyId int
						 ,intCompanyId int
						 ,dblPrice numeric(24,10)
						 ,dblUSDValue numeric(24,10)
						)

INSERT INTO @tblRKExposureForNonOTC (	intRowNum 
							,strContractNumber 
							,strName                                                                                       
							,dblQuantity                            
							,strUnitMeasure                                    
							,dblOrigPrice                         
							,strOrigPriceUOM                                                                             
							,dtmPeriod             
							,strContractType 
							,strCompanyName  
							,intConcurrencyId 
							,intContractDetailId 
							,intEntityId 
							,intUnitMeasureId 
							,intCurrencyId 
							,intCompanyId 
							,dblPrice							
							,dblUSDValue) 

EXEC uspRKCurExpForNonSelectedCurrency 	
					  @intCommodityId =@intCommodityId					
					, @dtmClosingPrice  = @dtmFutureClosingDate
					, @intCurrencyId =@intCurrencyId
					

DECLARE @tblRKExposureSummary TABLE (
						  intRowNum int
						 ,strSum nvarchar(100)
						 ,dblUSD  numeric(24,10)                                                                                             
						 ,intConcurrencyId  int   
						)

INSERT INTO @tblRKExposureSummary (	intRowNum 
							,strSum 
							,dblUSD                                                                                       
							,intConcurrencyId                            
							) 
EXEC uspRKCurrencyExposureSummary 	
					 @intCommodityId =@intCommodityId
					, @dtmFutureClosingDate  = @dtmFutureClosingDate
					, @intCurrencyId =@intCurrencyId
					, @dblAP = @dblAP
					, @dblAR = @dblAR
					, @dblMoneyMarket = @dblMoneyMarket

BEGIN TRANSACTION    

INSERT INTO tblRKCurExpStock (intConcurrencyId,
								intCurrencyExposureId,
								intContractDetailId,
								strLotNumber,
								intStorageLocationId,
								intItemId,
								intFutureMarketId,
								strSpotMonth,
								dblClosingPrice,
								dblMarketPremium,
								intMarketPremiumUOMId,
								dblMarketPrice,
								intMarketPriceUOMId,
								dblQuantity,
								dblValue,
								intCompanyId)
SELECT 1,
		@intCurrencyExposureId,
		intContractDetailId,
		strLotNumber,
		intStorageLocationId,
		intItemId,
		intFutureMarketId,
		strSpotMonth,
		dblSettlementPrice,
		dblMarketPremium,
		intMarketPremiumUOMId,
		dblMarketPrice,
		intMarketPriceCurrencyId,
		dblQty,
		isnull(dblValue,0.0),
		intCompanyId FROM @tblRKStock


INSERT INTO tblRKCurExpBankBalance(intConcurrencyId,intCurrencyExposureId,intBankId,intBankAccountId,dblAmount,intCurrencyId,intCompanyId)			
SELECT 1,@intCurrencyExposureId,intBankId,intBankAccountId,dblAmount,intCurrencyId,intCompanyId from @tblRKBankBalance 

insert into tblRKCurExpCurrencyContract(intConcurrencyId,
intCurrencyExposureId,
intFutOptTransactionId,
dtmDate,
strBuySell,
intBankId,
dtmMaturityDate,
strCurrencyPair,
dblAmount,
intAmountCurrencyId,
dblExchangeRate,
intExchangeRateCurrencyId,
dblBalanceAmount,
intBalanceAmountCurrencyId,
intCompanyId)
SELECT 1,@intCurrencyExposureId,
		intFutOptTransactionId,
		dtmFilledDate,
		strBuySell,
		intBankId,
		dtmMaturityDate,
		strCurrencyExchangeRateType,
		dblContractAmount,
		intAmountCurrencyId,
		dblExchangeRate,
		intExchangeRateCurrencyId,
		dblMatchAmount,
		intAmountCurrencyId,
		intCompanyId 
FROM @tblRKExposureForOTC

insert into tblRKCurExpNonOpenSales(intConcurrencyId,
intCurrencyExposureId,
intCustomerId,
dblQuantity,
intQuantityUOMId,
dblOrigPrice,
intOrigPriceUOMId,
intOrigPriceCurrencyId,
dblPrice,
strPeriod,
strContractType,
dblValueUSD,
intCompanyId,intContractDetailId)
SELECT 1,@intCurrencyExposureId,intEntityId,
dblQuantity,
intUnitMeasureId,
dblOrigPrice,
intUnitMeasureId,
intCurrencyId,
dblPrice,
dtmPeriod,
strContractType,
dblUSDValue,
intCompanyId,intContractDetailId from @tblRKExposureForNonOTC

insert into tblRKCurExpSummary(intConcurrencyId,
intCurrencyExposureId,
strTotalSum,
dblUSD)
SELECT 1,@intCurrencyExposureId,strSum,dblUSD FROM @tblRKExposureSummary 
					
COMMIT TRAN    
    
END TRY      
      
BEGIN CATCH  
   
 SET @ErrMsg = ERROR_MESSAGE()  
 IF XACT_STATE() != 0 ROLLBACK TRANSACTION   
 If @ErrMsg != ''   
 BEGIN  
  RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
 END  
   
END CATCH  