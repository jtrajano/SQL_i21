CREATE PROCEDURE [dbo].[uspARDeletePayment]
	  @PaymentIds	        AS Id READONLY
	, @intEntityUserId	    AS INT
    , @ysnRaiseError        AS BIT = 0
    , @strErrorMessage      AS NVARCHAR(MAX) = NULL OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
    DECLARE @strPostedRCV NVARCHAR(100) = NULL

    IF ISNULL(@intEntityUserId, 0) = 0
        BEGIN
            SELECT TOP 1 @intEntityUserId = [intEntityId] 
            FROM tblSMUserSecurity 
            WHERE intEntityId = @intEntityUserId
        END	    

    --VALIDATE POSTED PAYMENTS
    SELECT TOP 1 @strPostedRCV = strRecordNumber 
    FROM tblARPayment P 
    INNER JOIN @PaymentIds PID ON P.intPaymentId = PID.intId WHERE P.ysnPosted = 1
    
	IF ISNULL(@strPostedRCV, '') <> ''
        BEGIN
            SET @strErrorMessage = 'Posted Payment ' + @strPostedRCV + ' cannot be deleted!';
            
            IF @ysnRaiseError = 1
                BEGIN
                    RAISERROR(@strErrorMessage, 11, 1);
                    RETURN 0;
                END
        END

    --GET UNPOSTED PAYMENTS ONLY
    IF(OBJECT_ID('tempdb..#PAYMENTSTODELETE') IS NOT NULL)
    BEGIN
        DROP TABLE #PAYMENTSTODELETE
    END

    SELECT DISTINCT intPaymentId
    INTO #PAYMENTSTODELETE
    FROM tblARPayment P 
    INNER JOIN @PaymentIds PID ON P.intPaymentId = PID.intId 
    WHERE P.ysnPosted = 0 

    --DELETE PAYMENT
    DELETE P 
    FROM tblARPayment P 
    INNER JOIN #PAYMENTSTODELETE PID ON P.intPaymentId = PID.intPaymentId
	
    --AUDIT LOG
    WHILE EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSTODELETE)
        BEGIN
            DECLARE @intPaymentId INT

            SELECT TOP 1 @intPaymentId = intPaymentId FROM #PAYMENTSTODELETE ORDER BY intPaymentId

            EXEC dbo.uspSMAuditLog  @keyValue		= @intPaymentId						                -- Primary Key Value of the Invoice. 
                                  , @screenName		= 'AccountsReceivable.view.ReceivePaymentsDetail'	-- Screen Namespace
                                  , @entityId		= @intEntityUserId						            -- Entity Id.
                                  , @actionType		= 'Deleted'							                -- Action Type

            DELETE FROM #PAYMENTSTODELETE WHERE intPaymentId = @intPaymentId
        END
END TRY
BEGIN CATCH	
	SELECT @strErrorMessage = ERROR_MESSAGE()									
	RAISERROR(@strErrorMessage, 11, 1);
	RETURN 0	
END CATCH		

RETURN 1		                     
		                     
END