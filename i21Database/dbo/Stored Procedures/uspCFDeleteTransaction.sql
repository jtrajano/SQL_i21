CREATE PROCEDURE [dbo].[uspCFDeleteTransaction]
	  @intTransactionId AS INT	 
	 ,@intUserId AS INT	
	 ,@intContractId AS INT = 0
	 ,@ysnRaiseError AS BIT = 1
	 ,@strErrorMessage AS NVARCHAR(MAX) = NULL OUTPUT  
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

IF(ISNULL(@intContractId,0) = 0)
BEGIN

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

END
ELSE
BEGIN
	DECLARE @dblQuantity AS NUMERIC(18,6)
	SELECT TOP 1 @dblQuantity = dblQuantity FROM tblCFTransaction WHERE intTransactionId = @intTransactionId

	SET @dblQuantity = @dblQuantity * -1
	EXEC uspCTUpdateScheduleQuantity 
		@intContractDetailId = @intContractId
	,@dblQuantityToUpdate = @dblQuantity
	,@intUserId = @intUserId
	,@intExternalId = @intTransactionId
	,@strScreenName = 'Card Fueling Transaction Screen'

	DELETE FROM tblCFTransaction WHERE intTransactionId = @intTransactionId

	RETURN 1

END
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.

	SET @strErrorMessage = @ErrorMessage
	IF(ISNULL(@ysnRaiseError,0) = 1)
	BEGIN
		RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
	END
	
END CATCH