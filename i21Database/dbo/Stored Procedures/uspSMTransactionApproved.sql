CREATE PROCEDURE [dbo].[uspSMTransactionApproved]
 @type NVARCHAR(MAX),
  @recordId INT
AS
BEGIN
		DECLARE @intToEntityId			INT
		DECLARE @intCompanyLocationId			INT
		DECLARE @intToCompanyId			INT
		DECLARE @strToTransactionType	NVARCHAR(100)
		DECLARE @strInsert				NVARCHAR(100)
		
		DECLARE @intTransactionApprovedLogId INT

		INSERT INTO [tblCTSMTransactionApprovedLog](strType,intRecordId,dtmLog)
		SELECT @type,@recordId,GETDATE()
	
		SELECT @intTransactionApprovedLogId = SCOPE_IDENTITY()
		
		 SELECT 
		 @strToTransactionType	 = TT1.strTransactionType	 
		,@intToCompanyId		 = TC.intToCompanyId
		,@intToEntityId			 = TC.intEntityId
		,@intCompanyLocationId	 = TC.intCompanyLocationId
		,@strInsert				 = TC.strInsert
		FROM tblSMInterCompanyTransactionConfiguration TC 
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblCTContractHeader CH ON CH.intCompanyId = TC.intFromCompanyId AND CH.intBookId = TC.intFromBookId
		WHERE TT.strTransactionType ='Purchase Contract' AND CH.intContractHeaderId = @recordId
	

		IF @type = 'ContractManagement.view.Contract' OR @type = 'ContractManagement.view.Amendments'
		BEGIN
			DECLARE @intTransactionId INT, @intApprovalId INT,@intScreenId INT,@ysnOnceApproved BIT

			SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'  

			SELECT  @intTransactionId	=	intTransactionId,@ysnOnceApproved = ysnOnceApproved FROM tblSMTransaction WHERE intRecordId = @recordId AND intScreenId = @intScreenId

			SELECT	TOP 1	@intApprovalId	=	intApprovalId FROM tblSMApproval WHERE strStatus = 'Approved'  AND intTransactionId  = @intTransactionId ORDER BY 1 DESC

			BEGIN TRY
					UPDATE [tblCTSMTransactionApprovedLog] SET ysnOnceApproved = @ysnOnceApproved WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId
					
					EXEC	uspCTContractApproved @recordId,@intApprovalId,NULL,1
					
					UPDATE [tblCTSMTransactionApprovedLog] SET strErrMsg = 'Success' WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId
					
					IF EXISTS(SELECT 1 FROM tblCTContractHeader CH JOIN tblCTBookVsEntity BVE ON BVE.intBookId = CH.intBookId AND BVE.intEntityId = CH.intEntityId WHERE CH.intContractHeaderId = @recordId)
					BEGIN
							IF @strToTransactionType ='Sales Contract' AND @strInsert='Insert on Approval'
							BEGIN
								EXEC uspCTContractPopulateStgXML @recordId,@intToEntityId,@intCompanyLocationId,@strToTransactionType,@intToCompanyId,'Added'	
							END
					END
			END TRY
			BEGIN CATCH
				UPDATE [tblCTSMTransactionApprovedLog] SET strErrMsg = ERROR_MESSAGE() WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId
			END CATCH
		RETURN
	END

 RETURN
END