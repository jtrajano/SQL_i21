CREATE PROCEDURE [dbo].[uspAPCancelPayables]
	@payableIds NVARCHAR(4000),
	@userId AS INT,
	@billsCreated NVARCHAR(MAX) OUTPUT
AS

BEGIN  
	SET QUOTED_IDENTIFIER OFF  
	SET ANSI_NULLS ON  
	SET NOCOUNT ON  
	SET ANSI_WARNINGS OFF  
	
	BEGIN TRY
		DECLARE @transCount INT = @@TRANCOUNT; 
		IF @transCount = 0 BEGIN TRANSACTION;

		--DO LOGICS

		IF @transCount = 0 COMMIT TRANSACTION;
	
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorSeverity INT,  
			@ErrorNumber   INT,  
			@ErrorMessage nvarchar(4000),  
			@ErrorState INT,  
			@ErrorLine  INT,  
			@ErrorProc nvarchar(200);  
		-- Grab error information from SQL functions  
		SET @ErrorSeverity = ERROR_SEVERITY()  
		SET @ErrorNumber   = ERROR_NUMBER()  
		SET @ErrorMessage  = ERROR_MESSAGE()  
		SET @ErrorState    = ERROR_STATE()  
		SET @ErrorLine     = ERROR_LINE()  
		SET @ErrorProc     = ERROR_PROCEDURE()  

		-- SET @ErrorMessage  = 'Error creating voucher.' + CHAR(13) +   
		-- 'SQL Server Error Message is: ' + CAST(@ErrorNumber AS VARCHAR(10)) +   
		-- ' in procedure: ' + @ErrorProc + ' Line: ' + CAST(@ErrorLine AS VARCHAR(10)) + ' Error text: ' + @ErrorMessage  

		IF (XACT_STATE()) = -1  
		BEGIN  
			ROLLBACK TRANSACTION  
		END  
		ELSE IF (XACT_STATE()) = 1 AND @transCount = 0  
		BEGIN  
			ROLLBACK TRANSACTION  
		END  

		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
	END CATCH 
	
	RETURN 0  
END 