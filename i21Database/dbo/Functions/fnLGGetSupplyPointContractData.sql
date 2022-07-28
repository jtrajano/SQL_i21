﻿CREATE FUNCTION [dbo].[fnLGGetSupplyPointContractData](
	@intEntityVendorId INT
	,@intEntityLocationId INT
	,@intItemId INT
	,@dtmEffectiveDate DATETIME = NULL
	,@intContractDetailId INT = NULL
)
RETURNS @returntable TABLE (
	intEntityVendorId INT
	,intVendorLocationId INT
	,intCategoryId INT NULL
	,intContractHeaderId INT NULL
	,intContractDetailId INT NULL
	,strContractNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intContractSeq INT NULL
	,dblBalance NUMERIC(18, 6) NULL
	,dblScheduleQty NUMERIC(18, 6) NULL
	,dblAvailableQty NUMERIC(18, 6) NULL
	,dblAppliedQty NUMERIC(18, 6) NULL
	,dtmStartDate DATETIME NULL
	,dtmEndDate DATETIME NULL)
AS
BEGIN

	DECLARE @intCategoryId INT
	SELECT @intCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @intItemId

	INSERT INTO @returntable 
	SELECT TOP 1
		intEntityVendorId = CH.intEntityId
		,CD.intVendorLocationId
		,CD.intCategoryId
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,CH.strContractNumber
		,CD.intContractSeq
		,CD.dblBalance
		,dblScheduleQty = ISNULL(CD.dblScheduleQty, 0)
		,dblAvailableQty = CD.dblBalance - ISNULL(CD.dblScheduleQty, 0)
		,dblAppliedQty = CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END
		,CD.dtmStartDate 
		,CD.dtmEndDate
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
	WHERE CH.ysnSupplyPointContract = 1 
		AND CD.intCategoryId = @intCategoryId
		AND ((@intContractDetailId IS NOT NULL AND @intContractDetailId = CD.intContractDetailId)
			OR (@intContractDetailId IS NULL AND (@dtmEffectiveDate IS NULL OR @dtmEffectiveDate BETWEEN CD.dtmStartDate AND CD.dtmEndDate)))
		AND ((@intCategoryId IS NOT NULL AND @intCategoryId = CD.intCategoryId))
	ORDER BY CD.dtmStartDate DESC

	IF NOT EXISTS(SELECT 1 FROM @returntable) 
		INSERT INTO @returntable 
		SELECT
			intEntityVendorId = @intEntityVendorId
			,intVendorLocationId = @intEntityLocationId
			,intCategoryId = @intCategoryId
			,intContractHeaderId = NULL
			,intContractDetailId = NULL
			,strContractNumber = NULL
			,intContractSeq = NULL
			,dblBalance = 0
			,dblScheduleQty = 0
			,dblAvailableQty = 0
			,dblAppliedQty = 0
			,dtmStartDate = NULL
			,dtmEndDate = NULL
	
	RETURN;
	END
GO
