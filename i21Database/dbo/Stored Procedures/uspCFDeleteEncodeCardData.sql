CREATE PROCEDURE [dbo].[uspCFDeleteEncodeCardData]
	 @userId INT
AS
BEGIN
	
	BEGIN TRY
		BEGIN TRANSACTION
	
		DELETE FROM tblCFEncodeCard WHERE intEncodeCardId IN (SELECT intEncodeCardId FROM tblCFEncodeCardStagingTable WHERE ISNULL(intUserId,0) = 0 OR intUserId = @userId)
		DELETE FROM tblCFEncodeCardStagingTable WHERE ISNULL(intUserId,0) = 0 OR intUserId = @userId
		DELETE FROM tblCFEncodingPrinterSoftware 

		COMMIT TRANSACTION

		SELECT 
		 ysnSuccess = CAST(1 AS BIT)
		,strMessage = ''

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		SELECT 
		 ysnSuccess = CAST(0 AS BIT)
		,strMessage = ERROR_MESSAGE()

	END CATCH

END