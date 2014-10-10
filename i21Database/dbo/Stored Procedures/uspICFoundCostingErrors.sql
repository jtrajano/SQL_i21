/*
	Create the stored procedure to generate an error using RAISERROR. 
	The original error information is used to construct the msg_str for RAISERROR. 
*/

CREATE PROCEDURE [dbo].[uspICFoundCostingErrors]
AS

	-- Return if there is no error information to retrieve. 
	IF ERROR_NUMBER() IS NULL
		RETURN;

	DECLARE @ErrorMessage NVARCHAR(4000),
			@ErrorNumber INT,
			@ErrorSeverity INT,
			@ErrorState INT,
			@ErrorLine INT,
			@ErrorProcedure NVARCHAR(200);

	-- Assign variables to error-handling functions
	-- that captures information for RAISERROR. 
	SELECT
		@ErrorNumber = ERROR_NUMBER(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE(),
		@ErrorLine = ERROR_LINE(),
		@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

	-- Build the message string that will contain the original error information
	SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, ' + 
            'Message: '+ ERROR_MESSAGE();


	-- Raise an error: msg_str parameter for RAISERROR will contain the original error information. 
	RAISERROR(
		@ErrorMessage,
		@ErrorSeverity,
		1,
		@ErrorNumber,	-- parameter: original error number
		@ErrorSeverity,	-- parameter: original error severity
		@ErrorState,	-- parameter: original error state
		@ErrorProcedure, -- parameter: original error procedure name
		@ErrorLine		-- parameter: original error line number
	);

	/*
		For example, it will re-throw the error back to the calling app this kind of message: 

		Msg 50000, Level 11, State 1, Procedure uspICItemCostingErrorHandler, Line 35
		Error 50005, Level 11, State 1, Procedure uspICItemCostingUnPostValidation, Line 4, Message: ....
	*/

GO
