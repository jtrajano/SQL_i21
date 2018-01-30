CREATE PROCEDURE [dbo].[uspCTCreateDetailHistory]
	@intContractHeaderId	   INT,
    @intContractDetailId	   INT = NULL
AS	   

BEGIN TRY
		DECLARE @ErrMsg	NVARCHAR(MAX)
		DECLARE @intApprovalListId INT
		DECLARE @intLastModifiedById INT
		DECLARE @ysnAmdWoAppvl BIT
	
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
		
		DECLARE	@SCOPE_IDENTITY TABLE (intSequenceHistoryId INT)

		IF @intContractHeaderId IS NULL AND @intContractDetailId IS NOT NULL
		BEGIN
		SELECT @intContractHeaderId	=   intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @intContractDetailId
		END
		
		SELECT @intLastModifiedById = intLastModifiedById FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId
		SELECT @intApprovalListId   = intApprovalListId  FROM tblSMApprovalList WHERE strApprovalList ='Contract Amendment'
		SELECT @ysnAmdWoAppvl	    = ISNULL(ysnAmdWoAppvl,0) FROM tblCTCompanyPreference

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

		SELECT TOP 1
		 intContractHeaderId
		,intEntityId		
		,intPositionId		
		,intContractBasisId	
		,intTermId			
		,intGradeId			
		,intWeightId
	    FROM tblCTSequenceHistory 
		WHERE intContractHeaderId = @intContractHeaderId ORDER BY intSequenceHistoryId DESC
		
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
		,t1.intContractDetailId	
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
		FROM 
		(
		  SELECT * FROM 
			(
				SELECT	*,ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY intSequenceHistoryId DESC) intRowNum
				FROM	tblCTSequenceHistory
				WHERE	intContractHeaderId =@intContractHeaderId
			) t
			WHERE intRowNum = 1
		) t1

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
		OUTPUT	inserted.intSequenceHistoryId INTO @SCOPE_IDENTITY
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
    
	IF EXISTS(SELECT 1 FROM tblCTContractHeader WHERE intContractHeaderId = @intContractHeaderId AND (ISNULL(ysnPrinted,0)=1 OR ISNULL(ysnSigned,0)=1))
	BEGIN
		IF EXISTS(SELECT 1 FROM tblSMUserSecurityRequireApprovalFor WHERE [intEntityUserSecurityId] =@intLastModifiedById AND [intApprovalListId]=@intApprovalListId ) OR (@ysnAmdWoAppvl = 1)
		BEGIN
		  INSERT INTO tblCTSequenceAmendmentLog
		  (
			 intSequenceHistoryId
			,dtmHistoryCreated	
			,intContractHeaderId	
			,intContractDetailId
			,intAmendmentApprovalId
			,strItemChanged		
			,strOldValue		  	
			,strNewValue				
		  )
		  --Entity
		   SELECT TOP 1
		   intSequenceHistoryId   = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	  = GETDATE()
		  ,intContractHeaderId	  = @intContractHeaderId
		  ,intContractDetailId	  = NULL
		  ,intAmendmentApprovalId = 1
		  ,strItemChanged		  = 'Entity' 
		  ,strOldValue			  =  PreviousType.strName
		  ,strNewValue		      =  CurrentType.strName 

		  FROM tblCTSequenceHistory CurrentRow
		  JOIN @tblHeader			PreviousRow			ON PreviousRow.intEntityId		    <>  CurrentRow.intEntityId
		  JOIN tblEMEntity			CurrentType		    ON CurrentType.intEntityId			=	CurrentRow.intEntityId
		  JOIN tblEMEntity			PreviousType	    ON PreviousType.intEntityId			=	PreviousRow.intEntityId
		  JOIN @SCOPE_IDENTITY      NewRecords          ON  NewRecords.intSequenceHistoryId =   CurrentRow.intSequenceHistoryId 
		  
		  
		  UNION
		 --Position
		   SELECT TOP 1
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId		= NULL
		  ,intAmendmentApprovalId	= 2
		  ,strItemChanged		    = 'Position' 
		  ,strOldValue			    = PreviousType.strPosition
		  ,strNewValue		        = CurrentType.strPosition

		  FROM tblCTSequenceHistory   CurrentRow
		  JOIN @tblHeader			  PreviousRow			 ON PreviousRow.intPositionId        <>   CurrentRow.intPositionId
		  JOIN tblCTPosition		  CurrentType		     ON CurrentType.intPositionId        =	CurrentRow.intPositionId
		  JOIN tblCTPosition		  PreviousType	         ON PreviousType.intPositionId       =	PreviousRow.intPositionId
		  JOIN @SCOPE_IDENTITY        NewRecords             ON  NewRecords.intSequenceHistoryId =    CurrentRow.intSequenceHistoryId 
		  
		  UNION
		  --INCO/Ship Term
		   SELECT TOP 1
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId		= NULL
		  ,intAmendmentApprovalId	= 3
		  ,strItemChanged		    = 'INCO/Ship Term' 
		  ,strOldValue			    = PreviousType.strContractBasis
		  ,strNewValue		        = CurrentType.strContractBasis

		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intContractBasisId    <> CurrentRow.intContractBasisId
		  JOIN tblCTContractBasis		    CurrentType		        ON CurrentType.intContractBasisId    =	CurrentRow.intContractBasisId
		  JOIN tblCTContractBasis		    PreviousType	        ON PreviousType.intContractBasisId   =	PreviousRow.intContractBasisId
		  JOIN @SCOPE_IDENTITY				NewRecords				ON  NewRecords.intSequenceHistoryId	 =  CurrentRow.intSequenceHistoryId 
		    
		  UNION
		  --Terms
		   SELECT TOP 1
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId		= NULL
		  ,intAmendmentApprovalId	= 4
		  ,strItemChanged		    = 'Terms' 
		  ,strOldValue			    =  PreviousType.strTerm
		  ,strNewValue		        =  CurrentType.strTerm
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intTermId           <> CurrentRow.intTermId
		  JOIN tblSMTerm				    CurrentType				ON CurrentType.intTermID	        =	CurrentRow.intTermId
		  JOIN tblSMTerm				    PreviousType			ON PreviousType.intTermID	        =	PreviousRow.intTermId
		  JOIN @SCOPE_IDENTITY				NewRecords              ON  NewRecords.intSequenceHistoryId =   CurrentRow.intSequenceHistoryId 
		  
		  UNION
		  --Grades
		   SELECT TOP 1
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId		= NULL
		  ,intAmendmentApprovalId	= 5
		  ,strItemChanged		    = 'Grades' 
		  ,strOldValue			    = PreviousType.strWeightGradeDesc
		  ,strNewValue		        = CurrentType.strWeightGradeDesc 
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intGradeId           <> CurrentRow.intGradeId
		  JOIN tblCTWeightGrade				CurrentType				ON	CurrentType.intWeightGradeId    = CurrentRow.intGradeId
		  JOIN tblCTWeightGrade				PreviousType			ON	PreviousType.intWeightGradeId   = PreviousRow.intGradeId
		  JOIN @SCOPE_IDENTITY				NewRecords				ON  NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		  
		  
		  UNION
		  --Weights
		   SELECT TOP 1
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId		= NULL
		  ,intAmendmentApprovalId	= 6
		  ,strItemChanged		    = 'Weights' 
		  ,strOldValue			    = PreviousType.strWeightGradeDesc 
		  ,strNewValue		        = CurrentType.strWeightGradeDesc 
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblHeader					PreviousRow			    ON PreviousRow.intWeightId           <> CurrentRow.intWeightId
		  JOIN tblCTWeightGrade				CurrentType				ON	CurrentType.intWeightGradeId	 =	CurrentRow.intWeightId
		  JOIN tblCTWeightGrade				PreviousType			ON	PreviousType.intWeightGradeId	 =	PreviousRow.intWeightId
		  JOIN @SCOPE_IDENTITY				NewRecords              ON  NewRecords.intSequenceHistoryId  =   CurrentRow.intSequenceHistoryId 
		  
		  UNION
		  --intContractStatusId
		   SELECT
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId	    = CurrentRow.intContractDetailId
		  ,intAmendmentApprovalId	= 7
		  ,strItemChanged		    = 'Status' 
		  ,strOldValue			    = PreviousType.strContractStatus  
		  ,strNewValue		        = CurrentType.strContractStatus 
		  
		  FROM tblCTSequenceHistory				CurrentRow
		  JOIN @tblDetail						PreviousRow			        ON PreviousRow.intContractStatusId       <>  CurrentRow.intContractStatusId
		  JOIN tblCTContractStatus				CurrentType					ON	CurrentType.intContractStatusId	      =	 CurrentRow.intContractStatusId
		  JOIN tblCTContractStatus				PreviousType				ON	PreviousType.intContractStatusId	  =	 PreviousRow.intContractStatusId
		  JOIN @SCOPE_IDENTITY					NewRecords					ON  NewRecords.intSequenceHistoryId		  =  CurrentRow.intSequenceHistoryId 
		  WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		  
		  UNION
		  --dtmStartDate
		   SELECT
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId	    = CurrentRow.intContractDetailId
		  ,intAmendmentApprovalId	= 8
		  ,strItemChanged		    = 'Start Date' 
		  ,strOldValue			    = Convert(Nvarchar,PreviousRow.dtmStartDate,101)  
		  ,strNewValue		        = Convert(Nvarchar,CurrentRow.dtmStartDate,101)
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblDetail					PreviousRow			       ON Convert(Nvarchar,PreviousRow.dtmStartDate,101) <> Convert(Nvarchar,CurrentRow.dtmStartDate,101)
		  JOIN @SCOPE_IDENTITY				NewRecords				   ON  NewRecords.intSequenceHistoryId				 =  CurrentRow.intSequenceHistoryId 
		  WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		  
		  UNION
		  --dtmEndDate
		   SELECT
		   intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		  ,dtmHistoryCreated	    = GETDATE()
		  ,intContractHeaderId	    = @intContractHeaderId
		  ,intContractDetailId	    = CurrentRow.intContractDetailId
		  ,intAmendmentApprovalId	= 9
		  ,strItemChanged		    = 'End Date' 
		  ,strOldValue			    = Convert(Nvarchar,PreviousRow.dtmEndDate,101)  
		  ,strNewValue		        = Convert(Nvarchar,CurrentRow.dtmEndDate,101)
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @tblDetail					PreviousRow			       ON  Convert(Nvarchar,PreviousRow.dtmEndDate,101) <> Convert(Nvarchar,CurrentRow.dtmEndDate,101)
		  JOIN @SCOPE_IDENTITY				NewRecords				   ON  NewRecords.intSequenceHistoryId			    =  CurrentRow.intSequenceHistoryId 
		  WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		  
		   UNION
		   --Item
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 10
		   ,strItemChanged		    =  'Items' 
		   ,strOldValue			    =  PreviousType.strItemNo  
		   ,strNewValue		        =  CurrentType.strItemNo 
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow			       ON   PreviousRow.intItemId         <> CurrentRow.intItemId
		   JOIN tblICItem						CurrentType				   ON	CurrentType.intItemId	      =	 CurrentRow.intItemId
		   JOIN tblICItem						PreviousType			   ON	PreviousType.intItemId		  =	 PreviousRow.intItemId
		   JOIN @SCOPE_IDENTITY				    NewRecords				   ON  NewRecords.intSequenceHistoryId =CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		  
		  UNION
			--dblQuantity
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 11
		   ,strItemChanged		    =  'Quantity' 
		   ,strOldValue			    =  LTRIM(PreviousRow.dblQuantity)  
		   ,strNewValue		        =  LTRIM(CurrentRow.dblQuantity) 
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow			        ON   PreviousRow.dblQuantity		    <> CurrentRow.dblQuantity
		   JOIN @SCOPE_IDENTITY					NewRecords				    ON  NewRecords.intSequenceHistoryId     =  CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		  
		   UNION
			--Quantity UOM
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 12
		   ,strItemChanged		    =  'Quantity UOM'  
		   ,strOldValue			    = U21.strUnitMeasure
		   ,strNewValue		        = U2.strUnitMeasure
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	                       ON   PreviousRow.intItemUOMId        <> CurrentRow.intItemUOMId
		   JOIN	tblICItemUOM					PU								   ON	PU.intItemUOMId				    = CurrentRow.intItemUOMId		
		   JOIN	tblICUnitMeasure				U2								   ON	U2.intUnitMeasureId			    = PU.intUnitMeasureId
		   JOIN	tblICItemUOM					PU1								   ON	PU1.intItemUOMId			    = PreviousRow.intItemUOMId		
		   JOIN	tblICUnitMeasure				U21								   ON	U21.intUnitMeasureId		    = PU1.intUnitMeasureId
		   JOIN @SCOPE_IDENTITY					NewRecords						   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE  U2.intUnitMeasureId <> U21.intUnitMeasureId 
		   AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

		   UNION
		   --Futures Market
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 13
		   ,strItemChanged		    =  'Futures Market'
		   ,strOldValue			    = PreviousType.strFutMarketName
		   ,strNewValue		        = CurrentType.strFutMarketName 
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow						ON   CurrentRow.intFutureMarketId    <> PreviousRow.intFutureMarketId
		   JOIN tblRKFutureMarket				CurrentType						ON	 CurrentType.intFutureMarketId	 =	CurrentRow.intFutureMarketId
		   JOIN tblRKFutureMarket				PreviousType					ON	 PreviousType.intFutureMarketId	 =	PreviousRow.intFutureMarketId
		   JOIN @SCOPE_IDENTITY					NewRecords						ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

		   UNION
		   --Currency
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 14
		   ,strItemChanged		    =  'Currency'
		   ,strOldValue			    = PreviousType.strCurrency
		   ,strNewValue		        = CurrentType.strCurrency 
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intCurrencyId        <> PreviousRow.intCurrencyId
		   JOIN tblSMCurrency					CurrentType	 ON	  CurrentType.intCurrencyID		  =	CurrentRow.intCurrencyId
		   JOIN tblSMCurrency					PreviousType ON	  PreviousType.intCurrencyID	  =	PreviousRow.intCurrencyId
		   JOIN @SCOPE_IDENTITY					NewRecords   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

		   UNION
		   --FutureMonth
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 15
		   ,strItemChanged		    =  'Mn/Yr'
		   ,strOldValue			    = PreviousType.strFutureMonth
		   ,strNewValue		        = CurrentType.strFutureMonth 
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intFutureMonthId     <> PreviousRow.intFutureMonthId
		   JOIN tblRKFuturesMonth				CurrentType	 ON	  CurrentType.intFutureMonthId	  =	CurrentRow.intFutureMonthId
		   JOIN tblRKFuturesMonth				PreviousType ON	  PreviousType.intFutureMonthId	  =	PreviousRow.intFutureMonthId
		   JOIN @SCOPE_IDENTITY					NewRecords   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

		   UNION
		   --Futures
		    SELECT
		    intSequenceHistoryId     = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 16
		   ,strItemChanged		    =  'Futures'
		   ,strOldValue			    = LTRIM(PreviousRow.dblFutures)
		   ,strNewValue		        = LTRIM(CurrentRow.dblFutures)
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.dblFutures			   <> PreviousRow.dblFutures
		   JOIN @SCOPE_IDENTITY				    NewRecords   ON   NewRecords.intSequenceHistoryId  = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

		   UNION
		   --Basis
		    SELECT
		    intSequenceHistoryId    = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 17
		   ,strItemChanged		    = 'Basis'
		   ,strOldValue			    = LTRIM(PreviousRow.dblBasis)
		   ,strNewValue		        = LTRIM(CurrentRow.dblBasis)
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow			ON   CurrentRow.dblBasis			  <> PreviousRow.dblBasis
		   JOIN @SCOPE_IDENTITY				    NewRecords          ON   NewRecords.intSequenceHistoryId  = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		   
		   UNION
		   --CashPrice
		    SELECT
		    intSequenceHistoryId    = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 18
		   ,strItemChanged		    = 'Cash Price'
		   ,strOldValue			    = LTRIM(PreviousRow.dblCashPrice)
		   ,strNewValue		        = LTRIM(CurrentRow.dblCashPrice)
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow			ON   CurrentRow.dblCashPrice         <> PreviousRow.dblCashPrice
		   JOIN @SCOPE_IDENTITY					NewRecords          ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		   
		   UNION
		   --Cash Price UOM
		    SELECT
		    intSequenceHistoryId    = NewRecords.intSequenceHistoryId
		   ,dtmHistoryCreated	    = GETDATE()
		   ,intContractHeaderId	    = @intContractHeaderId
		   ,intContractDetailId	    = CurrentRow.intContractDetailId
		   ,intAmendmentApprovalId	= 19
		   ,strItemChanged		    = 'Cash Price UOM'
		   ,strOldValue			    = LTRIM(PreviousRow.dblCashPrice)
		   ,strNewValue		        = LTRIM(CurrentRow.dblCashPrice)
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intPriceItemUOMId    <> PreviousRow.intPriceItemUOMId
		   JOIN	tblICItemUOM					PU			 ON	  PU.intItemUOMId			      =	CurrentRow.intPriceItemUOMId		
		   JOIN	tblICUnitMeasure				U2			 ON	  U2.intUnitMeasureId		      =	PU.intUnitMeasureId
		   JOIN	tblICItemUOM					PU1			 ON	  PU1.intItemUOMId				  =	PreviousRow.intPriceItemUOMId	
		   JOIN	tblICUnitMeasure				U21			 ON	  U21.intUnitMeasureId			  =	PU1.intUnitMeasureId
		   JOIN @SCOPE_IDENTITY					NewRecords   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   WHERE U2.intUnitMeasureId <> U21.intUnitMeasureId
		   AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		END     
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
