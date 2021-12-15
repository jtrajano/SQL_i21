CREATE PROCEDURE [dbo].[uspCTCreateDetailHistory]
	@intContractHeaderId INT
	, @intContractDetailId INT = NULL
	, @strComment NVARCHAR(100) = NULL
	, @intSequenceUsageHistoryId INT = NULL
	, @ysnUseContractDate BIT = 0
	, @strSource NVARCHAR(50)
	, @strProcess NVARCHAR(50)
	, @intUserId INT

AS

BEGIN TRY	
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @intApprovalListId INT
		, @intLastModifiedById INT
		, @ysnAmdWoAppvl BIT
		, @intSequenceHistoryId INT
		, @intPrevHistoryId INT
		, @dblPrevQty NUMERIC(18, 6)
		, @dblPrevBal NUMERIC(18, 6)
		, @intPrevStatusId INT
		, @dblQuantity NUMERIC(18, 6)
		, @dblBalance NUMERIC(18, 6)
		, @intContractStatusId INT
		, @dblPrevFutures NUMERIC(18, 6)
		, @dblPrevBasis NUMERIC(18, 6)
		, @dblPrevCashPrice NUMERIC(18, 6)
		, @dblFutures NUMERIC(18, 6)
		, @dblBasis NUMERIC(18, 6)
		, @dblCashPrice NUMERIC(18, 6)
		, @strTransactionType NVARCHAR(20)
		, @strScreenName NVARCHAR(20)
        , @ysnStayAsDraftContractUntilApproved BIT
        , @ysnAddAmendmentForNonDraftContract BIT = 0
		, @ysnAmendmentForCashFuture BIT = 0
		;
	
	DECLARE @tblHeader AS TABLE (intContractHeaderId INT
		, intEntityId INT
		, intPositionId INT
		, intContractBasisId INT
		, intTermId INT
		, intGradeId INT
		, intWeightId INT
		, intFreightTermId INT)
		
	DECLARE @tblDetail AS TABLE (intContractHeaderId INT
		, intContractDetailId INT
		, intContractStatusId INT
		, dtmStartDate DATETIME
		, dtmEndDate DATETIME
		, intItemId INT
		, dblQuantity NUMERIC(18,6)
		, intItemUOMId INT
		, intFutureMarketId INT
		, intCurrencyId INT
		, intFutureMonthId INT
		, dblFutures NUMERIC(18,6)
		, dblBasis NUMERIC(18,6)
		, dblCashPrice NUMERIC(18,6)
		, intPriceItemUOMId INT
		, intBookId INT
		, intSubBookId INT)
	
	SELECT TOP 1 @strScreenName = strScreenName FROM tblCTSequenceUsageHistory WHERE intSequenceUsageHistoryId = @intSequenceUsageHistoryId

	DECLARE	@SCOPE_IDENTITY TABLE (intSequenceHistoryId INT)

	IF @intContractHeaderId IS NULL AND @intContractDetailId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId	=   intContractHeaderId FROM tblCTContractDetail with (nolock) WHERE intContractDetailId = @intContractDetailId
	END
		
	SELECT @intLastModifiedById = intLastModifiedById FROM tblCTContractHeader with (nolock) WHERE intContractHeaderId = @intContractHeaderId
	SELECT @intApprovalListId   = intApprovalListId FROM tblSMUserSecurityRequireApprovalFor with (nolock) WHERE [intEntityUserSecurityId] = @intLastModifiedById AND [intScreenId] = (select [intScreenId] from tblSMScreen where strScreenName = 'Amendment and Approvals')
	SELECT @ysnAmdWoAppvl       = ISNULL(ysnAmdWoAppvl,0), @ysnStayAsDraftContractUntilApproved = ISNULL(ysnStayAsDraftContractUntilApproved,0) FROM tblCTCompanyPreference

	DELETE FROM @tblHeader
	DELETE FROM @tblDetail

	INSERT INTO @tblHeader (intContractHeaderId
		, intEntityId
		, intPositionId
		, intContractBasisId
		, intTermId
		, intGradeId
		, intWeightId
		, intFreightTermId)
	SELECT TOP 1 intContractHeaderId
		, intEntityId
		, intPositionId
		, intContractBasisId
		, intTermId
		, intGradeId
		, intWeightId
		, intFreightTermId
	FROM tblCTSequenceHistory
	WHERE intContractHeaderId = @intContractHeaderId ORDER BY intSequenceHistoryId DESC
	
	INSERT INTO @tblDetail (intContractHeaderId
		, intContractDetailId
		, intContractStatusId
		, dtmStartDate
		, dtmEndDate
		, intItemId
		, dblQuantity
		, intItemUOMId
		, intFutureMarketId
		, intCurrencyId
		, intFutureMonthId
		, dblFutures
		, dblBasis
		, dblCashPrice
		, intPriceItemUOMId
		, intBookId
		, intSubBookId)
	SELECT intContractHeaderId
		, t1.intContractDetailId
		, intContractStatusId
		, dtmStartDate
		, dtmEndDate
		, intItemId
		, dblQuantity
		, intItemUOMId
		, intFutureMarketId
		, intCurrencyId
		, intFutureMonthId
		, dblFutures
		, dblBasis
		, dblCashPrice
		, intPriceItemUOMId
		, intBookId
		, intSubBookId
	FROM (SELECT *
		FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY intContractDetailId ORDER BY intSequenceHistoryId DESC) intRowNum
						FROM tblCTSequenceHistory
						WHERE intContractHeaderId = @intContractHeaderId
		) t WHERE intRowNum = 1
	) t1;

	INSERT INTO tblCTSequenceHistory (intContractHeaderId
		, intContractDetailId
		, intContractTypeId
		, intCommodityId
		, intEntityId
		, intContractStatusId
		, intCompanyLocationId
		, intItemId
		, intPricingTypeId
		, intFutureMarketId
		, intFutureMonthId
		, intCurrencyId
		, intDtlQtyInCommodityUOMId
		, intDtlQtyUnitMeasureId
		, intCurrencyExchangeRateId
		, dtmStartDate
		, dtmEndDate
		, dblQuantity
		, dblBalance
		, dblFutures
		, dblBasis
		, dblLotsPriced
		, dblLotsUnpriced
		, dblQtyPriced
		, dblQtyUnpriced
		, dblFinalPrice
		, dtmFXValidFrom
		, dtmFXValidTo
		, dblRate
		, strCommodity
		, strContractNumber
		, intContractSeq
		, strLocation
		, strContractType
		, strPricingType
		, dblScheduleQty
		, dtmHistoryCreated
		, dblCashPrice
		, strPricingStatus
		, intContractBasisId
		, intGradeId
		, intItemUOMId
		, intPositionId
		, intPriceItemUOMId
		, intTermId
		, intWeightId
		, intBookId
		, intSubBookId
		, dblRatio
		, strBook
		, strSubBook
		, intSequenceUsageHistoryId
		, dtmDateAdded
		, intUserId
		, intFreightTermId)
	OUTPUT inserted.intSequenceHistoryId INTO @SCOPE_IDENTITY
	SELECT CD.intContractHeaderId
		, CD.intContractDetailId
		, CH.intContractTypeId
		, CH.intCommodityId
		, intEntityId
		, intContractStatusId
		, CD.intCompanyLocationId
		, intItemId
		, CD.intPricingTypeId
		, CD.intFutureMarketId
		, CD.intFutureMonthId
		, intCurrencyId
		, QU.intCommodityUnitMeasureId
		, CD.intUnitMeasureId
		, CD.intCurrencyExchangeRateId
		, dtmStartDate
		, dtmEndDate
		, CD.dblQuantity
		, dblBalance
		, CD.dblFutures
		, dblBasis
		, CASE	WHEN isnull(CH.ysnMultiplePriceFixation,0) = 1 THEN ISNULL(PFM.dblLotsFixed, 0)
				WHEN CD.intPricingTypeId = 1 THEN CD.dblNoOfLots
				WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN 0
				ELSE ISNULL(PF.dblLotsFixed, 0) END
		, CASE	WHEN isnull(CH.ysnMultiplePriceFixation,0) = 1 THEN CD.dblNoOfLots - ISNULL(PFM.dblLotsFixed, 0)
				WHEN CD.intPricingTypeId = 1 THEN 0
				WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN CD.dblNoOfLots
				ELSE CD.dblNoOfLots - ISNULL(PF.dblLotsFixed, 0) END
		, CASE	WHEN isnull(CH.ysnMultiplePriceFixation,0) = 1 THEN ISNULL(FDM.dblQuantity, 0)
				WHEN CD.intPricingTypeId = 1 THEN CD.dblQuantity
				WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN 0
				ELSE ISNULL(FD.dblQuantity, 0) END
		, CASE	WHEN isnull(CH.ysnMultiplePriceFixation,0) = 1 THEN CD.dblQuantity - ISNULL(FDM.dblQuantity, 0)
				WHEN CD.intPricingTypeId = 1 THEN 0
				WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN CD.dblQuantity
				ELSE CD.dblQuantity - ISNULL(FD.dblQuantity, 0) END
		, CASE WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN NULL WHEN isnull(CH.ysnMultiplePriceFixation,0) = 1 THEN PFM.dblFinalPrice ELSE PF.dblFinalPrice END
		, dtmFXValidFrom
		, dtmFXValidTo
		, dblRate
		, CO.strCommodityCode
		, strContractNumber
		, intContractSeq
		, CL.strLocationName
		, strContractType
		, strPricingType
		, CD.dblScheduleQty
		, CASE	WHEN @ysnUseContractDate = 1 THEN ISNULL(CD.dtmCreated, CH.dtmCreated) ELSE GETDATE() END
		, dblCashPrice
		, CASE WHEN ISNULL(@strProcess, '') = 'Price Delete' THEN 'Unpriced'
			ELSE CASE WHEN CD.intPricingTypeId = 1 THEN 'Fully Priced'
					WHEN ISNULL(CD.dblNoOfLots, 0) = ISNULL(PF.dblLotsFixed, 0) AND CD.intPricingTypeId NOT IN(2, 8) THEN 'Fully Priced'
					WHEN ISNULL(CD.dblNoOfLots, 0) - ISNULL(PF.dblLotsFixed, 0) > 0 AND PF.intPriceFixationId IS NOT NULL THEN 'Partially Priced'
					ELSE 'Unpriced' END END
		, intContractBasisId = CH.intContractBasisId
		, intGradeId = CH.intGradeId
		, intItemUOMId = CD.intItemUOMId
		, intPositionId = CH.intPositionId
		, intPriceItemUOMId = CD.intPriceItemUOMId
		, intTermId = CH.intTermId
		, intWeightId = CH.intWeightId
		, intBookId = CD.intBookId
		, intSubBookId = CD.intSubBookId
		, dblRatio = CD.dblRatio
		, strBook = BK.strBook
		, strSubBook = SB.strSubBook
		, intSequenceUsageHistoryId = @intSequenceUsageHistoryId
		, CASE WHEN @ysnUseContractDate = 1 THEN GETDATE() ELSE NULL END
		, intUserId = @intUserId
		, intFreightTermId = CH.intFreightTermId
	FROM	tblCTContractDetail			CD with (nolock)
	JOIN	tblCTContractHeader			CH with (nolock)  ON  CH.intContractHeaderId	=	CD.intContractHeaderId
	JOIN	tblICCommodity				CO  ON  CO.intCommodityId		=	CH.intCommodityId
	JOIN	tblSMCompanyLocation	    CL  ON  CL.intCompanyLocationId =	CD.intCompanyLocationId
	JOIN	tblCTContractType		    CT  ON  CT.intContractTypeId	=	CH.intContractTypeId
	JOIN	tblCTPricingType		    PT  ON  PT.intPricingTypeId		=	CD.intPricingTypeId
	LEFT JOIN	tblICCommodityUnitMeasure	QU  ON  QU.intCommodityId		=	CH.intCommodityId AND QU.intUnitMeasureId		=	ISNULL(CD.intUnitMeasureId,QU.intUnitMeasureId)
	LEFT JOIN	tblCTPriceFixation		    PF  ON  PF.intContractDetailId	=	CD.intContractDetailId
	LEFT JOIN	tblCTBook					BK	ON BK.intBookId				=	CD.intBookId
	LEFT JOIN	tblCTSubBook				SB	ON SB.intSubBookId			=	CD.intSubBookId
	LEFT JOIN	(
		SELECT  intPriceFixationId,SUM(dblQuantity) AS  dblQuantity
		FROM	   tblCTPriceFixationDetail
		GROUP   BY  intPriceFixationId
	) FD  ON  FD.intPriceFixationId	  =	 PF.intPriceFixationId
  
	LEFT JOIN tblCTPriceFixationMultiplePrice      PFM  ON  PFM.intContractDetailId = CD.intContractDetailId  
	LEFT JOIN (  
		SELECT  intPriceFixationMultiplePriceId,SUM(dblQuantity) AS  dblQuantity  
		FROM    tblCTPriceFixationDetailMultiplePrice  
		GROUP   BY  intPriceFixationMultiplePriceId  
	) FDM  ON  FDM.intPriceFixationMultiplePriceId   =  PFM.intPriceFixationMultiplePriceId 
	WHERE   CD.intContractHeaderId  =   @intContractHeaderId
		AND	CD.intContractDetailId	=   ISNULL(@intContractDetailId,CD.intContractDetailId)

	DECLARE @intSequenceHistoryCount INT
		, @intValidSequenceHistoryCount INT;
    
	SELECT	@intSequenceHistoryId = MIN(intSequenceHistoryId) FROM @SCOPE_IDENTITY
	WHILE	ISNULL(@intSequenceHistoryId,0) > 0
	BEGIN
		SELECT @intPrevHistoryId = NULL
		SELECT @intContractDetailId = intContractDetailId FROM tblCTSequenceHistory WHERE intSequenceHistoryId = @intSequenceHistoryId
		SELECT @intPrevHistoryId = max(intSequenceHistoryId) FROM tblCTSequenceHistory WITH (NOLOCK) WHERE intSequenceHistoryId < @intSequenceHistoryId AND intContractDetailId = @intContractDetailId

		DECLARE @contractDetails AS [dbo].[ContractDetailTable]

		IF (OBJECT_ID('tempdb..#tempSequenceHistoryCompare') IS NOT NULL)
		BEGIN
			DROP TABLE #tempSequenceHistoryCompare;
		END

		SELECT TOP 2 intContractStatusId
			, intCompanyLocationId
			, intPricingTypeId
			, intFutureMarketId
			, intFutureMonthId
			, intCurrencyId
			, intDtlQtyInCommodityUOMId
			, intDtlQtyUnitMeasureId
			, intCurrencyExchangeRateId
			, intBookId
			, intSubBookId
			, dtmStartDate
			, dtmEndDate
			, dblQuantity
			, dblBalance
			, dblScheduleQty
			, dblFutures
			, dblBasis
			, dblCashPrice
			, dblLotsPriced
			, dblLotsUnpriced
			, dblQtyPriced
			, dblQtyUnpriced
			, dblFinalPrice
			, dblRatio
			, dtmFXValidFrom
			, dtmFXValidTo
			, dblRate
			, strPricingType
			, strPricingStatus
			, strCurrencypair
			, strBook
			, strSubBook
			, intPriceItemUOMId
			, intSequenceUsageHistoryId
			, ysnIsClosed = CASE WHEN intContractStatusId IN (1, 4) THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
		INTO #tempSequenceHistoryCompare
		FROM tblCTSequenceHistory WHERE intContractDetailId = @intContractDetailId ORDER BY intSequenceHistoryId DESC

		SELECT @intSequenceHistoryCount = COUNT(*) FROM #tempSequenceHistoryCompare

		SELECT @intValidSequenceHistoryCount = COUNT(*) FROM (
			SELECT DISTINCT * FROM #tempSequenceHistoryCompare
		)tbl

		IF (@intSequenceHistoryCount = 2 AND @intValidSequenceHistoryCount = 1)
		BEGIN
			DELETE
			FROM tblCTSequenceHistory
			WHERE intSequenceHistoryId = @intSequenceHistoryId;
		END
		ELSE
		BEGIN			
			SELECT @intPrevHistoryId = MAX(intSequenceHistoryId)
			FROM tblCTSequenceHistory WITH(NOLOCK)
			WHERE intSequenceHistoryId < @intSequenceHistoryId
				AND intContractDetailId = @intContractDetailId;
			
			IF @intPrevHistoryId IS NOT NULL
			BEGIN
				SELECT @dblPrevQty = dblQuantity
					, @dblPrevBal = dblBalance
					, @intPrevStatusId = intContractStatusId
					, @dblPrevFutures = dblFutures
					, @dblPrevBasis = dblBasis
					, @dblPrevCashPrice = dblCashPrice
				FROM tblCTSequenceHistory
				WHERE intSequenceHistoryId = @intPrevHistoryId;
				
				SELECT @dblQuantity = dblQuantity
					, @dblBalance = dblBalance
					, @intContractStatusId = intContractStatusId
					, @dblFutures = dblFutures
					, @dblBasis = dblBasis
					, @dblCashPrice = dblCashPrice
				FROM tblCTSequenceHistory
				WHERE intSequenceHistoryId = @intSequenceHistoryId;
				
				IF ISNULL(@dblPrevQty, 0) <> ISNULL(@dblQuantity, 0)
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
			END

			IF NOT (ISNULL(@strScreenName, '') = 'Credit Memo' AND @strProcess = 'Update Sequence Balance' AND @strSource = 'Inventory')
			BEGIN
				-- CONTRACT BALANCE LOG
				EXEC uspCTLogSummary @intContractHeaderId 	= 	@intContractHeaderId,
									 @intContractDetailId 	= 	@intContractDetailId,
									 @strSource			 	= 	@strSource,
									 @strProcess		 	= 	@strProcess,
									 @contractDetail 		= 	@contractDetails,		
									 @intUserId				=	@intUserId
			END
			
		END

		SELECT	@intSequenceHistoryId = MIN(intSequenceHistoryId) FROM @SCOPE_IDENTITY WHERE intSequenceHistoryId > @intSequenceHistoryId
	END

    IF EXISTS (SELECT TOP 1 1 FROM tblSMScreen scr
				LEFT JOIN tblSMTransaction txn ON txn.intScreenId = scr.intScreenId and txn.intRecordId = @intContractHeaderId
				LEFT JOIN tblSMApproval ap ON ap.intTransactionId = txn.intTransactionId
				WHERE scr.strNamespace = 'ContractManagement.view.Contract'
					AND ap.strStatus = 'Approved'
					AND @ysnStayAsDraftContractUntilApproved = 1)
    BEGIN
        SET @ysnAddAmendmentForNonDraftContract = 1;
    END

	
	IF EXISTS(
		SELECT
		TOP 1 1
		FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords   ON   NewRecords.intSequenceHistoryId	= CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow	 ON   ISNULL(CurrentRow.dblFutures,0)   <> ISNULL(PreviousRow.dblFutures,0) OR ISNULL(CurrentRow.dblCashPrice,0)   <> ISNULL(PreviousRow.dblCashPrice,0) 
		WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId 
			 AND (CurrentRow.dblOldFutures IS NOT NULL OR CurrentRow.dblOldCashPrice IS NOT NULL)
	)

	BEGIN
		SET @ysnAmendmentForCashFuture = 1
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
	
	IF EXISTS (
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
		IF EXISTS(SELECT TOP 1 1 FROM tblSMUserSecurityRequireApprovalFor WHERE intEntityUserSecurityId = @intLastModifiedById AND intApprovalListId = @intApprovalListId) OR (@ysnAmdWoAppvl = 1)
		BEGIN
			INSERT INTO tblCTSequenceAmendmentLog (intSequenceHistoryId
				, dtmHistoryCreated
				, intContractHeaderId
				, intContractDetailId
				, intAmendmentApprovalId
				, strItemChanged
				, strOldValue
				, strNewValue
				, intConcurrencyId)
			
			--Entity
			SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 1
				, strItemChanged			= 'Entity'
				, strOldValue				= PreviousType.strName
				, strNewValue				= CurrentType.strName
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords          ON  NewRecords.intSequenceHistoryId			=   CurrentRow.intSequenceHistoryId 
			JOIN @tblHeader				PreviousRow			ON  ISNULL(PreviousRow.intEntityId,0)		<>  ISNULL(CurrentRow.intEntityId,0)
			LEFT JOIN tblEMEntity		CurrentType		    ON CurrentType.intEntityId			        =	CurrentRow.intEntityId
			LEFT JOIN tblEMEntity		PreviousType	    ON PreviousType.intEntityId			        =	PreviousRow.intEntityId

			--Position
			UNION SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 2
				, strItemChanged			= 'Position'
				, strOldValue				= PreviousType.strPosition
				, strNewValue				= CurrentType.strPosition
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId			=    CurrentRow.intSequenceHistoryId 
			JOIN @tblHeader				PreviousRow			ON ISNULL(PreviousRow.intPositionId ,0)		<>   ISNULL(CurrentRow.intPositionId ,0)
			LEFT JOIN tblCTPosition		CurrentType			ON ISNULL(CurrentType.intPositionId ,0)		=	ISNULL(CurrentRow.intPositionId	,0)
			LEFT JOIN tblCTPosition		PreviousType		ON ISNULL(PreviousType.intPositionId,0)		=	ISNULL(PreviousRow.intPositionId,0)

			--INCO/Ship Term
			UNION SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 3
				, strItemChanged			= 'INCO/Ship Term' 
				, strOldValue				= PreviousType.strFreightTerm
				, strNewValue				= CurrentType.strFreightTerm
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId	 =  CurrentRow.intSequenceHistoryId 
			JOIN @tblHeader				PreviousRow			ON ISNULL(PreviousRow.intFreightTermId ,0)   <>   ISNULL(CurrentRow.intFreightTermId ,0)
			LEFT JOIN tblSMFreightTerms	CurrentType		    ON ISNULL(CurrentType.intFreightTermId ,0)   =	ISNULL(CurrentRow.intFreightTermId ,0)
			LEFT JOIN tblSMFreightTerms	PreviousType	    ON ISNULL(PreviousType.intFreightTermId,0)   =	ISNULL(PreviousRow.intFreightTermId,0)

			--Terms
			UNION SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 4
				, strItemChanged			= 'Terms'
				, strOldValue			    =  PreviousType.strTerm
				, strNewValue		        =  CurrentType.strTerm
				, intConcurrencyId			=  1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId			=   CurrentRow.intSequenceHistoryId
			JOIN @tblHeader				PreviousRow			ON ISNULL(PreviousRow.intTermId ,0)        <>   ISNULL(CurrentRow.intTermId	,0)
			LEFT JOIN tblSMTerm			CurrentType			ON ISNULL(CurrentType.intTermID	,0)         =	ISNULL(CurrentRow.intTermId	,0)
			LEFT JOIN tblSMTerm			PreviousType		ON ISNULL(PreviousType.intTermID,0)	        =	ISNULL(PreviousRow.intTermId,0)

			--Grades
			UNION SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 5
				, strItemChanged			= 'Grades' 
				, strOldValue			    = PreviousType.strWeightGradeDesc
				, strNewValue		        = CurrentType.strWeightGradeDesc
				, intConcurrencyId		    = 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId			 =    CurrentRow.intSequenceHistoryId 
			JOIN @tblHeader				PreviousRow			ON  ISNULL(PreviousRow.intGradeId       ,0)  <>   ISNULL(CurrentRow.intGradeId ,0)
			LEFT JOIN tblCTWeightGrade	CurrentType			ON	ISNULL(CurrentType.intWeightGradeId ,0)   =   ISNULL(CurrentRow.intGradeId ,0)
			LEFT JOIN tblCTWeightGrade	PreviousType		ON	ISNULL(PreviousType.intWeightGradeId,0)   =   ISNULL(PreviousRow.intGradeId,0)

			--Weights
			UNION SELECT TOP 1 intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId		= NULL
				, intAmendmentApprovalId	= 6
				, strItemChanged			= 'Weights'
				, strOldValue			    = PreviousType.strWeightGradeDesc
				, strNewValue		        = CurrentType.strWeightGradeDesc
				, intConcurrencyId		    = 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId			 =   CurrentRow.intSequenceHistoryId
			JOIN @tblHeader				PreviousRow			ON  ISNULL(PreviousRow.intWeightId      ,0)  <>  ISNULL(CurrentRow.intWeightId ,0)
			LEFT JOIN tblCTWeightGrade	CurrentType			ON	ISNULL(CurrentType.intWeightGradeId	,0)  =	 ISNULL(CurrentRow.intWeightId ,0)
			LEFT JOIN tblCTWeightGrade	PreviousType		ON	ISNULL(PreviousType.intWeightGradeId,0)	 =	 ISNULL(PreviousRow.intWeightId,0)

			--intContractStatusId
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 7
				, strItemChanged			= 'Status' 
				, strOldValue			    = PreviousType.strContractStatus
				, strNewValue		        = CurrentType.strContractStatus
				, intConcurrencyId		    = 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId		  =  CurrentRow.intSequenceHistoryId
			JOIN @tblDetail				PreviousRow			ON PreviousRow.intContractStatusId       <>  CurrentRow.intContractStatusId
			JOIN tblCTContractStatus	CurrentType			ON	CurrentType.intContractStatusId	      =	 CurrentRow.intContractStatusId
			JOIN tblCTContractStatus	PreviousType		ON	PreviousType.intContractStatusId	  =	 PreviousRow.intContractStatusId
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--dtmStartDate
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 8
				, strItemChanged			= 'Start Date'
				, strOldValue			    = Convert(Nvarchar,PreviousRow.dtmStartDate,101)
				, strNewValue		        = Convert(Nvarchar,CurrentRow.dtmStartDate,101)
				, intConcurrencyId		    = 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId				 =  CurrentRow.intSequenceHistoryId
			JOIN @tblDetail				PreviousRow			ON Convert(Nvarchar,PreviousRow.dtmStartDate,101) <> Convert(Nvarchar,CurrentRow.dtmStartDate,101)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--dtmEndDate
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId		= @intContractHeaderId
				, intContractDetailId		= CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 9
				, strItemChanged			= 'End Date' 
				, strOldValue			    = Convert(Nvarchar,PreviousRow.dtmEndDate,101)
				, strNewValue		        = Convert(Nvarchar,CurrentRow.dtmEndDate,101)
				, intConcurrencyId		    = 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId			    =  CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON  Convert(Nvarchar,PreviousRow.dtmEndDate,101) <> Convert(Nvarchar,CurrentRow.dtmEndDate,101)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Item
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 10
				, strItemChanged		    =  'Items' 
				, strOldValue			    =  PreviousType.strItemNo
				, strNewValue		        =  CurrentType.strItemNo
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON   PreviousRow.intItemId         <> CurrentRow.intItemId
			JOIN tblICItem				CurrentType			ON	CurrentType.intItemId	      =	 CurrentRow.intItemId
			JOIN tblICItem				PreviousType		ON	PreviousType.intItemId		  =	 PreviousRow.intItemId
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

			--dblQuantity
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 11
				, strItemChanged		    =  'Quantity' 
				, strOldValue			    =  LTRIM(PreviousRow.dblQuantity)  
				, strNewValue		        =  LTRIM(CurrentRow.dblQuantity)
				, intConcurrencyId			= 1 
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON  NewRecords.intSequenceHistoryId     =  CurrentRow.intSequenceHistoryId
			JOIN @tblDetail				PreviousRow			ON   PreviousRow.dblQuantity		    <> CurrentRow.dblQuantity
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Quantity UOM
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 12
				, strItemChanged		    =  'Quantity UOM'  
				, strOldValue			    = U21.strUnitMeasure
				, strNewValue		        = U2.strUnitMeasure
				, intConcurrencyId			= 1 
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON   PreviousRow.intItemUOMId        <> CurrentRow.intItemUOMId
			JOIN	tblICItemUOM		PU					ON	PU.intItemUOMId				    = CurrentRow.intItemUOMId		
			JOIN	tblICUnitMeasure	U2					ON	U2.intUnitMeasureId			    = PU.intUnitMeasureId
			JOIN	tblICItemUOM		PU1					ON	PU1.intItemUOMId			    = PreviousRow.intItemUOMId		
			JOIN	tblICUnitMeasure	U21					ON	U21.intUnitMeasureId		    = PU1.intUnitMeasureId
			WHERE  U2.intUnitMeasureId <> U21.intUnitMeasureId 
				AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Futures Market
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE() 
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 13
				, strItemChanged		    =  'Futures Market'
				, strOldValue			    = PreviousType.strFutMarketName
				, strNewValue		        = CurrentType.strFutMarketName
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	 CurrentRow
			JOIN @SCOPE_IDENTITY		 NewRecords			ON		    NewRecords.intSequenceHistoryId     =   CurrentRow.intSequenceHistoryId
			JOIN @tblDetail				 PreviousRow		ON   ISNULL(CurrentRow.intFutureMarketId,0)     <>  ISNULL(PreviousRow.intFutureMarketId,0)
			LEFT JOIN tblRKFutureMarket	 CurrentType		ON	 ISNULL(CurrentType.intFutureMarketId,0)    =	ISNULL(CurrentRow.intFutureMarketId	,0)
			LEFT JOIN tblRKFutureMarket	 PreviousType		ON	 ISNULL(PreviousType.intFutureMarketId,0) 	=	ISNULL(PreviousRow.intFutureMarketId,0)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Currency
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 14
				, strItemChanged		    =  'Currency'
				, strOldValue			    = PreviousType.strCurrency
				, strNewValue		        = CurrentType.strCurrency
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords			ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON   CurrentRow.intCurrencyId        <> PreviousRow.intCurrencyId
			JOIN tblSMCurrency			CurrentType			ON	  CurrentType.intCurrencyID		  =	CurrentRow.intCurrencyId
			JOIN tblSMCurrency			PreviousType		ON	  PreviousType.intCurrencyID	  =	PreviousRow.intCurrencyId
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--FutureMonth
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 15
				, strItemChanged		    =  'Mn/Yr'
				, strOldValue			    = PreviousType.strFutureMonth
				, strNewValue		        = CurrentType.strFutureMonth
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	 CurrentRow
			JOIN @SCOPE_IDENTITY		 NewRecords			ON	NewRecords.intSequenceHistoryId			= CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				 PreviousRow		ON	ISNULL(CurrentRow.intFutureMonthId  ,0)   <>  ISNULL(PreviousRow.intFutureMonthId ,0)
			LEFT JOIN tblRKFuturesMonth	 CurrentType		ON	ISNULL(CurrentType.intFutureMonthId ,0)    =	ISNULL(CurrentRow.intFutureMonthId	,0)
			LEFT JOIN tblRKFuturesMonth	 PreviousType		ON	ISNULL(PreviousType.intFutureMonthId,0)	 =	ISNULL(PreviousRow.intFutureMonthId	,0)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
				and PreviousType.strFutureMonth <> CurrentType.strFutureMonth
			
			--Futures
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 16
				, strItemChanged		    =  'Futures'
				, strOldValue			    = LTRIM(PreviousRow.dblFutures)
				, strNewValue		        = LTRIM(CurrentRow.dblFutures)
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords   ON   NewRecords.intSequenceHistoryId	= CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow	 ON   ISNULL(CurrentRow.dblFutures,0)   <> ISNULL(PreviousRow.dblFutures,0)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Basis
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId 
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 17
				, strItemChanged		    = 'Basis'
				, strOldValue			    = LTRIM(PreviousRow.dblBasis)
				, strNewValue		        = LTRIM(CurrentRow.dblBasis)
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords          ON   NewRecords.intSequenceHistoryId  = CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON   ISNULL(CurrentRow.dblBasis,0)    <> ISNULL(PreviousRow.dblBasis,0)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

			--CashPrice
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 18
				, strItemChanged		    = 'Cash Price'
				, strOldValue			    = LTRIM(PreviousRow.dblCashPrice)
				, strNewValue		        = LTRIM(CurrentRow.dblCashPrice)
				, intConcurrencyId			= 1 
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @SCOPE_IDENTITY		NewRecords          ON   NewRecords.intSequenceHistoryId	=  CurrentRow.intSequenceHistoryId 
			JOIN @tblDetail				PreviousRow			ON   ISNULL(CurrentRow.dblCashPrice,0)  <> ISNULL(PreviousRow.dblCashPrice,0)
			WHERE CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			and @ysnAmendmentForCashFuture = 1
			
			--Cash Price UOM
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 19
				, strItemChanged		    = 'Cash Price UOM'
				, strOldValue			    =  U21.strUnitMeasure
				, strNewValue		        =  U2.strUnitMeasure
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @tblDetail				PreviousRow			ON   CurrentRow.intPriceItemUOMId    <> PreviousRow.intPriceItemUOMId
			JOIN @SCOPE_IDENTITY		NewRecords			ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			JOIN	tblICItemUOM		PU					ON	  PU.intItemUOMId			      =	CurrentRow.intPriceItemUOMId		
			JOIN	tblICUnitMeasure	U2					ON	  U2.intUnitMeasureId		      =	PU.intUnitMeasureId
			JOIN	tblICItemUOM		PU1					ON	  PU1.intItemUOMId				  =	PreviousRow.intPriceItemUOMId	
			JOIN	tblICUnitMeasure	U21					ON	  U21.intUnitMeasureId			  =	PU1.intUnitMeasureId
			WHERE U2.intUnitMeasureId <> U21.intUnitMeasureId
				AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId

			--Book
			UNION SELECT intSequenceHistoryId = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 20
				, strItemChanged		    = 'Book'
				, strOldValue			    =  oldBook.strBook
				, strNewValue		        =  newBook.strBook
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @tblDetail				PreviousRow			ON   ISNULL(CurrentRow.intBookId,0)    <> ISNULL(PreviousRow.intBookId,0)
			JOIN @SCOPE_IDENTITY		NewRecords			ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			LEFT JOIN tblCTBook newBook on ISNULL(newBook.intBookId,0) = ISNULL(CurrentRow.intBookId,0)
			LEFT JOIN tblCTBook oldBook on ISNULL(oldBook.intBookId,0) = ISNULL(PreviousRow.intBookId,0)
			WHERE ISNULL(oldBook.intBookId,0) <> ISNULL(newBook.intBookId,0)
				AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
			
			--Sub Book
			UNION SELECT intSequenceHistoryId    = NewRecords.intSequenceHistoryId
				, dtmHistoryCreated			= GETDATE()
				, intContractHeaderId	    = @intContractHeaderId
				, intContractDetailId	    = CurrentRow.intContractDetailId
				, intAmendmentApprovalId	= 21
				, strItemChanged		    = 'Sub Book'
				, strOldValue			    =  oldSubBook.strSubBook
				, strNewValue		        =  newSubBook.strSubBook
				, intConcurrencyId			= 1
			FROM tblCTSequenceHistory	CurrentRow
			JOIN @tblDetail				PreviousRow			ON   ISNULL(CurrentRow.intSubBookId,0)    <> ISNULL(PreviousRow.intSubBookId,0)
			JOIN @SCOPE_IDENTITY		NewRecords			ON   NewRecords.intSequenceHistoryId = CurrentRow.intSequenceHistoryId 
			LEFT JOIN tblCTSubBook newSubBook on ISNULL(newSubBook.intSubBookId,0) = ISNULL(CurrentRow.intSubBookId,0)
			LEFT JOIN tblCTSubBook oldSubBook on ISNULL(oldSubBook.intSubBookId,0) = ISNULL(PreviousRow.intSubBookId,0)
			WHERE ISNULL(oldSubBook.intSubBookId,0) <> ISNULL(newSubBook.intSubBookId,0)
				AND CurrentRow.intContractDetailId = PreviousRow.intContractDetailId
		END     
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH
