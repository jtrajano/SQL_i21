CREATE PROCEDURE [dbo].[uspSTReportCheckoutChangeFundDetail]
	@intCheckoutId INT
AS
BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT strDescription, dblValue 
	FROM tblSTCheckoutChangeFund
	WHERE intCheckoutId = @intCheckoutId

END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH