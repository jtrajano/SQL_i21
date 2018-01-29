CREATE VIEW [dbo].[vyuCTAmendmentHistory]
AS
SELECT 
	 intSequenceHistoryKey = CONVERT(INT, DENSE_RANK() OVER (ORDER BY CurrentValue.intSequenceHistoryId,t.strItemChanged ))
	,intSequenceHistoryId = CurrentValue.intSequenceHistoryId
	,intContractHeaderId  = CurrentValue.intContractHeaderId
	,intContractDetailId  = CurrentValue.intContractDetailId
	,dtmHistoryCreated	  = CurrentValue.dtmHistoryCreated
	,strContractNumber    = CH.strContractNumber
	,intContractSeq       = CD.intContractSeq
	,intEntityId		  = CH.intEntityId
	,strEntityName		  = EY.strName
	,intContractTypeId    = CH.intContractTypeId
	,strContractType	  = TP.strContractType
	,strItemChanged		  = t.strItemChanged
	,strOldValue		  = t.OldValue
	,strNewValue		  = t.NewValue
	,intCommodityId		  = CH.intCommodityId
	,strCommodityCode	  = CO.strCommodityCode
	,ysnPrinted			  = CH.ysnPrinted
	,intCompanyLocationId = CD.intCompanyLocationId
	,strLocationName      = CL.strLocationName
	,strAmendmentNumber   = CurrentValue.strAmendmentNumber
	,strAmendmentComment  = CurrentValue.strAmendmentComment
FROM tblCTSequenceHistory CurrentValue
JOIN tblCTSequenceHistory PreviousValue ON PreviousValue.intSequenceHistoryId = CurrentValue.intSequenceHistoryId - 1
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CurrentValue.intContractHeaderId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CurrentValue.intContractDetailId
JOIN tblEMEntity EY ON EY.intEntityId = CurrentValue.intEntityId
JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
LEFT JOIN tblICCommodity CO ON CO.intCommodityId = CH.intCommodityId
JOIN 
(
--Entity
SELECT 
 CurrentHistoryId		= CurrentRow.intSequenceHistoryId
,PreviousHistoryId      = PreviousRow.intSequenceHistoryId
,strItemChanged			= 'Entity' 
,OldValue				= PreviousType.strName 
,NewValue				= CurrentType.strName 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblEMEntity CurrentType		  ON CurrentType.intEntityId		  =	CurrentRow.intEntityId
JOIN tblEMEntity PreviousType	      ON PreviousType.intEntityId		  =	PreviousRow.intEntityId
WHERE CurrentRow.intEntityId <> PreviousRow.intEntityId

UNION

--Position
SELECT 
 CurrentHistoryId		= CurrentRow.intSequenceHistoryId
,PreviousHistoryId		= PreviousRow.intSequenceHistoryId
,strItemChanged			= 'Position' 
,OldValue				= PreviousType.strPosition
,NewValue				= CurrentType.strPosition
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblCTPosition CurrentType		  ON	CurrentType.intPositionId	  =	CurrentRow.intPositionId
JOIN tblCTPosition PreviousType		  ON	PreviousType.intPositionId	  =	PreviousRow.intPositionId
WHERE CurrentRow.intPositionId <> PreviousRow.intPositionId

UNION
---INCO/Ship Term
SELECT 
 CurrentHistoryId		= CurrentRow.intSequenceHistoryId
,PreviousHistoryId		= PreviousRow.intSequenceHistoryId
,strItemChanged			= 'INCO/Ship Term' 
,OldValue				= PreviousType.strContractBasis
,NewValue				= CurrentType.strContractBasis
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON    PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblCTContractBasis CurrentType	  ON	CurrentType.intContractBasisId	 =	CurrentRow.intContractBasisId
JOIN tblCTContractBasis PreviousType  ON	PreviousType.intContractBasisId	 =	PreviousRow.intContractBasisId
WHERE CurrentRow.intContractBasisId <> PreviousRow.intContractBasisId

--Terms
UNION
SELECT 
 CurrentHistoryId	    = CurrentRow.intSequenceHistoryId
,PreviousHistoryId	    = PreviousRow.intSequenceHistoryId
,strItemChanged		    ='Terms' 
,OldValue			    = PreviousType.strTerm
,NewValue			    = CurrentType.strTerm
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId   = CurrentRow.intSequenceHistoryId - 1
JOIN tblSMTerm CurrentType	          ON CurrentType.intTermID				=	CurrentRow.intTermId
JOIN tblSMTerm PreviousType	          ON PreviousType.intTermID				=	PreviousRow.intTermId
WHERE CurrentRow.intTermId <> PreviousRow.intTermId


--Grades
UNION
SELECT 
CurrentHistoryId        = CurrentRow.intSequenceHistoryId
,PreviousHistoryId      = PreviousRow.intSequenceHistoryId
,strItemChanged         = 'Grades' 
,OldValue			    = PreviousType.strWeightGradeDesc
,NewValue			    = CurrentType.strWeightGradeDesc 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId  = CurrentRow.intSequenceHistoryId - 1
JOIN tblCTWeightGrade CurrentType	  ON	CurrentType.intWeightGradeId   = CurrentRow.intGradeId
JOIN tblCTWeightGrade PreviousType	  ON	PreviousType.intWeightGradeId  = PreviousRow.intGradeId
WHERE CurrentRow.intGradeId <> PreviousRow.intGradeId

--Weights
UNION
SELECT 
 CurrentHistoryId     = CurrentRow.intSequenceHistoryId
,PreviousHistoryId    = PreviousRow.intSequenceHistoryId
,strItemChanged	      = 'Weights' 
,OldValue		      = PreviousType.strWeightGradeDesc 
,NewValue		      = CurrentType.strWeightGradeDesc 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON    PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblCTWeightGrade CurrentType	  ON	CurrentType.intWeightGradeId	 =	CurrentRow.intWeightId
JOIN tblCTWeightGrade PreviousType	  ON	PreviousType.intWeightGradeId	 =	PreviousRow.intWeightId
WHERE CurrentRow.intWeightId <> PreviousRow.intWeightId

--intContractStatusId
UNION
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Status' 
,OldValue = PreviousType.strContractStatus 
,NewValue = CurrentType.strContractStatus 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblCTContractStatus CurrentType	ON	CurrentType.intContractStatusId				=	CurrentRow.intContractStatusId
JOIN tblCTContractStatus PreviousType	ON	PreviousType.intContractStatusId				=	PreviousRow.intContractStatusId
WHERE CurrentRow.intContractStatusId <> PreviousRow.intContractStatusId
--
--dtmStartDate
UNION

SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Start Date' 
,OldValue = Convert(Nvarchar,PreviousRow.dtmStartDate,101)
,NewValue = Convert(Nvarchar,CurrentRow.dtmStartDate,101)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dtmStartDate <> PreviousRow.dtmStartDate

--dtmEndDate
UNION

SELECT 
CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='End Date' 
,OldValue = Convert(Nvarchar,PreviousRow.dtmEndDate,101)
,NewValue = Convert(Nvarchar,CurrentRow.dtmEndDate,101)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dtmEndDate <> PreviousRow.dtmEndDate
--Item
UNION

SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Items' 
,OldValue = PreviousType.strItemNo
,NewValue = CurrentType.strItemNo 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblICItem CurrentType	ON	CurrentType.intItemId				=	CurrentRow.intItemId
JOIN tblICItem PreviousType	ON	PreviousType.intItemId				=	PreviousRow.intItemId
WHERE CurrentRow.intItemId <> PreviousRow.intItemId

--dblQuantity
UNION

SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Quantity' 
,OldValue = LTRIM(PreviousRow.dblQuantity)
,NewValue = LTRIM(CurrentRow.dblQuantity)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dblQuantity <> PreviousRow.dblQuantity

--Quantity UOM
UNION

SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Quantity UOM' 
,OldValue = U21.strUnitMeasure
,NewValue = U2.strUnitMeasure
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CurrentRow.intItemUOMId		
JOIN	tblICUnitMeasure				U2	ON	U2.intUnitMeasureId			=	PU.intUnitMeasureId
JOIN	tblICItemUOM					PU1	ON	PU1.intItemUOMId				=	PreviousRow.intItemUOMId		
JOIN	tblICUnitMeasure				U21	ON	U21.intUnitMeasureId			=	PU1.intUnitMeasureId

WHERE CurrentRow.intItemUOMId <> PreviousRow.intItemUOMId

UNION
--Futures Market
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId,strItemChanged='Futures Market' 
,OldValue = PreviousType.strFutMarketName
,NewValue = CurrentType.strFutMarketName 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblRKFutureMarket CurrentType	ON	CurrentType.intFutureMarketId				=	CurrentRow.intFutureMarketId
JOIN tblRKFutureMarket PreviousType	ON	PreviousType.intFutureMarketId				=	PreviousRow.intFutureMarketId
WHERE CurrentRow.intFutureMarketId <> PreviousRow.intFutureMarketId


UNION
--Currency
SELECT 
CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Currency' 
,OldValue = PreviousType.strCurrency
,NewValue = CurrentType.strCurrency 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblSMCurrency CurrentType	ON	CurrentType.intCurrencyID				=	CurrentRow.intCurrencyId
JOIN tblSMCurrency PreviousType	ON	PreviousType.intCurrencyID				=	PreviousRow.intCurrencyId
WHERE CurrentRow.intCurrencyId <> PreviousRow.intCurrencyId



UNION
--FutureMonth
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Mn/Yr' 
,OldValue = PreviousType.strFutureMonth
,NewValue = CurrentType.strFutureMonth 
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN tblRKFuturesMonth CurrentType	ON	CurrentType.intFutureMonthId				=	CurrentRow.intFutureMonthId
JOIN tblRKFuturesMonth PreviousType	ON	PreviousType.intFutureMonthId				=	PreviousRow.intFutureMonthId
WHERE CurrentRow.intFutureMonthId <> PreviousRow.intFutureMonthId


--Futures
UNION
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Futures' 
,OldValue = LTRIM(PreviousRow.dblFutures)
,NewValue = LTRIM(CurrentRow.dblFutures)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dblFutures <> PreviousRow.dblFutures

--Basis
UNION
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Basis' 
,OldValue = LTRIM(PreviousRow.dblBasis)
,NewValue = LTRIM(CurrentRow.dblBasis)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dblBasis <> PreviousRow.dblBasis

--CashPrice
UNION
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Cash Price' 
,OldValue = LTRIM(PreviousRow.dblCashPrice)
,NewValue = LTRIM(CurrentRow.dblCashPrice)
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
WHERE CurrentRow.dblCashPrice <> PreviousRow.dblCashPrice

--Cash Price UOM
UNION
SELECT 
 CurrentHistoryId=CurrentRow.intSequenceHistoryId
,PreviousHistoryId=PreviousRow.intSequenceHistoryId
,strItemChanged='Cash Price UOM' 
,OldValue = U21.strUnitMeasure
,NewValue = U2.strUnitMeasure
FROM tblCTSequenceHistory CurrentRow
JOIN tblCTSequenceHistory PreviousRow ON PreviousRow.intSequenceHistoryId = CurrentRow.intSequenceHistoryId - 1
JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CurrentRow.intPriceItemUOMId		
JOIN	tblICUnitMeasure				U2	ON	U2.intUnitMeasureId			=	PU.intUnitMeasureId
JOIN	tblICItemUOM					PU1	ON	PU1.intItemUOMId				=	PreviousRow.intPriceItemUOMId		
JOIN	tblICUnitMeasure				U21	ON	U21.intUnitMeasureId			=	PU1.intUnitMeasureId
WHERE CurrentRow.intPriceItemUOMId <> PreviousRow.intPriceItemUOMId
) t ON t.CurrentHistoryId=CurrentValue.intSequenceHistoryId AND t.PreviousHistoryId = PreviousValue.intSequenceHistoryId
