CREATE PROCEDURE [dbo].[uspRKLogRiskPosition]
	@SummaryLogs RKSummaryLog READONLY
	, @Rebuild BIT = 0
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN	
	DECLARE @intId INT
		, @strBatchId NVARCHAR(100)
		, @strTransactionType NVARCHAR(100)
		, @intTransactionRecordId INT
		, @strTransactionNumber NVARCHAR(100)
		, @dtmTransactionDate DATETIME
		, @intContractDetailId INT
		, @intContractHeaderId INT
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
		, @intUserId INT
		, @intEntityId INT
		, @ysnDelete BIT
		, @strNotes NVARCHAR(250)

	DECLARE @FinalTable AS TABLE (strBatchId NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intTransactionRecordId INT NOT NULL
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
		, strNotes NVARCHAR(250) NULL)

	SELECT * INTO #tmpSummaryLogs FROM @SummaryLogs

	-- Validate Batch Id
	IF EXISTS(SELECT TOP 1 1 FROM #tmpSummaryLogs WHERE ISNULL(strBatchId, '') = '')
	BEGIN
		EXEC uspSMGetStartingNumber 148, @strBatchId OUTPUT

		UPDATE tmp
		SET strBatchId = @strBatchId
		FROM #tmpSummaryLogs tmp
		WHERE ISNULL(strBatchId, '') = ''
	END

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpSummaryLogs)
	BEGIN
		SELECT TOP 1 @intId = intId
			, @strBatchId = strBatchId
			, @strTransactionType = strTransactionType
			, @intTransactionRecordId = intTransactionRecordId
			, @strTransactionNumber = strTransactionNumber
			, @dtmTransactionDate = dtmTransactionDate
			, @intContractDetailId = intContractDetailId
			, @intContractHeaderId = intContractHeaderId
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
			, @intUserId = intUserId
			, @intEntityId = intEntityId
			, @strNotes = strNotes
			, @ysnDelete = ysnDelete
		FROM #tmpSummaryLogs

		SELECT TOP 1 * INTO #tmpPrevLog FROM tblRKSummaryLog WHERE strTransactionType = @strTransactionType AND intTransactionRecordId = @intTransactionRecordId
		ORDER BY intSummaryLogId DESC

		-- Insert Delete Entry
		IF (ISNULL(@ysnDelete, 0) = 1)
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
			SELECT strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END
				, dblOrigNoOfLots * -1
				, dblContractSize
				, dblOrigQty * -1
				, dblPrice
				, intEntityId
				, intTicketId
				, @intUserId
				, 'Delete Record'
			FROM #tmpPrevLog
			CONTINUE
		END

		-- Validate if no changes was detected on fields with bearing
		IF EXISTS(SELECT TOP 1 1
			FROM #tmpPrevLog
			WHERE intTransactionRecordId = @intTransactionRecordId
				AND strTransactionType = @strTransactionType
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
			CONTINUE
		END

		-- Log counter entry to negate previous value
		IF (@strTransactionType IN ('Derivatives', 'Collateral', 'Collateral Adjustments'))
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM #tmpPrevLog)
			BEGIN
				INSERT INTO @FinalTable(strBatchId
					, strTransactionType
					, intTransactionRecordId
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
				SELECT strBatchId
					, strTransactionType
					, intTransactionRecordId
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
					, CASE WHEN strInOut = 'IN' THEN 'OUT' ELSE 'IN' END
					, dblOrigNoOfLots * -1
					, dblContractSize
					, dblOrigQty * -1
					, dblPrice
					, intEntityId
					, intTicketId
					, @intUserId
					, '(Negate previous value)' + ISNULL(strNotes, '')
				FROM #tmpPrevLog
			END
		END

		---------------------------------------
		------------ DERIVATIVES --------------
		---------------------------------------
		IF @strTransactionType = 'Derivatives'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
				, intLocationId = NULL
				, strInOut = CASE WHEN UPPER(der.strBuySell) = 'BUY' THEN 'IN' ELSE 'OUT' END
				, dblOrigNoOfLots = @dblNoOfLots * CASE WHEN UPPER(der.strBuySell) = 'BUY' THEN 1 ELSE -1 END
				, dblContractSize = m.dblContractSize
				, dblOrigQty = @dblNoOfLots * m.dblContractSize * CASE WHEN UPPER(der.strBuySell) = 'BUY' THEN 1 ELSE -1 END
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
			FROM tblRKFutOptTransaction der
			JOIN tblRKFutureMarket m ON m.intFutureMarketId = der.intFutureMarketId
			LEFT JOIN tblICCommodityUnitMeasure cUOM ON cUOM.intCommodityId = der.intCommodityId AND cUOM.intUnitMeasureId = m.intUnitMeasureId
			WHERE der.intFutOptTransactionId = @intTransactionRecordId
		END

		---------------------------------------
		------------- COLLATERAL --------------
		---------------------------------------
		ELSE IF @strTransactionType = 'Collateral'
		BEGIN
			SELECT TOP 1 @intFutureMarketId = CD.intFutureMarketId
				, @intFutureMonthId = CD.intFutureMonthId
				, @intEntityId = CH.intEntityId
			FROM tblCTContractDetail CD
			LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			WHERE CD.intContractHeaderId = @intContractHeaderId

			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
				, strInOut = CASE WHEN UPPER(col.strType) = 'PURCHASE' THEN 'IN' ELSE 'OUT' END
				, dblOrigNoOfLots = 0
				, dblContractSize = 0
				, dblOrigQty = @dblQty * CASE WHEN UPPER(col.strType) = 'PURCHASE' THEN 1 ELSE -1 END
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
			FROM tblRKCollateral col	
			WHERE col.intCollateralId = @intTransactionRecordId

			SET @intContractDetailId = NULL
		END

		---------------------------------------
		------- COLLATERAL ADJUSTMENTS --------
		---------------------------------------
		ELSE IF @strTransactionType = 'Collateral Adjustments'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
				, strInOut = CASE WHEN UPPER(col.strType) = 'SALE' THEN 'IN' ELSE 'OUT' END
				, dblOrigNoOfLots = 0
				, dblContractSize = 0
				, dblOrigQty = @dblQty * CASE WHEN UPPER(col.strType) = 'SALE' THEN 1 ELSE -1 END
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
			FROM tblRKCollateral col		
			WHERE col.intCollateralId = @intTransactionRecordId

			SET @intContractDetailId = NULL
		END

		----------------------------------------------
		------------- Inventory Receipt --------------
		----------------------------------------------
		ELSE IF @strTransactionType = 'Inventory Receipt'
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
				, strInOut = CASE WHEN ISNULL(@dblQty, 0) >= 0 THEN 'IN' ELSE 'OUT' END
				, dblOrigQty = @dblQty
				, dblPrice = @dblPrice
				, @intEntityId
				, @intTicketId
				, @intUserId
				, @strNotes
			FROM tblICInventoryReceiptItem IRI
			LEFT JOIN tblICItem I ON I.intItemId = IRI.intItemId
			WHERE IRI.intInventoryReceiptItemId = @intTransactionRecordId
		END

		------------------------------------
		------------- Voucher --------------
		------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
		------------- Invoice --------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			INSERT INTO @FinalTable(strBatchId
				, strTransactionType
				, intTransactionRecordId
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
				, @strTransactionType
				, @intTransactionRecordId
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
			FROM tblARInvoiceDetail ID
			LEFT JOIN tblICItem I ON I.intItemId = ID.intItemId
			WHERE ID.intInvoiceDetailId = @intTransactionRecordId
		END

		---------------------------------------
		------------- Grain --------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			PRINT 'BEGIN ' + @strTransactionType

			PRINT 'END ' + @strTransactionType
		END

		---------------------------------------
		------------- Scale --------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			PRINT 'BEGIN ' + @strTransactionType

			PRINT 'END ' + @strTransactionType
		END

		---------------------------------------
		--------- Contract Sequence -----------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			PRINT 'BEGIN ' + @strTransactionType

			PRINT 'END ' + @strTransactionType
		END

		---------------------------------------
		----------- Price Fixation ------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			PRINT 'BEGIN ' + @strTransactionType

			PRINT 'END ' + @strTransactionType
		END

		---------------------------------------
		-------------            --------------
		---------------------------------------
		ELSE IF @strTransactionType = ''
		BEGIN
			PRINT 'BEGIN ' + @strTransactionType

			PRINT 'END ' + @strTransactionType
		END

		------------------------------
		-- Process Contract Balance --
		------------------------------
		IF (ISNULL(@intContractDetailId, 0) <> 0)
		BEGIN
			DECLARE @cbLog AS CTContractBalanceLog

			IF (@strTransactionType = 'Contract Sequence')
			BEGIN
				INSERT INTO @cbLog (strBatchId
					, strTransactionType
					, intContractDetailId
					, intContractHeaderId
					, intContractTypeId
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
					, @strTransactionType
					, @intContractDetailId
					, @intContractHeaderId				
					, intContractTypeId
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
			END
			ELSE IF (@strTransactionType = 'Price Fixation')
			BEGIN
				INSERT INTO @cbLog (strBatchId
					, strTransactionType
					, intContractDetailId
					, intContractHeaderId
					, intContractTypeId
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
					, @strTransactionType
					, @intContractDetailId
					, @intContractHeaderId
					, intContractTypeId
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
				JOIN tblCTContractDetail cd ON cd.intContractDetailId = pf.intContractDetailId
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
				INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = ch.intCommodityId AND cum.ysnDefault = 1
				WHERE cd.intContractDetailId = @intContractHeaderId
					AND cd.intContractHeaderId = @intContractDetailId
			END

			EXEC uspCTLogContractBalance @cbLog, 0
		END
		------------------------------
		------------------------------

		
		DROP TABLE #tmpPrevLog

		DELETE FROM #tmpSummaryLogs
		WHERE intId = @intId
	END

	INSERT INTO tblRKSummaryLog(strBatchId
		, dtmCreatedDate
		, strTransactionType
		, intTransactionRecordId
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
		, strInOut
		, dblOrigNoOfLots
		, dblContractSize
		, dblOrigQty
		, dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes)
	SELECT strBatchId
		, dtmCreatedDate = CASE WHEN @Rebuild = 1 THEN dtmTransactionDate ELSE GETDATE() END
		, strTransactionType
		, intTransactionRecordId
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
		, strInOut
		, dblOrigNoOfLots
		, dblContractSize
		, dblOrigQty
		, dblPrice
		, intEntityId
		, intTicketId
		, intUserId
		, strNotes
	FROM @FinalTable

	DROP TABLE #tmpSummaryLogs
END