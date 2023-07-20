CREATE PROCEDURE uspMFGetShortTermPlanningView 
(
	@intDemandHeaderId		INT
  , @intUnitMeasureId		INT
  , @intCompanyLocationId	INT				= NULL
  , @intCategoryId			INT				= NULL
  , @strItemId				NVARCHAR(MAX)	= ''
)
AS
BEGIN
	DECLARE @dtmCurrentMonthStartDate	DATETIME = DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)
		  , @dtmCurrentMonthEndDate		DATETIME = DATEADD(DAY, - 1, DATEADD(month, 1, DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)))
		  , @dtmNextMonthStartDate		DATETIME = DATEADD(MONTH, 1, DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0))
		  , @dtmNextMonthEndDate		DATETIME = DATEADD(DAY, - 1, DATEADD(month, 1, DATEADD(MONTH, 1, DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0))))
		  , @intRemainingDay			INT		 = DATEDIFF(DAY, GETDATE(), DATEADD(s, - 1, DATEADD(mm, DATEDIFF(m, 0, GETDATE()) + 1, 0))) + 1
		  , @intNoOfDays				INT		 = DATEDIFF(dd, GETDATE(), DATEADD(mm, 1, GETDATE()))
		  , @dtmEndDateAfterSixMonth	DATETIME = DATEADD(DAY, - 1, DATEADD(MONTH, 6, DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)))
		  , @intConditionId				INT
		  , @dtmCurrentDate				DATETIME = GETDATE()
		  , @dtmAfter80Days				DATETIME = GETDATE() + 80

	DECLARE @tblMFItem TABLE 
	(
		intItemId INT
	);

	DECLARE @tblSMCompanyLocation TABLE 
	(
		intCompanyLocationId INT
	);


	IF @intCategoryId > 0 AND @strItemId = ''
		BEGIN
			INSERT INTO @tblMFItem 
			(
				intItemId
			)
			SELECT I.intItemId
			FROM tblICItem I
			WHERE I.intCategoryId = @intCategoryId AND I.strStatus = 'Active' AND I.strItemNo <> 'Futures Contract';
		END
	ELSE
		BEGIN
			INSERT INTO @tblMFItem 
			(
				intItemId
			)
			SELECT I.intItemId
			FROM tblICItem I
			WHERE I.intCategoryId = @intCategoryId 
			  AND I.strStatus = 'Active' 
			  AND I.intItemId IN 
			  ( 
				SELECT Item Collate Latin1_General_CI_AS
				FROM [dbo].[fnSplitString](@strItemId, ',')
			  )
		END

	IF @intCompanyLocationId IS NULL
		BEGIN
			INSERT INTO @tblSMCompanyLocation 
			(
				intCompanyLocationId
			)
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
		END
	ELSE
		BEGIN
			INSERT INTO @tblSMCompanyLocation 
			(
				intCompanyLocationId
			)
			SELECT @intCompanyLocationId AS intCompanyLocationId
		END
	
	/* Attribute ID */
	/************************************
	* 1  = Balance Month Forecast
	* 2  = Next Month Forecast
	* 3  = Avg 6 months Forecast
	* 4  = DOH
	* 5  = Available Inventory
	* 6  = Approved Qty
	* 7  = Not Approved Qty
	* 8  = In-Transit to WHSE
	* 9  = Arrived in Port
	* 10 = Scheduled
	* 11 = CBS
	* 12 = Late Open Contracts
	* 13 = Forward Open Contracts
	* 14 = No ETA
	* 15 = Not AVailable Inventory
	*************************************/

	IF OBJECT_ID('tempdb..#tblMFShortTermDemand') IS NOT NULL
		BEGIN
			DROP TABLE #tblMFShortTermDemand;
		END

	CREATE TABLE #tblMFPreShortTermDemand 
	(
		intItemId			INT
	  , intLocationId		INT
	  , dblQty				NUMERIC(18, 6)
	  , intAttributeId		INT
	  , intLoadContainerId	INT
	)

	CREATE TABLE #tblMFShortTermDemand 
	(
		intItemId			INT
	  , intLocationId		INT
	  , dblQty				NUMERIC(18, 6)
	  , intAttributeId		INT
	)

	/* Staging Balance Month Forecast. */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT DD.intItemId
		 , DD.intCompanyLocationId AS intLocationId
		 , dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, (DD.dblQuantity * @intRemainingDay / @intNoOfDays)) AS dblQty
		 /* Balance Month Forecast. */
		 , 1 AS intAttributeId 
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
	  AND dtmDemandDate BETWEEN @dtmCurrentMonthStartDate AND @dtmCurrentMonthEndDate;

	/* Staging Next Month Forecast. */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT DD.intItemId
		 , DD.intCompanyLocationId AS intLocationId
		 , dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity) AS dblQty
		 /* Next Month Forecast. */
		 , 2 AS intAttributeId -->Next Month Forecast
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
	  AND dtmDemandDate BETWEEN @dtmNextMonthStartDate AND @dtmNextMonthEndDate;

	/* Staging Avg 6 months Forecast */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT DD.intItemId
		 , DD.intCompanyLocationId AS intLocationId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, DD.dblQuantity)) / 6 AS dblQty
		 /* Avg 6 months Forecast */
		 , 3 AS intAttributeId 
	FROM tblMFDemandDetail DD
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = DD.intCompanyLocationId
	JOIN @tblMFItem I ON I.intItemId = DD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = DD.intItemUOMId
	WHERE intDemandHeaderId = @intDemandHeaderId
	  AND dtmDemandDate BETWEEN @dtmCurrentMonthStartDate AND @dtmEndDateAfterSixMonth
	GROUP BY DD.intItemId
		   , DD.intCompanyLocationId

	/* Staging Available Inventory */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT L.intItemId
		 , L.intLocationId AS intLocationId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, L.dblWeight)) AS dblQty
		 /* Available Inventory. */
		 , 5 AS intAttributeId 
	FROM tblICLot L
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	JOIN @tblMFItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intWeightUOMId
	WHERE L.dblQty > 0 AND L.intLotStatusId = 1
	GROUP BY L.intItemId
		   , L.intLocationId

	/* Staging NOT Available Inventory */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT L.intItemId
		 , L.intLocationId AS intLocationId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(I.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, L.dblWeight)) AS dblQty
		 /* NOT Available Inventory */
		 , 15 AS intAttributeId 
	FROM tblICLot L
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intLocationId
	JOIN @tblMFItem I ON I.intItemId = L.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = L.intWeightUOMId
	WHERE L.dblQty > 0
		AND L.intLotStatusId <> 1
	GROUP BY L.intItemId
		,L.intLocationId

	/* Staging DOH */
	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT Inv.intItemId
		 , Inv.intLocationId
		 , (CASE WHEN F.dblQty = 0 THEN 0
				 ELSE Inv.dblQty / F.dblQty
			END) * 30
		  /* DOH */
		 , 4 AS intAttributeId
	FROM #tblMFShortTermDemand Inv
	LEFT JOIN #tblMFShortTermDemand F ON F.intItemId = Inv.intItemId
									 AND F.intLocationId = Inv.intLocationId
									 AND F.intAttributeId = 3
	WHERE Inv.intAttributeId = 5

	SELECT @intConditionId = intConditionId
	FROM tblCTCondition
	WHERE strConditionName = 'CBS'

	/* Staging CBS */
	INSERT INTO #tblMFPreShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	  , intLoadContainerId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity) AS dblQty
		 /* CBS */
		 , 11 AS intAttributeId 
		 , LDCL.intLoadContainerId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId			= LD.intLoadId
						   AND L.intPurchaseSale	= 1
						   AND L.intShipmentType	= 1
						   AND ISNULL(L.ysnCancelled, 0) <> 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	JOIN tblLGLoadCondition LC ON LC.intLoadId = L.intLoadId AND LC.intConditionId = @intConditionId
	WHERE SS.intContractStatusId IN 
	(
		1
	  , 4
	)
	AND NOT EXISTS 
	(
		SELECT *
		FROM #tblMFPreShortTermDemand PS
		WHERE PS.intLoadContainerId = LDCL.intLoadContainerId
	)
	AND NOT EXISTS 
	(
		SELECT *
		FROM tblQMSample S1
		WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId AND S1.intSampleStatusId = 4 -->Rejected)
	)

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT intItemId
		 , intLocationId
		 , SUM(dblQty)
		 , intAttributeId
	FROM #tblMFPreShortTermDemand
	WHERE intAttributeId = 11
	GROUP BY intItemId
		   , intLocationId
		   , intAttributeId

	INSERT INTO #tblMFPreShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	  , intLoadContainerId
	)
	SELECT DISTINCT I.intItemId
				  , SS.intCompanyLocationId
				  , dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0)) AS dblQty
				  , (CASE WHEN S.intLoadDetailContainerLinkId IS NOT NULL THEN 6  /* Approved Qty */
						  WHEN LW1.intLoadWarehouseId IS NOT NULL THEN 7		  /* Not Approved Qty */	
						  ELSE 0
					 END) AS intAttributeId
				  , LDCL.intLoadContainerId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId 
					 AND L.intPurchaseSale = 1
					 AND L.intShipmentType = 1
					 AND IsNULL(L.ysnCancelled, 0) <> 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
						   AND S.intSampleStatusId = 3 /* Approved */
						   AND S.intLoadContainerId = LDCL.intLoadContainerId
	OUTER APPLY (SELECT TOP 1 LW.intLoadWarehouseId
				 FROM tblLGLoadWarehouse LW
				 WHERE LW.intLoadId = L.intLoadId AND NOT EXISTS (SELECT TOP 1 1
																  FROM tblMFStorageLocationExclude SE
																  WHERE SE.intSubLocationId = LW.intSubLocationId)) LW1
	WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
		AND SS.intContractStatusId IN 
		(
			1
		  , 4
		)
		AND ISNULL(L.dtmETAPOD, @dtmCurrentDate) <= @dtmCurrentDate
		AND NOT EXISTS 
		(
			SELECT *
			FROM #tblMFPreShortTermDemand PS
			WHERE PS.intLoadContainerId = LDCL.intLoadContainerId
		)
		AND NOT EXISTS 
		(
			SELECT *
			FROM tblQMSample S1
			WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
				AND S1.intSampleStatusId = 4 /* Rejected */
		)
		AND 
		(
			CASE WHEN S.intLoadDetailContainerLinkId IS NOT NULL THEN 6 -->Approved Qty
				 WHEN LW1.intLoadWarehouseId IS NOT NULL THEN 7 -->Not Approved Qty
				 ELSE 0
			END
		) > 0

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT intItemId
		 , intLocationId
		 , SUM(dblQty)
		 , intAttributeId
	FROM #tblMFPreShortTermDemand
	WHERE intAttributeId IN 
	(
		6
	  , 7
	)
	GROUP BY intItemId
		   , intLocationId
		   , intAttributeId

	INSERT INTO #tblMFPreShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	  , intLoadContainerId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0)) AS dblQty
		 , (CASE WHEN L.dtmETAPOD IS NOT NULL THEN 8 -->In-Transit to WHSE
				 ELSE 9 --> Arrived in Port
			END) AS intAttributeId
		,LDCL.intLoadContainerId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1 AND L.intShipmentType = 1 AND ISNULL(L.ysnCancelled, 0) <> 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	LEFT JOIN tblQMSample S ON S.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId AND S.intSampleStatusId = 3 /* Approved */
	OUTER APPLY (SELECT TOP 1 LW.intLoadWarehouseId
				 FROM tblLGLoadWarehouse LW
				 WHERE LW.intLoadId = L.intLoadId) AS LW1
	WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
	  AND SS.intContractStatusId IN 
	  (
	     1 
	   , 4
	  )
	  AND S.intLoadDetailContainerLinkId IS NULL
	  AND LW1.intLoadWarehouseId IS NULL
	  AND L.ysnArrivedInPort = 1
	  AND NOT EXISTS 
	  (
		 SELECT *
		 FROM #tblMFPreShortTermDemand PS
		 WHERE PS.intLoadContainerId = LDCL.intLoadContainerId
	  )
	  AND NOT EXISTS (SELECT *
					  FROM tblQMSample S1
					  WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId AND S1.intSampleStatusId = 4 /* Rejected */)

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT intItemId
		,intLocationId
		,SUM(dblQty)
		,intAttributeId
	FROM #tblMFPreShortTermDemand
	WHERE intAttributeId IN 
	(
		8
	  , 9
	)
	GROUP BY intItemId
		,intLocationId
		,intAttributeId

	INSERT INTO #tblMFPreShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	  , intLoadContainerId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity) AS dblQty
		 , 10 AS intAttributeId -->Scheduled
		 , LDCL.intLoadContainerId
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intPurchaseSale = 1 AND L.intShipmentType = 1 AND IsNULL(L.ysnCancelled, 0) <> 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE SS.intContractStatusId IN 
	(
		1
	  , 4
	)
		AND LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0) > 0
		AND NOT EXISTS (
			SELECT *
			FROM #tblMFPreShortTermDemand PS
			WHERE PS.intLoadContainerId = LDCL.intLoadContainerId
			)
		AND NOT EXISTS (
			SELECT *
			FROM tblQMSample S1
			WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId
				AND S1.intSampleStatusId = 4 -->Rejected)
			)

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT intItemId
		 , intLocationId
		 , SUM(dblQty)
		 , intAttributeId
	FROM #tblMFPreShortTermDemand
	WHERE intAttributeId = 10
	GROUP BY intItemId
		   , intLocationId
		   , intAttributeId

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblNetWeight - IsNULL(dblNet, 0))) AS dblQty
		 , 12 AS intAttributeId --> Late Open Contracts
	FROM tblCTContractDetail SS
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SS.intContractHeaderId AND CH.intContractTypeId = 1
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intNetWeightUOMId
	OUTER APPLY 
	(
		SELECT SUM(LD.dblNet) dblNet
			 , SUM(LD.dblQuantity) dblQuantity
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND IsNULL(L.ysnCancelled, 0) = 0
		WHERE LD.intPContractDetailId = SS.intContractDetailId
	) C2
	WHERE SS.intContractStatusId IN 
	(
		1
	  , 4
	)
	AND SS.dtmStartDate < @dtmCurrentMonthStartDate
	AND SS.dblQuantity - IsNULL(C2.dblQuantity, 0) > 0
	GROUP BY I.intItemId
		   , SS.intCompanyLocationId

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , SUM(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, SS.dblNetWeight - ISNULL(C2.dblNet, 0))) AS dblQty
		 , 13 AS intAttributeId -->Forward Open Contracts
	FROM tblCTContractDetail SS
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = SS.intContractHeaderId AND CH.intContractTypeId = 1
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intNetWeightUOMId
	OUTER APPLY 
	(
		SELECT SUM(LD.dblNet) dblNet
			 , SUM(LD.dblQuantity) dblQuantity
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND IsNULL(L.ysnCancelled, 0) = 0
		WHERE LD.intPContractDetailId = SS.intContractDetailId
	) C2
	WHERE SS.intContractStatusId IN (1, 4)
	  AND SS.dtmStartDate BETWEEN @dtmCurrentMonthStartDate AND @dtmAfter80Days
	  AND SS.dblQuantity - IsNULL(C2.dblQuantity, 0) > 0
	GROUP BY I.intItemId
		   , SS.intCompanyLocationId

	INSERT INTO #tblMFShortTermDemand 
	(
		intItemId
	  , intLocationId
	  , dblQty
	  , intAttributeId
	)
	SELECT I.intItemId
		 , SS.intCompanyLocationId
		 , sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, @intUnitMeasureId, LDCL.dblQuantity - ISNULL(LDCL.dblReceivedQty, 0))) AS dblQty
		 , 14 AS intAttributeId -->No ETA
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		AND L.intPurchaseSale = 1
		AND L.intShipmentType = 1
		AND IsNULL(L.ysnCancelled, 0) <> 1
	JOIN tblCTContractDetail SS ON SS.intContractDetailId = LD.intPContractDetailId
	JOIN @tblMFItem I ON I.intItemId = SS.intItemId
	JOIN @tblSMCompanyLocation CL ON CL.intCompanyLocationId = SS.intCompanyLocationId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN tblLGLoadDetailContainerLink LDCL ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE LDCL.dblQuantity - (ISNULL(LDCL.dblReceivedQty, 0)) > 0
	  AND SS.intContractStatusId IN 
	  (
	   		1
	      , 4
	  )
	  AND L.ysnArrivedInPort <> 1
	  AND L.dtmETAPOD IS NULL
	  AND NOT EXISTS (SELECT *
					  FROM #tblMFPreShortTermDemand PS
					  WHERE PS.intLoadContainerId = LDCL.intLoadContainerId)
	  AND NOT EXISTS (SELECT *
					  FROM tblQMSample S1
					  WHERE S1.intLoadDetailContainerLinkId = LDCL.intLoadDetailContainerLinkId AND S1.intSampleStatusId = 4 -->Rejected)
			)
	GROUP BY I.intItemId
		   , SS.intCompanyLocationId

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
		,[15] AS dblNotAvailableInventory
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
				,[15]
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
