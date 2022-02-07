CREATE PROCEDURE [dbo].[uspRKLogRiskPosition]
	@SummaryLogs RKSummaryLog READONLY
	, @Rebuild BIT = 0
	, @LogContracts BIT = 1
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN	
	DECLARE @intId INT
		, @strBatchId NVARCHAR(100)
		, @strBucketType NVARCHAR(100)
		, @intActionId INT
		, @strTransactionType NVARCHAR(100)
		, @intTransactionRecordId INT
		, @intTransactionRecordHeaderId INT
		, @strDistributionType NVARCHAR(100)
		, @strTransactionNumber NVARCHAR(100)
		, @dtmTransactionDate DATETIME
		, @intContractDetailId INT
		, @intContractHeaderId INT
		, @intFutOptTransactionId INT
		, @intTicketId INT
		, @intCommodityId INT
		, @intCommodityUOMId INT
		, @intItemId INT
		, @intBookId INT
		, @intSubBookId INT
		, @intLocationId INT
		, @intFutureMarketId INT
		, @intFutureMonthId INT
		, @dblNoOfLots DECIMAL(24, 10)
		, @dblQty DECIMAL(24, 10)
		, @dblPrice DECIMAL(24, 10)
		, @dblContractSize DECIMAL(24, 10)
		, @intUserId INT
		, @intEntityId INT
		, @ysnDelete BIT
		, @strNotes NVARCHAR(250)
		, @strInOut NVARCHAR(50)
		, @strMiscFields NVARCHAR(MAX)
		, @intTransCtr INT = 0
		, @intTotal INT
		, @intOptionMonthId INT
		, @strOptionMonth NVARCHAR(20)
		, @dblStrike DECIMAL(24, 10)
		, @strOptionType NVARCHAR(10)
		, @strInstrumentType NVARCHAR(30)
		, @intBrokerageAccountId INT
		, @strBrokerAccount NVARCHAR(50)
		, @strBroker NVARCHAR(50)
		, @strBuySell NVARCHAR(10)
		, @ysnPreCrush BIT
		, @strBrokerTradeNo NVARCHAR(50)
		, @intMatchNo INT
		, @intMatchDerivativesHeaderId INT
		, @intMatchDerivativesDetailId INT
		, @strStorageTypeCode NVARCHAR(3)
		, @ysnReceiptedStorage BIT
		, @intTypeId INT
		, @strStorageType NVARCHAR(50)
		, @intDeliverySheetId INT
		, @strTicketStatus NVARCHAR(50)
		, @strOwnedPhysicalStock NVARCHAR(50)
		, @strStorageTypeDescription NVARCHAR(50)
		, @ysnActive BIT
		, @ysnExternal BIT
		, @intStorageHistoryId INT
		, @intInventoryReceiptItemId INT
		, @intLoadDetailId INT

	DECLARE @FinalTable AS TABLE (strBatchId NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strBucketType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intActionId INT NULL
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intTransactionRecordId INT NULL
		, intTransactionRecordHeaderId INT NULL
		, strDistributionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, dtmTransactionDate DATETIME NOT NULL
		, intContractDetailId INT NULL
		, intContractHeaderId INT NULL
		, intFutureMarketId INT NULL
		, intFutureMonthId INT NULL
		, intFutOptTransactionId INT NULL
		, intCommodityId INT NULL
		, intItemId INT NULL
		, intProductTypeId INT NULL
		, intOrigUOMId INT NULL
		, intBookId INT NULL
		, intSubBookId INT NULL
		, intLocationId INT NULL
		, strInOut NVARCHAR(20) NULL
		, dblOrigNoOfLots DECIMAL(24, 10) NULL DEFAULT((0))
		, dblContractSize DECIMAL(24, 10) NULL DEFAULT((0))
		, dblOrigQty DECIMAL(24, 10) NULL DEFAULT((0))
		, dblPrice DECIMAL(24, 10) NULL DEFAULT((0))
		, intEntityId INT NULL
		, intTicketId INT NULL
		, intUserId INT NULL
		, strNotes NVARCHAR(250) NULL
		, ysnNegate BIT NULL
		, intRefSummaryLogId INT NULL
		, strMiscFields NVARCHAR(MAX)
		, intOptionMonthId INT NULL
		, strOptionMonth NVARCHAR(20) NULL
		, dblStrike DECIMAL(24, 10) NULL
		, strOptionType NVARCHAR(10) NULL
		, strInstrumentType NVARCHAR(30) NULL
		, intBrokerageAccountId INT NULL
		, strBrokerAccount NVARCHAR(50) NULL
		, strBroker NVARCHAR(50) NULL
		, strBuySell NVARCHAR(10) NULL
		, ysnPreCrush BIT NULL
		, strBrokerTradeNo NVARCHAR(50) NULL
		, intMatchNo INT NULL
		, intMatchDerivativesHeaderId INT NULL
		, intMatchDerivativesDetailId INT NULL
		, strStorageTypeCode NVARCHAR(3) NULL
		, ysnReceiptedStorage BIT NULL
		, intTypeId INT NULL
		, strStorageType NVARCHAR(50) NULL
		, intDeliverySheetId INT NULL
		, strTicketStatus NVARCHAR(50) NULL
		, strOwnedPhysicalStock NVARCHAR(50) NULL
		, strStorageTypeDescription NVARCHAR(50) NULL
		, ysnActive BIT NULL
		, ysnExternal BIT NULL
		, intStorageHistoryId INT NULL
		, intInventoryReceiptItemId INT NULL
		, intLoadDetailId INT NULL)

	SELECT @intTotal = COUNT(*) FROM @SummaryLogs

	SELECT * INTO #tmpSummaryLogs FROM @SummaryLogs ORDER BY dtmTransactionDate

	-- Validate Batch Id
	IF EXISTS(SELECT TOP 1 1 FROM #tmpSummaryLogs WHERE ISNULL(strBatchId, '') = '')
	BEGIN
		EXEC uspSMGetStartingNumber 148, @strBatchId OUTPUT

		UPDATE tmp
		SET strBatchId = @strBatchId
		FROM #tmpSummaryLogs tmp
		WHERE ISNULL(strBatchId, '') = ''
	END

	IF @Rebuild = 1 AND EXISTS(SELECT TOP 1 1 FROM #tmpSummaryLogs WHERE strBucketType IN('Company Owned','Sales In-Transit','Purchase In-Transit','Customer Owned','Delayed Pricing', 'On Hold')) 	
	BEGIN
		GOTO BulkRebuild
	END


	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpSummaryLogs)
	BEGIN
		SELECT @intId = NULL
			, @strBatchId = NULL
			, @strBucketType = NULL
			, @intActionId = NULL
			, @strTransactionType = NULL
			, @intTransactionRecordId = NULL
			, @intTransactionRecordHeaderId = NULL
			, @strDistributionType = NULL
			, @strTransactionNumber = NULL
			, @dtmTransactionDate = NULL
			, @intContractDetailId = NULL
			, @intContractHeaderId = NULL
			, @intFutOptTransactionId = NULL
			, @intTicketId = NULL
			, @intCommodityId = NULL
			, @intCommodityUOMId = NULL
			, @intItemId = NULL
			, @intBookId = NULL
			, @intSubBookId = NULL
			, @intLocationId = NULL
			, @intFutureMarketId = NULL
			, @intFutureMonthId = NULL
			, @dblNoOfLots = NULL
			, @dblQty = NULL
			, @dblPrice = NULL
			, @dblContractSize = NULL
			, @intUserId = NULL
			, @intEntityId = NULL
			, @ysnDelete = NULL
			, @strNotes = NULL
			, @strInOut = NULL			
			, @strMiscFields = NULL
			, @intOptionMonthId = NULL
			, @strOptionMonth = NULL
			, @dblStrike = NULL
			, @strOptionType = NULL
			, @strInstrumentType = NULL
			, @intBrokerageAccountId = NULL
			, @strBrokerAccount = NULL
			, @strBroker = NULL
			, @strBuySell = NULL
			, @ysnPreCrush = NULL
			, @strBrokerTradeNo = NULL
			, @intMatchNo = NULL
			, @intMatchDerivativesHeaderId = NULL
			, @intMatchDerivativesDetailId = NULL
			, @strStorageTypeCode = NULL
			, @ysnReceiptedStorage = NULL
			, @intTypeId = NULL
			, @strStorageType = NULL
			, @intDeliverySheetId = NULL
			, @strTicketStatus = NULL
			, @strOwnedPhysicalStock = NULL
			, @strStorageTypeDescription = NULL
			, @ysnActive = NULL
			, @ysnExternal = NULL
			, @intStorageHistoryId = NULL
			, @intInventoryReceiptItemId = NULL
			, @intLoadDetailId = NULL

		SELECT TOP 1 @intId = intId
			, @strBatchId = strBatchId
			, @strBucketType = strBucketType
			, @intActionId = intActionId
			, @strTransactionType = strTransactionType
			, @intTransactionRecordId = intTransactionRecordId
			, @intTransactionRecordHeaderId = intTransactionRecordHeaderId
			, @strDistributionType = strDistributionType
			, @strTransactionNumber = strTransactionNumber
			, @dtmTransactionDate = dtmTransactionDate
			, @intContractDetailId = intContractDetailId
			, @intContractHeaderId = intContractHeaderId
			, @intFutOptTransactionId = intFutOptTransactionId
			, @intTicketId = intTicketId
			, @intCommodityId = intCommodityId
			, @intCommodityUOMId = intCommodityUOMId
			, @intItemId = intItemId
			, @intBookId = intBookId
			, @intSubBookId = intSubBookId
			, @intLocationId = intLocationId
			, @intFutureMarketId = intFutureMarketId
			, @intFutureMonthId = intFutureMonthId
			, @dblNoOfLots = dblNoOfLots
			, @dblQty = dblQty
			, @dblPrice = dblPrice
			, @dblContractSize = dblContractSize
			, @intUserId = intUserId
			, @intEntityId = intEntityId
			, @strNotes = strNotes
			, @strInOut = strInOut
			, @ysnDelete = ysnDelete
			, @strMiscFields = strMiscFields
			, @intOptionMonthId =  intOptionMonthId
			, @strOptionMonth =  strOptionMonth
			, @dblStrike =  dblStrike
			, @strOptionType =  strOptionType
			, @strInstrumentType =  strInstrumentType
			, @intBrokerageAccountId =  intBrokerageAccountId
			, @strBrokerAccount =  strBrokerAccount
			, @strBroker =  strBroker
			, @strBuySell =  strBuySell
			, @ysnPreCrush =  ysnPreCrush
			, @strBrokerTradeNo =  strBrokerTradeNo
			, @intMatchNo = intMatchNo
			, @intMatchDerivativesHeaderId = intMatchDerivativesHeaderId
			, @intMatchDerivativesDetailId = intMatchDerivativesDetailId
			, @strStorageTypeCode =  strStorageTypeCode
			, @ysnReceiptedStorage =  ysnReceiptedStorage
			, @intTypeId =  intTypeId
			, @strStorageType =  strStorageType
			, @intDeliverySheetId =  intDeliverySheetId
			, @strTicketStatus =  strTicketStatus
			, @strOwnedPhysicalStock =  strOwnedPhysicalStock
			, @strStorageTypeDescription =  strStorageTypeDescription
			, @ysnActive =  ysnActive
			, @ysnExternal =  ysnExternal
			, @intStorageHistoryId =  intStorageHistoryId
			, @intInventoryReceiptItemId =  intInventoryReceiptItemId
			, @intLoadDetailId =  intLoadDetailId
		FROM #tmpSummaryLogs
		ORDER BY dtmTransactionDate

		IF OBJECT_ID('tempdb..#tmpPrevLog') IS NOT NULL
			DROP TABLE #tmpPrevLog

		IF (@strTransactionType IN ('Derivative Entry'))
		BEGIN
			-- Check if there is a manual change in commodity or distribution type (buy/sell), marked it as ysnNegate = 1 to have a reverse entry
			IF EXISTS(SELECT TOP 1 1
			FROM @FinalTable
			WHERE intTransactionRecordId = @intTransactionRecordId
				AND strBucketType = @strBucketType
				AND strTransactionType = @strTransactionType
				AND strTransactionNumber = @strTransactionNumber
				AND (intCommodityId <> @intCommodityId OR strDistributionType <> @strDistributionType OR intFutureMarketId <> @intFutureMarketId)
				AND ysnNegate IS NULL)
			BEGIN
				INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Fixing manual changes on derivative ' + ISNULL(@strTransactionNumber, '') + '.')
				INSERT INTO @FinalTable(strBatchId
					, strBucketType
					, intActionId
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, intLocationId
					, strInOut
					, dblOrigNoOfLots
					, dblContractSize
					, dblOrigQty
					, dblPrice
					, intEntityId
					, intTicketId
					, intUserId
					, strNotes
					, ysnNegate
					, intRefSummaryLogId
					, strMiscFields
					, intOptionMonthId
					, strOptionMonth
					, dblStrike
					, strOptionType
					, strInstrumentType
					, intBrokerageAccountId
					, strBrokerAccount
					, strBroker
					, strBuySell
					, ysnPreCrush
					, strBrokerTradeNo
					, intMatchNo
					, intMatchDerivativesHeaderId
					, intMatchDerivativesDetailId
					, strStorageTypeCode
					, ysnReceiptedStorage
					, intTypeId
					, strStorageType
					, intDeliverySheetId
					, strTicketStatus
					, strOwnedPhysicalStock
					, strStorageTypeDescription
					, ysnActive
					, ysnExternal
					, intStorageHistoryId
					, intInventoryReceiptItemId
					, intLoadDetailId)
				SELECT strBatchId
					, strBucketType
					, intActionId
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, intLocationId
					, strInOut = CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END
					, dblOrigNoOfLots * -1
					, dblContractSize
					, dblOrigQty * -1
					, dblPrice
					, intEntityId
					, intTicketId
					, @intUserId
					, strNotes
					, ysnNegate = 1
					, intRefSummaryLogId
					, strMiscFields
					, intOptionMonthId
					, strOptionMonth
					, dblStrike
					, strOptionType
					, strInstrumentType
					, intBrokerageAccountId
					, strBrokerAccount
					, strBroker
					, strBuySell
					, ysnPreCrush
					, strBrokerTradeNo
					, intMatchNo
					, intMatchDerivativesHeaderId
					, intMatchDerivativesDetailId
					, strStorageTypeCode
					, ysnReceiptedStorage
					, intTypeId
					, strStorageType
					, intDeliverySheetId
					, strTicketStatus
					, strOwnedPhysicalStock
					, strStorageTypeDescription
					, ysnActive
					, ysnExternal
					, intStorageHistoryId
					, intInventoryReceiptItemId
					, intLoadDetailId
				FROM @FinalTable
				WHERE intTransactionRecordId = @intTransactionRecordId
					AND strBucketType = @strBucketType
					AND strTransactionType = @strTransactionType
					AND strTransactionNumber = @strTransactionNumber
					AND (intCommodityId <> @intCommodityId OR strDistributionType <> @strDistributionType OR intFutureMarketId <> @intFutureMarketId)
					AND ysnNegate IS NULL


				UPDATE @FinalTable SET ysnNegate = 1
				WHERE intTransactionRecordId = @intTransactionRecordId
					AND strBucketType = @strBucketType
					AND strTransactionType = @strTransactionType
					AND strTransactionNumber = @strTransactionNumber
					AND (intCommodityId <> @intCommodityId OR strDistributionType <> @strDistributionType OR intFutureMarketId <> @intFutureMarketId)
					AND ysnNegate IS NULL
			END
		END
		
		
		SELECT TOP 1 *
		INTO #tmpPrevLog
		FROM tblRKSummaryLog
		WHERE strBucketType = @strBucketType
			AND strTransactionType = @strTransactionType
			AND intTransactionRecordId = @intTransactionRecordId
			AND ysnNegate = 0
		ORDER BY intSummaryLogId DESC

		-- Insert Delete Entry
		IF (ISNULL(@ysnDelete, 0) = 1)
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigNoOfLots
				, dblContractSize
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes
				, strMiscFields
				, intOptionMonthId
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, intBrokerageAccountId
				, strBrokerAccount
				, strBroker
				, strBuySell
				, ysnPreCrush
				, strBrokerTradeNo
				, intMatchNo
				, intMatchDerivativesHeaderId
				, intMatchDerivativesDetailId
				, strStorageTypeCode
				, ysnReceiptedStorage
				, intTypeId
				, strStorageType
				, intDeliverySheetId
				, strTicketStatus
				, strOwnedPhysicalStock
				, strStorageTypeDescription
				, ysnActive
				, ysnExternal
				, intStorageHistoryId
				, intInventoryReceiptItemId
				, intLoadDetailId)
			SELECT strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut 
				, dblOrigNoOfLots * -1
				, dblContractSize
				, dblOrigQty * -1
				, dblPrice
				, intEntityId
				, intTicketId
				, @intUserId
				, 'Delete Record'
				, strMiscField
				, intOptionMonthId
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, intBrokerageAccountId
				, strBrokerAccount
				, strBroker
				, strBuySell
				, ysnPreCrush
				, strBrokerTradeNo
				, intMatchNo
				, intMatchDerivativesHeaderId
				, intMatchDerivativesDetailId
				, strStorageTypeCode
				, ysnReceiptedStorage
				, intTypeId
				, strStorageType
				, intDeliverySheetId
				, strTicketStatus
				, strOwnedPhysicalStock
				, strStorageTypeDescription
				, ysnActive
				, ysnExternal
				, intStorageHistoryId
				, intInventoryReceiptItemId
				, intLoadDetailId
			FROM #tmpPrevLog

			DELETE FROM #tmpSummaryLogs
			WHERE intId = @intId

			CONTINUE
		END

		-- Validate if no changes was detected on fields with bearing
		IF EXISTS(SELECT TOP 1 1
			FROM #tmpPrevLog
			WHERE intTransactionRecordId = @intTransactionRecordId
				AND strBucketType = @strBucketType
				AND strTransactionType = @strTransactionType
				AND strDistributionType = @strDistributionType
				AND intCommodityId = @intCommodityId
				AND intFutureMarketId = @intFutureMarketId
				AND intFutureMonthId = @intFutureMonthId
				AND dblOrigNoOfLots = @dblNoOfLots
				AND dblOrigQty = @dblQty
				AND dblPrice = @dblPrice
				AND intContractDetailId = @intContractDetailId
				AND intContractHeaderId = @intContractHeaderId
				AND intTicketId = @intTicketId)
		BEGIN

			DELETE FROM #tmpSummaryLogs
			WHERE intId = @intId
			
			CONTINUE
		END

		-- Log counter entry to negate previous value
		IF (@strTransactionType IN ('Derivative Entry', 'Match Derivatives', 'Collateral', 'Collateral Adjustments'))
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM #tmpPrevLog)
			BEGIN
				INSERT INTO @FinalTable(strBatchId
					, strBucketType
					, intActionId
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, intLocationId
					, strInOut
					, dblOrigNoOfLots
					, dblContractSize
					, dblOrigQty
					, dblPrice
					, intEntityId
					, intTicketId
					, intUserId
					, strNotes
					, ysnNegate
					, intRefSummaryLogId
					, strMiscFields
					, intOptionMonthId
					, strOptionMonth
					, dblStrike
					, strOptionType
					, strInstrumentType
					, intBrokerageAccountId
					, strBrokerAccount
					, strBroker
					, strBuySell
					, ysnPreCrush
					, strBrokerTradeNo
					, intMatchNo
					, intMatchDerivativesHeaderId
					, intMatchDerivativesDetailId
					, strStorageTypeCode
					, ysnReceiptedStorage
					, intTypeId
					, strStorageType
					, intDeliverySheetId
					, strTicketStatus
					, strOwnedPhysicalStock
					, strStorageTypeDescription
					, ysnActive
					, ysnExternal
					, intStorageHistoryId
					, intInventoryReceiptItemId
					, intLoadDetailId)
				SELECT @strBatchId
					, strBucketType
					, intActionId
					, strTransactionType
					, intTransactionRecordId
					, intTransactionRecordHeaderId
					, strDistributionType
					, strTransactionNumber
					, dtmTransactionDate
					, intContractDetailId
					, intContractHeaderId
					, intFutureMarketId
					, intFutureMonthId
					, intFutOptTransactionId
					, intCommodityId
					, intItemId
					, intProductTypeId
					, intOrigUOMId
					, intBookId
					, intSubBookId
					, intLocationId
					, strInOut
					, dblOrigNoOfLots * -1
					, dblContractSize
					, dblOrigQty * -1
					, dblPrice
					, intEntityId
					, intTicketId
					, @intUserId
					, strNotes
					, 1
					, intSummaryLogId
					, strMiscField
					, intOptionMonthId
					, strOptionMonth
					, dblStrike
					, strOptionType
					, strInstrumentType
					, intBrokerageAccountId
					, strBrokerAccount
					, strBroker
					, strBuySell
					, ysnPreCrush
					, strBrokerTradeNo
					, intMatchNo
					, intMatchDerivativesHeaderId
					, intMatchDerivativesDetailId
					, strStorageTypeCode
					, ysnReceiptedStorage
					, intTypeId
					, strStorageType
					, intDeliverySheetId
					, strTicketStatus
					, strOwnedPhysicalStock
					, strStorageTypeDescription
					, ysnActive
					, ysnExternal
					, intStorageHistoryId
					, intInventoryReceiptItemId
					, intLoadDetailId
				FROM #tmpPrevLog
			END
		END

		---------------------------------------
		------------ DERIVATIVES --------------
		---------------------------------------
		IF (@strTransactionType = 'Derivative Entry' OR @strTransactionType = 'Match Derivatives' OR @strTransactionType = 'Options Lifecycle')
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigNoOfLots
				, dblContractSize
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes
				, strMiscFields
				, intOptionMonthId
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, intBrokerageAccountId
				, strBrokerAccount
				, strBroker
				, strBuySell
				, ysnPreCrush
				, strBrokerTradeNo
				, intMatchNo
				, intMatchDerivativesHeaderId
				, intMatchDerivativesDetailId
				, strStorageTypeCode
				, ysnReceiptedStorage
				, intTypeId
				, strStorageType
				, intDeliverySheetId
				, strTicketStatus
				, strOwnedPhysicalStock
				, strStorageTypeDescription
				, ysnActive
				, ysnExternal
				, intStorageHistoryId
				, intInventoryReceiptItemId
				, intLoadDetailId)
			SELECT @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intFutOptTransactionId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = @strInOut
				, dblOrigNoOfLots = @dblNoOfLots 
				, @dblContractSize
				, dblOrigQty = ISNULL(@dblQty, @dblNoOfLots * @dblContractSize)
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
				, @strMiscFields
				, @intOptionMonthId
				, @strOptionMonth
				, @dblStrike
				, @strOptionType
				, @strInstrumentType
				, @intBrokerageAccountId
				, @strBrokerAccount
				, @strBroker
				, @strBuySell
				, @ysnPreCrush
				, @strBrokerTradeNo
				, @intMatchNo
				, @intMatchDerivativesHeaderId
				, @intMatchDerivativesDetailId
				, @strStorageTypeCode
				, @ysnReceiptedStorage
				, @intTypeId
				, @strStorageType
				, @intDeliverySheetId
				, @strTicketStatus
				, @strOwnedPhysicalStock
				, @strStorageTypeDescription
				, @ysnActive
				, @ysnExternal
				, @intStorageHistoryId
				, @intInventoryReceiptItemId
				, @intLoadDetailId
		END

		---------------------------------------
		------------- COLLATERAL --------------
		---------------------------------------
		ELSE IF @strTransactionType = 'Collateral'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigNoOfLots
				, dblContractSize
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN UPPER(@strDistributionType) = 'PURCHASE' THEN 'IN' ELSE 'OUT' END
				, dblOrigNoOfLots = 0
				, dblContractSize = 0
				, dblOrigQty = @dblQty * CASE WHEN UPPER(@strDistributionType) = 'PURCHASE' THEN 1 ELSE -1 END
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
		END

		---------------------------------------
		------- COLLATERAL ADJUSTMENTS --------
		---------------------------------------
		ELSE IF @strTransactionType = 'Collateral Adjustments'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigNoOfLots
				, dblContractSize
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN UPPER(@strDistributionType) = 'SALE' THEN 'IN' ELSE 'OUT' END
				, dblOrigNoOfLots = 0
				, dblContractSize = 0
				, dblOrigQty = @dblQty * CASE WHEN UPPER(@strDistributionType) = 'SALE' THEN 1 ELSE -1 END
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
		END

		--------------------------------------
		------------- Inventory --------------
		--------------------------------------
		ELSE IF @strBucketType = 'Company Owned'
			 OR @strBucketType = 'Sales In-Transit'
			 OR @strBucketType = 'Purchase In-Transit'

		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, strTransactionType = CASE WHEN @strTransactionType LIKE 'Inventory Adjustment%' THEN 'Inventory Adjustment' ELSE @strTransactionType END
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL--I.intProductTypeId
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE 
						WHEN @strBucketType = 'Sales In-Transit' OR
							 @strBucketType = 'Purchase In-Transit' OR
							 @strTransactionType = 'Inventory Receipt' OR
							 @strTransactionType = 'Produce' OR
							 @strTransactionType = 'Inventory Transfer' OR
							 @strTransactionType like 'Inventory Adjustment%' OR
							 @strTransactionType = 'Storage Settlement'
							THEN CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'IN' ELSE 'OUT' END
						WHEN @strTransactionType = 'Inventory Shipment' OR
							 @strTransactionType = 'Invoice' OR
							 @strTransactionType  = 'Outbound Shipment' OR
							 @strTransactionType = 'Consume' 
							THEN CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'OUT' ELSE 'IN' END
						ELSE '' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
		END

		--------------------------------------
		----------- Customer Storage ---------
		--------------------------------------
		ELSE IF @strBucketType = 'Customer Owned' OR
				@strBucketType = 'Delayed Pricing'

		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes
				, strMiscFields
				, intOptionMonthId
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, intBrokerageAccountId
				, strBrokerAccount
				, strBroker
				, strBuySell
				, ysnPreCrush
				, strBrokerTradeNo
				, intMatchNo
				, intMatchDerivativesHeaderId
				, intMatchDerivativesDetailId
				, strStorageTypeCode
				, ysnReceiptedStorage
				, intTypeId
				, strStorageType
				, intDeliverySheetId
				, strTicketStatus
				, strOwnedPhysicalStock
				, strStorageTypeDescription
				, ysnActive
				, ysnExternal
				, intStorageHistoryId
				, intInventoryReceiptItemId
				, intLoadDetailId)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL--I.intProductTypeId
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'IN' ELSE 'OUT' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
				, @strMiscFields
				, @intOptionMonthId
				, @strOptionMonth
				, @dblStrike
				, @strOptionType
				, @strInstrumentType
				, @intBrokerageAccountId
				, @strBrokerAccount
				, @strBroker
				, @strBuySell
				, @ysnPreCrush
				, @strBrokerTradeNo
				, @intMatchNo
				, @intMatchDerivativesHeaderId
				, @intMatchDerivativesDetailId
				, @strStorageTypeCode
				, @ysnReceiptedStorage
				, @intTypeId
				, @strStorageType
				, @intDeliverySheetId
				, @strTicketStatus
				, @strOwnedPhysicalStock
				, @strStorageTypeDescription
				, @ysnActive
				, @ysnExternal
				, @intStorageHistoryId
				, @intInventoryReceiptItemId
				, @intLoadDetailId
		END

		------------------------------------
		------------- Voucher --------------
		------------------------------------
		ELSE IF @strTransactionType = 'Voucher'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = I.intProductTypeId
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'OUT' ELSE 'IN' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
			FROM tblAPBillDetail BD
			LEFT JOIN tblICItem I ON I.intItemId = BD.intItemId
			WHERE BD.intBillDetailId = @intTransactionRecordId
		END

		---------------------------------------
		------------- AP Payment --------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'OUT' ELSE 'INT' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
		END

		---------------------------------------
		------------- Scale --------------
		---------------------------------------
		ELSE IF @strBucketType = 'On Hold'
		BEGIN

			INSERT INTO @FinalTable(strBatchId
				, strBucketType
				, intActionId
				, strTransactionType
				, intTransactionRecordId
				, intTransactionRecordHeaderId
				, strDistributionType
				, strTransactionNumber
				, dtmTransactionDate
				, intContractDetailId
				, intContractHeaderId
				, intFutureMarketId
				, intFutureMonthId
				, intFutOptTransactionId
				, intCommodityId
				, intItemId
				, intProductTypeId
				, intOrigUOMId
				, intBookId
				, intSubBookId
				, intLocationId
				, strInOut
				, dblOrigQty
				, dblPrice
				, intEntityId
				, intTicketId
				, intUserId
				, strNotes
				, strMiscFields
				, intOptionMonthId
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, intBrokerageAccountId
				, strBrokerAccount
				, strBroker
				, strBuySell
				, ysnPreCrush
				, strBrokerTradeNo
				, intMatchNo
				, intMatchDerivativesHeaderId
				, intMatchDerivativesDetailId
				, strStorageTypeCode
				, ysnReceiptedStorage
				, intTypeId
				, strStorageType
				, intDeliverySheetId
				, strTicketStatus
				, strOwnedPhysicalStock
				, strStorageTypeDescription
				, ysnActive
				, ysnExternal
				, intStorageHistoryId
				, intInventoryReceiptItemId
				, intLoadDetailId)
			SELECT TOP 1 @strBatchId
				, @strBucketType
				, @intActionId
				, @strTransactionType
				, @intTransactionRecordId
				, @intTransactionRecordHeaderId
				, @strDistributionType
				, @strTransactionNumber
				, @dtmTransactionDate
				, @intContractDetailId
				, @intContractHeaderId
				, @intFutureMarketId
				, @intFutureMonthId
				, @intTransactionRecordId
				, @intCommodityId
				, @intItemId
				, intProductTypeId = NULL--I.intProductTypeId
				, intOrigUOMId = @intCommodityUOMId
				, @intBookId
				, @intSubBookId
				, @intLocationId
				, strInOut = CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'IN' ELSE 'OUT' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
				, @strMiscFields
				, @intOptionMonthId
				, @strOptionMonth
				, @dblStrike
				, @strOptionType
				, @strInstrumentType
				, @intBrokerageAccountId
				, @strBrokerAccount
				, @strBroker
				, @strBuySell
				, @ysnPreCrush
				, @strBrokerTradeNo
				, @intMatchNo
				, @intMatchDerivativesHeaderId
				, @intMatchDerivativesDetailId
				, @strStorageTypeCode
				, @ysnReceiptedStorage
				, @intTypeId
				, @strStorageType
				, @intDeliverySheetId
				, @strTicketStatus
				, @strOwnedPhysicalStock
				, @strStorageTypeDescription
				, @ysnActive
				, @ysnExternal
				, @intStorageHistoryId
				, @intInventoryReceiptItemId
				, @intLoadDetailId

		END

		------------------------------
		-- Process Contract Balance --
		------------------------------
		IF (ISNULL(@intContractDetailId, 0) <> 0 AND @LogContracts = 1)
		BEGIN
			DECLARE @cbLog AS CTContractBalanceLog

			IF (@strTransactionType = 'Price Fixation')
			BEGIN
				INSERT INTO @cbLog (strBatchId
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, strTransactionReferenceNo
					, intContractDetailId
					, intContractHeaderId
					, intContractTypeId
					, intContractSeq
					, intEntityId
					, intCommodityId
					, intItemId
					, intLocationId
					, intPricingTypeId
					, intFutureMarketId
					, intFutureMonthId
					, dblBasis
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes)		
				SELECT @strBatchId
					, 'Contract Balance'
					, strTransactionReference = 'Price Fixation'
					, intTransactionReferenceId = fd.intPriceFixationDetailId
					, strTransactionReferenceNo = pc.strPriceContractNo
					, @intContractDetailId
					, @intContractHeaderId
					, intContractTypeId
					, intContractSeq
					, intEntityId
					, ch.intCommodityId
					, intItemId
					, cd.intCompanyLocationId
					, cd.intPricingTypeId
					, cd.intFutureMarketId
					, cd.intFutureMonthId
					, cd.dblBasis
					, cd.dblFutures
					, intQtyUOMId = cd.intUnitMeasureId
					, intQtyCurrencyId = cd.intCurrencyId
					, cd.intBasisUOMId
					, cd.intBasisCurrencyId
					, intPriceUOMId = cd.intPriceItemUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty = @dblQty
					, intContractStatusId
					, cd.intBookId
					, cd.intSubBookId
					, ''
				FROM tblCTPriceFixationDetail fd
				JOIN tblCTPriceFixation pf ON pf.intPriceFixationId = fd.intPriceFixationId
				JOIN tblCTPriceContract pc ON pc.intPriceContractId = pf.intPriceContractId
				JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = ch.intCommodityId AND cum.ysnDefault = 1
				WHERE cd.intContractDetailId = @intContractHeaderId
					AND cd.intContractHeaderId = @intContractDetailId
			END
			ELSE
			BEGIN
				INSERT INTO @cbLog (strBatchId
					, strTransactionType
					, strTransactionReference
					, intTransactionReferenceId
					, strTransactionReferenceNo
					, intContractDetailId
					, intContractHeaderId
					, intContractTypeId
					, intContractSeq
					, intEntityId
					, intCommodityId
					, intItemId
					, intLocationId
					, intPricingTypeId
					, intFutureMarketId
					, intFutureMonthId
					, dblBasis
					, dblFutures
					, intQtyUOMId
					, intQtyCurrencyId
					, intBasisUOMId
					, intBasisCurrencyId
					, intPriceUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty
					, intContractStatusId
					, intBookId
					, intSubBookId
					, strNotes)		
				SELECT @strBatchId
					, 'Contract Balance'
					, strTransactionReference = @strTransactionType
					, intTransactionReferenceId = @intTransactionRecordId
					, strTransactionReferenceNo = @strTransactionNumber
					, @intContractDetailId
					, @intContractHeaderId				
					, intContractTypeId
					, intContractSeq
					, intEntityId
					, intCommodityId
					, intItemId
					, CD.intCompanyLocationId
					, CD.intPricingTypeId
					, CD.intFutureMarketId
					, CD.intFutureMonthId
					, CD.dblBasis
					, CD.dblFutures
					, intQtyUOMId = CD.intUnitMeasureId
					, intQtyCurrencyId = CD.intCurrencyId
					, CD.intBasisUOMId
					, CD.intBasisCurrencyId
					, intPriceUOMId = CD.intPriceItemUOMId
					, dtmStartDate
					, dtmEndDate
					, dblQty = @dblQty
					, intContractStatusId
					, CD.intBookId
					, CD.intSubBookId
					, ''
				FROM tblCTContractDetail CD
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				WHERE CD.intContractDetailId = @intContractHeaderId
					AND CD.intContractHeaderId = @intContractDetailId

				---------------------------------------------
				-- Process Purchase/Sales Basis Deliveries --
				---------------------------------------------
			END

			EXEC uspCTLogContractBalance @cbLog, 0
		END
		------------------------------
		------------------------------
		
		SET @intTransCtr += 1
		IF (@intTransCtr % 10000 = 0)
		BEGIN
			INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Processed ' + CAST(@intTransCtr AS NVARCHAR) + ' of ' + CAST(@intTotal AS NVARCHAR) + ' records.')
		END

		DELETE FROM #tmpSummaryLogs
		WHERE intId = @intId
	END
	
	GOTO Logging

	BulkRebuild:

	SET @intTransCtr = @intTotal

	INSERT INTO @FinalTable(strBatchId
		, strBucketType
		, intActionId
		, strTransactionType
		, intTransactionRecordId
		, intTransactionRecordHeaderId
		, strDistributionType
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intFutureMarketId
		, intFutureMonthId
		, intFutOptTransactionId
		, intCommodityId
		, intItemId
		, intProductTypeId
		, intOrigUOMId
		, intBookId
		, intSubBookId
		, intLocationId
		, strInOut
		, dblOrigQty
		, dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes
		, strMiscFields
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, strOptionType
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strBuySell
		, ysnPreCrush
		, strBrokerTradeNo
		, intMatchNo
		, intMatchDerivativesHeaderId
		, intMatchDerivativesDetailId
		, strStorageTypeCode
		, ysnReceiptedStorage
		, intTypeId
		, strStorageType
		, intDeliverySheetId
		, strTicketStatus
		, strOwnedPhysicalStock
		, strStorageTypeDescription
		, ysnActive
		, ysnExternal
		, intStorageHistoryId
		, intInventoryReceiptItemId
		, intLoadDetailId)
	SELECT strBatchId
		, strBucketType
		, intActionId
		, strTransactionType = CASE WHEN strTransactionType LIKE 'Inventory Adjustment%' THEN 'Inventory Adjustment' ELSE strTransactionType END
		, intTransactionRecordId
		, intTransactionRecordHeaderId
		, strDistributionType
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intFutureMarketId
		, intFutureMonthId
		, intTransactionRecordId
		, intCommodityId
		, intItemId
		, intProductTypeId = NULL--I.intProductTypeId
		, intOrigUOMId = intCommodityUOMId
		, intBookId
		, intSubBookId
		, intLocationId
		, strInOut = CASE 
				WHEN strBucketType = 'Sales In-Transit' OR
						strBucketType = 'Purchase In-Transit' OR
						strBucketType = 'Customer Owned' OR
						strBucketType = 'Delayed Pricing' OR
						strBucketType = 'On Hold' OR
						strTransactionType = 'Inventory Receipt' OR
						strTransactionType = 'Produce' OR
						strTransactionType = 'Inventory Transfer' OR
						strTransactionType like 'Inventory Adjustment%' OR
						strTransactionType = 'Storage Settlement'
					THEN CASE WHEN ISNULL(dblQty, 0) >= 0 THEN 'IN' ELSE 'OUT' END
				WHEN strTransactionType = 'Inventory Shipment' OR
						strTransactionType = 'Invoice' OR
						strTransactionType  = 'Outbound Shipment' OR
						strTransactionType = 'Consume' 
					THEN CASE WHEN ISNULL(dblQty, 0) >= 0 THEN 'OUT' ELSE 'IN' END
				ELSE '' END
		, dblOrigQty = dblQty
		, dblPrice = dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes
		, strMiscFields
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, strOptionType
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strBuySell
		, ysnPreCrush
		, strBrokerTradeNo
		, intMatchNo
		, intMatchDerivativesHeaderId
		, intMatchDerivativesDetailId
		, strStorageTypeCode
		, ysnReceiptedStorage
		, intTypeId
		, strStorageType
		, intDeliverySheetId
		, strTicketStatus
		, strOwnedPhysicalStock
		, strStorageTypeDescription
		, ysnActive
		, ysnExternal
		, intStorageHistoryId
		, intInventoryReceiptItemId
		, intLoadDetailId
	FROM #tmpSummaryLogs


	
	Logging:

	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Processed ' + CAST(@intTransCtr AS NVARCHAR) + ' of ' + CAST(@intTotal AS NVARCHAR) + ' records.')
	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Starting Bulk Insert.')

	INSERT INTO tblRKSummaryLog(strBatchId
		, dtmCreatedDate
		, strBucketType
		, intActionId
		, strAction
		, strTransactionType
		, intTransactionRecordId
		, intTransactionRecordHeaderId
		, strDistributionType
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intFutureMarketId
		, intFutureMonthId
		, intFutOptTransactionId
		, intCommodityId
		, intLocationId
		, intItemId
		, intProductTypeId
		, intOrigUOMId
		, intBookId
		, intSubBookId
		, strInOut
		, dblOrigNoOfLots
		, dblContractSize
		, dblOrigQty
		, dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes
		, ysnNegate
		, intRefSummaryLogId
		, strMiscField
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, strOptionType
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strBuySell
		, ysnPreCrush
		, strBrokerTradeNo
		, intMatchNo
		, intMatchDerivativesHeaderId
		, intMatchDerivativesDetailId
		, strStorageTypeCode
		, ysnReceiptedStorage
		, intTypeId
		, strStorageType
		, intDeliverySheetId
		, strTicketStatus
		, strOwnedPhysicalStock
		, strStorageTypeDescription
		, ysnActive
		, ysnExternal
		, intStorageHistoryId
		, intInventoryReceiptItemId
		, intLoadDetailId)
	SELECT strBatchId
		, dtmCreatedDate = CASE WHEN @Rebuild = 1 THEN DATEADD(MI,(DATEDIFF(MI, SYSDATETIME(),SYSUTCDATETIME())), dtmTransactionDate) ELSE GETUTCDATE() END
		, strBucketType
		, intActionId
		, strAction = A.strActionIn 
		, strTransactionType
		, intTransactionRecordId
		, intTransactionRecordHeaderId
		, strDistributionType
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intFutureMarketId
		, intFutureMonthId
		, intFutOptTransactionId
		, intCommodityId
		, intLocationId
		, intItemId
		, intProductTypeId
		, intOrigUOMId
		, intBookId
		, intSubBookId
		, strInOut
		, dblOrigNoOfLots
		, dblContractSize
		, dblOrigQty
		, dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes
		, ysnNegate
		, intRefSummaryLogId
		, strMiscFields
		, intOptionMonthId
		, strOptionMonth
		, dblStrike
		, strOptionType
		, strInstrumentType
		, intBrokerageAccountId
		, strBrokerAccount
		, strBroker
		, strBuySell
		, ysnPreCrush
		, strBrokerTradeNo
		, intMatchNo
		, intMatchDerivativesHeaderId
		, intMatchDerivativesDetailId
		, strStorageTypeCode
		, ysnReceiptedStorage
		, intTypeId
		, strStorageType
		, intDeliverySheetId
		, strTicketStatus
		, strOwnedPhysicalStock
		, strStorageTypeDescription
		, ysnActive
		, ysnExternal
		, intStorageHistoryId
		, intInventoryReceiptItemId
		, intLoadDetailId
	FROM @FinalTable F
	LEFT JOIN tblRKLogAction A ON A.intLogActionId = F.intActionId
	ORDER BY dtmTransactionDate

	INSERT INTO tblRKRebuildRTSLog(strLogMessage) VALUES ('Bulk Insert done.')

	DROP TABLE #tmpSummaryLogs
END
