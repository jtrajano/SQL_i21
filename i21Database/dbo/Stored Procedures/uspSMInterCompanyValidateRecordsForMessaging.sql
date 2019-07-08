CREATE PROCEDURE uspSMInterCompanyValidateRecordsForMessaging
@intInterCompanyMappingId INT

AS
BEGIN
	--START CREATE TEMPOPARY TABLES
	IF OBJECT_ID('tempdb..#TempInterCompanyMapping') IS NOT NULL
		DROP TABLE #TempInterCompanyMapping

	Create TABLE #TempInterCompanyMapping
	(
		[intInterCompanyMappingId]		INT				NOT NULL PRIMARY KEY IDENTITY,
		[intCurrentTransactionId]		[int]			NOT NULL,
		[intReferenceTransactionId]		[int]			NOT NULL,
		[intReferenceCompanyId]			[int]			NULL DEFAULT(0),
	)
	--END CREATE TEMPOPARY TABLES

	DECLARE @intInterCompanyIdToUse INT;
	DECLARE @intCurrentTransactionId INT;
	DECLARE @intReferenceTransactionId INT;
	DECLARE @intReferenceCompanyId INT;
	
	SELECT
		@intInterCompanyIdToUse = intInterCompanyMappingId,
		@intCurrentTransactionId = intCurrentTransactionId,
		@intReferenceTransactionId = intReferenceTransactionId,
		@intReferenceCompanyId = intReferenceCompanyId
	FROM tblSMInterCompanyMapping
	WHERE intInterCompanyMappingId = @intInterCompanyMappingId
		
	IF ISNULL(@intCurrentTransactionId, 0) <> 0 AND ISNULL(@intReferenceTransactionId, 0) <> 0
	BEGIN
		--SAME DATABASE
		IF ISNULL(@intReferenceCompanyId, 0) = 0
		BEGIN
			PRINT('------COPY RECORDS IN THE SAME DATABASE-------')
				
			--A->B, B->A
			EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intCurrentTransactionId, @intReferenceTransactionId
			EXEC dbo.[uspSMInterCompanyCopyMessagingDetails] @intReferenceTransactionId, @intCurrentTransactionId

			--FETCH other records for InterCompanyMapping in the current database
			--B->C
			INSERT INTO #TempInterCompanyMapping(intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId)
			SELECT intInterCompanyMappingId, intCurrentTransactionId, intReferenceTransactionId, intReferenceCompanyId
			FROM tblSMInterCompanyMapping
			WHERE intInterCompanyMappingId <> @intInterCompanyMappingId AND
			intCurrentTransactionId = @intReferenceTransactionId

			WHILE EXISTS(SELECT 1 FROM #TempInterCompanyMapping)
			BEGIN
				SELECT TOP 1 @intInterCompanyIdToUse = intInterCompanyMappingId, @intReferenceCompanyId = intReferenceCompanyId FROM #TempInterCompanyMapping
				
				IF ISNULL(@intReferenceCompanyId, 0) = 0
				BEGIN
					EXEC dbo.[uspSMInterCompanyValidateRecordsForMessaging] @intInterCompanyIdToUse
				END
				ELSE
				BEGIN
					--TODO
					PRINT('------EXECUTE [uspSMInterCompanyValidateRecordsForMessaging] IN THE OTHER DATABASE-------')
				END

				DELETE FROM #TempInterCompanyMapping WHERE intInterCompanyMappingId = @intInterCompanyIdToUse
			END

		END
		ELSE
		BEGIN
			--TODO
			PRINT('------COPY RECORDS IN THE OTHER DATABASE-------')

		END
	END

	RETURN 1


END
