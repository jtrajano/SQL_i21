CREATE PROCEDURE [dbo].[uspCTInterCompanyPriceContract] 
	@intPriceContractId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg					NVARCHAR(MAX)	
	DECLARE @intToCompanyId			INT
	DECLARE @intToEntityId			INT
	DECLARE @strInsert				NVARCHAR(100)
	DECLARE @strUpdate			    NVARCHAR(100)
	DECLARE @strToTransactionType	NVARCHAR(100)
	
	IF EXISTS(
				SELECT 1 FROM tblSMInterCompanyTransactionConfiguration TC 
				JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
				WHERE TT.strTransactionType ='Purchase Price Fixation'
			  )	
	BEGIN
	     SELECT 
		 @intToCompanyId		 = TC.intToCompanyId
		,@intToEntityId			 = TC.intEntityId			 
		,@strInsert				 = TC.strInsert				 
		,@strUpdate			   	 = TC.strUpdate
		,@strToTransactionType	 = TT1.strTransactionType
		FROM tblSMInterCompanyTransactionConfiguration  TC 
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		WHERE TT.strTransactionType ='Purchase Price Fixation'
		
		IF @strInsert = 'Insert'
		BEGIN
			IF EXISTS(SELECT 1 FROM tblCTPriceContract WHERE intPriceContractId = @intPriceContractId AND intConcurrencyId =1)
			BEGIN
			      EXEC uspCTPriceContractPopulateStgXML @intPriceContractId,@intToEntityId,@strToTransactionType,@intToCompanyId,'Added'
			END
		END
	END

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
