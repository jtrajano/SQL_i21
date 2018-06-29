
CREATE PROCEDURE uspRKInterCompanyDerivativeEntryProcessStgXML
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @intDerivativeEntryStageId INT,
		@intFutOptTransactionHeaderId INT,
		@intContractHeaderId INT,
		@strHeaderXML NVARCHAR(MAX),
		@strDetailXML NVARCHAR(MAX),
		@strTransactionType NVARCHAR(20),
		@intMultiCompanyId INT,
		@intCompanyLocationId INT,
		@intHedgedLots INT,
		@dtmTransactionDate DATETIME

DECLARE @NewHeaderId INT,
		@NewDetailId INT,
		@strTagReplaceXML NVARCHAR(MAX),
		@strInternalTradeNo NVARCHAR(20),
		@strNewInternalTradeNo NVARCHAR(20)

DECLARE @intDerivativeEntryAcknowledgementStageId INT,
		@strHeaderCondition		NVARCHAR(MAX),
		@strAckHeaderXML	NVARCHAR(MAX),
		@strAckDetailXML	NVARCHAR(MAX)


SELECT @intDerivativeEntryStageId = MIN(intDerivativeEntryStageId)
FROM tblRKInterCompanyDerivativeEntryStage
WHERE strFeedStatus IS NULL

	WHILE @intDerivativeEntryStageId > 0
	BEGIN
		
		SELECT
			 @intFutOptTransactionHeaderId	= intFutOptTransactionHeaderId
			,@intContractHeaderId			= intContractHeaderId
			,@strHeaderXML					= strHeaderXML
			,@strDetailXML					= strDetailXML
			,@strTransactionType			= strTransactionType
			,@intMultiCompanyId				= intMultiCompanyId
			,@intCompanyLocationId			= intCompanyLocationId
			,@strInternalTradeNo			= strInternalTradeNo
			,@intHedgedLots					= intHedgedLots
		FROM tblRKInterCompanyDerivativeEntryStage
		WHERE intDerivativeEntryStageId = @intDerivativeEntryStageId

		SET @dtmTransactionDate = GETDATE()

			--===============
			-- HEADER
			--===============
			SET @strHeaderXML = REPLACE(@strHeaderXML, 'intCompanyId>', 'CompanyId>')

			EXEC uspCTInsertINTOTableFromXML 'tblRKFutOptTransactionHeader',@strHeaderXML,@NewHeaderId OUTPUT

			UPDATE tblRKFutOptTransactionHeader
				SET dtmTransactionDate = @dtmTransactionDate
					,intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderId
			WHERE intFutOptTransactionHeaderId = @NewHeaderId

					INSERT INTO tblRKInterCompanyDerivativeEntryAcknowledgementStage 
					(
						 intFutOptTransactionHeaderId
						,dtmFeedDate
						,strMessage
						,strTransactionType
						,intMultiCompanyId
					)
					SELECT 
						 @NewHeaderId
						,GETDATE()
						,'Success'
						,@strTransactionType
						,@intMultiCompanyId

					SELECT @intDerivativeEntryAcknowledgementStageId = SCOPE_IDENTITY();

					SELECT @strHeaderCondition = 'intFutOptTransactionHeaderId = ' + LTRIM(@NewHeaderId)
						
					EXEC uspCTGetTableDataInXML 'tblRKFutOptTransactionHeader',@strHeaderCondition,@strAckHeaderXML  OUTPUT

					UPDATE  tblRKInterCompanyDerivativeEntryAcknowledgementStage 
					SET		strAckHeaderXML = @strAckHeaderXML 
					WHERE   intDerivativeEntryAcknowledgementStageId = @intDerivativeEntryAcknowledgementStageId
					
			--===============
			-- DETAIL
			--===============

			SET @strTagReplaceXML =  '<root>
																	<tags>
																		<toFind>&lt;intFutOptTransactionHeaderId&gt;'+LTRIM(@intFutOptTransactionHeaderId)+'&lt;/intFutOptTransactionHeaderId&gt;</toFind>
																		<toReplace>&lt;intFutOptTransactionHeaderId&gt;'+LTRIM(@NewHeaderId)+'&lt;/intFutOptTransactionHeaderId&gt;</toReplace>
																	</tags>
																</root>'

			SET @strDetailXML = REPLACE(@strDetailXML,'intFutOptTransactionId','intFutOptTransactionRefId')

			
			EXEC uspCTGetStartingNumber 'FutOpt Transaction',@strNewInternalTradeNo OUTPUT

			SET @strNewInternalTradeNo = @strNewInternalTradeNo + '-H'
			SET @strDetailXML = REPLACE(@strDetailXML,@strInternalTradeNo,@strNewInternalTradeNo)

			EXEC uspCTInsertINTOTableFromXML 'tblRKFutOptTransaction',@strDetailXML,@NewDetailId OUTPUT,@strTagReplaceXML
			
			UPDATE tblRKFutOptTransaction 
				SET strBuySell = CASE WHEN @strTransactionType = 'BUY' THEN 'Sell' ELSE 'Buy' END
					,dtmTransactionDate = @dtmTransactionDate
					,intLocationId = @intCompanyLocationId
			WHERE intFutOptTransactionId = @NewDetailId


						
				EXEC uspCTGetTableDataInXML 'tblRKFutOptTransaction',@strHeaderCondition,@strAckDetailXML  OUTPUT

				UPDATE  tblRKInterCompanyDerivativeEntryAcknowledgementStage 
				SET		strAckDetailXML = @strAckDetailXML 
				WHERE   intDerivativeEntryAcknowledgementStageId = @intDerivativeEntryAcknowledgementStageId
	
		--======================
		-- ASSIGN DERIVATIVE
		--======================
		DECLARE @intAssignFuturesToContractHeaderId INT,
				@intRefContractHeaderId INT,
				@intRefContractDetailId INT
		 --Get the reference contract
		 
		SELECT 
			@intRefContractHeaderId = H.intContractHeaderId, 
			@intRefContractDetailId = D.intContractDetailId 
		FROM tblCTContractHeader H 
			INNER JOIN tblCTContractDetail D ON H.intContractHeaderId = D.intContractHeaderId
		WHERE intContractHeaderRefId = @intContractHeaderId

		 ---------------Header Record Insert ----------------    
		 INSERT INTO tblRKAssignFuturesToContractSummaryHeader     
		  (intConcurrencyId)    
		 VALUES(1)    
    
		SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();      
		---------------Matched Record Insert ----------------    
		   INSERT INTO tblRKAssignFuturesToContractSummary    
		  (     
 			intAssignFuturesToContractHeaderId,
			intConcurrencyId,
			intContractHeaderId,
			intContractDetailId,
			dtmMatchDate,
			intFutOptTransactionId,
			dblAssignedLots,
			intHedgedLots,
			ysnIsHedged  
		  ) 
		  VALUES(
			@intAssignFuturesToContractHeaderId,
			1,
			@intRefContractHeaderId,
			@intRefContractDetailId,
			GETDATE(),
			@NewDetailId,
			0,
			@intHedgedLots,
			1
		  )  

		  UPDATE tblRKInterCompanyDerivativeEntryStage
		  SET strFeedStatus = 'Processed'
		  WHERE intDerivativeEntryStageId = @intDerivativeEntryStageId

		SELECT @intDerivativeEntryStageId = MIN(intDerivativeEntryStageId)
		FROM tblRKInterCompanyDerivativeEntryStage
		WHERE intDerivativeEntryStageId > @intDerivativeEntryStageId 
			AND strFeedStatus IS NULL
	END

IF @@ERROR <> 0	GOTO _Rollback

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
_Commit:
	COMMIT TRANSACTION
	GOTO _Exit
	
_Rollback:
	ROLLBACK TRANSACTION

_Exit: