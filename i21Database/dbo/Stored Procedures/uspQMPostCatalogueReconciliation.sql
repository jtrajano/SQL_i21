CREATE PROCEDURE uspQMPostCatalogueReconciliation
      @intCatalogueReconciliationId     INT = NULL
    , @intEntityId                      INT = NULL
    , @ysnPost                          BIT = 0
	, @strCatalogueIds					NVARCHAR(MAX) = NULL
	, @ysnSuccess						BIT = 0 OUTPUT
	, @strErrorMsg						NVARCHAR(MAX) = NULL OUTPUT	
AS
BEGIN TRY
	SET ANSI_WARNINGS ON
	
	BEGIN TRANSACTION

    DECLARE @dtmDateToday		DATETIME = CAST(GETDATE() AS DATE)
	DECLARE @strBillIds			NVARCHAR(MAX) = NULL
	DECLARE @strBatchIdUsed		NVARCHAR(100) = NULL

    IF OBJECT_ID('tempdb..#CATRECON') IS NOT NULL DROP TABLE #CATRECON
	CREATE TABLE #CATRECON (
		  intCatalogueReconciliationId		INT PRIMARY KEY
        , strReconciliationNumber           NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	)

	IF @intCatalogueReconciliationId IS NOT NULL
		BEGIN
			INSERT INTO #CATRECON
			SELECT intCatalogueReconciliationId	= CR.intCatalogueReconciliationId
				 , strReconciliationNumber      = CR.strReconciliationNumber
			FROM tblQMCatalogueReconciliation CR
			WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId
		END

	IF @strCatalogueIds IS NOT NULL
		BEGIN
			INSERT INTO #CATRECON
			SELECT intCatalogueReconciliationId	= CR.intCatalogueReconciliationId
				 , strReconciliationNumber      = CR.strReconciliationNumber
			FROM tblQMCatalogueReconciliation CR
			INNER JOIN fnGetRowsFromDelimitedValues(@strCatalogueIds) V ON CR.intCatalogueReconciliationId = V.intID
		END

	--POST VOUCHERS
	SELECT @strBillIds = LEFT(intBillId, LEN(intBillId) - 1)
	FROM (
		SELECT DISTINCT CAST(BD.intBillId AS VARCHAR(200))  + ', '
		FROM tblQMCatalogueReconciliationDetail CRD
		INNER JOIN #CATRECON CR ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
		INNER JOIN tblAPBillDetail BD ON CRD.intBillDetailId = BD.intBillDetailId
		INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
		WHERE CRD.intBillDetailId IS NOT NULL
		  AND B.ysnPosted <> @ysnPost
		FOR XML PATH ('')
	) C (intBillId)

	IF ISNULL(@strBillIds, '') <> ''
		BEGIN
			print 1
			--EXEC uspAPPostBill @param = @strBillIds, @post = @ysnPost, @userId = @intEntityId, @success = @ysnSuccess OUT, @batchIdUsed = @strBatchIdUsed OUT
		END
	ELSE
		SET @ysnSuccess = ISNULL(@ysnSuccess, 1)	

	SET @ysnSuccess = ISNULL(@ysnSuccess, 0)

	Select @ysnSuccess=1

	IF ISNULL(@ysnSuccess, 0) = 1
		BEGIN
			SET @strErrorMsg = CASE WHEN @ysnPost = 1 THEN 'Successfully Posted!' ELSE 'Successfully Unposted!' END

			UPDATE CR
			SET ysnPosted	= CASE WHEN @ysnPost = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , dtmPostDate	= CASE WHEN @ysnPost = 1 THEN @dtmDateToday ELSE NULL END
			FROM tblQMCatalogueReconciliation CR
			INNER JOIN #CATRECON CATRECON ON CR.intCatalogueReconciliationId = CATRECON.intCatalogueReconciliationId
			
			--ADUIT LOG
			DECLARE @auditLog AS BatchAuditLogParam

			INSERT INTO @auditLog (
				  [Id]
				, [Namespace]
				, [Action]
				, [Description]
				, [From]
				, [To]
				, [EntityId]
			)
			SELECT [Id]				= intCatalogueReconciliationId
				, [Namespace]		= 'Quality.view.CatalogueReconciliation'
				, [Action]			= CASE WHEN @ysnPost = 1 THEN 'Posted' ELSE 'Unposted' END 
				, [Description]		= ''
				, [From]			= ''
				, [To]				= strReconciliationNumber
				, [EntityId]		= @intEntityId
			FROM #CATRECON

			IF EXISTS (SELECT TOP 1 NULL FROM @auditLog)
				EXEC dbo.uspSMBatchAuditLog @AuditLogParam 	= @auditLog
										  , @EntityId		= @intEntityId
		END
	ELSE
		BEGIN
			SELECT TOP 1 @strErrorMsg = strMessage
			FROM tblAPPostResult AP
			INNER JOIN fnGetRowsFromDelimitedValues(@strBillIds) V ON AP.intTransactionId = V.intID
			WHERE strBatchNumber = @strBatchIdUsed

			--IF ISNULL(@strErrorMsg, '') = ''
			--	SET @strErrorMsg = 'Posting Voucher failed!'
		END

	IF OBJECT_ID('tempdb..#CATRECON') IS NOT NULL DROP TABLE #CATRECON

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH