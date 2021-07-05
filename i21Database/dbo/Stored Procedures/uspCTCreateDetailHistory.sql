﻿CREATE PROCEDURE [dbo].[uspCTCreateDetailHistory]
	@intContractHeaderId	   INT,
    @intContractDetailId	   INT = NULL,
	@strComment				   NVARCHAR(100) = NULL,
	@intSequenceUsageHistoryId INT = NULL,
	@ysnUseContractDate		   BIT = 0,
	@strSource				   NVARCHAR(50),
	@strProcess				   NVARCHAR(50),
	@intUserId				   INT
AS	   

BEGIN TRY
		DECLARE @ErrMsg					NVARCHAR(MAX),
				@intApprovalListId		INT,
				@intLastModifiedById	INT,
				@ysnAmdWoAppvl			BIT,
				@intSequenceHistoryId	INT,
				@intPrevHistoryId		iNT,
				@dblPrevQty				NUMERIC(18,6),
				@dblPrevBal				NUMERIC(18,6),
				@intPrevStatusId		INT,
				@dblQuantity			NUMERIC(18,6),
				@dblBalance				NUMERIC(18,6),
				@intContractStatusId	INT,
				@dblPrevFutures			NUMERIC(18,6),
				@dblPrevBasis			NUMERIC(18,6),
				@dblPrevCashPrice		NUMERIC(18,6),
				@dblFutures				NUMERIC(18,6),
				@dblBasis				NUMERIC(18,6),
				@dblCashPrice			NUMERIC(18,6),
				@strTransactionType		NVARCHAR(20),
				@strScreenName			NVARCHAR(20),
				@ysnStayAsDraftContractUntilApproved BIT,
                @ysnAddAmendmentForNonDraftContract BIT = 0
	
		DECLARE @tblHeader AS TABLE 
		(
			intContractHeaderId		       INT,
			intEntityId			           INT,
			intPositionId				   INT,
			intContractBasisId			   INT,
			intTermId					   INT,
			intGradeId					   INT,
			intWeightId					   INT,
			intFreightTermId				INT
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
		

		SELECT TOP 1 @strScreenName = strScreenName FROM tblCTSequenceUsageHistory WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId

		DECLARE	@SCOPE_IDENTITY TABLE (intSequenceHistoryId INT)

		IF @intContractHeaderId IS NULL AND @intContractDetailId IS NOT NULL
		BEGIN
		SELECT @intContractHeaderId	=   intContractHeaderId FROM tblCTContractDetail with (nolock) WHERE intContractDetailId = @intContractDetailId
		END
		
		SELECT @intLastModifiedById = intLastModifiedById FROM tblCTContractHeader with (nolock) WHERE intContractHeaderId = @intContractHeaderId
		SELECT @intApprovalListId   = intApprovalListId FROM tblSMUserSecurityRequireApprovalFor with (nolock) WHERE [intEntityUserSecurityId] = @intLastModifiedById AND [intScreenId] = (select [intScreenId] from tblSMScreen where strScreenName = 'Amendment and Approvals')
		SELECT @ysnAmdWoAppvl       = ISNULL(ysnAmdWoAppvl,0), @ysnStayAsDraftContractUntilApproved = isnull(ysnStayAsDraftContractUntilApproved,0) FROM tblCTCompanyPreference

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
			,intFreightTermId			
		)

		SELECT TOP 1
		 intContractHeaderId
		,intEntityId		
		,intPositionId		
		,intContractBasisId	
		,intTermId			
		,intGradeId			
		,intWeightId
		,intFreightTermId
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
			,dblScheduleQty,				dtmHistoryCreated,				dblCashPrice,						strPricingStatus,			intContractBasisId			
			,intGradeId,					intItemUOMId,					intPositionId,						intPriceItemUOMId,			intTermId			
			,intWeightId,					intBookId,						intSubBookId,						dblRatio,					strBook
			,strSubBook,					intSequenceUsageHistoryId,		dtmDateAdded,						intUserId,					intFreightTermId
		)
		OUTPUT	inserted.intSequenceHistoryId INTO @SCOPE_IDENTITY
		SELECT   
			 CD.intContractHeaderId,		CD.intContractDetailId,			CH.intContractTypeId,				CH.intCommodityId,		    intEntityId
			,intContractStatusId,			CD.intCompanyLocationId,		intItemId,							CD.intPricingTypeId,	    CD.intFutureMarketId
			,CD.intFutureMonthId,			intCurrencyId,					CASE WHEN CD.intUnitMeasureId IS NULL THEN QU.intCommodityUnitMeasureId ELSE NULL END
			,CD.intUnitMeasureId,			CD.intCurrencyExchangeRateId,   dtmStartDate,						dtmEndDate,						CD.dblQuantity
			,dblBalance,					CD.dblFutures,					dblBasis
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN CD.dblNoOfLots 
					WHEN    @strComment = 'Pricing Delete' THEN 0 
					ELSE	ISNULL(PF.dblLotsFixed,0)
			 END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN 0 
					WHEN    @strComment = 'Pricing Delete' THEN CD.dblNoOfLots 
					ELSE	CD.dblNoOfLots - ISNULL(PF.dblLotsFixed,0) 
			 END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN CD.dblQuantity 
					WHEN    @strComment = 'Pricing Delete' THEN 0 
					ELSE	ISNULL(FD.dblQuantity,0) 
			 END
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN 0 
					WHEN    @strComment = 'Pricing Delete' THEN CD.dblQuantity
					ELSE	CD.dblQuantity - ISNULL(FD.dblQuantity,0)
			 END
			,dblFinalPrice,					dtmFXValidFrom,					dtmFXValidTo,						dblRate,					CO.strCommodityCode
			,strContractNumber,				intContractSeq,					CL.strLocationName,					strContractType,		    strPricingType
			,CD.dblScheduleQty,				
			CASE	WHEN @ysnUseContractDate = 1 
						THEN ISNULL(CD.dtmCreated, CH.dtmCreated) 
					ELSE GETDATE() 
			END
			,dblCashPrice
			,CASE   WHEN	CD.intPricingTypeId	=	1 THEN	 'Fully Priced' 
					WHEN	ISNULL(CD.dblNoOfLots,0) = ISNULL(PF.dblLotsFixed,0) AND CD.intPricingTypeId NOT IN (2,8)	   THEN	 'Fully Priced' 
					WHEN	ISNULL(CD.dblNoOfLots,0) - ISNULL(PF.dblLotsFixed,0) > 0 
							AND PF.intPriceFixationId IS NOT NULL THEN	 'Partially Priced'
					ELSE	'Unpriced'
			END
		    ,intContractBasisId   = CH.intContractBasisId
			,intGradeId			  = CH.intGradeId
			,intItemUOMId		  = CD.intItemUOMId
			,intPositionId		  = CH.intPositionId
			,intPriceItemUOMId    = CD.intPriceItemUOMId
			,intTermId			  = CH.intTermId
			,intWeightId		  = CH.intWeightId
			,intBookId			  = CD.intBookId
			,intSubBookId		  = CD.intSubBookId
			,dblRatio			  = CD.dblRatio
			,strBook			  = BK.strBook
			,strSubBook			  = SB.strSubBook
			,intSequenceUsageHistoryId	=	@intSequenceUsageHistoryId
			,CASE	WHEN @ysnUseContractDate = 1 
						THEN GETDATE()
					ELSE NULL
			END
			,intUserId = @intUserId
			,intFreightTermId = CH.intFreightTermId
		FROM	tblCTContractDetail			CD with (nolock)
		JOIN	tblCTContractHeader			CH with (nolock)  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
		JOIN	tblICCommodity				CO  ON  CO.intCommodityId		=	CH.intCommodityId
		JOIN	tblSMCompanyLocation	    CL  ON  CL.intCompanyLocationId =	CD.intCompanyLocationId
		JOIN	tblCTContractType		    CT  ON  CT.intContractTypeId	=	CH.intContractTypeId
		JOIN	tblCTPricingType		    PT  ON  PT.intPricingTypeId		=	CD.intPricingTypeId
 LEFT	JOIN	tblICCommodityUnitMeasure	QU  ON  QU.intCommodityId		=	CH.intCommodityId
												AND QU.intUnitMeasureId		=	ISNULL(CD.intUnitMeasureId,QU.intUnitMeasureId)
 LEFT   JOIN	tblCTPriceFixation		    PF  ON  PF.intContractDetailId	=	CD.intContractDetailId
 LEFT	JOIN	tblCTBook					BK	ON BK.intBookId				=	CD.intBookId
 LEFT	JOIN	tblCTSubBook				SB	ON SB.intSubBookId			=	CD.intSubBookId
 LEFT   JOIN	 (
					SELECT  intPriceFixationId,SUM(dblQuantity) AS  dblQuantity
					FROM	   tblCTPriceFixationDetail
					GROUP   BY  intPriceFixationId

				  )					FD  ON  FD.intPriceFixationId	  =	 PF.intPriceFixationId
		WHERE   CD.intContractHeaderId  =   @intContractHeaderId
		AND		CD.intContractDetailId	=   ISNULL(@intContractDetailId,CD.intContractDetailId)
    
	SELECT	@intSequenceHistoryId = MIN(intSequenceHistoryId) FROM @SCOPE_IDENTITY
	WHILE	ISNULL(@intSequenceHistoryId,0) > 0
	BEGIN
		SELECT @intPrevHistoryId = NULL
		SELECT @intContractDetailId = intContractDetailId FROM tblCTSequenceHistory WHERE intSequenceHistoryId = @intSequenceHistoryId
		SELECT @intPrevHistoryId = max(intSequenceHistoryId) FROM tblCTSequenceHistory WITH (NOLOCK) WHERE intSequenceHistoryId < @intSequenceHistoryId AND intContractDetailId = @intContractDetailId

		IF @intPrevHistoryId IS not NULL
		BEGIN
			SELECT	@dblPrevQty = dblQuantity,@dblPrevBal = dblBalance,@intPrevStatusId = intContractStatusId,
					@dblPrevFutures = dblFutures,@dblPrevBasis = dblBasis,@dblPrevCashPrice = dblCashPrice
			FROM	tblCTSequenceHistory WHERE intSequenceHistoryId = @intPrevHistoryId

			SELECT	@dblQuantity = dblQuantity,@dblBalance = dblBalance,@intContractStatusId = intContractStatusId,
					@dblFutures = dblFutures,@dblBasis = dblBasis,@dblCashPrice = dblCashPrice
			FROM	tblCTSequenceHistory WHERE intSequenceHistoryId = @intSequenceHistoryId

			IF ISNULL(@dblPrevQty,0) <> ISNULL(@dblQuantity,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldQuantity = @dblPrevQty,ysnQtyChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@dblPrevBal,0) <> ISNULL(@dblBalance,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldBalance = @dblPrevBal,ysnBalanceChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@intPrevStatusId,0) <> ISNULL(@intContractStatusId,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET intOldStatusId = @intPrevStatusId,ysnStatusChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END

			IF ISNULL(@dblPrevFutures,0) <> ISNULL(@dblFutures,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldFutures = @dblPrevFutures,ysnFuturesChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@dblPrevBasis,0) <> ISNULL(@dblBasis,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldBasis = @dblPrevBasis,ysnBasisChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END
			IF ISNULL(@dblPrevCashPrice,0) <> ISNULL(@dblCashPrice,0)
			BEGIN
				UPDATE tblCTSequenceHistory SET dblOldCashPrice = @dblPrevCashPrice,ysnCashPriceChange = 1 WHERE intSequenceHistoryId = @intSequenceHistoryId
			END

			/*Chek if the new created sequence history has a difference from previous record*/
			declare @ysnWithChanges bit =0;
			select @ysnWithChanges =  case when
				she.intContractStatusId <> shn.intContractStatusId or (she.intContractStatusId  is null and  shn.intContractStatusId is not null) or (she.intContractStatusId is not null  and  shn.intContractStatusId is null)
				or she.intCompanyLocationId <> shn.intCompanyLocationId or (she.intCompanyLocationId  is null and  shn.intCompanyLocationId is not null) or (she.intCompanyLocationId is not null  and  shn.intCompanyLocationId is null)
				or she.intItemId <> shn.intItemId or (she.intItemId  is null and  shn.intItemId is not null) or (she.intItemId is not null  and  shn.intItemId is null)
				or she.intPricingTypeId <> shn.intPricingTypeId or (she.intPricingTypeId  is null and  shn.intPricingTypeId is not null) or (she.intPricingTypeId is not null  and  shn.intPricingTypeId is null)
				or she.intFutureMarketId <> shn.intFutureMarketId or (she.intFutureMarketId  is null and  shn.intFutureMarketId is not null) or (she.intFutureMarketId is not null  and  shn.intFutureMarketId is null)
				or she.intFutureMonthId <> shn.intFutureMonthId or (she.intFutureMonthId  is null and  shn.intFutureMonthId is not null) or (she.intFutureMonthId is not null  and  shn.intFutureMonthId is null)
				or she.intDtlQtyInCommodityUOMId <> shn.intDtlQtyInCommodityUOMId or (she.intDtlQtyInCommodityUOMId  is null and  shn.intDtlQtyInCommodityUOMId is not null) or (she.intDtlQtyInCommodityUOMId is not null  and  shn.intDtlQtyInCommodityUOMId is null)
				or she.intDtlQtyUnitMeasureId <> shn.intDtlQtyUnitMeasureId or (she.intDtlQtyUnitMeasureId  is null and  shn.intDtlQtyUnitMeasureId is not null) or (she.intDtlQtyUnitMeasureId is not null  and  shn.intDtlQtyUnitMeasureId is null)
				or she.intCurrencyExchangeRateId <> shn.intCurrencyExchangeRateId or (she.intCurrencyExchangeRateId  is null and  shn.intCurrencyExchangeRateId is not null) or (she.intCurrencyExchangeRateId is not null  and  shn.intCurrencyExchangeRateId is null)
				or she.intBookId <> shn.intBookId or (she.intBookId  is null and  shn.intBookId is not null) or (she.intBookId is not null  and  shn.intBookId is null)
				or she.intSubBookId <> shn.intSubBookId or (she.intSubBookId  is null and  shn.intSubBookId is not null) or (she.intSubBookId is not null  and  shn.intSubBookId is null)
				or she.dtmStartDate <> shn.dtmStartDate or (she.dtmStartDate  is null and  shn.dtmStartDate is not null) or (she.dtmStartDate is not null  and  shn.dtmStartDate is null)
				or she.dtmEndDate <> shn.dtmEndDate or (she.dtmEndDate  is null and  shn.dtmEndDate is not null) or (she.dtmEndDate is not null  and  shn.dtmEndDate is null)
				or she.dblQuantity <> shn.dblQuantity or (she.dblQuantity  is null and  shn.dblQuantity is not null) or (she.dblQuantity is not null  and  shn.dblQuantity is null)
				or she.dblBalance <> shn.dblBalance or (she.dblBalance  is null and  shn.dblBalance is not null) or (she.dblBalance is not null  and  shn.dblBalance is null)
				or she.dblScheduleQty <> shn.dblScheduleQty or (she.dblScheduleQty  is null and  shn.dblScheduleQty is not null) or (she.dblScheduleQty is not null  and  shn.dblScheduleQty is null)
				or she.dblFutures <> shn.dblFutures or (she.dblFutures  is null and  shn.dblFutures is not null) or (she.dblFutures is not null  and  shn.dblFutures is null)
				or she.dblBasis <> shn.dblBasis or (she.dblBasis  is null and  shn.dblBasis is not null) or (she.dblBasis is not null  and  shn.dblBasis is null)
				or she.dblCashPrice <> shn.dblCashPrice or (she.dblCashPrice  is null and  shn.dblCashPrice is not null) or (she.dblCashPrice is not null  and  shn.dblCashPrice is null)
				or she.dblLotsPriced <> shn.dblLotsPriced or (she.dblLotsPriced  is null and  shn.dblLotsPriced is not null) or (she.dblLotsPriced is not null  and  shn.dblLotsPriced is null)
				or she.dblLotsUnpriced <> shn.dblLotsUnpriced or (she.dblLotsUnpriced  is null and  shn.dblLotsUnpriced is not null) or (she.dblLotsUnpriced is not null  and  shn.dblLotsUnpriced is null)
				or she.dblQtyPriced <> shn.dblQtyPriced or (she.dblQtyPriced  is null and  shn.dblQtyPriced is not null) or (she.dblQtyPriced is not null  and  shn.dblQtyPriced is null)
				or she.dblQtyUnpriced <> shn.dblQtyUnpriced or (she.dblQtyUnpriced  is null and  shn.dblQtyUnpriced is not null) or (she.dblQtyUnpriced is not null  and  shn.dblQtyUnpriced is null)
				or she.dblFinalPrice <> shn.dblFinalPrice or (she.dblFinalPrice  is null and  shn.dblFinalPrice is not null) or (she.dblFinalPrice is not null  and  shn.dblFinalPrice is null)
				or she.dblRatio <> shn.dblRatio or (she.dblRatio  is null and  shn.dblRatio is not null) or (she.dblRatio is not null  and  shn.dblRatio is null)
				or she.dtmFXValidFrom <> shn.dtmFXValidFrom or (she.dtmFXValidFrom  is null and  shn.dtmFXValidFrom is not null) or (she.dtmFXValidFrom is not null  and  shn.dtmFXValidFrom is null)
				or she.dtmFXValidTo <> shn.dtmFXValidTo or (she.dtmFXValidTo  is null and  shn.dtmFXValidTo is not null) or (she.dtmFXValidTo is not null  and  shn.dtmFXValidTo is null)
				or she.intContractSeq <> shn.intContractSeq or (she.intContractSeq  is null and  shn.intContractSeq is not null) or (she.intContractSeq is not null  and  shn.intContractSeq is null)
				or she.strPricingStatus <> shn.strPricingStatus or (she.strPricingStatus  is null and  shn.strPricingStatus is not null) or (she.strPricingStatus is not null  and  shn.strPricingStatus is null)
				or she.strCurrencypair <> shn.strCurrencypair or (she.strCurrencypair  is null and  shn.strCurrencypair is not null) or (she.strCurrencypair is not null  and  shn.strCurrencypair is null)
				or she.intGradeId <> shn.intGradeId or (she.intGradeId  is null and  shn.intGradeId is not null) or (she.intGradeId is not null  and  shn.intGradeId is null)
				or she.intItemUOMId <> shn.intItemUOMId or (she.intItemUOMId  is null and  shn.intItemUOMId is not null) or (she.intItemUOMId is not null  and  shn.intItemUOMId is null)
				or she.intPositionId <> shn.intPositionId or (she.intPositionId  is null and  shn.intPositionId is not null) or (she.intPositionId is not null  and  shn.intPositionId is null)
				or she.intPriceItemUOMId <> shn.intPriceItemUOMId or (she.intPriceItemUOMId  is null and  shn.intPriceItemUOMId is not null) or (she.intPriceItemUOMId is not null  and  shn.intPriceItemUOMId is null)
				or she.intTermId <> shn.intTermId or (she.intTermId  is null and  shn.intTermId is not null) or (she.intTermId is not null  and  shn.intTermId is null)
				or she.intWeightId <> shn.intWeightId or (she.intWeightId  is null and  shn.intWeightId is not null) or (she.intWeightId is not null  and  shn.intWeightId is null)
				or she.strAmendmentComment <> shn.strAmendmentComment or (she.strAmendmentComment  is null and  shn.strAmendmentComment is not null) or (she.strAmendmentComment is not null  and  shn.strAmendmentComment is null)
				or she.dblOldQuantity <> shn.dblOldQuantity or (she.dblOldQuantity  is null and  shn.dblOldQuantity is not null) or (she.dblOldQuantity is not null  and  shn.dblOldQuantity is null)
				or she.dblOldBalance <> shn.dblOldBalance or (she.dblOldBalance  is null and  shn.dblOldBalance is not null) or (she.dblOldBalance is not null  and  shn.dblOldBalance is null)
				or she.intOldStatusId <> shn.intOldStatusId or (she.intOldStatusId  is null and  shn.intOldStatusId is not null) or (she.intOldStatusId is not null  and  shn.intOldStatusId is null)
				or she.ysnQtyChange <> shn.ysnQtyChange or (she.ysnQtyChange  is null and  shn.ysnQtyChange is not null) or (she.ysnQtyChange is not null  and  shn.ysnQtyChange is null)
				or she.ysnStatusChange <> shn.ysnStatusChange or (she.ysnStatusChange  is null and  shn.ysnStatusChange is not null) or (she.ysnStatusChange is not null  and  shn.ysnStatusChange is null)
				or she.ysnBalanceChange <> shn.ysnBalanceChange or (she.ysnBalanceChange  is null and  shn.ysnBalanceChange is not null) or (she.ysnBalanceChange is not null  and  shn.ysnBalanceChange is null)
				or she.dblOldFutures <> shn.dblOldFutures or (she.dblOldFutures  is null and  shn.dblOldFutures is not null) or (she.dblOldFutures is not null  and  shn.dblOldFutures is null)
				or she.dblOldBasis <> shn.dblOldBasis or (she.dblOldBasis  is null and  shn.dblOldBasis is not null) or (she.dblOldBasis is not null  and  shn.dblOldBasis is null)
				or she.dblOldCashPrice <> shn.dblOldCashPrice or (she.dblOldCashPrice  is null and  shn.dblOldCashPrice is not null) or (she.dblOldCashPrice is not null  and  shn.dblOldCashPrice is null)
				or she.ysnFuturesChange <> shn.ysnFuturesChange or (she.ysnFuturesChange  is null and  shn.ysnFuturesChange is not null) or (she.ysnFuturesChange is not null  and  shn.ysnFuturesChange is null)
				or she.ysnBasisChange <> shn.ysnBasisChange or (she.ysnBasisChange  is null and  shn.ysnBasisChange is not null) or (she.ysnBasisChange is not null  and  shn.ysnBasisChange is null)
				or she.ysnCashPriceChange <> shn.ysnCashPriceChange or (she.ysnCashPriceChange  is null and  shn.ysnCashPriceChange is not null) or (she.ysnCashPriceChange is not null  and  shn.ysnCashPriceChange is null)
				or she.dtmDateAdded <> shn.dtmDateAdded or (she.dtmDateAdded  is null and  shn.dtmDateAdded is not null) or (she.dtmDateAdded is not null  and  shn.dtmDateAdded is null)
				or she.intFreightTermId <> shn.intFreightTermId or (she.intFreightTermId  is null and  shn.intFreightTermId is not null) or (she.intFreightTermId is not null  and  shn.intFreightTermId is null)
				then 1 else 0 end
				from 
				tblCTSequenceHistory she
				left join tblCTSequenceHistory shn on shn.intSequenceHistoryId = @intPrevHistoryId
				where she.intSequenceHistoryId = @intSequenceHistoryId

				if (@ysnWithChanges = 0)
				BEGIN
					delete from tblCTSequenceHistory where intSequenceHistoryId = @intSequenceHistoryId
				end
		END

		IF NOT (ISNULL(@strScreenName, '') = 'Credit Memo' AND @strProcess = 'Update Sequence Balance' AND @strSource = 'Inventory')
		BEGIN
			-- CONTRACT BALANCE LOG
			DECLARE @contractDetails AS [dbo].[ContractDetailTable]
			EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
								 @intContractDetailId 	= 	@intContractDetailId,
								 @strSource			 	= 	@strSource,
								 @strProcess		 	= 	@strProcess,
								 @contractDetail 		= 	@contractDetails,		
								 @intUserId				=	@intUserId
		END


		SELECT	@intSequenceHistoryId = MIN(intSequenceHistoryId) FROM @SCOPE_IDENTITY WHERE intSequenceHistoryId > @intSequenceHistoryId
	END

    if exists (
        select
            top 1 1
        from
            tblSMScreen scr
            left join tblSMTransaction txn on txn.intScreenId = scr.intScreenId and txn.intRecordId = @intContractHeaderId
            left join tblSMApproval ap on ap.intTransactionId = txn.intTransactionId
        where
            scr.strNamespace = 'ContractManagement.view.Contract'
            and ap.strStatus = 'Approved'
            and @ysnStayAsDraftContractUntilApproved = 1
    )
    begin
        set @ysnAddAmendmentForNonDraftContract = 1;
    end

	IF EXISTS(
        SELECT TOP 1 1
        FROM tblCTContractHeader
        WHERE intContractHeaderId = @intContractHeaderId
        AND (
                (
                    isnull(@ysnStayAsDraftContractUntilApproved,0)=0
                    and
                    (
                        ISNULL(ysnPrinted,0)=1
                        OR ISNULL(ysnSigned,0)=1                
                    )
                )

            OR isnull(@ysnAddAmendmentForNonDraftContract,0)=1
        )
	)
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor WHERE [intEntityUserSecurityId] =@intLastModifiedById AND [intApprovalListId]=@intApprovalListId ) OR (@ysnAmdWoAppvl = 1)
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
		  ,strOldValue			    = PreviousType.strFreightTerm
		  ,strNewValue		        = CurrentType.strFreightTerm
		  ,intConcurrencyId		  =  1

		  FROM tblCTSequenceHistory			    CurrentRow
		  JOIN @SCOPE_IDENTITY				    NewRecords				ON  NewRecords.intSequenceHistoryId	 =  CurrentRow.intSequenceHistoryId 
		  JOIN @tblHeader					    PreviousRow			    ON ISNULL(PreviousRow.intFreightTermId ,0)   <>   ISNULL(CurrentRow.intFreightTermId ,0)
		  LEFT JOIN tblSMFreightTerms		    CurrentType		        ON ISNULL(CurrentType.intFreightTermId ,0)   =	ISNULL(CurrentRow.intFreightTermId ,0)
		  LEFT JOIN tblSMFreightTerms		    PreviousType	        ON ISNULL(PreviousType.intFreightTermId,0)   =	ISNULL(PreviousRow.intFreightTermId,0)
		  
		    
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
