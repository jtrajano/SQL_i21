CREATE PROCEDURE [dbo].[uspCTGetBrokerageCommission]
	@intEntityId			INT			=	NULL,
    @strStatus				NVARCHAR(50)=	NULL,
    @intContractHeaderId	INT			=	NULL,
	@strType				NVARCHAR(50)=	NULL,
    @ysnSummary				BIT			=	0,
	@intBrkgCommnId			INT			=	0
AS 

	DECLARE @ysnReceivable BIT
	SELECT	@ysnReceivable	=	CASE	WHEN	@strType = 'Receivables' THEN 1
										WHEN	@strType = 'Payables' THEN 0
										ELSE	NULL
								END

	IF @strStatus = 'All' SET @strStatus = NULL

	IF OBJECT_ID('tempdb..#Status') IS NOT NULL  					
		DROP TABLE #Status
	
	SELECT strCurrency,strStatus COLLATE Latin1_General_CI_AS strStatus INTO #Status
	FROM(
		SELECT 'Not yet due' AS strStatus UNION ALL
		SELECT 'Due' AS strStatus UNION ALL
		SELECT 'Requested' AS strStatus UNION ALL
		SELECT 'Received/Paid' AS strStatus
	)t,tblSMCurrency

	IF OBJECT_ID('tempdb..#BrkgDetail') IS NOT NULL  					
		DROP TABLE #BrkgDetail					

	SELECT	*	INTO #BrkgDetail FROM
	(
		SELECT  CST.intContractCostId AS intBrkgCommnDetailId,
				CST.intContractCostId,
				CST.dblReqstdAmount,
				CST.dblRcvdPaidAmount,
				ISNULL(CST.strStatus, (CASE WHEN CST.dtmDueDate <= DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) THEN 'Due' ELSE 'Not yet due' END)) AS strStatus,
				CST.dtmDueDate,
				CST.strCurrency,
				CST.ysnReceivable,
				CST.dblRate,
				CST.intUnitMeasureId AS intCostUOMId,
				CST.intItemId,
				CST.intVendorId AS intCostEntityId,

				dbo.fnRemoveTrailingZeroes(CST.dblRate) + ' ' +CST.strCurrency + '/' + CST.strUOM AS strRateUnit,
	   
				SEQ.strSequenceNumber,
				SEQ.dtmContractDate,
				SEQ.strItemNo,
				SEQ.strEntityName		AS  strSeller , 
				SEQ.dtmStartDate,
				SEQ.dtmEndDate,
				SEQ.dblQuantity,
				SEQ.strItemUOM,
				SEQ.intUnitMeasureId	AS	intQtyUOMId,

				HDR.strCustomerContract AS	strSellerRef ,
				HDR.strCPContract		AS	strBuyerRef,
	   
				SEY.strName				AS	strBuyer,

				dbo.fnCTConvertQuantityToTargetItemUOM(SEQ.intItemId,SEQ.intUnitMeasureId,CST.intUnitMeasureId,SEQ.dblQuantity)*CST.dblRate AS dblEstimatedAmount,
				dbo.fnCTConvertQuantityToTargetItemUOM(SEQ.intItemId,SEQ.intUnitMeasureId,CST.intUnitMeasureId,dblNet)*CST.dblRate AS dblAccruedAmount,
				dblNet,
				SEQ.strPricingType,
				SEQ.intContractHeaderId

		FROM	vyuCTContractCostView	CST
		JOIN	vyuCTContractSequence	SEQ	ON	SEQ.intContractDetailId =   CST.intContractDetailId
											AND CST.intVendorId			=   ISNULL(@intEntityId,CST.intVendorId)
											AND	SEQ.intContractHeaderId	=	ISNULL(@intContractHeaderId,SEQ.intContractHeaderId)
											AND	CST.ysnReceivable		=	ISNULL(@ysnReceivable,CST.ysnReceivable)
		JOIN	tblCTContractHeader		HDR ON	HDR.intContractHeaderId =   CST.intContractHeaderId
		JOIN	tblEMEntity				SEY ON	SEY.intEntityId			=   HDR.intCounterPartyId
		JOIN	tblICItem				CIM	ON	CIM.intItemId		    =   CST.intItemId 
											AND	CIM.strCostType			=   'Commission'
		LEFT	JOIN
		(
				SELECT  intPContractDetailId,
						SUM(dbo.fnCTConvertQtyToTargetItemUOM(LD.intWeightItemUOMId,CD.intItemUOMId,dblNet)) dblNet
	    
				FROM	tblLGLoadDetail		LD 
				JOIN	tblLGLoad			LO  ON	 LO.intLoadId			=   LD.intLoadId
				JOIN	tblCTContractDetail CD  ON	 CD.intContractDetailId	=   LD.intPContractDetailId
				WHERE   LO.intShipmentStatus <> 10
				AND	    LO.ysnPosted = 1 
				AND	    LO.intPurchaseSale  = 1
				GROUP BY intPContractDetailId
		)								LDL ON	LDL.intPContractDetailId =	SEQ.intContractDetailId
	)t
	WHERE	ISNULL(strStatus,'')	=   ISNULL(@strStatus,ISNULL(strStatus,''))

	IF @ysnSummary = 0
	BEGIN
		SELECT * FROM #BrkgDetail
	END
	ELSE
	BEGIN
		IF ISNULL(@intBrkgCommnId,0) = 0
		BEGIN
			SELECT	CAST(ROW_NUMBER() OVER (ORDER BY strCurrency ASC) AS INT) AS intBrkgCommnDetailId,
					*,
					dblRecEstimated - dblPayEstimated AS dblNetEstimated,
					dblRecActual - dblPayActual AS dblNetActual
			FROM
			(
				SELECT	S.strCurrency,
						S.strStatus,
						SUM(CASE WHEN ysnReceivable = 1 THEN dblEstimatedAmount ELSE 0 END) dblRecEstimated, 
						SUM(CASE WHEN ysnReceivable = 1 THEN 0 ELSE dblEstimatedAmount END) dblPayEstimated,
						SUM(CASE	WHEN	S.strStatus IN ('Not yet due', 'Due') OR ysnReceivable <> 1
								THEN	0 
								ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intQtyUOMId,intCostUOMId,dblNet)*dblRate 
						END) AS dblRecActual,
						SUM(CASE	WHEN	S.strStatus IN ('Not yet due', 'Due') OR ysnReceivable = 1
								THEN	0 
								ELSE	dbo.fnCTConvertQuantityToTargetItemUOM(intItemId,intQtyUOMId,intCostUOMId,dblNet)*dblRate 
						END) AS dblPayActual,
						CASE	WHEN S.strStatus = 'Not yet due'	THEN 1
								WHEN S.strStatus = 'Due'			THEN 2
								WHEN S.strStatus = 'Requested'		THEN 3
								WHEN S.strStatus = 'Received/Paid'	THEN 4
						END	AS	intSort
				FROM #Status S
				LEFT JOIN #BrkgDetail B ON B.strStatus = S.strStatus AND B.strCurrency = S.strCurrency
				GROUP BY S.strStatus,S.strCurrency
			)t
			WHERE strCurrency IN (SELECT DISTINCT  strCurrency FROM #BrkgDetail)
			ORDER BY intSort
		END
		ELSE
		BEGIN
			SELECT	CAST(ROW_NUMBER() OVER (ORDER BY strCurrency ASC) AS INT) AS intBrkgCommnDetailId,
					*,
					dblRecEstimated - dblPayEstimated AS dblNetEstimated,
					dblRecActual - dblPayActual AS dblNetActual
			FROM
			(
				SELECT	S.strCurrency,
						S.strStatus,
						SUM(CASE	 WHEN ysnReceivable = 1 AND S.strStatus = 'Requested' THEN dblDueEstimated 
								 WHEN ysnReceivable = 1 AND S.strStatus = 'Received/Paid' THEN dblReqstdAmount 
								 ELSE 0 END) dblRecEstimated, 
						SUM(CASE	 WHEN ysnReceivable <> 1 AND S.strStatus = 'Requested' THEN dblDueEstimated 
								 WHEN ysnReceivable <> 1 AND S.strStatus = 'Received/Paid' THEN dblReqstdAmount 
								 ELSE 0 END) dblPayEstimated,
						SUM(CASE	 WHEN ysnReceivable = 1 AND S.strStatus = 'Requested' THEN dblReqstdAmount 
								 WHEN ysnReceivable = 1 AND S.strStatus = 'Received/Paid' THEN dblRcvdPaidAmount 
								 ELSE 0 END) AS dblRecActual,
						SUM(CASE	 WHEN ysnReceivable <> 1 AND S.strStatus = 'Requested' THEN dblReqstdAmount 
								 WHEN ysnReceivable <> 1 AND S.strStatus = 'Received/Paid' THEN dblRcvdPaidAmount 
								 ELSE 0 END) AS dblPayActual,
						CASE	WHEN S.strStatus = 'Not yet due'	THEN 1
								WHEN S.strStatus = 'Due'			THEN 2
								WHEN S.strStatus = 'Requested'		THEN 3
								WHEN S.strStatus = 'Received/Paid'	THEN 4
						END	AS	intSort
				FROM	#Status S
		LEFT	JOIN	vyuCTGridBrokerageCommissionDetail	B	ON	B.strStatus		=	S.strStatus 
																AND B.strCurrency	=	S.strCurrency
																AND	intBrkgCommnId	=	@intBrkgCommnId
				GROUP BY S.strStatus,S.strCurrency
			)t
			WHERE strCurrency IN (SELECT DISTINCT  strCurrency FROM vyuCTGridBrokerageCommissionDetail WHERE intBrkgCommnId = @intBrkgCommnId)
			ORDER BY intSort
		END
	END