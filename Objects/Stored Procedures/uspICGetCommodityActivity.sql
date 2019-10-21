CREATE PROCEDURE [dbo].[uspICGetCommodityActivity]
	@dtmDate AS DATETIME,
	@guidSessionId UNIQUEIDENTIFIER,
	@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF




	exec uspICGetDailyStockPosition @dtmDate, @guidSessionId, @intUserId



	insert into tblICStagingCommodityActivity(
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
	select 

		a.guidSessionId
		,a.intCommodityId
		,a.strCommodityCode
		,a.dtmDate
		,a.intCategoryId
		,a.strCategoryCode
		,a.intLocationId
		,a.strLocationName
		,a.strItemUOM
		,sum(a.dblOpeningQty) as dblOpeningQty
		,sum(a.dblReceivedQty) as dblReceivedQty
		,sum(a.dblInvoicedQty) as dblInvoicedQty
		,sum(a.dblAdjustments) as dblAdjustments
		,sum(a.dblTransfersReceived) as dblTransfersReceived
		,sum(a.dblTransfersShipped) as dblTransfersShipped
		,sum(a.dblInTransitInbound) as dblInTransitInbound
		,sum(a.dblInTransitOutbound) as dblInTransitOutbound
		,sum(a.dblConsumed) as dblConsumed
		,sum(a.dblProduced) as dblProduced
		,sum(a.dblClosingQty) as dblClosingQty
		,b.ysnLicensed as ysnLocationLicensed 

	from tblICStagingDailyStockPosition as a
		join tblSMCompanyLocation as b
			on a.intLocationId = b.intCompanyLocationId
		where a.guidSessionId = @guidSessionId
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

	delete 
		from tblICStagingDailyStockPosition
			where guidSessionId = @guidSessionId



