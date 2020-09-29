CREATE VIEW [dbo].vyuIPLoadContainerView
AS
SELECT   L.intLoadId
		,LD.intLoadDetailId
		,LC.intLoadContainerId
		,LC.strComments
		,LC.strContainerNumber
		,LC.strCustomsComments
		,LC.strFDAComments
		,LC.strFreightComments
		,LC.strLotNumber
		,LC.strMarks
		,LC.strOtherMarks
		,LC.strSealNumber
		,LC.strUSDAComments
		,LC.dblGrossWt
		,LC.dblNetWt
		,LC.dblQuantity
		,LC.dblTareWt
		,LC.dblTotalCost
		,LC.dblUnitCost
		,LC.dtmUnloading
		,LC.dtmCustoms
		,LC.dtmFDA
		,LC.dtmFreight
		,LC.dtmUSDA
		,LC.ysnCustomsHold
		,LC.ysnDutyPaid
		,LC.ysnFDAHold
		,CONVERT(BIT,ISNULL(LC.ysnRejected,0)) AS ysnRejected
		,LC.ysnUSDAHold
		,LC.dblCustomsClearedQty
		,LC.dblIntransitQty
		,LC.strDocumentNumber
		,LC.dtmClearanceDate
		,LC.strClearanceMonth
		,LC.dblDeclaredWeight
		,LC.dblStaticValue
		,LC.intStaticValueCurrencyId
		,CU.strCurrency AS strStaticValueCurrency
		,LC.dblAmount
		,LC.intAmountCurrencyId
		,ACU.strCurrency AS strAmountCurrency
		,LC.strRemarks
		,LC.intSort
	    ,L.intBookId
	    ,BO.strBook
	    ,L.intSubBookId
	    ,SB.strSubBook
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,LCIU.strUnitMeasure AS strUnitMeasure
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intStaticValueCurrencyId
LEFT JOIN tblSMCurrency ACU ON ACU.intCurrencyID = LC.intAmountCurrencyId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
