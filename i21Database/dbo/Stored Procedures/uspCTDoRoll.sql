CREATE PROCEDURE [dbo].[uspCTDoRoll]
	@XML VARCHAR(max)
   ,@intUserId	 INT
AS
BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX),
			@idoc					INT

	DECLARE @OldEndDate				NVARCHAR(50),
			@NewEndDate				NVARCHAR(50),			
			@OldFutures				DECIMAL(12,4),
			@NewFutures				DECIMAL(12,4),
			@OldBasis				DECIMAL(12,4),
			@NewBasis				DECIMAL(12,4),
			@OldFutureMarketId		INT,
			@OldFutureMarket		NVARCHAR(50),
			@NewFutureMarketId		INT,
			@NewFutureMarket		NVARCHAR(50),
			@OldFutureMonthId		INT,
			@OldFuturesMonth		NVARCHAR(50),
			@NewFutureMonthId		INT,
			@NewFuturesMonth		NVARCHAR(50),
			@details				NVARCHAR(MAX)
			
			
   DECLARE  @ContractHeaderId		INT,			
			@ContractDetailId		INT,
			@ContractSeq			INT,
	        @Count					INT 
   
   DECLARE @OldtblCTContractDetail AS TABLE
   (
			intContractDetailId		INT,			
			dtmEndDate				DATETIME,
			dblFutures				DECIMAL(12,4),
			dblBasis				DECIMAL(12,4),
			intFutureMarketId		INT,
			FutureMarket			NVARCHAR(50),
			intFutureMonthId		INT,
			FuturesMonth			NVARCHAR(50)
   )
	                  
	EXEC sp_xml_preparedocument @idoc OUTPUT, @XML 
	
	IF OBJECT_ID('tempdb..#tblCTContractDetail') IS NOT NULL  				
		DROP TABLE #tblCTContractDetail				
	
	SELECT	*
	INTO	#tblCTContractDetail	
	FROM	OPENXML(@idoc, 'root/detail',2)
	WITH
	(
			intContractDetailId		INT,
			intConcurrencyId		INT,
			dtmEndDate				DATETIME,
			dblFutures				DECIMAL(12,4),
			dblBasis				DECIMAL(12,4),
			intFutureMonthId		INT,
			intFutureMarketId		INT
	)  
	
	INSERT INTO @OldtblCTContractDetail
	(
	   intContractDetailId	
	  ,dtmEndDate			
	  ,dblFutures			
	  ,dblBasis
	  ,intFutureMarketId
	  ,FutureMarket	
	  ,intFutureMonthId	
	  ,FuturesMonth		
	)
	SELECT  
	   intContractDetailId	= CD.intContractDetailId
	  ,dtmEndDate			= CD.dtmEndDate
	  ,dblFutures			= CD.dblFutures
	  ,dblBasis				= CD.dblBasis
	  ,intFutureMarketId	= CD.intFutureMarketId
	  ,FutureMarket			= Market.strFutMarketName
	  ,intFutureMonthId		= CD.intFutureMonthId
	  ,FuturesMonth			= FMonth.strFutureMonth
	  FROM	tblCTContractDetail		CD
	  JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId
	  JOIN  tblRKFutureMarket       Market ON Market.intFutureMarketId = CD.intFutureMarketId
	  JOIN  tblRKFuturesMonth		FMonth ON FMonth.intFutureMonthId  = CD.intFutureMonthId

	SELECT	@Count = COUNT(1) 
	FROM	tblCTContractDetail		CD
	JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId AND TD.intConcurrencyId = CD.intConcurrencyId
	
	IF	@Count <> (SELECT COUNT(1) FROM #tblCTContractDetail)
		RAISERROR('Some of the sequences are modified or deleted by other users.',16,1)
		
	UPDATE	CD
	SET		CD.intConcurrencyId		=	CD.intConcurrencyId + 1,	
			CD.dtmEndDate			=	TD.dtmEndDate,
			CD.dblFutures			=	CASE WHEN TD.dblFutures IS NULL THEN CD.dblFutures ELSE TD.dblFutures END,
			CD.dblBasis				=	CASE WHEN TD.dblBasis IS NULL THEN CD.dblBasis ELSE TD.dblBasis END,
			CD.dblOriginalBasis		=	CASE WHEN TD.dblBasis IS NULL THEN CD.dblBasis ELSE TD.dblBasis END,
			CD.intFutureMonthId		=	TD.intFutureMonthId,
			CD.dblCashPrice		    =	CASE WHEN CD.dblCashPrice IS NULL THEN CD.dblCashPrice ELSE ISNULL(TD.dblFutures,0) + ISNULL(TD.dblBasis,0) END,
			CD.dblTotalCost		    =	CASE WHEN CD.dblTotalCost IS NULL THEN CD.dblTotalCost ELSE (ISNULL(TD.dblFutures,0) + ISNULL(TD.dblBasis,0)) * ISNULL(CD.dblQuantity,0) END,
			CD.intFutureMarketId	=	CASE WHEN ISNULL(TD.intFutureMarketId,0) = 0 THEN CD.intFutureMarketId ELSE TD.intFutureMarketId END
				
	FROM	tblCTContractDetail		CD
	JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId

	-- UPDATE TOTAL COST
	UPDATE	CD
	SET		CD.dblTotalCost			= 	dbo.fnCalculateQtyBetweenUOM(CD.intItemUOMId, CD.intPriceItemUOMId, CD.dblQuantity) 
										* (CD.dblCashPrice / (CASE WHEN CU.ysnSubCurrency = 1 THEN CU.intCent ELSE 1 END))
	FROM	tblCTContractDetail		CD
	JOIN	#tblCTContractDetail	TD ON TD.intContractDetailId = CD.intContractDetailId
	LEFT    JOIN	tblSMCurrency	CU	ON	CU.intCurrencyID	 = CD.intCurrencyId
	
	--EXEC	uspCTCreateDetailHistory	NULL, @intDonorId

	  SELECT @ContractDetailId = MIN(intContractDetailId) FROM #tblCTContractDetail
	  
	  WHILE @ContractDetailId >0
	  BEGIN
			
			SET @ContractHeaderId   = NULL
			SET @ContractSeq        = NULL
			SET @details		    = NULL
			SET @OldEndDate			= NULL
			SET @NewEndDate			= NULL
			SET @OldFutures			= NULL
			SET @NewFutures			= NULL
			SET @OldBasis			= NULL
			SET @NewBasis			= NULL
			SET @OldFutureMarketId	= NULL
			SET @OldFutureMarket	= NULL
			SET @NewFutureMarketId  = NULL
			SET @NewFutureMarket	= NULL
			SET @OldFutureMonthId	= NULL
			SET @OldFuturesMonth	= NULL
			SET @NewFutureMonthId   = NULL
			SET @NewFuturesMonth	= NULL

			SELECT @ContractHeaderId = intContractHeaderId FROM tblCTContractDetail WHERE intContractDetailId = @ContractDetailId

			EXEC uspCTCreateDetailHistory	@intContractHeaderId = @ContractHeaderId, 
											@intContractDetailId = @ContractDetailId, 
											@strSource			 = 'Contract',
										    @strProcess		 	 = 'Do Roll',
											@intUserId			 = @intUserId

			SELECT @ContractSeq = intContractSeq FROM tblCTContractDetail WHERE intContractDetailId = @ContractDetailId 

			SELECT 
				    @OldEndDate			= dbo.fnRemoveTimeOnDate(Old.dtmEndDate)
				   ,@NewEndDate			= dbo.fnRemoveTimeOnDate(New.dtmEndDate)
				   ,@OldFutures			= ISNULL(Old.dblFutures,0)
				   ,@NewFutures			= ISNULL(New.dblFutures,0)
				   ,@OldBasis			= ISNULL(Old.dblBasis,0)
				   ,@NewBasis			= ISNULL(New.dblBasis,0)
				   ,@OldFutureMarketId	= Old.intFutureMarketId
				   ,@OldFutureMarket	= Old.FutureMarket
				   ,@NewFutureMarketId  = New.intFutureMarketId
				   ,@NewFutureMarket	= Market.strFutMarketName
				   ,@OldFutureMonthId	= Old.intFutureMonthId
				   ,@OldFuturesMonth	= Old.FuturesMonth
				   ,@NewFutureMonthId   = New.intFutureMonthId
				   ,@NewFuturesMonth	= FMonth.strFutureMonth
			
			FROM @OldtblCTContractDetail    Old
			JOIN tblCTContractDetail		New ON New.intContractDetailId = Old.intContractDetailId
			JOIN  tblRKFutureMarket         Market ON Market.intFutureMarketId = New.intFutureMarketId
			JOIN  tblRKFuturesMonth		    FMonth ON FMonth.intFutureMonthId  = New.intFutureMonthId
			WHERE Old.intContractDetailId = @ContractDetailId

				SET @details ='{  
								 "action":"Updated",
								 "change":"Updated - Record: '+LTRIM(@ContractHeaderId)+'",
								 "keyValue":'+LTRIM(@ContractHeaderId)+',
								 "iconCls":"small-tree-modified",
								 "children":[  
									 {  
											"change":"tblCTContractDetails",
											"change":"tblCTContractDetails",
											"children":[  
											 {  
												"action":"Updated",
												"change":"Updated - Record: Sequence - '+LTRIM(@ContractSeq)+' Roll Contract ",
												"keyValue":'+LTRIM(@ContractDetailId)+',
												"iconCls":"small-tree-modified",
												"children":
												 [   
													 '
												     IF @OldEndDate <> @NewEndDate
													 SET @details = @details+'
													 {  
												        "change":"dtmEndDate",
												        "from":"'+LTRIM(@OldEndDate)+'",
												        "to":"'+LTRIM(@NewEndDate)+'",
												        "leaf":true,
												        "iconCls":"small-gear",
												        "isField":true,
												        "keyValue":'+LTRIM(@ContractDetailId)+',
												        "associationKey":"tblCTContractDetails",
												        "changeDescription":"End Date"
												     },'

													 IF @OldFutures <> @NewFutures
													 SET @details = @details+'
													 {  
												      "change":"dblFutures",
												      "from":"'+LTRIM(@OldFutures)+'",
												      "to":"'+LTRIM(@NewFutures)+'",
												      "leaf":true,
												      "iconCls":"small-gear",
												      "isField":true,
												      "keyValue":'+LTRIM(@ContractDetailId)+',
												      "associationKey":"tblCTContractDetails",
												      "changeDescription":"Futures Price",
												      "hidden":false
												     },'
												   
												    IF @OldBasis <> @NewBasis
													SET @details = @details+'
												    
												     {  
												        "change":"dblBasis",
												        "from":'+LTRIM(@OldBasis)+',
												        "to":"'+LTRIM(@NewBasis)+'",
												        "leaf":true,
												        "iconCls":"small-gear",
												        "isField":true,
												        "keyValue":'+LTRIM(@ContractDetailId)+',
												        "associationKey":"tblCTContractDetails",
												        "changeDescription":"Basis",
												        "hidden":false
												     },'
													 
													 IF @OldFutureMarketId <> @NewFutureMarketId
													 SET @details = @details+'
													 {  
														"change":"intFutureMarketId",
														"from":"'+LTRIM(@OldFutureMarketId)+'",
														"to":"'+LTRIM(@NewFutureMarketId)+'",
														"leaf":true,
														"iconCls":"small-gear",
														"isField":true,
														"keyValue":'+LTRIM(@ContractDetailId)+',
														"associationKey":"tblCTContractDetails",
														"hidden":true
												     },					                                   
												     {  
												        "change":"strFutMarketName",
												        "from":"'+LTRIM(@OldFutureMarket)+'",
												        "to":"'+LTRIM(@NewFutureMarket)+'",
												        "leaf":true,
												        "iconCls":"small-gear",
												        "isField":true,
												        "keyValue":'+LTRIM(@ContractDetailId)+',
												        "associationKey":"tblCTContractDetails",
												        "changeDescription":"Future Market",
												        "hidden":false
												     },'
												   
												   IF @OldFutureMonthId <> @NewFutureMonthId
													  SET @details = @details
													+'
													{  
												      "change":"intFutureMonthId",
												      "from":"'+LTRIM(@OldFutureMonthId)+'",
												      "to":"'+LTRIM(@NewFutureMonthId)+'",
												      "leaf":true,
												      "iconCls":"small-gear",
												      "isField":true,
												      "keyValue":'+LTRIM(@ContractDetailId)+',
												      "associationKey":"tblCTContractDetails",
												      "hidden":true
												   },					                                   
												   {  
												      "change":"strFutureMonth",
												      "from":"'+LTRIM(@OldFuturesMonth)+'",
												      "to":"'+LTRIM(@NewFuturesMonth)+'",
												      "leaf":true,
												      "iconCls":"small-gear",
												      "isField":true,
												      "keyValue":'+LTRIM(@ContractDetailId)+',
												      "associationKey":"tblCTContractDetails",
												      "changeDescription":"Futures Month/Yr",
												      "hidden":false
												   }'
												  
												  IF RIGHT(@details,1) = ','
												  SET @details = SUBSTRING(@details,0,LEN(@details))

												  SET @details = @details +'
												]
										  }
									   ],
										"iconCls":"small-tree-grid",
										"changeDescription":"Details"
									  }
									]
								 }'

			 EXEC
			 [uspSMAuditLog]
			 @screenName         = 'ContractManagement.view.Contract'			
			,@keyValue           =  @ContractHeaderId			
			,@entityId	         =  @intUserId		
			,@actionType	     = 'Updated' 		
			,@actionIcon	     = 'small-tree-modified'		
			,@changeDescription  = ''  
			,@fromValue			 = ''			
			,@toValue			 = ''			
			,@details			 = @details

			SELECT @ContractDetailId = MIN(intContractDetailId) FROM #tblCTContractDetail  WHERE intContractDetailId > @ContractDetailId
	  END

END TRY      

BEGIN CATCH       

	SET @ErrMsg = ERROR_MESSAGE()      
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      

END CATCH
