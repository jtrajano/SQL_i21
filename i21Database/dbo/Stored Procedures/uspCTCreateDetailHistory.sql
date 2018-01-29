CREATE PROCEDURE [dbo].[uspCTCreateDetailHistory]
	@intContractHeaderId	   INT,
    @intContractDetailId	   INT = NULL
AS	   

BEGIN TRY
		DECLARE @ErrMsg	NVARCHAR(MAX)
		DECLARE @intSequenceHistoryId INT
		DECLARE @intApprovalListId INT
		DECLARE @intLastModifiedById INT
	
		DECLARE @tblHeader AS TABLE 
		(
			intContractHeaderId		       INT,
			intEntityId			           INT,
			intPositionId				   INT,
			intContractBasisId			   INT,
			intTermId					   INT,
			intGradeId					   INT,
			intWeightId					   INT
		)
		
		DECLARE @tblDetail AS TABLE 
		(
			intContractHeaderId		       INT,
			intContractDetailId		       INT,
			intContractStatusId		       INT,
			dtmStartDate				   DATETIME,
			dtmEndDate				       DATETIME,
			intItemId				       INT,
			dblQuantity				       NUMERIC(18,6),
			intItemUOMId				   INT,
			intFutureMarketId		       INT,
			intCurrencyId			       INT,
			intFutureMonthId		       INT,
			dblFutures					   NUMERIC(18,6),
			dblBasis				       NUMERIC(18,6),
			dblCashPrice			       NUMERIC(18,6),
			intPriceItemUOMId			   INT
		)

		IF @intContractHeaderId IS NULL AND @intContractDetailId IS NOT NULL
		BEGIN
		SELECT @intContractHeaderId	=   intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		END
		
		SELECT @intLastModifiedById = intLastModifiedById FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId
		SELECT @intApprovalListId =intApprovalListId  FROM tblSMApprovalList WHERE strApprovalList ='Contract Amendment'

		DELETE FROM @tblHeader
		DELETE FROM @tblDetail

		INSERT INTO @tblHeader
		(
			 intContractHeaderId
			,intEntityId			
			,intPositionId		
			,intContractBasisId	
			,intTermId			
			,intGradeId			
			,intWeightId			
		)

		SELECT 
		 intContractHeaderId
		,intEntityId		
		,intPositionId		
		,intContractBasisId	
		,intTermId			
		,intGradeId			
		,intWeightId
	    FROM tblCTContractHeader 
		WHERE intContractHeaderId = @intContractHeaderId
		
		INSERT INTO @tblDetail
		(
		    intContractHeaderId	
		   ,intContractDetailId	
		   ,intContractStatusId	
		   ,dtmStartDate		
		   ,dtmEndDate			
		   ,intItemId			
		   ,dblQuantity			
		   ,intItemUOMId		
		   ,intFutureMarketId	
		   ,intCurrencyId		
		   ,intFutureMonthId	
		   ,dblFutures			
		   ,dblBasis			
		   ,dblCashPrice		
		   ,intPriceItemUOMId	 
		)
		SELECT 
		 intContractHeaderId	
		,intContractDetailId	
		,intContractStatusId	
		,dtmStartDate		
		,dtmEndDate			
		,intItemId			
		,dblQuantity			
		,intItemUOMId		
		,intFutureMarketId	
		,intCurrencyId		
		,intFutureMonthId	
		,dblFutures			
		,dblBasis			
		,dblCashPrice		
		,intPriceItemUOMId
		FROM tblCTContractDetail 
		WHERE intContractDetailId = @intContractDetailId

		INSERT INTO tblCTSequenceHistory
		(
			 intContractHeaderId,			intContractDetailId,			intContractTypeId,					intCommodityId,				intEntityId
			,intContractStatusId,			intCompanyLocationId,			intItemId,							intPricingTypeId,		    intFutureMarketId
			,intFutureMonthId,				intCurrencyId,					intDtlQtyInCommodityUOMId,			intDtlQtyUnitMeasureId,	    intCurrencyExchangeRateId
			,dtmStartDate,					dtmEndDate,						dblQuantity,						dblBalance,					dblFutures
			,dblBasis,						dblLotsPriced,					dblLotsUnpriced,					dblQtyPriced,				dblQtyUnpriced
			,dblFinalPrice,					dtmFXValidFrom,					dtmFXValidTo,						dblRate,					strCommodity
			,strContractNumber,				intContractSeq,					strLocation,						strContractType,		    strPricingType
			,dblScheduleQty,				dtmHistoryCreated,				dblCashPrice,						strPricingStatus
			,intContractBasisId  
			,intGradeId			
			,intItemUOMId		
			,intPositionId		
			,intPriceItemUOMId   
			,intTermId			
			,intWeightId		
		)

		SELECT   
			 CD.intContractHeaderId,		CD.intContractDetailId,			CH.intContractTypeId,				CH.intCommodityId,		    intEntityId
			,intContractStatusId,			CD.intCompanyLocationId,		intItemId,							CD.intPricingTypeId,	    CD.intFutureMarketId
			,CD.intFutureMonthId,			intCurrencyId,					QU.intCommodityUnitMeasureId,		CD.intUnitMeasureId,	    CD.intCurrencyExchangeRateId
			,dtmStartDate,					dtmEndDate,						CD.dblQuantity,						dblBalance,					CD.dblFutures
			,dblBasis,						PF.dblLotsFixed,				CD.dblNoOfLots - PF.dblLotsFixed,	FD.dblQuantity,				CD.dblQuantity - FD.dblQuantity
			,dblFinalPrice,					dtmFXValidFrom,					dtmFXValidTo,						dblRate,					CO.strCommodityCode
			,strContractNumber,				intContractSeq,					CL.strLocationName,					strContractType,		    strPricingType
			,CD.dblScheduleQty,				GETDATE(),						dblCashPrice
			,CASE   WHEN	ISNULL(CD.dblNoOfLots,0) = ISNULL(PF.dblLotsFixed,0) AND CD.intPricingTypeId NOT IN (2,8)	   THEN	 'Fully Priced' 
					WHEN	ISNULL(CD.dblNoOfLots,0) - ISNULL(PF.dblLotsFixed,0) > 0 
							AND PF.intPriceFixationId IS NOT NULL THEN	 'Parially Priced'
					ELSE	'Unpriced'
			END
		    ,intContractBasisId   = CH.intContractBasisId
			,intGradeId			  = CH.intGradeId
			,intItemUOMId		  = CD.intItemUOMId
			,intPositionId		  = CH.intPositionId
			,intPriceItemUOMId    = CD.intPriceItemUOMId
			,intTermId			  = CH.intTermId
			,intWeightId		  = CH.intWeightId
		FROM	tblCTContractDetail			CD
		JOIN	tblCTContractHeader			CH  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblICCommodity				CO  ON  CO.intCommodityId		=	CH.intCommodityId
		JOIN	tblSMCompanyLocation	    CL  ON  CL.intCompanyLocationId =	CD.intCompanyLocationId
		JOIN	tblCTContractType		    CT  ON  CT.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblCTPricingType		    PT  ON  PT.intPricingTypeId		=	CD.intPricingTypeId
		JOIN	tblICCommodityUnitMeasure	QU  ON  QU.intCommodityId		=	CH.intCommodityId
												AND QU.intUnitMeasureId		=	CD.intUnitMeasureId	        
 LEFT   JOIN	 tblCTPriceFixation		    PF  ON  PF.intContractDetailId	=	CD.intContractDetailId
 LEFT   JOIN	 (
					SELECT  intPriceFixationId,SUM(dblQuantity) AS  dblQuantity
					FROM	   tblCTPriceFixationDetail
					GROUP   BY  intPriceFixationId

				  )					FD  ON  FD.intPriceFixationId	  =	 PF.intPriceFixationId
		WHERE   CD.intContractHeaderId  =   @intContractHeaderId
		AND		CD.intContractDetailId	=   ISNULL(@intContractDetailId,CD.intContractDetailId)	   
	
    SET @intSequenceHistoryId = SCOPE_IDENTITY()
	
	IF EXISTS(SELECT 1 FROM tblSMUserSecurityRequireApprovalFor WHERE [intEntityUserSecurityId] =@intLastModifiedById AND [intApprovalListId]=@intApprovalListId )
	BEGIN
	  INSERT INTO tblCTSequenceAmendmentLog
	  (
		 intSequenceHistoryId
		,dtmHistoryCreated	
		,intContractHeaderId	
		,intContractDetailId
		,strItemChanged
		,intAmendmentApprovalId		
		,strOldValue		  	
		,strNewValue				
	  )
	  --Entity
	   SELECT
	   intSequenceHistoryId   = @intSequenceHistoryId
	  ,dtmHistoryCreated	  = GETDATE()
	  ,intContractHeaderId	  = @intContractHeaderId
	  ,intContractDetailId	  = @intContractDetailId
	  ,intAmendmentApprovalId = 1
	  ,strItemChanged		  = 'Entity' 
	  ,strOldValue			  =  PreviousType.strName
	  ,strNewValue		      =  CurrentType.strName 

	  FROM tblCTSequenceHistory CurrentRow
	  JOIN @tblHeader			PreviousRow			ON PreviousRow.intEntityId  <> CurrentRow.intEntityId
	  JOIN tblEMEntity			CurrentType		    ON CurrentType.intEntityId   =	CurrentRow.intEntityId
	  JOIN tblEMEntity			PreviousType	    ON PreviousType.intEntityId  =	PreviousRow.intEntityId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	 --Position
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 2
	  ,strItemChanged		    = 'Position' 
	  ,strOldValue			    = PreviousType.strPosition
	  ,strNewValue		        = CurrentType.strPosition

	  FROM tblCTSequenceHistory   CurrentRow
	  JOIN @tblHeader			  PreviousRow			ON PreviousRow.intPositionId    <> CurrentRow.intPositionId
	  JOIN tblCTPosition		  CurrentType		    ON CurrentType.intPositionId    =	CurrentRow.intPositionId
	  JOIN tblCTPosition		  PreviousType	        ON PreviousType.intPositionId   =	PreviousRow.intPositionId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	  --INCO/Ship Term
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 3
	  ,strItemChanged		    = 'INCO/Ship Term' 
	  ,strOldValue			    = PreviousType.strContractBasis
	  ,strNewValue		        = CurrentType.strContractBasis

	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intContractBasisId    <> CurrentRow.intContractBasisId
	  JOIN tblCTContractBasis		    CurrentType		        ON CurrentType.intContractBasisId    =	CurrentRow.intContractBasisId
	  JOIN tblCTContractBasis		    PreviousType	        ON PreviousType.intContractBasisId   =	PreviousRow.intContractBasisId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	    
	  UNION
	  --Terms
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 4
	  ,strItemChanged		    = 'Terms' 
	  ,strOldValue			    =  PreviousType.strTerm
	  ,strNewValue		        =  CurrentType.strTerm
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intTermId     <> CurrentRow.intTermId
	  JOIN tblSMTerm				    CurrentType				ON CurrentType.intTermID	 =	CurrentRow.intTermId
	  JOIN tblSMTerm				    PreviousType			ON PreviousType.intTermID	 =	PreviousRow.intTermId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	  --Grades
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 5
	  ,strItemChanged		    = 'Grades' 
	  ,strOldValue			    = PreviousType.strWeightGradeDesc
	  ,strNewValue		        = CurrentType.strWeightGradeDesc 
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intGradeId         <> CurrentRow.intGradeId
	  JOIN tblCTWeightGrade CurrentType							ON	CurrentType.intWeightGradeId   = CurrentRow.intGradeId
	  JOIN tblCTWeightGrade PreviousType						ON	PreviousType.intWeightGradeId  = PreviousRow.intGradeId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  
	  UNION
	  --Weights
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 6
	  ,strItemChanged		    = 'Weights' 
	  ,strOldValue			    = PreviousType.strWeightGradeDesc 
	  ,strNewValue		        = CurrentType.strWeightGradeDesc 
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intWeightId         <> CurrentRow.intWeightId
	  JOIN tblCTWeightGrade				CurrentType				ON	CurrentType.intWeightGradeId	 =	CurrentRow.intWeightId
	  JOIN tblCTWeightGrade				PreviousType			ON	PreviousType.intWeightGradeId	 =	PreviousRow.intWeightId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	  --intContractStatusId
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 7
	  ,strItemChanged		    = 'Status' 
	  ,strOldValue			    = PreviousType.strContractStatus  
	  ,strNewValue		        = CurrentType.strContractStatus 
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblDetail					PreviousRow			       ON PreviousRow.intContractStatusId         <> CurrentRow.intContractStatusId
	  JOIN tblCTContractStatus				CurrentType				ON	CurrentType.intContractStatusId	      =	 CurrentRow.intContractStatusId
	  JOIN tblCTContractStatus				PreviousType			ON	PreviousType.intContractStatusId	  =	 PreviousRow.intContractStatusId
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	  --dtmStartDate
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 8
	  ,strItemChanged		    = 'Start Date' 
	  ,strOldValue			    = Convert(Nvarchar,PreviousRow.dtmStartDate,101)  
	  ,strNewValue		        = Convert(Nvarchar,CurrentRow.dtmStartDate,101)
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblDetail					PreviousRow			       ON Convert(Nvarchar,PreviousRow.dtmStartDate,101) <> Convert(Nvarchar,CurrentRow.dtmStartDate,101)
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
	  --dtmEndDate
	   SELECT
	   intSequenceHistoryId     = @intSequenceHistoryId
	  ,dtmHistoryCreated	    = GETDATE()
	  ,intContractHeaderId	    = @intContractHeaderId
	  ,intContractDetailId	    = @intContractDetailId
	  ,intAmendmentApprovalId	= 9
	  ,strItemChanged		    = 'End Date' 
	  ,strOldValue			    = Convert(Nvarchar,PreviousRow.dtmEndDate,101)  
	  ,strNewValue		        = Convert(Nvarchar,CurrentRow.dtmEndDate,101)
	  
	  FROM tblCTSequenceHistory			CurrentRow
	  JOIN @tblDetail					PreviousRow			       ON Convert(Nvarchar,PreviousRow.dtmEndDate,101) <> Convert(Nvarchar,CurrentRow.dtmEndDate,101)
	  WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	   UNION
	   --Item
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 10
	   ,strItemChanged		    =  'Items' 
	   ,strOldValue			    =  PreviousType.strItemNo  
	   ,strNewValue		        =  CurrentType.strItemNo 
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow			       ON   PreviousRow.intItemId         <> CurrentRow.intItemId
	   JOIN tblICItem						CurrentType				   ON	CurrentType.intItemId	      =	 CurrentRow.intItemId
	   JOIN tblICItem						PreviousType			   ON	PreviousType.intItemId		  =	 PreviousRow.intItemId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	  UNION
		--dblQuantity
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 11
	   ,strItemChanged		    =  'Quantity' 
	   ,strOldValue			    =  LTRIM(PreviousRow.dblQuantity)  
	   ,strNewValue		        =  LTRIM(CurrentRow.dblQuantity) 
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow			       ON   PreviousRow.dblQuantity <> CurrentRow.dblQuantity
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	  
	   UNION
		--Quantity UOM
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 12
	   ,strItemChanged		    =  'Quantity UOM'  
	   ,strOldValue			    = U21.strUnitMeasure
	   ,strNewValue		        = U2.strUnitMeasure
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	                       ON   PreviousRow.intItemUOMId <> CurrentRow.intItemUOMId
	   JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId				=	CurrentRow.intItemUOMId		
	   JOIN	tblICUnitMeasure				U2	ON	U2.intUnitMeasureId			=	PU.intUnitMeasureId
	   JOIN	tblICItemUOM					PU1	ON	PU1.intItemUOMId			=	PreviousRow.intItemUOMId		
	   JOIN	tblICUnitMeasure				U21	ON	U21.intUnitMeasureId		=	PU1.intUnitMeasureId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId AND U2.intUnitMeasureId <> U21.intUnitMeasureId

	   UNION
	   --Futures Market
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 13
	   ,strItemChanged		    =  'Futures Market'
	   ,strOldValue			    = PreviousType.strFutMarketName
	   ,strNewValue		        = CurrentType.strFutMarketName 
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intFutureMarketId <> PreviousRow.intFutureMarketId
	   JOIN tblRKFutureMarket CurrentType	ON	CurrentType.intFutureMarketId				=	CurrentRow.intFutureMarketId
	   JOIN tblRKFutureMarket PreviousType	ON	PreviousType.intFutureMarketId				=	PreviousRow.intFutureMarketId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId 

	   UNION
	   --Currency
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 14
	   ,strItemChanged		    =  'Currency'
	   ,strOldValue			    = PreviousType.strCurrency
	   ,strNewValue		        = CurrentType.strCurrency 
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intCurrencyId <> PreviousRow.intCurrencyId
	   JOIN tblSMCurrency CurrentType	ON	CurrentType.intCurrencyID				=	CurrentRow.intCurrencyId
	   JOIN tblSMCurrency PreviousType	ON	PreviousType.intCurrencyID				=	PreviousRow.intCurrencyId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId 

	   UNION
	   --FutureMonth
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 15
	   ,strItemChanged		    =  'Mn/Yr'
	   ,strOldValue			    = PreviousType.strFutureMonth
	   ,strNewValue		        = CurrentType.strFutureMonth 
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intFutureMonthId  <> PreviousRow.intFutureMonthId
	   JOIN tblRKFuturesMonth CurrentType	ON	CurrentType.intFutureMonthId				=	CurrentRow.intFutureMonthId
	   JOIN tblRKFuturesMonth PreviousType	ON	PreviousType.intFutureMonthId				=	PreviousRow.intFutureMonthId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId 

	   UNION
	   --Futures
	    SELECT
	    intSequenceHistoryId     = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 16
	   ,strItemChanged		    =  'Futures'
	   ,strOldValue			    = LTRIM(PreviousRow.dblFutures)
	   ,strNewValue		        = LTRIM(CurrentRow.dblFutures)
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.dblFutures  <> PreviousRow.dblFutures
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId 

	   UNION
	   --Basis
	    SELECT
	    intSequenceHistoryId    = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 17
	   ,strItemChanged		    = 'Basis'
	   ,strOldValue			    = LTRIM(PreviousRow.dblBasis)
	   ,strNewValue		        = LTRIM(CurrentRow.dblBasis)
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.dblBasis  <> PreviousRow.dblBasis
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId 
	   
	   UNION
	   --CashPrice
	    SELECT
	    intSequenceHistoryId    = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 18
	   ,strItemChanged		    = 'Cash Price'
	   ,strOldValue			    = LTRIM(PreviousRow.dblCashPrice)
	   ,strNewValue		        = LTRIM(CurrentRow.dblCashPrice)
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.dblCashPrice  <> PreviousRow.dblCashPrice
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId
	   
	   UNION
	   --Cash Price UOM
	    SELECT
	    intSequenceHistoryId    = @intSequenceHistoryId
	   ,dtmHistoryCreated	    = GETDATE()
	   ,intContractHeaderId	    = @intContractHeaderId
	   ,intContractDetailId	    = @intContractDetailId
	   ,intAmendmentApprovalId	= 19
	   ,strItemChanged		    = 'Cash Price UOM'
	   ,strOldValue			    = LTRIM(PreviousRow.dblCashPrice)
	   ,strNewValue		        = LTRIM(CurrentRow.dblCashPrice)
	   
	   FROM tblCTSequenceHistory			CurrentRow
	   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intPriceItemUOMId <> PreviousRow.intPriceItemUOMId
	   JOIN	tblICItemUOM					PU	ON	PU.intItemUOMId						=	CurrentRow.intPriceItemUOMId		
	   JOIN	tblICUnitMeasure				U2	ON	U2.intUnitMeasureId					=	PU.intUnitMeasureId
	   JOIN	tblICItemUOM					PU1	ON	PU1.intItemUOMId					=	PreviousRow.intPriceItemUOMId	
	   JOIN	tblICUnitMeasure				U21	ON	U21.intUnitMeasureId				=	PU1.intUnitMeasureId
	   WHERE CurrentRow.intSequenceHistoryId   = @intSequenceHistoryId AND U2.intUnitMeasureId <> U21.intUnitMeasureId
	END     

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
