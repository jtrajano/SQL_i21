CREATE PROCEDURE [dbo].[uspARPOSBatchProcess]
	@intPOSEndOfDayId	INT
AS

--IF EXISTS(SELECT TOP 1 NULL FROM tblARPOSEndOfDay WHERE intPOSEndOfDayId = @intPOSEndOfDayId AND ysnClosed = 1)
--	BEGIN
--		RAISERROR('EOD is already closed.', 16, 1)
--		RETURN
--	END

--REGULAR POS
IF(OBJECT_ID('tempdb..#REGULARTRANS') IS NOT NULL)
BEGIN
	DROP TABLE #REGULARTRANS
END

SELECT intPOSId			= POS.intPOSId
	 , intEntityUserId	= POS.intEntityUserId
	 , ysnProcessed		= CAST(0 AS BIT)
INTO #REGULARTRANS
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
LEFT JOIN (
	SELECT TOP 1 intPOSId
	FROM tblARPOSDetail
	WHERE dblQuantity < 0
	GROUP BY intPOSId
) NEGQTY ON POS.intPOSId = NEGQTY.intPOSId
WHERE POS.ysnReturn = 0
  AND POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND POS.dblTotal > 0
  AND NEGQTY.intPOSId IS NULL
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId

--RETURNED POS
IF(OBJECT_ID('tempdb..#RETURNEDTRANS') IS NOT NULL)
BEGIN
	DROP TABLE #RETURNEDTRANS
END

SELECT intPOSId			= POS.intPOSId
	 , intEntityUserId	= POS.intEntityUserId
	 , ysnProcessed		= CAST(0 AS BIT)
INTO #RETURNEDTRANS
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
WHERE POS.ysnReturn = 1
  AND POS.intOriginalPOSTransactionId IS NOT NULL
  AND POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND POS.dblTotal < 0
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId

--MIXED POS
 IF(OBJECT_ID('tempdb..#MIXEDTRANS') IS NOT NULL)
BEGIN
	DROP TABLE #MIXEDTRANS
END

SELECT intPOSId			= POS.intPOSId
	 , intEntityUserId	= POS.intEntityUserId
	 , ysnProcessed		= CAST(0 AS BIT)
INTO #MIXEDTRANS
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
CROSS APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity < 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) NEGQTY
WHERE POS.ysnReturn = 0
  AND POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId

DELETE BP
FROM tblARPOSBatchProcessLog BP
INNER JOIN #REGULARTRANS RT ON BP.intPOSId = RT.intPOSId

DELETE BP
FROM tblARPOSBatchProcessLog BP
INNER JOIN #RETURNEDTRANS RT ON BP.intPOSId = RT.intPOSId

DELETE BP
FROM tblARPOSBatchProcessLog BP
INNER JOIN #MIXEDTRANS MT ON BP.intPOSId = MT.intPOSId

--PROCESS REGULAR TRANSACTIONS
WHILE EXISTS (SELECT TOP 1 NULL FROM #REGULARTRANS WHERE ysnProcessed = 0)
	BEGIN
		DECLARE @intRTPOSId		INT = NULL
			  , @intRTUserId	INT = NULL
			  , @InitTranCount	INT = NULL
			  , @strRTErrMsg	NVARCHAR(MAX) = NULL
			  , @strInvIds		NVARCHAR(MAX) = NULL
			  , @Savepoint		NVARCHAR(32)  = NULL

		SELECT TOP 1 @intRTPOSId	= intPOSId
				   , @intRTUserId	= intEntityUserId
		FROM #REGULARTRANS 
		WHERE ysnProcessed = 0 
		ORDER BY intPOSId

		SET @InitTranCount = @@TRANCOUNT
		SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

		IF @InitTranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION @Savepoint
		
		BEGIN TRY
			EXEC dbo.uspARProcessPOSToInvoice @intRTPOSId, @intRTUserId, 'Invoice', @strRTErrMsg OUT, @strInvIds OUT

			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			) 
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= 'Successfully Processed.'
				 , ysnSuccess			= CAST(1 AS BIT)
				 , dtmDateProcessed		= GETDATE()
			FROM tblARPOS POS
			WHERE intPOSId = @intRTPOSId
		END TRY
		BEGIN CATCH
			SELECT @strRTErrMsg = ERROR_MESSAGE()					
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		
			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			)
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= @strRTErrMsg
				 , ysnSuccess			= CAST(0 AS BIT)
				 , dtmDateProcessed		= GETDATE() 
			FROM tblARPOS POS
			WHERE intPOSId = @intRTPOSId
		END CATCH
		
		IF @InitTranCount = 0
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
			END	
			
		UPDATE #REGULARTRANS SET ysnProcessed = 1 WHERE intPOSId = @intRTPOSId
	END

--PROCESS RETURNED TRANSACTIONS
WHILE EXISTS (SELECT TOP 1 NULL FROM #RETURNEDTRANS WHERE ysnProcessed = 0)
	BEGIN
		DECLARE @intRefundPOSId			INT = NULL
			  , @intRefundUserId		INT = NULL
			  , @RefundInitTranCount	INT = NULL
			  , @strRefundErrMsg		NVARCHAR(MAX) = NULL
			  , @strRefundInvIds		NVARCHAR(MAX) = NULL
			  , @RefundSavepoint		NVARCHAR(32)  = NULL

		SELECT TOP 1 @intRefundPOSId	= intPOSId
				   , @intRefundUserId	= intEntityUserId
		FROM #RETURNEDTRANS 
		WHERE ysnProcessed = 0 
		ORDER BY intPOSId

		SET @RefundInitTranCount = @@TRANCOUNT
		SET @RefundSavepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @RefundInitTranCount)), 1, 32)

		IF @RefundInitTranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION @RefundSavepoint
		
		BEGIN TRY
			EXEC dbo.uspARPOSNegativeTransaction @intRefundPOSId, @intRefundUserId, @strRefundErrMsg OUT, @strRefundInvIds OUT

			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			) 
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= 'Successfully Processed.'
				 , ysnSuccess			= CAST(1 AS BIT)
				 , dtmDateProcessed		= GETDATE()
			FROM tblARPOS POS
			WHERE intPOSId = @intRefundPOSId
		END TRY
		BEGIN CATCH
			SELECT @strRefundErrMsg = ERROR_MESSAGE()					
			IF @RefundInitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @RefundSavepoint
		
			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			)
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= @strRefundErrMsg
				 , ysnSuccess			= CAST(0 AS BIT)
				 , dtmDateProcessed		= GETDATE() 
			FROM tblARPOS POS
			WHERE intPOSId = @intRefundPOSId
		END CATCH
		
		IF @RefundInitTranCount = 0
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
			END	

		UPDATE #RETURNEDTRANS SET ysnProcessed = 1 WHERE intPOSId = @intRefundPOSId
	END

--PROCESS MIXED TRANSACTIONS
WHILE EXISTS (SELECT TOP 1 NULL FROM #MIXEDTRANS WHERE ysnProcessed = 0)
	BEGIN
		DECLARE @intMTPOSId			INT = NULL
			  , @intMTUserId		INT = NULL
			  , @MTInitTranCount	INT = NULL
			  , @strMTErrMsg		NVARCHAR(MAX) = NULL
			  , @strMTInvIds		NVARCHAR(MAX) = NULL
			  , @MTSavepoint		NVARCHAR(32) = NULL

		SELECT TOP 1 @intMTPOSId	= intPOSId
				   , @intMTUserId	= intEntityUserId
		FROM #MIXEDTRANS 
		WHERE ysnProcessed = 0 
		ORDER BY intPOSId

		SET @MTInitTranCount = @@TRANCOUNT
		SET @MTSavepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @MTInitTranCount)), 1, 32)

		IF @MTInitTranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION @MTSavepoint
		
		BEGIN TRY
			EXEC dbo.uspARPOSMixedTransaction @intMTPOSId, @intMTUserId, @strMTErrMsg OUT, @strMTInvIds OUT

			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			) 
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= 'Successfully Processed.'
				 , ysnSuccess			= CAST(1 AS BIT)
				 , dtmDateProcessed		= GETDATE()
			FROM tblARPOS POS
			WHERE intPOSId = @intMTPOSId
		END TRY
		BEGIN CATCH
			SELECT @strMTErrMsg = ERROR_MESSAGE()
								
			IF @MTInitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @MTSavepoint
		
			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			)
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= @strMTErrMsg
				 , ysnSuccess			= CAST(0 AS BIT)
				 , dtmDateProcessed		= GETDATE() 
			FROM tblARPOS POS		
			WHERE intPOSId = @intMTPOSId
		END CATCH
		
		IF @MTInitTranCount = 0
			BEGIN
				IF (XACT_STATE()) = -1
					ROLLBACK TRANSACTION
				IF (XACT_STATE()) = 1
					COMMIT TRANSACTION
			END	

		UPDATE #MIXEDTRANS SET ysnProcessed = 1 WHERE intPOSId = @intMTPOSId
	END