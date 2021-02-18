CREATE PROCEDURE [dbo].uspCTReportContractCommitmentDetailSalesMP
	
	 @intContractHeaderId INT
	,@strDetailAmendedColumns NVARCHAR(MAX) = NULL
	
AS

BEGIN TRY
	
	DECLARE	@ErrMsg NVARCHAR(MAX)

	
	DECLARE 	@intContractDetailId INT

	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId


	BEGIN
		 SELECT 
			 intContractHeaderId	= intContractHeaderId
			,strCondition			= strConditionDescription
			
			FROM   tblCTContractCondition CC
			WHERE  CC.intContractHeaderId = 	@intContractHeaderId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractCommitmentDetailSalesMP - '+ ERROR_MESSAGE() 
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH