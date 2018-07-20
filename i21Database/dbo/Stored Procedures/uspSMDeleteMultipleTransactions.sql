CREATE PROCEDURE [dbo].[uspSMDeleteMultipleTransactions]
	@recordIds nvarchar(500),
	@namespace nvarchar(500)
AS
BEGIN TRANSACTION

BEGIN TRY
	DELETE FROM tblSMTransaction where intTransactionId in (select * from dbo.fnSplitStringWithTrim(@recordIds,','))
	AND intScreenId = (SELECT top 1 intScreenId from tblSMScreen where strNamespace = @namespace)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
END CATCH