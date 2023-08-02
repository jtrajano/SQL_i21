CREATE PROCEDURE [dbo].[uspLGUpdateNotifyPartyGroup]
	@intContractHeaderId AS INT,
	@intUserId AS INT
AS
BEGIN TRY
DECLARE @strOrigin AS NVARCHAR(50),
		@strSubLocation AS NVARCHAR(50),
		@strDestinationPort AS NVARCHAR(50),
		@intContractDetailId AS INT,
		@intLoadId AS INT,
		@intNotifyPartyCount AS INT,
		@strErrMsg NVARCHAR(MAX)

IF OBJECT_ID('tempdb.dbo.#tmpContractDetail') IS NOT NULL
	DROP TABLE #tmpContractDetail

CREATE TABLE #tmpContractDetail (
	strOrigin NVARCHAR(50),
	strSubLocation NVARCHAR(50),
	strDestinationPort NVARCHAR(50),
	intContractDetailId INT,
);

INSERT INTO #tmpContractDetail
SELECT
	strOrigin,
	strSubLocationName,
	strDestinationPoint,
	intContractDetailId
FROM vyuCTGridContractDetail
WHERE intContractHeaderId = @intContractHeaderId

-- Declare variables for iterating through the temp table
DECLARE @RowCount INT, @CurrentRow INT = 1;

-- Get the total number of rows in the temp table
SELECT @RowCount = COUNT(*) FROM #tmpContractDetail;


-- Start the loop
WHILE @CurrentRow <= @RowCount
BEGIN
    ;WITH CTE AS (
        SELECT *, ROW_NUMBER() OVER (ORDER BY intContractDetailId) AS RowNum
        FROM #tmpContractDetail
    )
    
    SELECT 
		@intContractDetailId = intContractDetailId,
		@strOrigin = strOrigin,
		@strSubLocation = strSubLocation,
		@strDestinationPort = strDestinationPort
    FROM CTE
    WHERE RowNum = @CurrentRow;

	SELECT @intLoadId = intLoadId
	FROM tblLGLoadDetail
	WHERE intPContractDetailId  = @intContractDetailId

	SELECT @intNotifyPartyCount = COUNT(*) 
	FROM vyuLGNotifyPartyGroupView
	WHERE
		strOriginCountry = @strOrigin AND
		strSubLocationName = @strSubLocation AND
		strDestinationPort = @strDestinationPort

	-- Validate if the Load is not Posted or Cancelled
	IF EXISTS (
		SELECT intShipmentStatus 
		FROM tblLGLoad 
		WHERE 
			intLoadId = @intLoadId AND 
			(ISNULL(ysnPosted, 0) = 1 OR
			ISNULL(ysnCancelled, 0) = 1)
	)
	BEGIN
		SET @CurrentRow = @CurrentRow + 1;
		CONTINUE;
	END

	IF (@intNotifyPartyCount > 0)
	BEGIN
		DELETE 
		FROM tblLGLoadNotifyParties 
		WHERE intLoadId = @intLoadId;

		INSERT INTO tblLGLoadNotifyParties (
			[intConcurrencyId],
			[intLoadId],
			[strNotifyOrConsignee],
			[strType],
			[intEntityId],
			[intCompanySetupID],
			[intBankId],
			[intEntityLocationId],
			[intCompanyLocationId]
		)
		SELECT 
			[intConcurrencyId],
			[intLoadId] = @intLoadId,
			[strNotifyOrConsignee],
			[strType],
			[intEntityId],
			[intCompanySetupID],
			[intBankId],
			[intEntityLocationId],
			[intCompanyLocationId]
		FROM vyuLGNotifyPartyGroupView
		WHERE
			strOriginCountry = @strOrigin AND
			strSubLocationName = @strSubLocation AND
			strDestinationPort = @strDestinationPort

		EXEC uspSMAuditLog
        @keyValue = @intLoadId,                                     -- Primary Key Value
        @screenName = 'Logistics.view.ShipmentSchedule',            -- Screen Namespace
        @entityId = @intUserId,                                     -- Entity Id.
        @actionType = 'Processed',                                  -- Action Type (Processed, Posted, Unposted and etc.)
        @changeDescription = 'Updated Notify Parties from Contracts'-- Description
	END

    -- Increment the current row counter
    SET @CurrentRow = @CurrentRow + 1;
END

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH