CREATE PROCEDURE [dbo].[uspCTSaveINCOShipTerm]
    @intContractBasisId INT
AS

BEGIN TRY
	
	DECLARE	 @ErrMsg	NVARCHAR(MAX)

	IF EXISTS (SELECT * FROM tblCTContractBasis WHERE intContractBasisId = @intContractBasisId AND ysnDefault = 1)
	BEGIN
	   UPDATE tblCTContractBasis SET ysnDefault = 0 WHERE intContractBasisId <> @intContractBasisId
	END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
