-- Note:
-- If TBO location ID is passed in @intLocationId, this SP will delete the batch for both TBO and MU locations
-- If MU location ID is ppased in @intLocation id, this SP will delete only the batch for MU location
CREATE PROCEDURE [dbo].[uspMFDeleteBatch]
(
	@strBatchId			NVARCHAR(50)
  , @intLocationId		INT
  , @ysnSuccess			BIT OUTPUT
  , @strErrorMessage	NVARCHAR(MAX) OUTPUT
)
AS

BEGIN TRY
	BEGIN TRANSACTION 

	-- Start validations
    -- Check if there is an existing load that uses the batch
    DECLARE @strLoadNumber NVARCHAR(50)

    SELECT @strLoadNumber = L.strLoadNumber
    FROM tblLGLoad L
    INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
    INNER JOIN tblMFBatch B ON B.intBatchId = LD.intBatchId
    WHERE B.strBatchId = @strBatchId
    AND (B.intLocationId = @intLocationId OR B.intBuyingCenterLocationId = @intLocationId)

    IF @strLoadNumber IS NOT NULL

    BEGIN
        SET @strErrorMessage = 'Batch ' + @strBatchId + ' is already used in load ' + @strLoadNumber + '. Unable to delete the batch.';
        SET @ysnSuccess = 0
        RETURN -1;
    END
    -- End validation

    -- Set the associated sample's batch ID to blank
    UPDATE S
    SET strBatchNo = NULL
    FROM tblQMSample S
    INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
    WHERE B.strBatchId = @strBatchId
    AND (B.intLocationId = @intLocationId OR B.intBuyingCenterLocationId = @intLocationId)

    -- Delete the actual batch
    DELETE FROM tblMFBatch
    WHERE strBatchId = @strBatchId
    AND (intLocationId = @intLocationId OR intBuyingCenterLocationId = @intLocationId)

    SET @ysnSuccess = 1;


	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	
	DECLARE @msg AS VARCHAR(MAX) = ERROR_MESSAGE()

	ROLLBACK TRANSACTION 

	RAISERROR(@msg, 11, 1) 

END CATCH 
