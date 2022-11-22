CREATE PROCEDURE uspQMPostCatalogueReconciliation
      @intCatalogueReconciliationId     INT
    , @intEntityId                      INT = NULL
    , @ysnPost                          BIT = 0
AS
BEGIN TRY
	BEGIN TRANSACTION

    DECLARE @dtmDateToday   DATETIME = CAST(GETDATE() AS DATE)

    IF OBJECT_ID('tempdb..#CATRECON') IS NOT NULL DROP TABLE #CATRECON
	CREATE TABLE #CATRECON (
		  intCatalogueReconciliationId		INT PRIMARY KEY
        , strReconciliationNumber           NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	)

    INSERT INTO #CATRECON
    SELECT intCatalogueReconciliationId	= CR.intCatalogueReconciliationId
         , strReconciliationNumber      = CR.strReconciliationNumber
    FROM tblQMCatalogueReconciliation CR
    WHERE intCatalogueReconciliationId = @intCatalogueReconciliationId

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

	IF OBJECT_ID('tempdb..#CATRECON') IS NOT NULL DROP TABLE #CATRECON

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH