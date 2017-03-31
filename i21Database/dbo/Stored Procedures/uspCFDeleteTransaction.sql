CREATE PROCEDURE [dbo].[uspCFDeleteTransaction]
	  @intTransactionId AS INT	 
	 ,@intUserId AS INT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

Declare @incval int,
		@intEntityUserSecurityId int,
        @intInvoiceId int,	
        @total int;

	
DECLARE @IVTable TABLE
    (
	intId INT IDENTITY PRIMARY KEY CLUSTERED,
	intTransactionId int,
    intInvoiceId int	
    )

BEGIN TRY

SELECT	TOP 1 @intEntityUserSecurityId = [intEntityId] 
		FROM	dbo.tblSMUserSecurity 
		WHERE	[intEntityId] = @intUserId

INSERT INTO @IVTable
SELECT intTransactionId,intInvoiceId  from tblARInvoice INV
WHERE intTransactionId = @intTransactionId


SELECT @total = count(*) from @IVTable;
SET @incval = 1 
WHILE @incval <= @total 
BEGIN
   SELECT @intInvoiceId = intInvoiceId, @intTransactionId = intTransactionId FROM @IVTable WHERE intId = @incval

   --UPDATE tblCFTransaction 
   --set intInvoiceId = null where intTransactionId = @intTransactionId

   IF ISNULL(@intInvoiceId,0) != 0
   BEGIN
       EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId ,@intUserId 
   END 
   SET @incval = @incval + 1;

   DELETE FROM tblCFTransaction WHERE intTransactionId = @intTransactionId

END;

RETURN 1

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH