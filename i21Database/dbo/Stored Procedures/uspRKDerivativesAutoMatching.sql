CREATE PROCEDURE uspRKDerivativesAutoMatching
      @strCondition nvarchar(50) 
	, @dtmFromFilledDate DATE
	, @dtmToFilledDate DATE
	, @dtmMatchDate DATE
	, @intUserId INT
  
AS  

--declare @strCondition nvarchar(50) = 'Between'
--, @dtmFromFilledDate DATE = '03-01-2022'
--, @dtmToFilledDate DATE = '03-02-2022'
--, @dtmMatchDate DATE = GETDATE()
--, @intUserId INT  = 1


DECLARE @tempOpenDerivativesForAutoMatching AS TABLE(
	dblBalanceLot NUMERIC(18,6)
	,dblBalanceLotRoll NUMERIC(18,6)
	,dblSelectedLot NUMERIC(18,6)
	,intSelectedInstrumentTypeId INT
	,intInstrumentTypeId INT
	,strTransactionNo NVARCHAR(100)
	,dtmTransactionDate DATETIME
	,dblTotalLot NUMERIC(18,6)
	,dblSelectedLot1 NUMERIC(18,6)
	,dblSelectedLotRoll NUMERIC(18,6)
	,dblOptionsMatchedLot NUMERIC(18,6)
	,strBS NVARCHAR(1)
	,strBuySell NVARCHAR(10)
	,dblPrice NUMERIC(18,6)
	,dtmCreateDateTime DATETIME
	,strBook NVARCHAR(100)
	,strSubBook NVARCHAR(100)
	,intFutureMarketId INT
	,intBrokerageAccountId INT
	,intLocationId INT
	,intFutureMonthId INT
	,intCommodityId INT
	,intEntityId INT
	,intBookId INT
	,intSubBookId INT
	,intFutOptTransactionId INT
	,dblContractSize NUMERIC(18,6)
	,dblFutCommission NUMERIC(18,6)
	,intBrokerageCommissionId INT
	,dtmFilledDate DATETIME
	,intFutOptTransactionHeaderId INT
	,intCurrencyId INT
	,strCurrency NVARCHAR(40)
	,intMainCurrencyId INT
	,strMainCurrency NVARCHAR(40)
	,intCent INT
	,ysnSubCurrency BIT
	,intBankId INT
	,intBankAccountId INT
	,intCurrencyExchangeRateTypeId INT
	,strBrokerTradeNo NVARCHAR(50)
	,strFutureMonth NVARCHAR(20)
	,strOptionType NVARCHAR(20)
	,dblStrike NUMERIC(18,6)
)

DECLARE @tempMatchDerivativeHeader AS TABLE (
	intMatchNo INT
	,dtmMatchDate DATETIME
	,intCompanyLocationId INT
	,intCommodityId INT
	,intFutureMarketId INT
	,intFutureMonthId INT
	,intEntityId INT
	,intBrokerageAccountId INT
	,intBookId INT
	,intSubBookId INT
	,intSelectedInstrumentTypeId INT
	,strType NVARCHAR(10)
	,strMatchingType NVARCHAR(10)
	--,intCurrencyExchangeRateTypeId INT
	--,intBankId INT
	--,intBankAccountId INT
	--,ysnPosted BIT
	--,intCompanyId INT
	--,strRollNo NVARCHAR(50)

)

DECLARE @tempMatchDerivativesDetail AS TABLE (
	dblMatchQty NUMERIC(18,6)
	,dblFutCommission NUMERIC(18,6)
	,intLFutOptTransactionId INT
	,intSFutOptTransactionId INT
	,dtmMatchedDate DATETIME
	,intLFutOptTransactionHeaderId INT
	,intSFutOptTransactionHeaderId INT

)



DECLARE @tempResult AS TABLE (
	Result NVARCHAR(MAX),
	SortId INT
)

--Get Open Derivatives based on filter criteria
IF @strCondition = 'Between'
BEGIN
	INSERT INTO @tempOpenDerivativesForAutoMatching 
	SELECT * FROM vyuRKOpenDerivativesForAutoMatching WHERE dtmFilledDate BETWEEN @dtmFromFilledDate AND @dtmToFilledDate
END
ELSE IF @strCondition = 'Equals'
BEGIN
	INSERT INTO @tempOpenDerivativesForAutoMatching 
	SELECT * FROM vyuRKOpenDerivativesForAutoMatching WHERE dtmFilledDate = @dtmFromFilledDate
END
ELSE IF @strCondition = 'Not Equal To'
BEGIN
	INSERT INTO @tempOpenDerivativesForAutoMatching 
	SELECT * FROM vyuRKOpenDerivativesForAutoMatching WHERE dtmFilledDate <> @dtmFromFilledDate
END
ELSE IF @strCondition = 'Before'
BEGIN
	INSERT INTO @tempOpenDerivativesForAutoMatching 
	SELECT * FROM vyuRKOpenDerivativesForAutoMatching WHERE dtmFilledDate < @dtmFromFilledDate
END
ELSE IF @strCondition = 'After'
BEGIN
	INSERT INTO @tempOpenDerivativesForAutoMatching 
	SELECT * FROM vyuRKOpenDerivativesForAutoMatching WHERE dtmFilledDate > @dtmFromFilledDate
END



DECLARE @intCommodityId INT
		,@intCompanyLocationId INT
		,@intFutureMarketId INT
		,@intSelectedInstrumentTypeId INT = 1 --Exchange Traded

--Get the availale Market
SELECT DISTINCT intFutureMarketId INTO #tempMarkets FROM @tempOpenDerivativesForAutoMatching

--Loop thru markets
WHILE EXISTS (SELECT TOP 1 * FROM #tempMarkets)
BEGIN
	SELECT @intFutureMarketId = intFutureMarketId FROM #tempMarkets ORDER BY intFutureMarketId DESC


	--Get the availale commodity
	SELECT DISTINCT intCommodityId INTO #tempCommodities FROM @tempOpenDerivativesForAutoMatching WHERE intFutureMarketId = @intFutureMarketId

	--Loop thru commodities
	WHILE EXISTS (SELECT TOP 1 * FROM #tempCommodities)
	BEGIN
		SELECT @intCommodityId = intCommodityId FROM #tempCommodities ORDER BY intCommodityId DESC

	
		--Get the availale locations
		SELECT DISTINCT intLocationId INTO #tempLocations FROM @tempOpenDerivativesForAutoMatching WHERE intFutureMarketId = @intFutureMarketId and intCommodityId = @intCommodityId

		--Loop thru locations
		WHILE EXISTS (SELECT TOP 1 * FROM #tempLocations)
		BEGIN
			SELECT @intCompanyLocationId = intLocationId FROM #tempLocations ORDER BY intLocationId DESC

	

			--Separate Buy and Sell
			SELECT * INTO #tempBuy FROM @tempOpenDerivativesForAutoMatching WHERE strBuySell = 'Buy' AND intCommodityId = @intCommodityId AND intFutureMarketId = @intFutureMarketId AND intLocationId = @intCompanyLocationId
			SELECT * INTO #tempSell FROM @tempOpenDerivativesForAutoMatching WHERE strBuySell = 'Sell' AND intCommodityId = @intCommodityId AND intFutureMarketId = @intFutureMarketId AND intLocationId = @intCompanyLocationId

			
			--Broker 
			SELECT DISTINCT intEntityId INTO #tempBroker FROM #tempBuy 
			DECLARE @intBrokerageId INT

			WHILE EXISTS(SELECT TOP 1 * FROM #tempBroker)
			BEGIN
				SELECT @intBrokerageId = intEntityId FROM #tempBroker ORDER BY intEntityId DESC

			

				--Broker Account
				SELECT DISTINCT intBrokerageAccountId INTO #tempBrokerAccounts FROM #tempBuy WHERE intEntityId = @intBrokerageId
				DECLARE @intBrokerageAccountId INT

			
				WHILE EXISTS(SELECT TOP 1 * FROM #tempBrokerAccounts)
				BEGIN
					SELECT @intBrokerageAccountId = intBrokerageAccountId FROM #tempBrokerAccounts ORDER BY intBrokerageAccountId DESC


					--Month
					SELECT DISTINCT intFutureMonthId INTO #tempMonths FROM #tempBuy WHERE intBrokerageAccountId = @intBrokerageAccountId AND intEntityId = @intBrokerageId
					DECLARE @intFutureMonthId INT

					WHILE EXISTS(SELECT TOP 1 * FROM #tempMonths)
					BEGIN
						SELECT @intFutureMonthId = intFutureMonthId FROM #tempMonths ORDER BY intFutureMonthId DESC

						--Both Exists for Futures
						IF EXISTS (SELECT * FROM #tempBuy WHERE intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 1)
							AND EXISTS (SELECT * FROM #tempSell WHERE  intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 1)
						BEGIN
				
							--Get Buy and Sell ready for matching
							SELECT strTransactionNo, dtmFilledDate, strBuySell, dblBalanceLot, strFutureMonth, dblPrice, intFutOptTransactionId, intFutOptTransactionHeaderId, dblFutCommission 
							INTO #tempBuyForMatching
							FROM #tempBuy WHERE intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 1
							ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC


							SELECT strTransactionNo, dtmFilledDate, strBuySell, dblBalanceLot, strFutureMonth, dblPrice, intFutOptTransactionId, intFutOptTransactionHeaderId ,dblFutCommission
							INTO #tempSellForMatching
							FROM #tempSell WHERE intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 1
							ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC

							--SELECT * FROM #tempBuyForMatching
							--SELECT * FROM #tempSellForMatching


							DECLARE @dblBuyLot NUMERIC(18,6)
									,@dblSellLot NUMERIC(18,6)
									,@intLFutOptTranactionId INT
									,@intSFutOptTranactionId INT
									,@intLFutOptTranactionHeaderId INT
									,@intSFutOptTranactionHeaderId INT
									,@dblFutCommission NUMERIC(18,6)

							--Loop thru Buys
							WHILE EXISTS(SELECT TOP 1 * FROM #tempBuyForMatching)
							BEGIN
								SELECT TOP 1 
									@dblBuyLot = dblBalanceLot
									,@intLFutOptTranactionId = intFutOptTransactionId
									,@intLFutOptTranactionHeaderId = intFutOptTransactionHeaderId
									,@dblFutCommission = dblFutCommission
								FROM #tempBuyForMatching
								ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC

					
								--Loop thru Sells
								WHILE EXISTS(SELECT TOP 1 * FROM #tempSellForMatching)
								BEGIN

									IF @dblBuyLot < 1
									BEGIN
										BREAK
									END

									SELECT TOP 1 
										@dblSellLot = dblBalanceLot
										,@intSFutOptTranactionId = intFutOptTransactionId
										,@intSFutOptTranactionHeaderId = intFutOptTransactionHeaderId
									FROM #tempSellForMatching 
									ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC

									IF @dblSellLot < 1
									BEGIN
										BREAK
									END

									IF @dblBuyLot <= @dblSellLot
									BEGIN
										INSERT INTO @tempMatchDerivativesDetail(
											dblMatchQty
											,dblFutCommission
											,intLFutOptTransactionId
											,intSFutOptTransactionId
											,dtmMatchedDate
											,intLFutOptTransactionHeaderId
											, intSFutOptTransactionHeaderId)
										SELECT 
											@dblBuyLot
											,dblFutCommission = @dblFutCommission * @dblBuyLot
											,@intLFutOptTranactionId
											,@intSFutOptTranactionId
											,@dtmMatchDate
											,@intLFutOptTranactionHeaderId
											,@intSFutOptTranactionHeaderId
							
										UPDATE #tempSellForMatching SET dblBalanceLot = dblBalanceLot - @dblBuyLot WHERE intFutOptTransactionId = @intSFutOptTranactionId

										BREAK
									END

									IF @dblBuyLot > @dblSellLot
									BEGIN

										INSERT INTO @tempMatchDerivativesDetail(
											dblMatchQty
											,dblFutCommission
											,intLFutOptTransactionId
											,intSFutOptTransactionId
											,dtmMatchedDate
											,intLFutOptTransactionHeaderId
											, intSFutOptTransactionHeaderId)
										SELECT 
											@dblSellLot
											,dblFutCommission = @dblFutCommission * @dblSellLot
											,@intLFutOptTranactionId
											,@intSFutOptTranactionId
											,@dtmMatchDate
											,@intLFutOptTranactionHeaderId
											,@intSFutOptTranactionHeaderId
							
										SET @dblBuyLot = @dblBuyLot - @dblSellLot

									END

									DELETE FROM #tempSellForMatching WHERE intFutOptTransactionId = @intSFutOptTranactionId
								END

								DELETE FROM #tempBuyForMatching WHERE intFutOptTransactionId = @intLFutOptTranactionId

						

						
							END

							--========================================================
							--			Create Match Derivatives for Futures
							--========================================================

							DECLARE @intMatchNo INT
							DECLARE @intMatchFuturesPSHeaderId INT

							
							SELECT @intMatchNo = intNumber FROM tblSMStartingNumber WHERE intStartingNumberId = 44
							SET @intMatchNo = @intMatchNo + 1

							--Create the Match Derivatives Header
							INSERT INTO @tempMatchDerivativeHeader(
								intMatchNo 
								,dtmMatchDate 
								,intCompanyLocationId 
								,intCommodityId 
								,intFutureMarketId 
								,intFutureMonthId 
								,intEntityId 
								,intBrokerageAccountId 
								,intBookId 
								,intSubBookId 
								,intSelectedInstrumentTypeId 
								,strType
								,strMatchingType
							)
							SELECT
								@intMatchNo
								,@dtmMatchDate
								,@intCompanyLocationId
								,@intCommodityId
								,@intFutureMarketId
								,@intFutureMonthId 
								,intEntityId = @intBrokerageId
								,@intBrokerageAccountId 
								,intBookId = NULL
								,intSubBookId = NULL
								,@intSelectedInstrumentTypeId
								,strType = 'Realize'
								,strMatchingType = 'Auto'

							
							INSERT INTO tblRKMatchFuturesPSHeader(
								intMatchNo 
								,dtmMatchDate 
								,intCompanyLocationId 
								,intCommodityId 
								,intFutureMarketId 
								,intFutureMonthId 
								,intEntityId 
								,intBrokerageAccountId 
								,intBookId 
								,intSubBookId 
								,intSelectedInstrumentTypeId 
								,strType
								,strMatchingType
								,intConcurrencyId
								
							)
							SELECT intMatchNo 
								,dtmMatchDate 
								,intCompanyLocationId 
								,intCommodityId 
								,intFutureMarketId 
								,intFutureMonthId 
								,intEntityId 
								,intBrokerageAccountId 
								,intBookId 
								,intSubBookId 
								,intSelectedInstrumentTypeId 
								,strType
								,strMatchingType
								,intConcurrencyId = 1
							FROM @tempMatchDerivativeHeader

							
							SET @intMatchFuturesPSHeaderId = SCOPE_IDENTITY()


							INSERT INTO tblRKMatchFuturesPSDetail(
								intMatchFuturesPSHeaderId
								,dblMatchQty
								,dblFutCommission
								,intLFutOptTransactionId
								,intSFutOptTransactionId
								,dtmMatchedDate
								,intLFutOptTransactionHeaderId
								,intSFutOptTransactionHeaderId
								,intConcurrencyId
							) 
							SELECT @intMatchFuturesPSHeaderId
								,dblMatchQty
								,dblFutCommission
								,intLFutOptTransactionId
								,intSFutOptTransactionId
								,dtmMatchedDate
								,intLFutOptTransactionHeaderId
								,intSFutOptTransactionHeaderId
								,intConcurrencyId = 1
							FROM @tempMatchDerivativesDetail


							UPDATE tblSMStartingNumber SET intNumber  = @intMatchNo WHERE intStartingNumberId = 44

							--Insert to Audit Log
							EXEC uspSMAuditLog 
							   @keyValue = @intMatchFuturesPSHeaderId       -- Primary Key Value of the Match Derivatives. 
							   ,@screenName = 'RiskManagement.view.MatchDerivatives'        -- Screen Namespace
							   ,@entityId = @intUserId     -- Entity Id.
							   ,@actionType = 'Created'       -- Action Type
							   ,@changeDescription = ''     -- Description
							   ,@fromValue = ''          -- Previous Value
							   ,@toValue = ''           -- New Value

							--Insert to History Log
							EXEC uspRKMatchDerivativesHistoryInsert  @intMatchFuturesPSHeaderId, 'ADD', @intUserId

							--Insert to DPR Summary Log
							EXEC uspRKSaveMatchDerivative @intMatchFuturesPSHeaderId, @intUserId


							INSERT INTO @tempResult
							SELECT 'Auto-Matching of Futures created Match Number ' + CAST(@intMatchNo AS NVARCHAR(50)), 1
							
							--For debugging
							--SELECT * FROM @tempMatchDerivativeHeader
							--SELECT * FROM @tempMatchDerivativesDetail

							DELETE FROM @tempMatchDerivativesDetail
							DELETE FROM @tempMatchDerivativeHeader


					
							DROP TABLE #tempBuyForMatching
							DROP TABLE #tempSellForMatching


						END

		
						--Both Exists for Options
						IF EXISTS (SELECT * FROM #tempBuy WHERE intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2)
							AND EXISTS (SELECT * FROM #tempSell WHERE  intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2)
						BEGIN
				
							SELECT DISTINCT strOptionType INTO #tempOptionType FROM #tempBuy WHERE intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2
							DECLARE @strOptionType NVARCHAR(20)

							--Loop thru Option Type
							WHILE EXISTS(SELECT TOP 1 * FROM #tempOptionType)
							BEGIN
								SELECT TOP 1 @strOptionType = strOptionType FROM #tempOptionType


								SELECT DISTINCT dblStrike INTO #tempStrike FROM #tempBuy
								WHERE intEntityId = @intBrokerageId AND intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2 AND strOptionType = @strOptionType
								DECLARE @dblStrike NUMERIC(18,6)

								--Loop thru Strike
								WHILE EXISTS(SELECT TOP 1 * FROM #tempStrike)
								BEGIN
									SELECT TOP 1 @dblStrike = dblStrike FROM #tempStrike

									--Get Buy and Sell ready for matching options
									SELECT strTransactionNo, dtmFilledDate, strBuySell, dblBalanceLot, strFutureMonth, dblPrice, intFutOptTransactionId, intFutOptTransactionHeaderId 
									INTO #tempBuyForMatchingOptions
									FROM #tempBuy 
									WHERE intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2 AND strOptionType = @strOptionType AND dblStrike = @dblStrike
									ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC


									SELECT strTransactionNo, dtmFilledDate, strBuySell, dblBalanceLot, strFutureMonth, dblPrice, intFutOptTransactionId, intFutOptTransactionHeaderId 
									INTO #tempSellForMatchingOptions
									FROM #tempSell 
									WHERE intBrokerageAccountId = @intBrokerageAccountId AND intFutureMonthId = @intFutureMonthId AND intInstrumentTypeId = 2 AND strOptionType = @strOptionType AND dblStrike = @dblStrike
									ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC


									IF EXISTS (SELECT * FROM #tempBuyForMatchingOptions) AND EXISTS (SELECT * FROM #tempSellForMatchingOptions)
									BEGIN

										DECLARE @dblBuyLotOptions NUMERIC(18,6)
												,@dblSellLotOptions NUMERIC(18,6)
												,@intLFutOptTranactionIdOptions INT
												,@intSFutOptTranactionIdOptions INT

										--Loop thru Buys
										WHILE EXISTS(SELECT TOP 1 * FROM #tempBuyForMatchingOptions)
										BEGIN
											SELECT TOP 1 
												@dblBuyLotOptions  = dblBalanceLot
												,@intLFutOptTranactionIdOptions  = intFutOptTransactionId
											FROM #tempBuyForMatchingOptions
											ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC

					
											--Loop thru Sells
											WHILE EXISTS(SELECT TOP 1 * FROM #tempSellForMatchingOptions)
											BEGIN

												SELECT TOP 1 
													@dblSellLotOptions  = dblBalanceLot
													,@intSFutOptTranactionIdOptions = intFutOptTransactionId
												FROM #tempSellForMatchingOptions 
												ORDER BY dtmFilledDate ASC, dblPrice ASC, strTransactionNo ASC

												IF @dblBuyLotOptions  <= @dblSellLotOptions 
												BEGIN
													INSERT INTO @tempMatchDerivativesDetail(
														dblMatchQty
														,intLFutOptTransactionId
														,intSFutOptTransactionId
														,dtmMatchedDate)
													SELECT 
														@dblBuyLotOptions 
														,@intLFutOptTranactionIdOptions 
														,@intSFutOptTranactionIdOptions 
														,@dtmMatchDate
							
													UPDATE #tempSellForMatchingOptions SET dblBalanceLot = dblBalanceLot - @dblBuyLotOptions  WHERE intFutOptTransactionId = @intSFutOptTranactionIdOptions 

													BREAK
												END

												IF @dblBuyLotOptions  > @dblSellLotOptions 
												BEGIN

													INSERT INTO @tempMatchDerivativesDetail(
														dblMatchQty
														,intLFutOptTransactionId
														,intSFutOptTransactionId
														,dtmMatchedDate)
													SELECT 
														@dblSellLotOptions 
														,@intLFutOptTranactionIdOptions 
														,@intSFutOptTranactionIdOptions 
														,@dtmMatchDate
							
													SET @dblBuyLotOptions  = @dblBuyLotOptions  - @dblSellLotOptions 

												END

												DELETE FROM #tempSellForMatchingOptions WHERE intFutOptTransactionId = @intSFutOptTranactionIdOptions 
											END

											DELETE FROM #tempBuyForMatchingOptions WHERE intFutOptTransactionId = @intLFutOptTranactionIdOptions 

						

						
										END

										--========================================================
										--			Create Match Derivatives for Options
										--========================================================

										DECLARE @strTranNo NVARCHAR(50)
										DECLARE @intOptionsMatchPnSHeaderId INT


										INSERT INTO tblRKOptionsMatchPnSHeader (intConcurrencyId)
										VALUES (1)
	
										SELECT @intOptionsMatchPnSHeaderId = SCOPE_IDENTITY()


										SELECT @strTranNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0) FROM tblRKOptionsMatchPnS

										INSERT INTO tblRKOptionsMatchPnS (intOptionsMatchPnSHeaderId
											, strTranNo
											, dtmMatchDate
											, dblMatchQty
											, intLFutOptTransactionId
											, intSFutOptTransactionId
											, strMatchingType
											, intConcurrencyId)
										SELECT @intOptionsMatchPnSHeaderId 
											, @strTranNo + ROW_NUMBER() OVER (ORDER BY intLFutOptTransactionId)
											, dtmMatchedDate
											, dblMatchQty
											, intLFutOptTransactionId
											, intSFutOptTransactionId
											, strMatchingType = 'Auto'
											, 1 as intConcurrencyId
										FROM @tempMatchDerivativesDetail


							

										DECLARE @strTranNoLast NVARCHAR(50)

										SELECT @strTranNoLast = ISNULL(MAX(strTranNo), 0) FROM tblRKOptionsMatchPnS

										
										INSERT INTO @tempResult
										SELECT 'Auto-Matching of Options created Trans No. ' + CAST(@strTranNo + 1 AS NVARCHAR(50)) + ' to ' + @strTranNoLast, 2
							
										--For debugging
										--SELECT * FROM @tempMatchDerivativesDetail

										DELETE FROM @tempMatchDerivativesDetail


									
								
									END

									DELETE FROM #tempStrike WHERE dblStrike = @dblStrike
								
									DROP TABLE #tempBuyForMatchingOptions 
									DROP TABLE #tempSellForMatchingOptions 
								END

								DROP TABLE #tempStrike


								DELETE FROM #tempOptionType WHERE strOptionType = @strOptionType
							END

							DROP TABLE #tempOptionType
							


						END

		


						DELETE FROM #tempMonths WHERE intFutureMonthId = @intFutureMonthId

					END

		
					DELETE FROM #tempBrokerAccounts WHERE intBrokerageAccountId = @intBrokerageAccountId

					DROP TABLE #tempMonths
				END
			
				
				DELETE FROM #tempBroker WHERE intEntityId = @intBrokerageId
				
				DROP TABLE #tempBrokerAccounts
			END


			DELETE FROM #tempLocations WHERE intLocationId = @intCompanyLocationId

			DROP TABLE #tempBroker
			DROP TABLE #tempBuy
			DROP TABLE #tempSell
		END

		DELETE FROM #tempCommodities WHERE intCommodityId = @intCommodityId

		
		DROP TABLE #tempLocations

	END

	
	DROP TABLE #tempCommodities
	DELETE FROM #tempMarkets WHERE intFutureMarketId = @intFutureMarketId

END


	IF EXISTS (SELECT * FROM @tempResult)
	BEGIN
		SELECT Result FROM @tempResult ORDER BY SortId
	END


DROP TABLE #tempMarkets


