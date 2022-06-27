CREATE PROCEDURE uspMFGetShortTermPlanningView (
	@intDemandHeaderId INT
	,@intUnitMeasureId INT
	,@intCompanyLocationId INT = NULL
	,@intCategoryId INT = NULL
	,@strItemId NVARCHAR(MAX) = ''
	)
AS
BEGIN
	DECLARE @dtmCurrentMonthStartDate DATETIME
		,@dtmCurrentMonthEndDate DATETIME
		,@dtmNextMonthStartDate DATETIME
		,@dtmNextMonthEndDate DATETIME
		,@intRemainingDay INT
		,@intNoOfDays INT
		,@dtmEndDateAfterSixMonth DATETIME
		,@intConditionId INT
	DECLARE @tblMFItem TABLE (intItemId INT)
	DECLARE @tblSMCompanyLocation TABLE (intCompanyLocationId INT)

	SELECT @dtmCurrentMonthStartDate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)

	SELECT @dtmCurrentMonthEndDate = dateadd(day, - 1, dateadd(month, 1, @dtmCurrentMonthStartDate))

	SELECT @dtmNextMonthStartDate = dateadd(month, 1, @dtmCurrentMonthStartDate)

	SELECT @dtmNextMonthEndDate = dateadd(day, - 1, dateadd(month, 1, @dtmNextMonthStartDate))

	SELECT @dtmEndDateAfterSixMonth = dateadd(day, - 1, dateadd(month, 6, @dtmCurrentMonthStartDate))

	IF @intCategoryId > 0
		AND @strItemId = ''
	BEGIN
		INSERT INTO @tblMFItem (intItemId)
		SELECT I.intItemId
		FROM tblICItem I
		WHERE I.intCategoryId = @intCategoryId
			AND I.strStatus = 'Active'
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFItem (intItemId)
		SELECT I.intItemId
		FROM tblICItem I
		WHERE I.intCategoryId = @intCategoryId
			AND I.strStatus = 'Active'
			AND I.intItemId IN (
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strItemId, ',')
				)
	END

	IF @intCompanyLocationId IS NULL
	BEGIN
		INSERT INTO @tblSMCompanyLocation (intCompanyLocationId)
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
	END
	ELSE
	BEGIN
		INSERT INTO @tblSMCompanyLocation (intCompanyLocationId)
		SELECT @intCompanyLocationId AS intCompanyLocationId
	END

	--Attribute Id
	--1-->Balance Month Forecast
	--2-->Next Month Forecast
	--3-->Avg 6 months Forecast
	--4-->DOH
	--5-->Available Inventory
	--6-->Approved Qty
	--7-->Not Approved Qty
	--8-->In-Transit to WHSE
	--9-->Arrived in Port
	--10-->Scheduled
	--11-->CBS
	--12-->Late Open Contracts
	--13-->Forward Open Contracts
	--14-->No ETA
	IF OBJECT_ID('tempdb..#tblMFShortTermDemand') IS NOT NULL
		DROP TABLE #tblMFShortTermDemand

	SELECT @intRemainingDay = DATEDIFF(day, getdate(), DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0))) + 1

	SELECT @intNoOfDays = datediff(dd, getdate(), dateadd(mm, 1, getdate()))

	CREATE TABLE #tblMFPreShortTermDemand (
		intItemId INT
		,intLocationId INT
		,dblQty NUMERIC(18, 0)
		--,intItemUOMId INT
		,intAttributeId INT
		)

	CREATE TABLE #tblMFShortTermDemand (
		intItemId INT
		,intLocationId INT
		,dblQty NUMERIC(18, 0)
		--,intItemUOMId INT
		,intAttributeId INT
		)

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT DD.intItemId
		,DD.intCompanyLocationId AS intLocationId
		,dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (DD.dblQuantity * @intRemainingDay / @intNoOfDays)) AS dblQty
		,1 AS intAttributeId -->Balance Month Forecast
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
		AND dtmDemandDate BETWEEN @dtmCurrentMonthStartDate
			AND @dtmCurrentMonthEndDate

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT DD.intItemId
		,DD.intCompanyLocationId AS intLocationId
		,dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity) AS dblQty
		,2 AS intAttributeId -->Next Month Forecast
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
		AND dtmDemandDate BETWEEN @dtmNextMonthStartDate
			AND @dtmNextMonthEndDate

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT DD.intItemId
		,DD.intCompanyLocationId AS intLocationId
		,Sum(dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity)) / 6 AS dblQty
		,3 AS intAttributeId -->Avg 6 months Forecast
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
		AND dtmDemandDate BETWEEN @dtmCurrentMonthStartDate
			AND @dtmEndDateAfterSixMonth
	GROUP BY DD.intItemId
		,DD.intCompanyLocationId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT L.intItemId
		,L.intLocationId AS intLocationId
		,Sum(dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, L.dblWeight)) AS dblQty
		,5 AS intAttributeId -->Available Inventory
	FROM tblICLot L
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	JOIN @tblMFItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intWeightUOMId
	WHERE L.dblQty > 0
	GROUP BY L.intItemId
		,L.intLocationId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT Inv.intItemId
		,Inv.intLocationId
		,Inv.dblQty / IsNULL(CASE 
				WHEN F.dblQty = 0
					THEN 1
				ELSE F.dblQty
				END, 1)*30
		,4 AS intAttributeId -->DOH
	FROM #tblMFShortTermDemand Inv
	LEFT JOIN #tblMFShortTermDemand F ON F.intItemId = Inv.intItemId
		AND F.intLocationId = Inv.intLocationId AND F.intAttributeId=3
	WHERE Inv.intAttributeId = 5

	DELETE
	FROM #tblMFPreShortTermDemand

	INSERT INTO #tblMFPreShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0)) AS dblQty
		,(
			CASE 
				WHEN S.intLoadDetailContainerLinkId IS NOT NULL
					THEN 6 -->Approved Qty
				ELSE 7 -->Not Approved Qty
				END
			) AS intAttributeId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.intShipmentType = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
		AND S.intSampleStatusId = 3 -->Approved
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
		AND SS.intContractStatusId IN (
			1
			,4
			)
		AND L.dtmETAPOD <= GETDATE()

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT intItemId
		,intLocationId
		,SUM(dblQty)
		,intAttributeId
	FROM #tblMFPreShortTermDemand
	GROUP BY intItemId
		,intLocationId
		,intAttributeId

	DELETE
	FROM #tblMFPreShortTermDemand

	INSERT INTO #tblMFPreShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0)) AS dblQty
		,(
			CASE 
				WHEN L.dtmETAPOD IS NOT NULL
					THEN 8 -->In-Transit to WHSE
				ELSE 9 -->Arrived in Port
				END
			) AS intAttributeId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.intShipmentType = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
		AND S.intSampleStatusId = 3 -->Approved
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
		AND SS.intContractStatusId IN (
			1
			,4
			)
		AND S.intLoadDetailContainerLinkId IS NULL
		AND LW.intLoadId IS NULL
		AND L.ysnArrivedInPort = 1

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT intItemId
		,intLocationId
		,SUM(dblQty)
		,intAttributeId
	FROM #tblMFPreShortTermDemand
	GROUP BY intItemId
		,intLocationId
		,intAttributeId

	SELECT @intConditionId = intConditionId
	FROM tblCTCondition
	WHERE strConditionName = 'CBS'

	DELETE
	FROM #tblMFPreShortTermDemand

	INSERT INTO #tblMFPreShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity) AS dblQty
		,(
			CASE 
				WHEN LC.intLoadId IS NOT NULL
					THEN 11 -->CBS
				WHEN L.intShipmentStatus = 1
					THEN 10 -->Scheduled
				END
			) AS intAttributeId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.intShipmentType = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblLGLoadCondition LC ON LC.intLoadId = L.intLoadId
		AND LC.intConditionId = @intConditionId
	WHERE SS.intContractStatusId IN (
			1
			,4
			)

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT intItemId
		,intLocationId
		,SUM(dblQty)
		,intAttributeId
	FROM #tblMFPreShortTermDemand
	GROUP BY intItemId
		,intLocationId
		,intAttributeId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblQuantity - IsNULL(SS.dblScheduleQty, 0))) AS dblQty
		,12 AS intAttributeId -->Late Open Contracts
	FROM tblCTContractDetail SS
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	WHERE SS.intContractStatusId IN (
			1
			,4
			)
		AND SS.dtmUpdatedAvailabilityDate < @dtmCurrentMonthStartDate
		AND SS.dblQuantity - IsNULL(SS.dblScheduleQty, 0) > 0
	GROUP BY I.intItemId
		,SS.intCompanyLocationId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblQuantity - IsNULL(SS.dblScheduleQty, 0))) AS dblQty
		,13 AS intAttributeId -->Forward Open Contracts
	FROM tblCTContractDetail SS
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	WHERE SS.intContractStatusId IN (
			1
			,4
			)
		AND SS.dtmUpdatedAvailabilityDate BETWEEN @dtmCurrentMonthStartDate
			AND @dtmNextMonthEndDate
		AND SS.dblQuantity - IsNULL(SS.dblScheduleQty, 0) > 0
	GROUP BY I.intItemId
		,SS.intCompanyLocationId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT I.intItemId
		,SS.intCompanyLocationId
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0))) AS dblQty
		,14 AS intAttributeId -->No ETA
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.intShipmentType = 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE ISNULL(LDCL.dblQuantity, LD.dblQuantity) - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
		AND SS.intContractStatusId IN (
			1
			,4
			)
		AND L.ysnArrivedInPort <> 1
		AND L.dtmETAPOD IS NULL
	GROUP BY I.intItemId
		,SS.intCompanyLocationId

	SELECT CONVERT(INT, ROW_NUMBER() OVER (
				ORDER BY (
						SELECT 1
						)
				)) AS intRowNo
		,pvt.intItemId
		,L.strLotOrigin AS strCompany
		,L.strLocationName AS strCompanyLocation
		,I.strItemNo
		,I.strDescription
		,C.strCategoryCode AS strItemCategory
		,I.strExternalGroup AS strItemGroup
		,CA.strDescription AS strProductType
		,CA1.strDescription AS strOrigin
		,C2.strCertificationName AS strCertification
		,[1] AS dblCurrentMonthForecast
		,[2] AS dblNextMonthForecast
		,[3] AS dblAvg6MonthsForecast
		,[4] AS dblDOH
		,[5] AS dblAvailableInventory
		,[6] AS dblApprovedQty
		,[7] AS dblNotApprovedQty
		,[8] AS dblInTransittoWHSE
		,[9] AS dblArrivedInPort
		,[10] AS dblScheduled
		,[11] AS dblCBS
		,[12] AS dblLateOpenContracts
		,[13] AS dblForwardOpenContracts
		,[14] AS dblNoETA
	FROM (
		SELECT *
		FROM #tblMFShortTermDemand
		) src
	PIVOT(MAX(src.dblQty) FOR src.intAttributeId IN (
				[1]
				,[2]
				,[3]
				,[4]
				,[5]
				,[6]
				,[7]
				,[8]
				,[9]
				,[10]
				,[11]
				,[12]
				,[13]
				,[14]
				)) AS pvt
	JOIN dbo.tblICItem I ON I.intItemId = pvt.intItemId
	JOIN dbo.tblICCategory C ON C.intCategoryId = I.intCategoryId
	JOIN dbo.tblSMCompanyLocation L ON L.intCompanyLocationId = pvt.intLocationId
	LEFT JOIN dbo.tblICCommodityAttribute CA ON CA.intCommodityId = I.intCommodityId
		AND CA.intCommodityAttributeId = I.intProductTypeId
	LEFT JOIN tblICCommodityAttribute CA1 ON CA1.intCommodityAttributeId = I.intOriginId
	OUTER APPLY (
		SELECT TOP 1 C2.strCertificationName
		FROM tblICItemCertification IC
		JOIN tblICCertification C2 ON C2.intCertificationId = IC.intCertificationId
			AND IC.intItemId = I.intItemId
		) C2
END
