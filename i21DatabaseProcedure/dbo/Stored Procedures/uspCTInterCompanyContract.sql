CREATE PROCEDURE [dbo].[uspCTInterCompanyContract]
	@ContractHeaderId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg					NVARCHAR(MAX)	
	DECLARE @intToCompanyId			INT
	DECLARE @intToEntityId			INT
	DECLARE @intCompanyLocationId	INT
	DECLARE @strInsert				NVARCHAR(100)
	DECLARE @strUpdate			    NVARCHAR(100)
	DECLARE @strToTransactionType	NVARCHAR(100)
	
	
	IF EXISTS(
				SELECT 1 FROM tblSMInterCompanyTransactionConfiguration TC 
				JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
				WHERE TT.strTransactionType ='Purchase Contract'
			  )
	BEGIN

		IF EXISTS(SELECT 1 FROM tblCTContractHeader CH 
						  JOIN tblCTBookVsEntity BVE ON BVE.intBookId = CH.intBookId 
						  AND BVE.intEntityId = CH.intEntityId WHERE CH.intContractHeaderId = @ContractHeaderId)
		BEGIN
				 SELECT 
				  @intToCompanyId			 = TC.intToCompanyId
				 ,@intToEntityId			 = TC.intEntityId			 
				 ,@strInsert				 = TC.strInsert				 
				 ,@strUpdate			   	 = TC.strUpdate
				 ,@strToTransactionType	 = TT1.strTransactionType
				 ,@intCompanyLocationId	 = TC.intCompanyLocationId
				 FROM tblSMInterCompanyTransactionConfiguration  TC 
				 JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
				 JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
				 JOIN tblCTContractHeader CH ON CH.intCompanyId = TC.intFromCompanyId AND CH.intBookId = TC.intFromBookId
				 WHERE TT.strTransactionType ='Purchase Contract' AND CH.intContractHeaderId = @ContractHeaderId

				IF @strInsert = 'Insert'
				BEGIN
					IF EXISTS(SELECT 1 FROM tblCTContractHeader WHERE intContractHeaderId = @ContractHeaderId AND intConcurrencyId =1)
					BEGIN
						  EXEC uspCTContractPopulateStgXML @ContractHeaderId,@intToEntityId,@intCompanyLocationId,@strToTransactionType,@intToCompanyId,'Added'
					END
					ELSE IF EXISTS(SELECT 1 FROM tblCTContractHeader WHERE intContractHeaderId = @ContractHeaderId AND intConcurrencyId > 1)
					BEGIN
						  EXEC uspCTContractPopulateStgXML @ContractHeaderId,@intToEntityId,@intCompanyLocationId,@strToTransactionType,@intToCompanyId,'Modified'
					END
				END
		END	
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

