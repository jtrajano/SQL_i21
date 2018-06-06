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
			,dblBasis
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN CD.dblNoOfLots ELSE PF.dblLotsFixed END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN 0 ELSE CD.dblNoOfLots - PF.dblLotsFixed END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN CD.dblQuantity ELSE FD.dblQuantity END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN 0 ELSE CD.dblQuantity - FD.dblQuantity END
			,dblFinalPrice,					dtmFXValidFrom,					dtmFXValidTo,						dblRate,					CO.strCommodityCode
			,strContractNumber,				intContractSeq,					CL.strLocationName,					strContractType,		    strPricingType
			,CD.dblScheduleQty,				GETDATE(),						dblCashPrice
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN	 'Fully Priced' 
					WHEN	ISNULL(CD.dblNoOfLots,0) = ISNULL(PF.dblLotsFixed,0) AND CD.intPricingTypeId NOT IN (2,8)	   THEN	 'Fully Priced' 
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
			,intConcurrencyId				
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
		  ,intConcurrencyId		  =  1 

		  FROM tblCTSequenceHistory		CurrentRow
		  JOIN @SCOPE_IDENTITY			NewRecords          ON  NewRecords.intSequenceHistoryId				=   CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader				PreviousRow			ON  ISNULL(PreviousRow.intEntityId,0)		    <>  ISNULL(CurrentRow.intEntityId,0)
		  LEFT JOIN tblEMEntity			CurrentType		    ON CurrentType.intEntityId			            =	CurrentRow.intEntityId
		  LEFT JOIN tblEMEntity			PreviousType	    ON PreviousType.intEntityId			            =	PreviousRow.intEntityId
		  
		  
		  
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
		  ,intConcurrencyId		  =  1

		  FROM tblCTSequenceHistory		  CurrentRow
		  JOIN @SCOPE_IDENTITY			  NewRecords             ON  NewRecords.intSequenceHistoryId		   =    CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader				  PreviousRow			 ON ISNULL(PreviousRow.intPositionId ,0)       <>   ISNULL(CurrentRow.intPositionId ,0)
		  LEFT JOIN tblCTPosition		  CurrentType		     ON ISNULL(CurrentType.intPositionId ,0)       =	ISNULL(CurrentRow.intPositionId	,0)
		  LEFT JOIN tblCTPosition		  PreviousType	         ON ISNULL(PreviousType.intPositionId,0)       =	ISNULL(PreviousRow.intPositionId,0)
		  
		  
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
		  ,intConcurrencyId		  =  1

		  FROM tblCTSequenceHistory			    CurrentRow
		  JOIN @SCOPE_IDENTITY				    NewRecords				ON  NewRecords.intSequenceHistoryId	 =  CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader					    PreviousRow			    ON ISNULL(PreviousRow.intContractBasisId ,0)   <>   ISNULL(CurrentRow.intContractBasisId ,0)
		  LEFT JOIN tblCTContractBasis		    CurrentType		        ON ISNULL(CurrentType.intContractBasisId ,0)   =	ISNULL(CurrentRow.intContractBasisId ,0)
		  LEFT JOIN tblCTContractBasis		    PreviousType	        ON ISNULL(PreviousType.intContractBasisId,0)   =	ISNULL(PreviousRow.intContractBasisId,0)
		  
		    
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
		  ,intConcurrencyId			=  1
		  
		  FROM tblCTSequenceHistory				CurrentRow
		  JOIN @SCOPE_IDENTITY					NewRecords              ON  NewRecords.intSequenceHistoryId			=   CurrentRow.intSequenceHistoryId
		  JOIN @tblHeader						PreviousRow			    ON ISNULL(PreviousRow.intTermId ,0)        <>   ISNULL(CurrentRow.intTermId	,0)
		  LEFT JOIN tblSMTerm				    CurrentType				ON ISNULL(CurrentType.intTermID	,0)         =	ISNULL(CurrentRow.intTermId	,0)
		  LEFT JOIN tblSMTerm				    PreviousType			ON ISNULL(PreviousType.intTermID,0)	        =	ISNULL(PreviousRow.intTermId,0)
		   
		  
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
		  ,intConcurrencyId		    =  1 
		  
		  FROM tblCTSequenceHistory					CurrentRow
		  JOIN @SCOPE_IDENTITY						NewRecords				ON  NewRecords.intSequenceHistoryId			 =    CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader							PreviousRow			    ON  ISNULL(PreviousRow.intGradeId       ,0)  <>   ISNULL(CurrentRow.intGradeId ,0)
		  LEFT JOIN tblCTWeightGrade				CurrentType				ON	ISNULL(CurrentType.intWeightGradeId ,0)   =   ISNULL(CurrentRow.intGradeId ,0)
		  LEFT JOIN tblCTWeightGrade				PreviousType			ON	ISNULL(PreviousType.intWeightGradeId,0)   =   ISNULL(PreviousRow.intGradeId,0)
		  
		  
		  
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
		  ,intConcurrencyId		    =  1  
		  
		  FROM tblCTSequenceHistory					CurrentRow
		  JOIN @SCOPE_IDENTITY						NewRecords              ON  NewRecords.intSequenceHistoryId			 =   CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader							PreviousRow			    ON  ISNULL(PreviousRow.intWeightId      ,0)  <>  ISNULL(CurrentRow.intWeightId ,0)
		  LEFT JOIN tblCTWeightGrade				CurrentType				ON	ISNULL(CurrentType.intWeightGradeId	,0)  =	 ISNULL(CurrentRow.intWeightId ,0)
		  LEFT JOIN tblCTWeightGrade				PreviousType			ON	ISNULL(PreviousType.intWeightGradeId,0)	 =	 ISNULL(PreviousRow.intWeightId,0)
		 
		  
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
		  ,intConcurrencyId		    =  1  
		  
		  FROM tblCTSequenceHistory				CurrentRow
		  JOIN @SCOPE_IDENTITY					NewRecords					ON  NewRecords.intSequenceHistoryId		  =  CurrentRow.intSequenceHistoryId
		  JOIN @tblDetail						PreviousRow			        ON PreviousRow.intContractStatusId       <>  CurrentRow.intContractStatusId
		  JOIN tblCTContractStatus				CurrentType					ON	CurrentType.intContractStatusId	      =	 CurrentRow.intContractStatusId
		  JOIN tblCTContractStatus				PreviousType				ON	PreviousType.intContractStatusId	  =	 PreviousRow.intContractStatusId
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
		  ,intConcurrencyId		    =  1 
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @SCOPE_IDENTITY				NewRecords				   ON  NewRecords.intSequenceHistoryId				 =  CurrentRow.intSequenceHistoryId 
		  JOIN @tblDetail					PreviousRow			       ON Convert(Nvarchar,PreviousRow.dtmStartDate,101) <> Convert(Nvarchar,CurrentRow.dtmStartDate,101)
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
		  ,intConcurrencyId		    =  1 
		  
		  FROM tblCTSequenceHistory			CurrentRow
		  JOIN @SCOPE_IDENTITY				NewRecords				   ON  NewRecords.intSequenceHistoryId			    =  CurrentRow.intSequenceHistoryId 
		  JOIN @tblDetail					PreviousRow			       ON  Convert(Nvarchar,PreviousRow.dtmEndDate,101) <> Convert(Nvarchar,CurrentRow.dtmEndDate,101)
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY				    NewRecords				   ON  NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow			       ON   PreviousRow.intItemId         <> CurrentRow.intItemId
		   JOIN tblICItem						CurrentType				   ON	CurrentType.intItemId	      =	 CurrentRow.intItemId
		   JOIN tblICItem						PreviousType			   ON	PreviousType.intItemId		  =	 PreviousRow.intItemId
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY					NewRecords				    ON  NewRecords.intSequenceHistoryId     =  CurrentRow.intSequenceHistoryId
		   JOIN @tblDetail					    PreviousRow			        ON   PreviousRow.dblQuantity		    <> CurrentRow.dblQuantity
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY					NewRecords						   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow	                       ON   PreviousRow.intItemUOMId        <> CurrentRow.intItemUOMId
		   JOIN	tblICItemUOM					PU								   ON	PU.intItemUOMId				    = CurrentRow.intItemUOMId		
		   JOIN	tblICUnitMeasure				U2								   ON	U2.intUnitMeasureId			    = PU.intUnitMeasureId
		   JOIN	tblICItemUOM					PU1								   ON	PU1.intItemUOMId			    = PreviousRow.intItemUOMId		
		   JOIN	tblICUnitMeasure				U21								   ON	U21.intUnitMeasureId		    = PU1.intUnitMeasureId
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
		   ,intConcurrencyId		=  1   
		   
		   FROM tblCTSequenceHistory				CurrentRow
		   JOIN @SCOPE_IDENTITY						NewRecords						ON		    NewRecords.intSequenceHistoryId     =   CurrentRow.intSequenceHistoryId
		   JOIN @tblDetail							PreviousRow						ON   ISNULL(CurrentRow.intFutureMarketId,0)     <>  ISNULL(PreviousRow.intFutureMarketId,0)
		   LEFT JOIN tblRKFutureMarket				CurrentType						ON	 ISNULL(CurrentType.intFutureMarketId,0)    =	ISNULL(CurrentRow.intFutureMarketId	,0)
		   LEFT JOIN tblRKFutureMarket				PreviousType					ON	 ISNULL(PreviousType.intFutureMarketId,0) 	=	ISNULL(PreviousRow.intFutureMarketId,0)
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
		   ,intConcurrencyId		=  1   
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY					NewRecords   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intCurrencyId        <> PreviousRow.intCurrencyId
		   JOIN tblSMCurrency					CurrentType	 ON	  CurrentType.intCurrencyID		  =	CurrentRow.intCurrencyId
		   JOIN tblSMCurrency					PreviousType ON	  PreviousType.intCurrencyID	  =	PreviousRow.intCurrencyId
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
		   ,intConcurrencyId		=  1   
		   
		   FROM tblCTSequenceHistory			    CurrentRow
		   JOIN @SCOPE_IDENTITY					    NewRecords   ON   NewRecords.intSequenceHistoryId			= CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					        PreviousRow	 ON   ISNULL(CurrentRow.intFutureMonthId  ,0)   <>  ISNULL(PreviousRow.intFutureMonthId ,0)
		   LEFT JOIN tblRKFuturesMonth				CurrentType	 ON	  ISNULL(CurrentType.intFutureMonthId ,0)    =	ISNULL(CurrentRow.intFutureMonthId	,0)
		   LEFT JOIN tblRKFuturesMonth				PreviousType ON	  ISNULL(PreviousType.intFutureMonthId,0)	 =	ISNULL(PreviousRow.intFutureMonthId	,0)
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY				    NewRecords   ON   NewRecords.intSequenceHistoryId	= CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow	 ON   ISNULL(CurrentRow.dblFutures,0)   <> ISNULL(PreviousRow.dblFutures,0)
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY				    NewRecords          ON   NewRecords.intSequenceHistoryId  = CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow			ON   ISNULL(CurrentRow.dblBasis,0)    <> ISNULL(PreviousRow.dblBasis,0)
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
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @SCOPE_IDENTITY					NewRecords          ON   NewRecords.intSequenceHistoryId	=  CurrentRow.intSequenceHistoryId 
		   JOIN @tblDetail					    PreviousRow			ON   ISNULL(CurrentRow.dblCashPrice,0)  <> ISNULL(PreviousRow.dblCashPrice,0)
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
		   ,strOldValue			    =  U21.strUnitMeasure
		   ,strNewValue		        =  U2.strUnitMeasure
		   ,intConcurrencyId		=  1  
		   
		   FROM tblCTSequenceHistory			CurrentRow
		   JOIN @tblDetail					    PreviousRow	 ON   CurrentRow.intPriceItemUOMId    <> PreviousRow.intPriceItemUOMId
		   JOIN @SCOPE_IDENTITY					NewRecords   ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
		   JOIN	tblICItemUOM					PU			 ON	  PU.intItemUOMId			      =	CurrentRow.intPriceItemUOMId		
		   JOIN	tblICUnitMeasure				U2			 ON	  U2.intUnitMeasureId		      =	PU.intUnitMeasureId
		   JOIN	tblICItemUOM					PU1			 ON	  PU1.intItemUOMId				  =	PreviousRow.intPriceItemUOMId	
		   JOIN	tblICUnitMeasure				U21			 ON	  U21.intUnitMeasureId			  =	PU1.intUnitMeasureId
		   WHERE U2.intUnitMeasureId <> U21.intUnitMeasureId
		   AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		END     
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
