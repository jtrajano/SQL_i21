
-- Create a i21-only compliant stored procedure. 
-- There is another stored procedure of the same name in the Integration project. 
-- If there is no integration, this stored procedure will be used. 
-- Otherwise, the stored procedure in the integration will be used. 

CREATE PROCEDURE uspCMProcessUndepositedFunds
	@ysnPost AS BIT 
	,@intBankAccountId AS INT 
	,@strTransactionId NVARCHAR(40) = NULL 
	,@intUserId INT = NULL 
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do nothing for now. 

--=====================================================================================================================================
-- 	EXIT ROUTINES 
---------------------------------------------------------------------------------------------------------------------------------------

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_BookGLEntries

Exit_BookGLEntries_WithErrors:
	SET @isSuccessful = 0		
	GOTO Exit_BookGLEntries	
	
Exit_BookGLEntries:

-- Clean up. Remove any disposable temporary tables here.
-- None