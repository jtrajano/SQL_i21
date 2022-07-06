CREATE PROCEDURE [dbo].[uspLGBatchUpdateDates]
	@strLoadIds NVARCHAR(MAX)
	,@strDateField NVARCHAR(200)
	,@intAddDays AS INT
	,@dtmSetDate AS DATETIME
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @xmlLoads XML
		,@intLoadId INT
		,@dtmOldDate DATETIME
		,@dtmNewDate DATETIME
		,@strDateFieldName NVARCHAR(200)

SELECT @xmlLoads = CAST('<A>'+ REPLACE(@strLoadIds, ',', '</A><A>')+ '</A>' AS XML) 

--Parse the Loads Parameter to Temporary Table
SELECT RTRIM(LTRIM(T.value('.', 'INT'))) AS intLoadId
INTO #tmpLoads
FROM @xmlLoads.nodes('/A') AS X(T) 
WHERE RTRIM(LTRIM(T.value('.', 'INT'))) > 0

/* Declare Audit Log variables */
DECLARE @intLogId INT
	,@intTransactionId INT
	,@intLoadAuditParentId INT
	,@intContainerAuditParentId INT
	,@intContainerUpdatedAuditParentId INT

/* Get field name to update */
SELECT @strDateFieldName = CASE (@strDateField)
	WHEN 'Insurance Declaration' THEN 'dtmInsuranceDeclaration'
	WHEN 'ETA POD' THEN 'dtmETAPOD'
	ELSE '' END

/* Loop through each Load */
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpLoads)
BEGIN
	SELECT TOP 1 
		@intLoadId = intLoadId 
		,@dtmOldDate = NULL	
		,@dtmNewDate = NULL
	FROM #tmpLoads

	/* Get the current date */
	SELECT @dtmOldDate = CASE @strDateField 
		WHEN 'Insurance Declaration' THEN dtmInsuranceDeclaration
		WHEN 'ETA POD' THEN dtmETAPOD
		ELSE NULL END
	FROM tblLGLoad L
	WHERE intLoadId = @intLoadId

	/* Calculate the new date */
	IF (@intAddDays IS NOT NULL AND @intAddDays <> 0 AND @dtmOldDate IS NOT NULL)
		SET @dtmNewDate = DATEADD(DD, @intAddDays, @dtmOldDate)
	ELSE IF (@dtmSetDate IS NOT NULL)
		SET @dtmNewDate = @dtmSetDate

	/* If new date is calculated and is not the same as old date, proceed with update */
	IF (@dtmNewDate IS NOT NULL AND (@dtmOldDate IS NULL OR @dtmOldDate <> @dtmNewDate))
	BEGIN
		IF (@strDateField = 'Insurance Declaration')
			UPDATE tblLGLoad SET dtmInsuranceDeclaration = @dtmNewDate WHERE intLoadId = @intLoadId
		ELSE IF (@strDateField = 'ETA POD') 
			UPDATE tblLGLoad SET dtmETAPOD = @dtmNewDate WHERE intLoadId = @intLoadId

		/* Insert to Audit Log */
		--Get Transaction Id
		EXEC uspSMInsertTransaction @screenNamespace = 'Logistics.view.ShipmentSchedule', @intKeyValue = @intLoadId, @output = @intTransactionId OUTPUT

		--Insert to SM Log
		INSERT INTO tblSMLog (strType, dtmDate, intEntityId, intTransactionId, intConcurrencyId) 
		VALUES('Audit', GETUTCDATE(), @intUserId, @intTransactionId, 1)
		SET @intLogId = SCOPE_IDENTITY()

		--Insert Load parent Audit entry
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strAction, strChange, intConcurrencyId)
		SELECT @intLogId, @intLoadId, 'Updated', ('Updated (from Batch Update Dates) - Record: ' + CAST(@intLoadId AS nvarchar(20))), 1
			SET @intLoadAuditParentId = SCOPE_IDENTITY()

		--Insert Load child Audit entry
		INSERT INTO tblSMAudit (intLogId, intKeyValue, strChange, strFrom, strTo, strAlias, ysnField, ysnHidden, intParentAuditId, intConcurrencyId)
		SELECT @intLogId, @intLoadId, @strDateFieldName, @dtmOldDate, @dtmNewDate, @strDateField, 1, 0, @intLoadAuditParentId, 1

	END

	/* Loop control */
	DELETE FROM #tmpLoads WHERE intLoadId = @intLoadId

END

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpLoads')) DROP TABLE #tmpLoads

GO