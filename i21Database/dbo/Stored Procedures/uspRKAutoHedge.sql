CREATE PROC uspRKAutoHedge
   @XML nvarchar(MAX),
   @intFutOptTransactionId INT OUTPUT               
AS          
BEGIN   Try       
 DECLARE @dtmTransactionDate datetime,
            @intEntityId int,
            @intBrokerageAccountId int,
            @intFutureMarketId int,
            @intFutureMonthId int,
            @intInstrumentTypeId int,
            @intCommodityId int,
            @intLocationId int,
            @intTraderId int,
            @strInternalTradeNo nvarchar(10),
            @strBrokerTradeNo nvarchar(50),
            @strBuySell nvarchar(10),
            @intNoOfContract int,
            @dblPrice int,
            @strStatus nvarchar(50),
            @dtmFilledDate datetime,
            @strReserveForFix nvarchar(50),
            @intBookId int,
            @intSubBookId int,
            @ysnOffset bit,
            @intFutOptTransactionHeaderId int,
            @ErrMsg nvarchar(max),
            @intCurrencyId INT
    


INSERT INTO tblRKFutOptTransactionHeader  Values(1)
SELECT @intFutOptTransactionHeaderId = SCOPE_IDENTITY() 
DECLARE @idoc int
EXEC sp_xml_preparedocument @idoc OUTPUT, @XML          
      
SELECT  
        @intFutOptTransactionId = intFutOptTransactionId,
      @dtmTransactionDate =    dtmTransactionDate ,
      @intEntityId =     intEntityId ,
      @intBrokerageAccountId = intBrokerageAccountId ,
      @intFutureMarketId =     intFutureMarketId ,
      @intFutureMonthId =      intFutureMonthId ,
      @intInstrumentTypeId =   intInstrumentTypeId ,
      @intCommodityId =  intCommodityId ,
      @intLocationId =   intLocationId ,
      @intTraderId =     intTraderId ,
      @strInternalTradeNo = strInternalTradeNo ,
      @strBrokerTradeNo =      strBrokerTradeNo ,
      @strBuySell =      strBuySell ,
      @intNoOfContract = intNoOfContract, 
      @dblPrice =  dblPrice ,
      @strStatus = strStatus ,
      @dtmFilledDate =   dtmFilledDate ,
      @strReserveForFix =      strReserveForFix ,
      @intBookId = intBookId ,
      @intSubBookId =    intSubBookId ,
      @ysnOffset = ysnOffset ,
      @intCurrencyId = intCurrencyId

FROM OPENXML(@idoc,'root',2)          
WITH(
intFutOptTransactionId INT,
dtmTransactionDate datetime,
intEntityId int,
intBrokerageAccountId int,
intFutureMarketId int,
intFutureMonthId int,
intInstrumentTypeId int,
intCommodityId int,
intLocationId int,
intTraderId int,
strInternalTradeNo nvarchar(10),
strBrokerTradeNo nvarchar(50),
strBuySell nvarchar(10),
intNoOfContract int,
dblPrice int,
strStatus nvarchar(50),
dtmFilledDate datetime,
strReserveForFix nvarchar(50),
intBookId int,
intSubBookId int,
ysnOffset bit,
intCurrencyId INT,
CurrentDate datetime
)      
IF ISNULL(@intFutOptTransactionId,0) > 0
BEGIN
      UPDATE tblRKFutOptTransaction
      SET 
      
      intEntityId =     @intEntityId ,
      intBrokerageAccountId = @intBrokerageAccountId ,
      intFutureMarketId =     @intFutureMarketId ,
      intFutureMonthId =      @intFutureMonthId ,
      intNoOfContract = @intNoOfContract, 
      dblPrice =  @dblPrice 
      WHERE intFutOptTransactionId = @intFutOptTransactionId
END
ELSE
BEGIN
      IF ISNULL(@strInternalTradeNo,'') = ''
      BEGIN
            SELECT @strInternalTradeNo = strPrefix + LTRIM(intNumber) FROM tblSMStartingNumber WHERE strTransactionType = 'FutOpt Transaction'
            UPDATE tblSMStartingNumber SET intNumber = intNumber + 1 WHERE strTransactionType = 'FutOpt Transaction'
      END

      INSERT INTO tblRKFutOptTransaction(dtmTransactionDate ,
              intFutOptTransactionHeaderId,
              intEntityId ,
              intBrokerageAccountId ,
              intFutureMarketId ,
              intFutureMonthId ,
              intInstrumentTypeId ,
              intCommodityId ,
              intLocationId ,
              intTraderId ,
              strInternalTradeNo ,
              strBrokerTradeNo ,
              strBuySell ,
              intNoOfContract ,
              dblPrice ,
              strStatus ,
              dtmFilledDate ,
              strReserveForFix ,
              intBookId ,
              intSubBookId ,
              ysnOffset,
              intCurrencyId,
              intConcurrencyId 
               )    
            VALUES(@dtmTransactionDate ,
            @intFutOptTransactionHeaderId,
              @intEntityId ,
              @intBrokerageAccountId ,
              @intFutureMarketId ,
              @intFutureMonthId ,
              @intInstrumentTypeId ,
              @intCommodityId ,
              @intLocationId ,
              @intTraderId ,
              @strInternalTradeNo ,
              @strBrokerTradeNo ,
              @strBuySell ,
              @intNoOfContract ,
              @dblPrice ,
              @strStatus ,
              @dtmFilledDate ,
              @strReserveForFix ,
              @intBookId ,
              @intSubBookId ,
              @ysnOffset  ,
              @intCurrencyId,
              1
      )          

      SET @intFutOptTransactionId = SCOPE_IDENTITY()
END
  
END TRY    
    
BEGIN CATCH    
 SET @ErrMsg = ERROR_MESSAGE()    
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
END CATCH    



