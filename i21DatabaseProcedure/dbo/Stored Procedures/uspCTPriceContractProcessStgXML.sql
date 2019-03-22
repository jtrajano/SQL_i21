CREATE PROCEDURE [dbo].[uspCTPriceContractProcessStgXML]	
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg										NVARCHAR(MAX)
	DECLARE @intPriceContractStageId					INT
	DECLARE @intPriceContractId							INT
	DECLARE @strPriceContractNo							NVARCHAR(MAX)
	DECLARE @strNewPriceContractNo						NVARCHAR(MAX)	
	DECLARE @strPriceContractXML						NVARCHAR(MAX)
	DECLARE @strPriceFixationXML						NVARCHAR(MAX)
	DECLARE @strPriceFixationDetailXML					NVARCHAR(MAX)
	DECLARE @strReference								NVARCHAR(MAX)
	DECLARE @strRowState								NVARCHAR(MAX)
	DECLARE @strFeedStatus								NVARCHAR(MAX)
	DECLARE @dtmFeedDate								DATETIME
	DECLARE @strMessage									NVARCHAR(MAX)
	DECLARE @intMultiCompanyId							INT	
	DECLARE @intEntityId								INT
	DECLARE @strTransactionType							NVARCHAR(MAX)
	DECLARE @strTagRelaceXML							NVARCHAR(MAX)
	DECLARE @NewPriceContractId							INT
	DECLARE @NewPriceFixationId							INT
	DECLARE @NewPriceFixationDetailId					INT	
	DECLARE @intPriceContractAcknowledgementStageId     INT
	DECLARE @strPriceContractCondition					NVARCHAR(MAX)
	DECLARE @strPriceFixationCondition					NVARCHAR(MAX)
	DECLARE @strPriceFixationAllId						NVARCHAR(MAX)
	DECLARE @strAckPriceContractXML						NVARCHAR(MAX)
	DECLARE @strAckPriceFixationXML						NVARCHAR(MAX)
	DECLARE @strAckPriceFixationDetailXML				NVARCHAR(MAX)
	DECLARE @strHedgeXML								NVARCHAR(MAX)
	DECLARE @TempPriceFixationId						INT
	DECLARE @intPriceFixationId							INT	
	DECLARE @intContractHeaderId						INT
	DECLARE @intContractDetailId						INT
	DECLARE @intPriceFixationRefId						INT
	DECLARE @idoc										INT 
	DECLARE @intNumber                                   INT

	DECLARE @tblCTPriceFixation AS TABLE
	(
		[TempPriceFixationId]	    INT IDENTITY(1,1),
		[intPriceFixationId]		INT,
		[intPriceContractId]		INT,
		[intConcurrencyId]		    INT,
		[intContractHeaderId]	    INT, 
		[intContractDetailId]	    INT,
		[intOriginalFutureMarketId] INT,
		[intOriginalFutureMonthId]  INT,
		[dblOriginalBasis]			NUMERIC(18,6),
		[dblTotalLots]				NUMERIC(18,6),
		[dblLotsFixed]				NUMERIC(18,6),
		[intLotsHedged]				INT,
		[dblPolResult]				NUMERIC(18,6),
		[dblPremiumPoints]			NUMERIC(18,6),
		[ysnAAPrice]				BIT,
		[ysnSettlementPrice]		BIT,
		[ysnToBeAgreed]				BIT,
		[dblSettlementPrice]		NUMERIC(18,6),
		[dblAgreedAmount]			NUMERIC(18,6),
		[intAgreedItemUOMId]		INT,
		[dblPolPct]					NUMERIC(18,6),
		[dblPriceWORollArb]			NUMERIC(18,6),
		[dblRollArb]				NUMERIC(18,6),
		[dblPolSummary]				NUMERIC(18,6),
		[dblAdditionalCost]			NUMERIC(18,6),
		[dblFinalPrice]				NUMERIC(18,6),
		[intFinalPriceUOMId]		INT,
		[ysnSplit]					BIT,
		[intPriceFixationRefId]		INT
	)

	SELECT @intPriceContractStageId = MIN(intPriceContractStageId)
	FROM tblCTPriceContractStage WHERE ISNULL(strFeedStatus,'')=''

	WHILE @intPriceContractStageId > 0
	BEGIN
			
			SET @intPriceContractId			= NULL
			SET @strPriceContractNo			= NULL
			SET @strPriceContractXML		= NULL
			SET @strPriceFixationXML		= NULL
			SET @strPriceFixationDetailXML	= NULL			
			SET @strReference				= NULL
			SET @strRowState				= NULL
			SET @strFeedStatus				= NULL
			SET @dtmFeedDate				= NULL
			SET @strMessage					= NULL
			SET @intMultiCompanyId			= NULL			
			SET @intEntityId				= NULL
			SET @strTransactionType			= NULL

			 SELECT
			  @intPriceContractId			= intPriceContractId		
			 ,@strPriceContractNo			= strPriceContractNo		
			 ,@strPriceContractXML			= strPriceContractXML		
			 ,@strPriceFixationXML			= strPriceFixationXML		
			 ,@strPriceFixationDetailXML	= strPriceFixationDetailXML
			 ,@strReference					= strReference			
			 ,@strRowState					= strRowState			
			 ,@strFeedStatus				= strFeedStatus			
			 ,@dtmFeedDate					= dtmFeedDate			
			 ,@strMessage					= strMessage			
			 ,@intMultiCompanyId			= intMultiCompanyId
			 ,@intEntityId					= intEntityId			
			 ,@strTransactionType			= strTransactionType
			 FROM tblCTPriceContractStage
			 WHERE intPriceContractStageId = @intPriceContractStageId
			 
			
			 IF @strTransactionType ='Sales Price Fixation'
			 BEGIN
					
					-------------------------PriceContract-----------------------------------------------------------
					EXEC uspCTGetStartingNumber 'Price Contract',@strNewPriceContractNo OUTPUT
					
					SET @strPriceContractXML= REPLACE(@strPriceContractXML,@strPriceContractNo,@strNewPriceContractNo)
					SET @strPriceContractXML= REPLACE(@strPriceContractXML,'intCompanyId>', 'CompanyId>')

					EXEC uspCTInsertINTOTableFromXML 'tblCTPriceContract',@strPriceContractXML,@NewPriceContractId OUTPUT
					
					

					UPDATE tblCTPriceContract 
					SET    strPriceContractNo    = @strNewPriceContractNo
						  ,intPriceContractRefId = @intPriceContractId
					WHERE  intPriceContractId    = @NewPriceContractId

						INSERT INTO tblCTPriceContractAcknowledgementStage 
						(
								 intAckPriceContractId
								,strAckPriceContracNo
								,dtmFeedDate
								,strMessage
								,strTransactionType
								,intMultiCompanyId
						)
						SELECT 
							 @NewPriceContractId
							,@strNewPriceContractNo
							,GETDATE()
							,'Success'
							,@strTransactionType
							,@intMultiCompanyId

						SELECT @intPriceContractAcknowledgementStageId = SCOPE_IDENTITY();

					---------------------------------------------PriceFixation------------------------------------------					
					 
					EXEC sp_xml_preparedocument @idoc OUTPUT, @strPriceFixationXML	
					
					INSERT INTO @tblCTPriceFixation
					(
						 [intPriceFixationId]
						,[intPriceContractId]		    
						,[intConcurrencyId]		    
						,[intContractHeaderId]	    
						,[intContractDetailId]	    
						,[intOriginalFutureMarketId] 
						,[intOriginalFutureMonthId]  
						,[dblOriginalBasis]			
						,[dblTotalLots]				
						,[dblLotsFixed]				
						,[intLotsHedged]				
						,[dblPolResult]				
						,[dblPremiumPoints]			
						,[ysnAAPrice]				
						,[ysnSettlementPrice]		
						,[ysnToBeAgreed]				
						,[dblSettlementPrice]		
						,[dblAgreedAmount]			
						,[intAgreedItemUOMId]		
						,[dblPolPct]					
						,[dblPriceWORollArb]			
						,[dblRollArb]				
						,[dblPolSummary]				
						,[dblAdditionalCost]			
						,[dblFinalPrice]				
						,[intFinalPriceUOMId]		
						,[ysnSplit]					
						,[intPriceFixationRefId]		
					)	
					
					SELECT 
					 [intPriceFixationId]					
					,[intPriceContractId]		    
					,[intConcurrencyId]		    
					,[intContractHeaderId]	    
					,[intContractDetailId]	    
					,[intOriginalFutureMarketId] 
					,[intOriginalFutureMonthId]  
					,[dblOriginalBasis]			
					,[dblTotalLots]				
					,[dblLotsFixed]				
					,[intLotsHedged]				
					,[dblPolResult]				
					,[dblPremiumPoints]			
					,[ysnAAPrice]				
					,[ysnSettlementPrice]		
					,[ysnToBeAgreed]				
					,[dblSettlementPrice]		
					,[dblAgreedAmount]			
					,[intAgreedItemUOMId]		
					,[dblPolPct]					
					,[dblPriceWORollArb]			
					,[dblRollArb]				
					,[dblPolSummary]				
					,[dblAdditionalCost]			
					,[dblFinalPrice]				
					,[intFinalPriceUOMId]		
					,[ysnSplit]					
					,[intPriceFixationRefId]
					FROM OPENXML(@idoc, 'tblCTPriceFixations/tblCTPriceFixation', 2) WITH 
					(
						[intPriceFixationId]		INT				,
						[intPriceContractId]		INT				,
						[intConcurrencyId]		    INT				,
						[intContractHeaderId]	    INT  			,
						[intContractDetailId]	    INT 			,
						[intOriginalFutureMarketId] INT 			,
						[intOriginalFutureMonthId]  INT 			,
						[dblOriginalBasis]			NUMERIC(18,6)	,
						[dblTotalLots]				NUMERIC(18,6)	,
						[dblLotsFixed]				NUMERIC(18,6)	,
						[intLotsHedged]				INT				,
						[dblPolResult]				NUMERIC(18,6)	,
						[dblPremiumPoints]			NUMERIC(18,6)	,
						[ysnAAPrice]				BIT				,
						[ysnSettlementPrice]		BIT				,
						[ysnToBeAgreed]				BIT				,
						[dblSettlementPrice]		NUMERIC(18,6)	,
						[dblAgreedAmount]			NUMERIC(18,6)	,
						[intAgreedItemUOMId]		INT				,
						[dblPolPct]					NUMERIC(18,6)	,
						[dblPriceWORollArb]			NUMERIC(18,6)	,
						[dblRollArb]				NUMERIC(18,6)	,
						[dblPolSummary]				NUMERIC(18,6)	,
						[dblAdditionalCost]			NUMERIC(18,6)	,
						[dblFinalPrice]				NUMERIC(18,6)	,
						[intFinalPriceUOMId]		INT 			,
						[ysnSplit]					BIT				,
						[intPriceFixationRefId]		INT
					)	

						SELECT @TempPriceFixationId = MIN(TempPriceFixationId)
						FROM @tblCTPriceFixation

						WHILE @TempPriceFixationId > 0
						BEGIN
								SET @intPriceFixationId    = NULL
								SET @NewPriceFixationId    = NULL
								SET @intContractHeaderId   = NULL
								SET @intContractDetailId   = NULL
								SET @intPriceFixationRefId = NULL

								SELECT 
								 @intPriceFixationId    = intPriceFixationId   
								,@intContractHeaderId   = intContractHeaderId  
								,@intContractDetailId   = intContractDetailId  
								,@intPriceFixationRefId = intPriceFixationRefId
								FROM @tblCTPriceFixation 
								WHERE TempPriceFixationId = @TempPriceFixationId
								
							
								UPDATE tbl
								SET  tbl.intContractHeaderId = CH.intContractHeaderId
								    ,tbl.intContractDetailId = CD.intContractDetailId
									,tbl.intPriceContractId  = @NewPriceContractId
								FROM @tblCTPriceFixation tbl
								JOIN tblCTContractHeader CH ON CH.intContractHeaderRefId = tbl.intContractHeaderId
								JOIN tblCTContractDetail CD ON CD.intContractDetailRefId = tbl.intContractDetailId
								

								INSERT INTO tblCTPriceFixation
								(
									 [intPriceContractId]		 
									,[intConcurrencyId]		    
									,[intContractHeaderId]	    
									,[intContractDetailId]	    
									,[intOriginalFutureMarketId] 
									,[intOriginalFutureMonthId]  
									,[dblOriginalBasis]			
									,[dblTotalLots]				
									,[dblLotsFixed]				
									,[intLotsHedged]			
									,[dblPolResult]				
									,[dblPremiumPoints]			
									,[ysnAAPrice]				
									,[ysnSettlementPrice]		
									,[ysnToBeAgreed]			
									,[dblSettlementPrice]		
									,[dblAgreedAmount]			
									,[intAgreedItemUOMId]		
									,[dblPolPct]				
									,[dblPriceWORollArb]		
									,[dblRollArb]				
									,[dblPolSummary]			
									,[dblAdditionalCost]		
									,[dblFinalPrice]			
									,[intFinalPriceUOMId]		
									,[ysnSplit]					
									,[intPriceFixationRefId]
								)
								SELECT
									 [intPriceContractId]		 
									,[intConcurrencyId]		    
									,[intContractHeaderId]	    
									,[intContractDetailId]	    
									,[intOriginalFutureMarketId] 
									,[intOriginalFutureMonthId]  
									,[dblOriginalBasis]			
									,[dblTotalLots]				
									,[dblLotsFixed]				
									,[intLotsHedged]			
									,[dblPolResult]				
									,[dblPremiumPoints]			
									,[ysnAAPrice]				
									,[ysnSettlementPrice]		
									,[ysnToBeAgreed]			
									,[dblSettlementPrice]		
									,[dblAgreedAmount]			
									,[intAgreedItemUOMId]		
									,[dblPolPct]				
									,[dblPriceWORollArb]		
									,[dblRollArb]				
									,[dblPolSummary]			
									,[dblAdditionalCost]		
									,[dblFinalPrice]			
									,[intFinalPriceUOMId]		
									,[ysnSplit]					
									,[intPriceFixationRefId]
									FROM @tblCTPriceFixation 
									WHERE TempPriceFixationId = @TempPriceFixationId
								  
								  SET @NewPriceFixationId = SCOPE_IDENTITY();

								  UPDATE tblCTPriceFixation 
								  SET intPriceFixationRefId = @intPriceFixationId 
								  WHERE intPriceFixationId  = @NewPriceFixationId

							SELECT @TempPriceFixationId = MIN(TempPriceFixationId)
							FROM @tblCTPriceFixation WHERE TempPriceFixationId > @TempPriceFixationId
						END
					---------------------------------------------PriceFixationDetail-----------------------------------------------

					DECLARE @tblPriceFixation AS TABLE
					(
						intRowNo INT IDENTITY,
						PriceFixationId INT,
						TradeNo  NVARCHAR(20) 
					)
					
					EXEC sp_xml_preparedocument @idoc OUTPUT, @strPriceFixationDetailXML
					
					INSERT INTO @tblPriceFixation(PriceFixationId,TradeNo)
					SELECT DISTINCT intPriceFixationId,strTradeNo 
					FROM OPENXML(@idoc, 'tblCTPriceFixationDetails/tblCTPriceFixationDetail', 2) WITH 
						(
								 intPriceFixationId INT
								,strTradeNo NVARCHAR(20) 
						 )
					
					
					DECLARE @strFixationDetailXml NVARCHAR(max)=''
					
					SELECT @strFixationDetailXml = @strFixationDetailXml 
												+ '<tags>' +
															'<toFind>&lt;intPriceFixationId&gt;'   +LTRIM(t1.PriceFixationId)+'&lt;/intPriceFixationId&gt;</toFind>' + 
															'<toReplace>&lt;intPriceFixationId&gt;'+LTRIM(t1.intPriceFixationId)+'&lt;/intPriceFixationId&gt;</toReplace>'
												+ '</tags>'
												+ '<tags>' +
															'<toFind>&lt;strTradeNo&gt;'   +LTRIM(t1.TradeNo)+'&lt;/strTradeNo&gt;</toFind>' + 
															'<toReplace>&lt;strTradeNo&gt;'+LTRIM(SN.strPrefix)+LTRIM(SN.intNumber + t1.intRowNo)+'&lt;/strTradeNo&gt;</toReplace>'
												+ '</tags>'
					FROM  (
							 SELECT t.intRowNo
							 ,t.intPriceFixationId
							 ,td.PriceFixationId 
							 ,td.TradeNo
							 From
							 (
							 	SELECT ROW_NUMBER() OVER(ORDER BY intPriceFixationId) intRowNo , * FROM tblCTPriceFixation cd WHERE cd.intPriceContractId = @NewPriceContractId
							 ) t 
							 JOIN @tblPriceFixation td on t.intRowNo=td.intRowNo 
					     ) t1
                    JOIN  tblSMStartingNumber SN ON 1 =1  
					WHERE SN.strTransactionType = N'Price Fixation Trade No'

					SELECT @intNumber = COUNT(1) FROM @tblPriceFixation
					UPDATE tblSMStartingNumber SET intNumber = intNumber + @intNumber + 1 
					WHERE strTransactionType = N'Price Fixation Trade No'
					
					Set @strFixationDetailXml = '<root>' + @strFixationDetailXml + '</root>'
					
					SET @strPriceFixationDetailXML = REPLACE(@strPriceFixationDetailXML,'intPriceFixationDetailId','intPriceFixationDetailRefId')	

					EXEC uspCTInsertINTOTableFromXML 'tblCTPriceFixationDetail',@strPriceFixationDetailXML,@NewPriceFixationDetailId OUTPUT,@strFixationDetailXml

					----------------------------------Hedge----------------------------------									
						EXEC uspCTSavePriceContract @NewPriceContractId,@strHedgeXML
					
					
					-----------------------------Acknowledgement-------------------------

					-------------------------PriceContract-----------------------------------------------------------
						SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@NewPriceContractId)
						
						EXEC uspCTGetTableDataInXML 'tblCTPriceContract',@strPriceContractCondition,@strAckPriceContractXML  OUTPUT

						UPDATE  tblCTPriceContractAcknowledgementStage 
						SET		strAckPriceContractXML = @strAckPriceContractXML 
						WHERE   intPriceContractAcknowledgementStageId =@intPriceContractAcknowledgementStageId

						---------------------------------------------PriceFixation------------------------------------------
						SELECT @strPriceContractCondition = 'intPriceContractId = ' + LTRIM(@NewPriceContractId)
						
						EXEC uspCTGetTableDataInXML 'tblCTPriceFixation',@strPriceContractCondition,@strAckPriceFixationXML  OUTPUT

						UPDATE  tblCTPriceContractAcknowledgementStage 
						SET		strAckPriceFixationXML =@strAckPriceFixationXML 
						WHERE   intPriceContractAcknowledgementStageId =@intPriceContractAcknowledgementStageId

						---------------------------------------------PriceFixationDetail-----------------------------------------------


					SELECT @strPriceFixationAllId = STUFF((
													SELECT DISTINCT ',' + LTRIM(intPriceFixationId)
													FROM tblCTPriceFixation
													WHERE intPriceContractId = @NewPriceContractId
													FOR XML PATH('')
													), 1, 1, '')

					SELECT @strPriceFixationCondition = 'intPriceFixationId IN ('+ LTRIM(@strPriceFixationAllId)+')'

					EXEC uspCTGetTableDataInXML 'tblCTPriceFixationDetail',@strPriceFixationCondition,@strAckPriceFixationDetailXML  OUTPUT

					SELECT @strPriceFixationCondition = 'intPriceFixationId IN ('+ LTRIM(@strPriceFixationAllId)+')'

					EXEC [dbo].[uspCTGetTableDataInXML] 
						'tblCTPriceFixationDetail'
						,@strPriceFixationCondition
						,@strPriceFixationDetailXML OUTPUT
						,NULL
						,NULL

						UPDATE  tblCTPriceContractAcknowledgementStage 
						SET		strAckPriceFixationDetailXML = @strAckPriceFixationDetailXML 
						WHERE   intPriceContractAcknowledgementStageId = @intPriceContractAcknowledgementStageId

				-----------------------------------------------------------------------------------------------------------------------------------------------------
			 END
		
		UPDATE tblCTPriceContractStage SET strFeedStatus = 'Processed' WHERE intPriceContractStageId = @intPriceContractStageId

		SELECT @intPriceContractStageId = MIN(intPriceContractStageId)
		FROM tblCTPriceContractStage
		WHERE intPriceContractStageId > @intPriceContractStageId AND ISNULL(strFeedStatus,'')=''

	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
