CREATE VIEW vyuMFInvPlngSummaryDetail
AS
SELECT strItemNo
	,strAttributeName
	,strMonth
	,dblPlannedPurchaseQty
	,dblUnAllocatedPurchaseQty
	,dblPlannedPurchaseQty - dblUnAllocatedPurchaseQty AS dblDifference
	,dtmStartDate
FROM (
	SELECT I.strItemNo
		,'UnAllocated Purchase' strAttributeName
		,Left(DATENAME(mm, DateAdd(m, 2, SS.dtmStartDate)), 3) + ' ' + Right(DATENAME(YY, DateAdd(m, 2, SS.dtmStartDate)), 2) AS strMonth
		,Convert(Decimal(26,12),0.0) AS dblPlannedPurchaseQty
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, PS.intUnitMeasureId, SS.dblBalance)) AS dblUnAllocatedPurchaseQty
		,DateAdd(m, 2, SS.dtmStartDate) as dtmStartDate
	FROM dbo.tblMFInvPlngSummaryDetail SD
	JOIN dbo.tblMFInvPlngSummary PS ON PS.intInvPlngSummaryId = SD.intInvPlngSummaryId
		AND SD.intMainItemId IS NOT NULL and SD.intAttributeId=1 and SD.strFieldName='strMonth1'
	JOIN dbo.tblCTContractDetail SS ON SS.intItemId = SD.intItemId
	JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = SS.intContractHeaderId
		AND CH.intContractTypeId = 1
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
	WHERE SS.intContractStatusId = 1
		AND NOT EXISTS (
			SELECT *
			FROM tblLGAllocationDetail AD
			WHERE AD.intPContractDetailId = SS.intContractDetailId
			)
		AND SD.intInvPlngSummaryId IN (
			SELECT Max(PS.intInvPlngSummaryId)
			FROM tblMFInvPlngSummary PS
			)
	GROUP BY I.strItemNo
		,Left(DATENAME(mm, DateAdd(m, 2, SS.dtmStartDate)), 3) + ' ' + Right(DATENAME(YY, DateAdd(m, 2, SS.dtmStartDate)), 2)
		,DateAdd(m, 2, SS.dtmStartDate)
	UNION
	
	SELECT I.strItemNo
		,'UnAllocated Purchase' strAttributeName
		,Left(DATENAME(mm, DateAdd(m, 2, SS.dtmStartDate)), 3) + ' ' + Right(DATENAME(YY, DateAdd(m, 2, SS.dtmStartDate)), 2) AS strMonth
		,0.0 AS dblPlannedPurchaseQty
		,sum(dbo.fnCTConvertQuantityToTargetItemUOM(SS.intItemId, IU.intUnitMeasureId, PS.intUnitMeasureId, SS.dblBalance)) AS dblUnAllocatedPurchaseQty
		,DateAdd(m, 2, SS.dtmStartDate) as dtmStartDate
	FROM dbo.tblMFInvPlngSummaryDetail SD
	JOIN dbo.tblMFInvPlngSummary PS ON PS.intInvPlngSummaryId = SD.intInvPlngSummaryId
		AND SD.intMainItemId IS NULL and SD.intAttributeId=1 and SD.strFieldName='strMonth1'
	JOIN dbo.tblCTContractDetail SS ON SS.intItemBundleId = SD.intItemId
	JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = SS.intContractHeaderId
		AND CH.intContractTypeId = 1
	JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = SS.intItemUOMId
	JOIN dbo.tblICItem I ON I.intItemId = SD.intItemId
	WHERE SS.intContractStatusId = 1
		AND NOT EXISTS (
			SELECT *
			FROM tblLGAllocationDetail AD
			WHERE AD.intPContractDetailId = SS.intContractDetailId
			)
		AND NOT EXISTS (
			SELECT *
			FROM dbo.tblMFInvPlngSummaryDetail SD1
			WHERE SD1.intMainItemId IS NOT NULL
				AND SD1.intItemId = SS.intItemId
				AND SD1.intInvPlngSummaryId = SD.intInvPlngSummaryId
			)
		AND SD.intInvPlngSummaryId IN (
			SELECT Max(PS.intInvPlngSummaryId)
			FROM tblMFInvPlngSummary PS
			)
	GROUP BY I.strItemNo
		,Left(DATENAME(mm, DateAdd(m, 2, SS.dtmStartDate)), 3) + ' ' + Right(DATENAME(YY, DateAdd(m, 2, SS.dtmStartDate)), 2)
		,DateAdd(m, 2, SS.dtmStartDate)
	UNION
	
	SELECT I.strItemNo
		,RA.strAttributeName
		,SD1.strValue AS strMonth
		,SD.strValue
		,0.0 AS dblUnAllocatedPurchaseQty
		,Convert(Datetime,'01 '+ SD1.strValue)
	FROM tblMFInvPlngSummaryDetail SD
	JOIN tblICItem I ON I.intItemId = SD.intItemId
	JOIN tblCTReportAttribute RA ON RA.intReportAttributeID = SD.intAttributeId
	JOIN tblMFInvPlngSummaryDetail SD1 ON SD1.strFieldName = SD.strFieldName
		AND SD1.intInvPlngSummaryId = SD.intInvPlngSummaryId
		AND SD1.intAttributeId = 1
	WHERE SD.intAttributeId = 5
		AND SD.intInvPlngSummaryId IN (
			SELECT Max(PS.intInvPlngSummaryId)
			FROM tblMFInvPlngSummary PS
			)
	) AS DT

