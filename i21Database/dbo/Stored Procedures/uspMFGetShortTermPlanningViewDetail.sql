CREATE PROCEDURE [dbo].[uspMFGetShortTermPlanningViewDetail] (
	@intItemId INT = 0
	,@strColumnName NVARCHAR(50) = 'Available Inventory'
	,@intDemandHeaderId INT
	,@intUnitMeasureId INT
	,@intCompanyLocationId INT = 0
	,@intUserId INT
	,@intCategoryId INT = NULL
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
		,@dtmCurrentDate DATETIME
		,@dtmAfter80Days DATETIME
	DECLARE @tblMFItem TABLE (intItemId INT)
	DECLARE @tblSMCompanyLocation TABLE (intCompanyLocationId INT)

	SELECT @dtmCurrentDate = GETDATE()

	SELECT @dtmAfter80Days = @dtmCurrentDate + 80

	SELECT @dtmCurrentMonthStartDate = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)

	SELECT @dtmCurrentMonthEndDate = dateadd(day, - 1, dateadd(month, 1, @dtmCurrentMonthStartDate))

	SELECT @dtmNextMonthStartDate = dateadd(month, 1, @dtmCurrentMonthStartDate)

	SELECT @dtmNextMonthEndDate = dateadd(day, - 1, dateadd(month, 1, @dtmNextMonthStartDate))

	SELECT @dtmEndDateAfterSixMonth = dateadd(day, - 1, dateadd(month, 6, @dtmCurrentMonthStartDate))

	IF @intItemId > 0
	BEGIN
		INSERT INTO @tblMFItem (intItemId)
		SELECT I.intItemId
		FROM tblICItem I
		WHERE I.intItemId = @intItemId
			AND I.strStatus = 'Active'
	END
	ELSE
	BEGIN
		INSERT INTO @tblMFItem (intItemId)
		SELECT I.intItemId
		FROM tblICItem I
		WHERE I.intCategoryId = @intCategoryId
			AND I.strStatus = 'Active'
	END

	IF @intCompanyLocationId = 0
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

	CREATE TABLE #tblMFShortTermDemand (
		intItemId INT
		,intLocationId INT
		,dblQty NUMERIC(18, 0)
		,intAttributeId INT
		)

	DELETE
	FROM tblMFShortTermPlanningViewDetail
	WHERE intUserId = @intUserId

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

	INSERT INTO tblMFShortTermPlanningViewDetail (
		intContractDetailId
		,intItemId
		,intLocationId
		,dblQty
		,strQtyUOM
		,dblWeight
		,strWeightUOM
		,intAttributeId
		,intUserId
		,strContainerNumber
		,strMarks
		,intSubLocationId
		)
	SELECT L.intContractDetailId
		,L.intItemId
		,L.intLocationId AS intLocationId
		,SUM(L.dblQty)
		,U1.strUnitMeasure
		,SUM(L.dblWeight)
		,U2.strUnitMeasure
		,5 AS intAttributeId -->Available Inventory
		,@intUserId
		,L.strContainerNo
		,L.strMarkings
		,L.intSubLocationId
	FROM tblICLot L
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	JOIN @tblMFItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intItemUOMId
	JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM IU2 ON IU2.intItemUOMId = L.intWeightUOMId
	LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = IU2.intUnitMeasureId
	WHERE L.dblQty > 0
	GROUP BY L.intContractDetailId
		,L.intItemId
		,L.intLocationId
		,U1.strUnitMeasure
		,U2.strUnitMeasure
		,L.strContainerNo
		,L.strMarkings
		,L.intSubLocationId

	INSERT INTO #tblMFShortTermDemand (
		intItemId
		,intLocationId
		,dblQty
		,intAttributeId
		)
	SELECT Inv.intItemId
		,Inv.intLocationId
		,(
			CASE 
				WHEN Max(F.dblQty) = 0
					THEN 0
				ELSE SUM(Inv.dblWeight) / MAX(F.dblQty)
				END
			) * 30
		,4 AS intAttributeId -->DOH
	FROM tblMFShortTermPlanningViewDetail Inv
	LEFT JOIN #tblMFShortTermDemand F ON F.intItemId = Inv.intItemId
		AND F.intLocationId = Inv.intLocationId
		AND F.intAttributeId = 3
	WHERE Inv.intAttributeId = 5
		AND intUserId = @intUserId
	GROUP BY Inv.intItemId
		,Inv.intLocationId

	IF @strColumnName NOT IN (
			'Available Inventory'
			,'All Item'
			)
	BEGIN
		DELETE
		FROM tblMFShortTermPlanningViewDetail
		WHERE intUserId = @intUserId
	END

	IF @strColumnName IN (
			'Approved Qty'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,6 AS intAttributeId -->Approved Qty
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
			AND S.intSampleStatusId = 3 -->Approved
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseContainer LC ON LC.intLoadWarehouseId = LW.intLoadWarehouseId
			AND LC.intLoadContainerId = LDCL.intLoadContainerId
		WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
			AND SS.intContractStatusId IN (
				1
				,4
				)
			AND L.dtmETAPOD <= GETDATE()
	END

	IF @strColumnName IN (
			'Not Approved Qty'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,7 AS intAttributeId -->Not Approved Qty
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		JOIN tblLGLoadWarehouseContainer LC ON LC.intLoadWarehouseId = LW.intLoadWarehouseId
			AND LC.intLoadContainerId = LDCL.intLoadContainerId
		WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
			AND SS.intContractStatusId IN (
				1
				,4
				)
			AND L.dtmETAPOD <= @dtmCurrentDate
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 3 -->Approved)
				)
	END

	IF @strColumnName IN (
			'InTransit to WHSE'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,8 AS intAttributeId -->In-Transit to WHSE
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
			AND S.intSampleStatusId = 3 -->Approved
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadWarehouseContainer LC ON LC.intLoadWarehouseId = LW.intLoadWarehouseId
			AND LC.intLoadContainerId = LDCL.intLoadContainerId
		WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
			AND SS.intContractStatusId IN (
				1
				,4
				)
			AND S.intLoadDetailContainerLinkId IS NULL
			AND LC.intLoadWarehouseContainerId IS NULL
			AND L.ysnArrivedInPort = 1
			AND L.dtmETAPOD IS NOT NULL
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShortTermPlanningViewDetail SP
				WHERE SP.intLoadContainerId = LDCL.intLoadContainerId
					AND SP.intUserId = @intUserId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 4 -->Rejected)
				)
	END

	IF @strColumnName IN (
			'Arrived in Port'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,9 AS intAttributeId -->Arrived in Port
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
			AND S.intSampleStatusId = 3 -->Approved
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadWarehouseContainer LC ON LC.intLoadWarehouseId = LW.intLoadWarehouseId
			AND LC.intLoadContainerId = LDCL.intLoadContainerId
		WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
			AND SS.intContractStatusId IN (
				1
				,4
				)
			AND S.intLoadDetailContainerLinkId IS NULL
			AND LC.intLoadWarehouseContainerId IS NULL
			AND L.ysnArrivedInPort = 1
			AND L.dtmETAPOD IS NULL
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShortTermPlanningViewDetail SP
				WHERE SP.intLoadContainerId = LDCL.intLoadContainerId
					AND SP.intUserId = @intUserId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 4 -->Rejected)
				)
	END

	SELECT @intConditionId = intConditionId
	FROM tblCTCondition
	WHERE strConditionName = 'CBS'

	IF @strColumnName IN (
			'CBS'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,11 AS intAttributeId -->CBS
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		JOIN tblLGLoadCondition LC ON LC.intLoadId = L.intLoadId
			AND LC.intConditionId = @intConditionId
		WHERE SS.intContractStatusId IN (
				1
				,4
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShortTermPlanningViewDetail SP
				WHERE SP.intLoadContainerId = LDCL.intLoadContainerId
					AND SP.intUserId = @intUserId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 4 -->Rejected)
				)
	END

	IF @strColumnName IN (
			'Scheduled'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LD.intPContractDetailId
			,LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,10 AS intAttributeId -->Scheduled
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		WHERE SS.intContractStatusId IN (
				1
				,4
				)
			AND L.intShipmentStatus = 1
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShortTermPlanningViewDetail SP
				WHERE SP.intLoadContainerId = LDCL.intLoadContainerId
					AND SP.intUserId = @intUserId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 4 -->Rejected)
				)
	END

	IF @strColumnName IN (
			'Late Open Contracts'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT SS.intContractDetailId
			,I.intItemId
			,SS.intCompanyLocationId
			,12 AS intAttributeId -->Late Open Contracts
			,@intUserId
		FROM tblCTContractDetail SS
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		WHERE SS.intContractStatusId IN (
				1
				,4
				)
			AND SS.dtmUpdatedAvailabilityDate < @dtmCurrentMonthStartDate
			AND SS.dblBalance > 0
	END

	IF @strColumnName IN (
			'Forward Open Contracts'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intContractDetailId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT SS.intContractDetailId
			,I.intItemId
			,SS.intCompanyLocationId
			,13 AS intAttributeId -->Forward Open Contracts
			,@intUserId
		FROM tblCTContractDetail SS
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		WHERE SS.intContractStatusId IN (
				1
				,4
				)
			AND SS.dtmUpdatedAvailabilityDate BETWEEN @dtmCurrentDate
				AND @dtmAfter80Days
			AND SS.dblQuantity - IsNULL(SS.dblScheduleQty, 0) > 0
	END

	IF @strColumnName IN (
			'No ETA'
			,'All Item'
			)
	BEGIN
		INSERT INTO tblMFShortTermPlanningViewDetail (
			intLoadContainerId
			,intItemId
			,intLocationId
			,intAttributeId
			,intUserId
			)
		SELECT LDCL.intLoadContainerId
			,I.intItemId
			,SS.intCompanyLocationId
			,14 AS intAttributeId -->No ETA
			,@intUserId
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			AND L.intPurchaseSale = 1
			AND L.intShipmentType = 1
		JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
		JOIN @tblMFItem I ON I.intItemId = SS.intItemId
		JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
		JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
		WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
			AND SS.intContractStatusId IN (
				1
				,4
				)
			AND IsNULL(L.ysnArrivedInPort, 0) <> 1
			AND L.dtmETAPOD IS NULL
			AND NOT EXISTS (
				SELECT *
				FROM tblMFShortTermPlanningViewDetail SP
				WHERE SP.intLoadContainerId = LDCL.intLoadContainerId
					AND SP.intUserId = @intUserId
				)
			AND NOT EXISTS (
				SELECT *
				FROM tblQMSample S1
				WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
					AND S1.intSampleStatusId = 4 -->Rejected)
				)
	END

	UPDATE D
	SET D.dblBalanceMonthForecast = CurrentMonth.dblQty
		,D.dblNextMonthForecast = NextMonth.dblQty
		,D.dblDOH = DOH.dblQty
	FROM dbo.tblMFShortTermPlanningViewDetail D
	LEFT JOIN #tblMFShortTermDemand CurrentMonth ON CurrentMonth.intItemId = D.intItemId
		AND CurrentMonth.intLocationId = D.intLocationId
		AND CurrentMonth.intAttributeId = 1 -->Balance Month Forecast
	LEFT JOIN #tblMFShortTermDemand NextMonth ON NextMonth.intItemId = D.intItemId
		AND NextMonth.intLocationId = D.intLocationId
		AND NextMonth.intAttributeId = 2 -->Next Month Forecast
	LEFT JOIN #tblMFShortTermDemand DOH ON DOH.intItemId = D.intItemId
		AND DOH.intLocationId = D.intLocationId
		AND DOH.intAttributeId = 4 -->DOH
	WHERE D.intUserId = @intUserId
END
