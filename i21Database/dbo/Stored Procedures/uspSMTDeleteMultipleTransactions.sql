CREATE PROCEDURE [dbo].[uspSMTDeleteMultipleTransactions]
	@recordIds nvarchar(500),
	@namespace nvarchar(500)
AS
BEGIN TRY
	BEGIN TRANSACTION
		IF ISNULL(@recordIds, 0) <> 0 and ISNULL(@namespace, 0) <> 0
		BEGIN
			DELETE FROM tblSMTransaction where intTransactionId in (select * from dbo.fnSplitStringWithTrim(@recordIds,','))
			AND intScreenId = (SELECT top 1 intScreenId from tblSMScreen where strNamespace = @namespace)
		END
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
END CATCH