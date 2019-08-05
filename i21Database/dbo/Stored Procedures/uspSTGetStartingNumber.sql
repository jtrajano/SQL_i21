CREATE PROCEDURE [dbo].[uspSTGetStartingNumber]
	@strModule NVARCHAR(100)
	, @strTransactionType NVARCHAR(150)
	, @strPrefix NVARCHAR(100)
	, @intLocationId INT
	, @strBatchId NVARCHAR(100) OUTPUT
	, @ysnSuccess BIT OUTPUT
	, @strMessage NVARCHAR(1000) OUTPUT
AS
BEGIN TRY
		
		SET ANSI_WARNINGS OFF
		SET NOCOUNT ON;
		DECLARE @InitTranCount INT;
		SET @InitTranCount = @@TRANCOUNT
		DECLARE @Savepoint NVARCHAR(32) = SUBSTRING(('uspSTGetStartingNumber' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

		IF @InitTranCount = 0
			BEGIN
				BEGIN TRANSACTION
			END
				
		ELSE
			BEGIN
				SAVE TRANSACTION @Savepoint
			END



		SET @ysnSuccess = CAST(1 AS BIT)
		SET @strMessage = ''
		SET @strBatchId = NULL

		IF EXISTS(SELECT intStartingNumberId 
		          FROM tblSMStartingNumber 
				  WHERE strModule = @strModule 
					AND strTransactionType = @strTransactionType
					AND strPrefix = @strPrefix)
			BEGIN
				
				DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId 
														 FROM tblSMStartingNumber 
														 WHERE strModule = @strModule 
															AND strTransactionType = @strTransactionType
															AND strPrefix = @strPrefix)	

				EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 

				GOTO ExitWithCommit
			END
		ELSE
			BEGIN
				SET @strBatchId = NULL
				SET @ysnSuccess = CAST(0 AS BIT)
				SET @strMessage = 'Batch number for prefix ' + @strPrefix + ' does not exists.'

				GOTO ExitWithRollback;
			END

		

END TRY
BEGIN CATCH	
	SET @strBatchId = NULL
	SET @ysnSuccess = CAST(0 AS BIT)
	SET @strMessage = ERROR_MESSAGE()

	GOTO ExitWithRollback;
END CATCH



ExitWithCommit:
	IF @InitTranCount = 0
		BEGIN
			COMMIT TRANSACTION
		END

	GOTO ExitPost



ExitWithRollback:
		IF @InitTranCount = 0
			BEGIN
				IF ((XACT_STATE()) <> 0)
				BEGIN
					ROLLBACK TRANSACTION
				END
			END
			
		ELSE
			BEGIN
				IF ((XACT_STATE()) <> 0)
					BEGIN
						ROLLBACK TRANSACTION @Savepoint
					END
			END
			
		
ExitPost: