CREATE FUNCTION dbo.fnRKGetInitialMargin (
	 @intFutOptTransactionId INT
	,@ClosingDate DATE
	,@dtmTradeDate DATE
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN

	DECLARE @result AS NUMERIC(18, 6)
	
	set @ClosingDate= CONVERT(NVARCHAR, @ClosingDate, 111)
	set @dtmTradeDate= CONVERT(NVARCHAR, @dtmTradeDate, 111)
	
	IF (@dtmTradeDate = @ClosingDate)
	BEGIN		
		SELECT @result= case when isnull(dblPerFutureContract,0)>0 then dblPerFutureContract*intNoOfContract else 
		
					CASE WHEN dblContractMargin <= dblMinAmount THEN dblMinAmount
							 WHEN dblContractMargin >= dblMaxAmount THEN dblMaxAmount
							 ELSE dblContractMargin END end
		FROM(
		SELECT dblMinAmount,dblMaxAmount,dblPercenatage,
		((intNoOfContract*isnull(dblPrice,0)*dblContractSize)*dblPercenatage)/100 as dblContractMargin,
		dblPerFutureContract,intNoOfContract
		FROM tblRKFutOptTransaction ft
		JOIN tblRKFutureMarket fm on ft.intFutureMarketId=fm.intFutureMarketId
		JOIN tblRKBrokerageAccount ba on ba.intBrokerageAccountId=ft.intBrokerageAccountId
		JOIN tblRKBrokerageCommission bc on bc.intBrokerageAccountId= ba.intBrokerageAccountId and bc.intFutureMarketId=ft.intFutureMarketId
		WHERE intFutOptTransactionId = @intFutOptTransactionId)t
	END
	ELSE
	BEGIN
		SET @result = 0
	END

	RETURN -(abs(@result))
END