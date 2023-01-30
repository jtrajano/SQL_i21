CREATE PROCEDURE uspQMClearTIN
	  @strTINIds	NVARCHAR(200) = NULL
	, @intEntityId	INT
AS

BEGIN TRY
	BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#TIN') IS NOT NULL DROP TABLE #TIN
	CREATE TABLE #TIN (
		  intTINClearanceId		INT PRIMARY KEY
		, intBatchId			INT NULL
		, strBatchId			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

	SET @strTINIds = NULLIF(@strTINIds, '')

	IF @strTINIds IS NOT NULL
		BEGIN
			INSERT INTO #TIN
			SELECT intTINClearanceId	= TIN.intTINClearanceId
				 , intBatchId			= TIN.intBatchId
				 , strBatchId			= B.strBatchId	
			FROM tblQMTINClearance TIN
			INNER JOIN fnGetRowsFromDelimitedValues(@strTINIds) ID ON TIN.intTINClearanceId = ID.intID
			LEFT JOIN tblMFLotInventory LI on LI.intBatchId =TIN.intBatchId
			LEFT JOIN tblICLot L on L.intLotId =LI.intLotId 
			LEFT JOIN tblMFBatch B ON B.intBatchId = TIN.intBatchId
			WHERE ISNULL(L.dblQty, 0) = 0 AND L.intLotId IS NOT NULL
		END
	ELSE
		BEGIN
			INSERT INTO #TIN
			SELECT intTINClearanceId	= TIN.intTINClearanceId
				 , intBatchId			= TIN.intBatchId
				 , strBatchId			= B.strBatchId	
			FROM tblQMTINClearance TIN
			LEFT JOIN tblMFLotInventory LI on LI.intBatchId =TIN.intBatchId
			LEFT JOIN tblICLot L on L.intLotId =LI.intLotId
			LEFT JOIN tblMFBatch B ON B.intBatchId = TIN.intBatchId
			WHERE ISNULL(L.dblQty, 0) = 0 AND L.intLotId IS NOT NULL
		END

	UPDATE TIN
	SET ysnEmpty	= CAST(1 AS BIT)
	  , intBatchId	= NULL
	FROM tblQMTINClearance TIN
	INNER JOIN #TIN TTIN ON TIN.intTINClearanceId = TTIN.intTINClearanceId

	DECLARE @SingleAuditLogParam	SingleAuditLogParam

	WHILE EXISTS (SELECT TOP 1 1 FROM #TIN)
		BEGIN			
			DECLARE @intTINClearanceId		INT = NULL
				  , @strBatchId				NVARCHAR(100) = NULL

			SELECT TOP 1 @intTINClearanceId = intTINClearanceId
					   , @strBatchId		= strBatchId
			FROM #TIN

			DELETE FROM @SingleAuditLogParam
			INSERT INTO @SingleAuditLogParam (
				  [Id]
				, [Action]
				, [Change]
				, [From]
				, [To]
				, [ParentId]
			)
			SELECT [Id]			= 1
				 , [Action]		= 'Clear TIN'
				 , [Change]		= 'Updated - Record: ' + CAST(@intTINClearanceId AS NVARCHAR(100))
				 , [From]		= NULL
				 , [To]			= NULL
				 , [ParentId]	= NULL
			
			UNION ALL

			SELECT [Id]			= 2
				 , [Action]		= NULL
				 , [Change]		= 'Empty'
				 , [From]		= 'False'
				 , [To]			= 'True'
				 , [ParentId]	= 1

			UNION ALL
			
			SELECT [Id]			= 3
				 , [Action]		= NULL
				 , [Change]		= 'Batch Id'
				 , [From]		= @strBatchId
				 , [To]			= NULL
				 , [ParentId]	= 1

			EXEC uspSMSingleAuditLog @screenName = 'Quality.view.TINClearance'
							       , @recordId = @intTINClearanceId
								   , @entityId = @intEntityId
								   , @AuditLogParam = @SingleAuditLogParam

			DELETE FROM #TIN WHERE intTINClearanceId = @intTINClearanceId
		END

	IF OBJECT_ID('tempdb..#TIN') IS NOT NULL DROP TABLE #TIN

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH