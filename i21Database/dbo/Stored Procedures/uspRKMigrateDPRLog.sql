CREATE PROCEDURE [dbo].[uspRKMigrateDPRLog]	
AS
BEGIN

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKDPRRunLog') AND 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKDPRRunLogDetail') AND
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKTempDPRDetailLog')
	BEGIN

		BEGIN TRAN

		DELETE FROM tblRKDPRRunLog
		TRUNCATE TABLE tblRKDPRRunLogDetail
		DBCC CHECKIDENT ('[tblRKDPRRunLog]', RESEED, 0);


		SELECT DISTINCT  --top 1
			intRunNumber
			,dtmRunDateTime
			,dtmDPRDate
			,strDPRPositionIncludes
			,strDPRPositionBy
			,strDPRPurchaseSale
			,strDPRVendorCustomer
			,strCommodityCode
			,intUserId 
		INTO #tempOldDPRDetailLog
		FROM tblRKTempDPRDetailLog
		ORDER BY intRunNumber


		DECLARE @intRunNumber INT
				,@dtmRunDateTime DATETIME
				,@dtmDPRDate DATETIME
				,@strDPRPositionIncludes NVARCHAR(50)
				,@strDPRPositionBy NVARCHAR(50)
				,@strDPRPurchaseSale NVARCHAR(50)
				,@strDPRVendorCustomer NVARCHAR(200)
				,@strCommodityCode NVARCHAR(200)
				,@intUserId INT
				,@intDPRRunLogId INT

		WHILE EXISTS (SELECT TOP 1 1 FROM #tempOldDPRDetailLog)
		BEGIN
			SELECT TOP 1 
				@intRunNumber = intRunNumber 
				,@dtmRunDateTime = dtmRunDateTime
				,@dtmDPRDate = dtmDPRDate
				,@strDPRPositionIncludes = strDPRPositionIncludes
				,@strDPRPositionBy = strDPRPositionBy
				,@strDPRPurchaseSale = strDPRPurchaseSale
				,@strDPRVendorCustomer = strDPRVendorCustomer
				,@strCommodityCode = strCommodityCode
				,@intUserId = intUserId 
			FROM #tempOldDPRDetailLog


			INSERT INTO tblRKDPRRunLog(
				intRunNumber
				,dtmRunDateTime
				,dtmDPRDate
				,strDPRPositionIncludes
				,strDPRPositionBy
				,strDPRPurchaseSale
				,strDPRVendorCustomer
				,strCommodityCode
				,intUserId 
			)
			SELECT
				@intRunNumber
				,@dtmRunDateTime
				,@dtmDPRDate
				,@strDPRPositionIncludes
				,@strDPRPositionBy
				,@strDPRPurchaseSale
				,@strDPRVendorCustomer
				,@strCommodityCode
				,@intUserId 

			SET @intDPRRunLogId = SCOPE_IDENTITY()

	
			INSERT INTO tblRKDPRRunLogDetail(
				intDPRRunLogId
				,strContractNumber
				,intSeqNo
				,intContractHeaderId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,strUnitMeasure
				,strAccountNumber
				,strTranType
				,dblNoOfLot
				,dblDelta
				,intBrokerageAccountId
				,strInstrumentType
				,strEntityName
				,intOrderId
				,intItemId
				,strItemNo
				,intCategoryId
				,strCategory
				,intFutureMarketId
				,strFutMarketName
				,intFutureMonthId
				,strFutureMonth
				,strDeliveryDate
				,strBrokerTradeNo
				,strNotes
				,ysnPreCrush
				,strTransactionReferenceId
				,intTransactionReferenceId
				,intTransactionReferenceDetailId
			)
			SELECT
				@intDPRRunLogId
				,strContractNumber
				,intSeqNo
				,intContractHeaderId
				,strInternalTradeNo
				,intFutOptTransactionHeaderId
				,strType
				,strLocationName
				,strContractEndMonth
				,strContractEndMonthNearBy
				,dblTotal
				,strUnitMeasure
				,strAccountNumber
				,strTranType
				,dblNoOfLot
				,dblDelta
				,intBrokerageAccountId
				,strInstrumentType
				,strEntityName
				,intOrderId
				,intItemId
				,strItemNo
				,intCategoryId
				,strCategory
				,intFutureMarketId
				,strFutMarketName
				,intFutureMonthId
				,strFutureMonth
				,strDeliveryDate
				,strBrokerTradeNo
				,strNotes
				,ysnPreCrush
				,strTransactionReferenceId
				,intTransactionReferenceId
				,intTransactionReferenceDetailId
			FROM tblRKTempDPRDetailLog
			WHERE intRunNumber = @intRunNumber


			DELETE FROM #tempOldDPRDetailLog WHERE intRunNumber = @intRunNumber

		END

		DROP TABLE #tempOldDPRDetailLog

		COMMIT TRAN
	END

END