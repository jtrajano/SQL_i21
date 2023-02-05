Create PROCEDURE [dbo].[uspCTLoadContractDetailImport]
	@intContractDetailImportHeaderId INT
AS

BEGIN TRY	

	Declare @ErrMsg Nvarchar(MAX)

	SELECT * 
	into #tmpTable
	FROM  vyuCTContractDetailImport
	WHERE intContractDetailImportHeaderId = @intContractDetailImportHeaderId


	DELETE FROM tblCTContractDetailImport WHERE intContractDetailImportHeaderId = @intContractDetailImportHeaderId

	SELECT * FROM #tmpTable ORDER BY intContractDetailImportId


END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
END CATCH