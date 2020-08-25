CREATE PROCEDURE [dbo].[uspICGetCommodityActivity]
	@dtmDate  AS DATETIME,
	@guidSessionId UNIQUEIDENTIFIER,
	@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

EXEC uspICGetDailyStockPosition 
	@dtmDate
	, @guidSessionId
	, @intUserId
	
INSERT INTO tblICStagingCommodityActivity(
	guidSessionId,
	intCommodityId,
	strCommodityCode,
	dtmDate,
	intCategoryId,
	strCategoryCode,
	intLocationId,
	strLocationName,
	strItemUOM,

	dblOpeningQty,
	dblReceivedQty,
	dblInvoicedQty,
	dblAdjustments,
	dblTransfersReceived,
	dblTransfersShipped,
	dblInTransitInbound,
	dblInTransitOutbound,
	dblConsumed,
	dblProduced,
	dblClosingQty,
	ysnLocationLicensed
)
SELECT 
	a.guidSessionId
	,a.intCommodityId
	,a.strCommodityCode
	,a.dtmDate
	,a.intCategoryId
	,a.strCategoryCode
	,a.intLocationId
	,a.strLocationName
	,a.strItemUOM
	,sum(a.dblOpeningQty) AS dblOpeningQty
	,sum(a.dblReceivedQty) AS dblReceivedQty
	,sum(a.dblInvoicedQty) AS dblInvoicedQty
	,sum(a.dblAdjustments) AS dblAdjustments
	,sum(a.dblTransfersReceived) AS dblTransfersReceived
	,sum(a.dblTransfersShipped) AS dblTransfersShipped
	,sum(a.dblInTransitInbound) AS dblInTransitInbound
	,sum(a.dblInTransitOutbound) AS dblInTransitOutbound
	,sum(a.dblConsumed) AS dblConsumed
	,sum(a.dblProduced) AS dblProduced
	,sum(a.dblClosingQty) AS dblClosingQty
	,b.ysnLicensed AS ysnLocationLicensed 

FROM 
	tblICStagingDailyStockPosition AS a
	INNER JOIN tblSMCompanyLocation AS b
		ON a.intLocationId = b.intCompanyLocationId
WHERE 
	a.guidSessionId = @guidSessionId
group by
	a.guidSessionId
	,a.intCommodityId
	,a.strCommodityCode
	,a.dtmDate
	,a.intCategoryId
	,a.strCategoryCode
	,a.intLocationId
	,a.strLocationName
	,a.strItemUOM
	,b.ysnLicensed

DELETE 
FROM tblICStagingDailyStockPosition
WHERE guidSessionId = @guidSessionId