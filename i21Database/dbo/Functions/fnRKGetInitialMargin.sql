CREATE FUNCTION dbo.fnRKGetInitialMargin (
	 @intFutOptTransactionId INT
	)
RETURNS NUMERIC(18, 6)
AS
BEGIN

	DECLARE @result AS NUMERIC(18, 6)
		
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


	RETURN -(abs(isnull(@result,0)))
END