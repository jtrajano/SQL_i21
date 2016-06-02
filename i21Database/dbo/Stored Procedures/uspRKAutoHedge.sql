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
            @dblPrice numeric(18,6),
            @strStatus nvarchar(50),
            @dtmFilledDate datetime,
            @strReserveForFix nvarchar(50),
            @intBookId int,
            @intSubBookId int,
            @ysnOffset bit,
            @intFutOptTransactionHeaderId int,
            @ErrMsg nvarchar(max),
            @intCurrencyId INT,
			@intContractHeaderId INT,
			@intContractDetailId INT,
			@strXml  nvarchar(max),
			@intMatchedLots INT,
			@ysnMultiplePriceFixation BIT,
			@strXmlNew  nvarchar(max),
			@dblNoOfLots numeric(18,6),
			@intSelectedInstrumentTypeId INT
    


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
      @intCurrencyId = intCurrencyId,
	  @intContractHeaderId = intContractHeaderId,
	  @intContractDetailId = intContractDetailId,
	  @intSelectedInstrumentTypeId = intSelectedInstrumentTypeId

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
dblPrice NUMERIC(18,6),
strStatus nvarchar(50),
dtmFilledDate datetime,
strReserveForFix nvarchar(50),
intBookId int,
intSubBookId int,
ysnOffset bit,
intCurrencyId INT,
CurrentDate datetime,
intContractHeaderId INT,
intContractDetailId INT,
intSelectedInstrumentTypeId INT
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

	  SELECT @intMatchedLots = SUM(intLots) FROM tblRKOptionsPnSExercisedAssigned WHERE intFutOptTransactionId = @intFutOptTransactionId

	  IF @intMatchedLots < @intNoOfContract
	  BEGIN
		RAISERROR('Cannot change number of hedged lots as it is used in Match Futures Purchase and sales.',16,1)
	  END

	IF ISNULL(@intContractDetailId,0) > 0
		UPDATE tblRKAssignFuturesToContractSummary SET intHedgedLots = @intNoOfContract WHERE intContractDetailId = @intContractDetailId AND intFutOptTransactionId = @intFutOptTransactionId
	ELSE
		UPDATE tblRKAssignFuturesToContractSummary SET intHedgedLots = @intNoOfContract WHERE intContractHeaderId = @intContractHeaderId AND intFutOptTransactionId = @intFutOptTransactionId
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
              intConcurrencyId ,
			  intSelectedInstrumentTypeId
               )    
            VALUES(CONVERT(DATETIME,CONVERT(CHAR(10),@dtmTransactionDate,110)) ,
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
              CONVERT(DATETIME,CONVERT(CHAR(10),@dtmFilledDate,110)),
              @strReserveForFix ,
              @intBookId ,
              @intSubBookId ,
              @ysnOffset  ,
              @intCurrencyId,
              1,
			  @intSelectedInstrumentTypeId
      )          

      SET @intFutOptTransactionId = SCOPE_IDENTITY()

		SET @strXml = '<root><Transaction>';
		SET @strXml = @strXml + '<intContractHeaderId>' + LTRIM(@intContractHeaderId) + '</intContractHeaderId>'
		SET @strXml = @strXml + '<intContractDetailId>#ID#</intContractDetailId>'
		SET @strXml = @strXml + '<dtmMatchDate>' + LTRIM(GETDATE()) + '</dtmMatchDate>'
		SET @strXml = @strXml + '<intFutOptTransactionId>' + LTRIM(@intFutOptTransactionId) + '</intFutOptTransactionId>'
		SET @strXml = @strXml + '<intHedgedLots>#LOT#</intHedgedLots>'
		SET @strXml = @strXml + '<dblAssignedLots>0</dblAssignedLots>'
		SET @strXml = @strXml + '<ysnIsHedged>1</ysnIsHedged>'
		SET @strXml = @strXml + '</Transaction></root>'

	  SELECT @ysnMultiplePriceFixation = ysnMultiplePriceFixation FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId

	  IF @ysnMultiplePriceFixation = 1 
	  BEGIN
		
		SELECT  @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId

		WHILE ISNULL(@intContractDetailId,0) > 0
		BEGIN
			SELECT @dblNoOfLots = dblNoOfLots FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
			SET @strXmlNew = REPLACE(@strXml,'#ID#',LTRIM(@intContractDetailId))
			SET @strXmlNew = REPLACE(@strXmlNew,'#LOT#',LTRIM(@dblNoOfLots))
			EXEC uspRKAssignFuturesToContractSummarySave @strXmlNew

			SELECT  @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
		END
	  END
	  ELSE
	  BEGIN
			SET @strXmlNew = REPLACE(@strXml,'#ID#',LTRIM(@intContractDetailId))
			SET @strXmlNew = REPLACE(@strXmlNew,'#LOT#',LTRIM(@intNoOfContract))
			EXEC uspRKAssignFuturesToContractSummarySave @strXmlNew
	  END
END
  
END TRY    
    
BEGIN CATCH    
 SET @ErrMsg = ERROR_MESSAGE()    
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')    
END CATCH    