CREATE FUNCTION [dbo].[fnCTGetBrokerageCommission]
(
	@intBrokerageAccountId	INT,
	@intFutureMarketId		INT,
	@dtmTransactionDate		DATETIME
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@dblFutCommission AS NUMERIC(18,6)

	SELECT	TOP 1 @dblFutCommission = dblFutCommission 
	FROM	tblRKBrokerageCommission	BC
	WHERE	BC.intBrokerageAccountId	=	@intBrokerageAccountId 
	AND		BC.intFutureMarketId		=	@intFutureMarketId
	AND		@dtmTransactionDate		BETWEEN BC.dtmEffectiveDate AND BC.dtmEndDate

	RETURN @dblFutCommission;	
END