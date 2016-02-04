CREATE PROCEDURE [dbo].[uspGRGetContracts]
	@strSearchCriteria NVARCHAR(MAX)
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @sql NVARCHAR(MAX)	
	
	IF @strSearchCriteria <> ''
		SET @sql='SELECT * FROM vyuCTContractDetailView WHERE '+@strSearchCriteria+' Order By intContractDetailId'
	ELSE
		SET @sql='SELECT * FROM vyuCTContractDetailView Order By intContractDetailId'

	EXEC sp_executesql @sql
			
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')		
END CATCH