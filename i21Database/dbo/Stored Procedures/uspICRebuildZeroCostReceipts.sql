CREATE PROCEDURE [dbo].[uspICRebuildZeroCostReceipts]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @SourceTypeNone AS INT = 0
		,@SourceTypeScale AS INT = 1
		,@SourceTypeInboundShipment AS INT = 2
		,@SourceTypeTransport AS INT = 3
		,@SourceTypeSettleStorage AS INT = 4

		,@PurchaseTicketType AS INT = 1
		,@SaleTicketType AS INT = 2

		,@ReturnsBasisUOMSequenceType AS INT = 1
		,@ReturnFuturesUOMSequenceType AS INT = 2
		,@ReturnsFuturesBasisUOMSequenceType AS INT = 3

-- Assign the RM and Basis cost to the IR. 
UPDATE	ri
SET		ri.dblUnitCost = 
		--ISNULL( 
		--	dbo.fnRKGetFutureAndBasisPrice (
		--		@PurchaseTicketType	-- @intTicketType, -- 1- purchase. 2- sale.
		--		,st.intCommodityId	-- @intCommodityId
		--		,dbo.fnGetSeqMonth(cd.dtmEndDate) -- @strSeqMonth nvarchar(10) --'Dec 2016'
		--		,@ReturnFuturesUOMSequenceType -- @intSequenceTypeId -- 1.	‘01’ – Returns, Basis($) and Unit of Measure 2.	‘02’ – Returns, Futures($) and Unit of Measure   3. 	‘03’ – Returns, Futures($), Basis ($) and Unit of Measure
		--		,c.intFutureMarketId -- @intFutureMarketId  
		--		,r.intLocationId -- @intLocationId int = null,
		--		,cd.dblBasis -- @dblBasisCost NUMERIC(18, 6)
		--	), 0
		--) 

		ISNULL( 
			dbo.fnRKGetFutureAndBasisPrice (
				@PurchaseTicketType	--@intTicketType INT = 1	,-- 1- purchase. 2- sale.
				,st.intCommodityId--@intCommodityId INT = NULL
				,dbo.fnGetSeqMonth(cd.dtmEndDate)--@strSeqMonth NVARCHAR(10)	,--'Dec 2016'
				,1--cd.intPricingTypeId--@intSequenceTypeId INT,   -- 1.	‘01’ – Basis 2.	‘02’ – HTA   3. ‘03’ – DP    (PricingType Need to pass)
				,cd.intFutureMarketId--@intFutureMarketId INT= NULL  -- Contract Futre market Name
				,cd.intFutureMonthId--@intFutureMonthId INT= NULL -- Contract Future Month Id
				,r.intLocationId--@intLocationId INT = NULL
				,cd.intMarketZoneId--@intMarketZoneId INT = NULL
				,cd.dblBasis--@dblBasisCost NUMERIC(18, 6)
				,ri.intItemId--@intItemId int = null
			), 0
		) 
FROM	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st
			ON st.intTicketId = ri.intSourceId
		LEFT JOIN tblICCommodity c
			ON c.intCommodityId = st.intCommodityId
		LEFT JOIN (
			tblCTContractHeader ct INNER JOIN tblCTContractDetail cd
				ON ct.intContractHeaderId = cd.intContractHeaderId
		)
			ON ct.intContractHeaderId = ri.intOrderId
			AND cd.intContractDetailId = ri.intLineNo
		LEFT JOIN tblCTPricingType pt
			ON pt.intPricingTypeId = ct.intPricingTypeId
WHERE	ri.dblUnitCost = 0
		AND r.ysnPosted = 1
		AND r.intSourceType = @SourceTypeScale
		AND pt.strPricingType = 'Basis'

-- Assign the cost to the Inventory transaction from the IR transaction. 
UPDATE	t
SET		t.dblCost = ri.dblUnitCost
FROM	tblICInventoryReceipt r INNER JOIN (
			tblICInventoryReceiptItem ri LEFT JOIN tblICInventoryReceiptItemLot rl
				ON rl.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
		)
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st
			ON st.intTicketId = ri.intSourceId
		INNER JOIN tblICInventoryTransaction t
			ON t.strTransactionId = r.strReceiptNumber
			AND t.intTransactionId = r.intInventoryReceiptId
			AND t.intTransactionDetailId = ri.intInventoryReceiptItemId
			AND ISNULL(t.intLotId, 0) = ISNULL(rl.intLotId, 0) 
			AND t.ysnIsUnposted = 0 		
WHERE	t.dblCost <> ri.dblUnitCost 
		AND t.dblCost = 0 
		AND r.ysnPosted = 1
		AND r.intSourceType = @SourceTypeScale

-- Open the fiscal year periods
IF OBJECT_ID('tblGLFiscalYearPeriodOriginal') IS NULL 
BEGIN 
	SELECT	* 
	INTO	tblGLFiscalYearPeriodOriginal
	FROM	tblGLFiscalYearPeriod
END 

UPDATE tblGLFiscalYearPeriod
SET ysnOpen = 1
	,ysnINVOpen = 1
	,ysnAROpen = 1

-- Repost the inventory transaction 
EXEC uspICRebuildInventoryValuation
	@dtmStartDate = '01/01/2015' -- From the beginning. 
	,@strItemNo = NULL -- All items 
	,@isPeriodic = 1 -- Repost using periodic. 
	,@ysnRegenerateBillGLEntries = 0	-- Do regenerate the Voucher G/L entries. 

-- Re-close the fiscal year periods
UPDATE	FYPeriod
SET		ysnOpen = FYPeriodOriginal.ysnOpen
		,ysnINVOpen = FYPeriodOriginal.ysnINVOpen
		,ysnAROpen = FYPeriodOriginal.ysnAROpen
FROM	tblGLFiscalYearPeriod FYPeriod INNER JOIN tblGLFiscalYearPeriodOriginal FYPeriodOriginal
			ON FYPeriod.intGLFiscalYearPeriodId = FYPeriodOriginal.intGLFiscalYearPeriodId

DROP TABLE tblGLFiscalYearPeriodOriginal