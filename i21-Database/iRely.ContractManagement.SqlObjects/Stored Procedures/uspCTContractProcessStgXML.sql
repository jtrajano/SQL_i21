CREATE PROCEDURE [dbo].[uspCTContractProcessStgXML]
	--@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE @intContractStageId		INT
	DECLARE @intContractHeaderId	INT
	DECLARE @strCustomerContract	NVARCHAR(MAX)
	DECLARE @strContractNumber		NVARCHAR(MAX)
	DECLARE @strNewContractNumber	NVARCHAR(MAX)
	DECLARE @strHeaderXML			NVARCHAR(MAX)
	DECLARE @strDetailXML			NVARCHAR(MAX)
	DECLARE @strCostXML				NVARCHAR(MAX)
	DECLARE @strDocumentXML			NVARCHAR(MAX)
	DECLARE @strReference			NVARCHAR(MAX)
	DECLARE @strRowState			NVARCHAR(MAX)
	DECLARE @strFeedStatus			NVARCHAR(MAX)
	DECLARE @dtmFeedDate			DATETIME
	DECLARE @strMessage				NVARCHAR(MAX)
	DECLARE @intMultiCompanyId		INT
	DECLARE @intEntityId			INT
	DECLARE @intCompanyLocationId	INT
	DECLARE @strTransactionType		NVARCHAR(MAX)
	DECLARE @strTagRelaceXML		NVARCHAR(MAX)

	DECLARE @NewContractHeaderId	INT
	DECLARE @NewContractDetailId	INT
	DECLARE @NewContractCostId      INT
	
	DECLARE @intContractAcknowledgementStageId       INT
	DECLARE @strHeaderCondition		NVARCHAR(MAX)
	DECLARE @strCostCondition		NVARCHAR(MAX)
	DECLARE @strContractDetailAllId NVARCHAR(MAX)
	DECLARE @strAckHeaderXML		NVARCHAR(MAX)
	DECLARE @strAckDetailXML		NVARCHAR(MAX)
	DECLARE @strAckCostXML			NVARCHAR(MAX)
	DECLARE @strAckDocumentXML		NVARCHAR(MAX)
		
	

	SELECT @intContractStageId = MIN(intContractStageId)
	FROM tblCTContractStage 
	WHERE ISNULL(strFeedStatus,'')='' AND strRowState ='Added'
	

	
	WHILE @intContractStageId > 0
	BEGIN
			
			SET @intContractHeaderId	= NULL
			SET @strContractNumber		= NULL
			SET @strHeaderXML			= NULL
			SET @strDetailXML			= NULL
			SET @strCostXML				= NULL
			SET @strDocumentXML			= NULL
			SET @strReference			= NULL
			SET @strRowState			= NULL
			SET @strFeedStatus			= NULL
			SET @dtmFeedDate			= NULL
			SET @strMessage				= NULL
			SET @intMultiCompanyId		= NULL
			
			SET @intEntityId			= NULL
			SET @intCompanyLocationId	= NULL
			SET @strTransactionType		= NULL

			 SELECT
			  @intContractHeaderId	= intContractHeaderId	
			 ,@strContractNumber	= strContractNumber
			 ,@strCustomerContract	= strContractNumber		
			 ,@strHeaderXML			= strHeaderXML		
			 ,@strDetailXML			= strDetailXML		
			 ,@strCostXML			= strCostXML
			 ,@strDocumentXML		= strDocumentXML		
			 ,@strReference			= strReference			
			 ,@strRowState			= strRowState			
			 ,@strFeedStatus		= strFeedStatus			
			 ,@dtmFeedDate			= dtmFeedDate			
			 ,@strMessage			= strMessage			
			 ,@intMultiCompanyId	= intMultiCompanyId		
			 		
			 ,@intEntityId			= intEntityId
			 ,@intCompanyLocationId = intCompanyLocationId			
			 ,@strTransactionType	= strTransactionType
			 FROM tblCTContractStage
			 WHERE intContractStageId = @intContractStageId
			 
			
			 IF @strTransactionType ='Sales Contract'
			 BEGIN
					
					------------------Header------------------------------------------------------
					EXEC uspCTGetStartingNumber 'SaleContract',@strNewContractNumber OUTPUT
					
					SET @strHeaderXML = REPLACE(@strHeaderXML,@strContractNumber,@strNewContractNumber)
					SET @strHeaderXML = REPLACE(@strHeaderXML, 'intCompanyId>', 'CompanyId>')

					EXEC uspCTInsertINTOTableFromXML 'tblCTContractHeader',@strHeaderXML,@NewContractHeaderId OUTPUT

					UPDATE tblCTContractHeader 
					SET  intContractTypeId      = 2
					    ,intEntityId            = @intEntityId
						,intContractHeaderRefId = @intContractHeaderId
						,strCustomerContract	= @strCustomerContract
					WHERE intContractHeaderId   = @NewContractHeaderId

						INSERT INTO tblCTContractAcknowledgementStage 
						(
								 intContractHeaderId
								,strContractAckNumber
								,dtmFeedDate
								,strMessage
								,strTransactionType
								,intMultiCompanyId
						)
						SELECT 
							 @NewContractHeaderId
							,@strNewContractNumber
							,GETDATE()
							,'Success'
							,@strTransactionType
							,@intMultiCompanyId

						SELECT @intContractAcknowledgementStageId = SCOPE_IDENTITY();

						SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)
						
						EXEC uspCTGetTableDataInXML 'tblCTContractHeader',@strHeaderCondition,@strAckHeaderXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckHeaderXML =@strAckHeaderXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId
					-----------------------------------Detail-------------------------------------------
					SET @strTagRelaceXML = NULL
					SET @strTagRelaceXML =  '<root>
																	<tags>
																		<toFind>&lt;intContractHeaderId&gt;'+LTRIM(@intContractHeaderId)+'&lt;/intContractHeaderId&gt;</toFind>
																		<toReplace>&lt;intContractHeaderId&gt;'+LTRIM(@NewContractHeaderId)+'&lt;/intContractHeaderId&gt;</toReplace>
																	</tags>
																</root>'
					
					SET @strDetailXML = REPLACE(@strDetailXML,'intContractDetailId','intContractDetailRefId')
					
					EXEC uspCTInsertINTOTableFromXML 'tblCTContractDetail',@strDetailXML,@NewContractDetailId OUTPUT,	@strTagRelaceXML

						UPDATE tblCTContractDetail 
						SET intCompanyLocationId	 = @intCompanyLocationId
						WHERE  intContractHeaderId   = @NewContractHeaderId
					
						SELECT @strHeaderCondition = 'intContractHeaderId = ' + LTRIM(@NewContractHeaderId)
						
						EXEC uspCTGetTableDataInXML 'tblCTContractDetail',@strHeaderCondition,@strAckDetailXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckDetailXML =@strAckDetailXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId

					-----------------------------------------Cost-------------------------------------------
					DECLARE @idoc INT
					DECLARE @tblDetailId AS TABLE
					(
					intRowNo INT IDENTITY,
					intDetailId INT
					)
					
					EXEC sp_xml_preparedocument @idoc OUTPUT, @strCostXML
					
					INSERT INTO @tblDetailId(intDetailId)
					SELECT DISTINCT intContractDetailId 
					FROM OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost', 2) WITH 
						(
								intContractDetailId INT
						 )
					
					
					DECLARE @strCostReplaceXml NVARCHAR(max)=''
					
					SELECT @strCostReplaceXml = @strCostReplaceXml +  '<tags>' +
					'<toFind>&lt;intContractDetailId&gt;'+LTRIM(t1.intDetailId)+'&lt;/intContractDetailId&gt;</toFind>' + 
					'<toReplace>&lt;intContractDetailId&gt;'+LTRIM(t1.intContractDetailId)+'&lt;/intContractDetailId&gt;</toReplace>'
					+ '</tags>'
					FROM  (
					SELECT t.intContractDetailId,td.intDetailId 
					From
					(SELECT ROW_NUMBER() OVER(ORDER BY intContractDetailId) intRowNo , * FROM tblCTContractDetail cd WHERE cd.intContractHeaderId=@NewContractHeaderId) t 
					JOIN @tblDetailId td on t.intRowNo=td.intRowNo 
					) t1
					
					Set @strCostReplaceXml = '<root>' + @strCostReplaceXml + '</root>'
					
					SET @strCostXML = REPLACE(@strCostXML,'intContractCostId','intContractCostRefId')	

					EXEC uspCTInsertINTOTableFromXML 'tblCTContractCost',@strCostXML,@NewContractCostId OUTPUT,@strCostReplaceXml

					SELECT @strContractDetailAllId = STUFF((
													SELECT DISTINCT ',' + LTRIM(intContractDetailId)
													FROM tblCTContractDetail
													WHERE intContractHeaderId = @NewContractHeaderId
													FOR XML PATH('')
													), 1, 1, '')

					SELECT @strCostCondition = 'intContractDetailId IN ('+ LTRIM(@strContractDetailAllId)+')'

					EXEC uspCTGetTableDataInXML 'tblCTContractCost',@strCostCondition,@strAckCostXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckCostXML = @strAckCostXML 
						WHERE   intContractAcknowledgementStageId = @intContractAcknowledgementStageId

				------------------------------------------------------------Document-----------------------------------------------------
				SET @strTagRelaceXML =NULL
				SET @strTagRelaceXML =  '<root>
																	<tags>
																		<toFind>&lt;intContractHeaderId&gt;'+LTRIM(@intContractHeaderId)+'&lt;/intContractHeaderId&gt;</toFind>
																		<toReplace>&lt;intContractHeaderId&gt;'+LTRIM(@NewContractHeaderId)+'&lt;/intContractHeaderId&gt;</toReplace>
																	</tags>
																</root>'
					
					SET @strDocumentXML = REPLACE(@strDocumentXML,'intContractDocumentId','intContractDocumentRefId')

					EXEC uspCTInsertINTOTableFromXML 'tblCTContractDocument',@strDocumentXML,@NewContractDetailId OUTPUT,@strTagRelaceXML

						
						
						EXEC uspCTGetTableDataInXML 'tblCTContractDocument',@strHeaderCondition,@strAckDocumentXML  OUTPUT

						UPDATE  tblCTContractAcknowledgementStage 
						SET		strAckDocumentXML =@strAckDocumentXML 
						WHERE   intContractAcknowledgementStageId =@intContractAcknowledgementStageId
					
					----------------------------CALL Stored procedure for APPROVAL -----------------------------------------------------------
					
					DECLARE @intCreatedById INT
					SELECT @intCreatedById = intCreatedById FROM tblCTContractHeader WHERE intContractHeaderId = @NewContractHeaderId

					DECLARE @config AS ApprovalConfigurationType
					INSERT INTO @config (strApprovalFor, strValue)
					SELECT 'Contract Type', 'Sale'

					EXEC uspSMSubmitTransaction
					  @type = 'ContractManagement.view.Contract',
					  @recordId = @NewContractHeaderId,
					  @transactionNo = @strNewContractNumber,
					  @transactionEntityId = @intEntityId,
					  @currentUserEntityId = @intCreatedById,
					  @amount = 0,
					  @approverConfiguration = @config 

					--------------------------------------------------------------------------------------------------------------------------

			 END
		     
			 UPDATE tblCTContractStage SET strFeedStatus = 'Processed' WHERE intContractStageId = @intContractStageId
	
		SELECT @intContractStageId = MIN(intContractStageId)
		FROM tblCTContractStage
		WHERE intContractStageId > @intContractStageId AND ISNULL(strFeedStatus,'')='' AND strRowState ='Added'
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

