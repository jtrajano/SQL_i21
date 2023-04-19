CREATE PROCEDURE [dbo].[uspLGCancelAllocation]
	 @intAllocationHeaderId INT,
	 @ysnCancel BIT = 0,
	 @UserId INT = NULL
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE	@intAllocationDetailId AS INT
	DECLARE	@intSContractHeaderId AS INT
	DECLARE	@intSContractDetailId AS INT
	DECLARE	@intPContractHeaderId AS INT
	DECLARE	@intPContractDetailId AS INT
	DECLARE	@dblQuantity AS NUMERIC(18,6)
	DECLARE	@intScreenId AS INT
	DECLARE @ysnCancelled AS BIT

	-- Validate if the Cancellation/Reversal is valid
	SELECT @ysnCancelled = ysnCancelled FROM tblLGAllocationHeader WHERE @intAllocationHeaderId = intAllocationHeaderId
	IF (ISNULL(@ysnCancelled, 0) = ISNULL(@ysnCancel, 0))
	BEGIN
		RETURN
	END	

	-- Validate if the LS associated with the Allocation, if it exists, is cancelled
	IF EXISTS (
		SELECT L.strLoadNumber 
		FROM tblLGAllocationHeader AH
		INNER JOIN tblLGAllocationDetail AD ON AD.intAllocationHeaderId = AH.intAllocationHeaderId
		INNER JOIN tblLGLoadDetail LD ON LD.intAllocationDetailId = AD.intAllocationDetailId
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE AH.intAllocationHeaderId = @intAllocationHeaderId AND L.intShipmentStatus != 10
	)
	BEGIN
		RAISERROR('Cannot cancel the Allocation. The Load associated with it is being used. Try cancelling the Load first.', 16, 1)  
	END

	If(OBJECT_ID('tempdb..#temp') Is Not Null)
	Begin
		Drop Table #Temp
	End

	CREATE TABLE #Temp
	(
		intRowNum INT,
		intAllocationDetailId INT,
		intSContractHeaderId INT,
		intSContractDetailId INT, 
		intPContractHeaderId INT, 
		intPContractDetailId INT, 
		dblQuantity NUMERIC(18,6)
	)

	INSERT INTO #Temp
	SELECT 
		DISTINCT ROW_NUMBER() over(order by intAllocationHeaderId) AS intRowNum,
		intAllocationDetailId,
		intSContractHeaderId,
		intSContractDetailId,
		intPContractHeaderId,
		intPContractDetailId,
		dblSDetailQuantity
	FROM vyuLGAllocationDetails
	WHERE intAllocationHeaderId = @intAllocationHeaderId
  
	DECLARE @Counter INT , @MaxRNum INT
	SELECT
		@Counter = min(intRowNum),
		@MaxRNum = max(intRowNum)
	FROM #Temp  

	SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'Logistics.view.Allocation'
   
	WHILE(@Counter IS NOT NULL AND @Counter <= @MaxRNum)  
	BEGIN  
		SELECT 
			@intAllocationDetailId = intAllocationDetailId,
			@intSContractHeaderId = intSContractHeaderId,
			@intSContractDetailId = intSContractDetailId,
			@intPContractHeaderId = intPContractHeaderId,
			@intPContractDetailId = intPContractDetailId,
			@dblQuantity = dblQuantity
		FROM #Temp WHERE intRowNum = @Counter  

		IF (@ysnCancel = 1)
		BEGIN
			SET @dblQuantity = @dblQuantity * -1
			EXEC dbo.[uspCTUpdateAllocatedQuantity]
				@intContractDetailId = @intSContractDetailId,
				@dblQuantityToUpdate = @dblQuantity,
				@intUserId = @UserId,
				@intExternalId = @intAllocationDetailId,
				@strScreenName = 'Allocation'

			DELETE FROM tblSMInterCompanyMapping WHERE intCurrentTransactionId = @intPContractDetailId AND intReferenceTransactionId = @intSContractDetailId AND intScreenId = @intScreenId

			UPDATE tblLGAllocationHeader
			SET ysnCancelled = 1
			WHERE intAllocationHeaderId = @intAllocationHeaderId

			EXEC uspSMAuditLog
				@keyValue = @intAllocationHeaderId,
				@screenName = 'Logistics.view.Allocation',
				@entityId = @UserId,
				@actionType = 'Cancelled'
		END
		ELSE
		BEGIN
			EXEC dbo.[uspCTUpdateAllocatedQuantity]
				@intContractDetailId = @intSContractDetailId,
				@dblQuantityToUpdate = @dblQuantity,
				@intUserId = @UserId,
				@intExternalId = @intAllocationDetailId,
				@strScreenName = 'Allocation'

			EXEC [dbo].[uspSMInterCompanyUpdateMapping] 
				@currentTransactionId = @intPContractHeaderId,
				@referenceTransactionId = @intSContractHeaderId,
				@referenceCompanyId = NULL,
				@screenId = @intScreenId,
				@populatedByInterCompany = 0

			UPDATE tblLGAllocationHeader
			SET ysnCancelled = 0
			WHERE intAllocationHeaderId = @intAllocationHeaderId

			EXEC uspSMAuditLog
				@keyValue = @intAllocationHeaderId,
				@screenName = 'Logistics.view.Allocation',
				@entityId = @UserId,
				@actionType = 'Reverse Cancelled'
		END

		SET @Counter = @Counter  + 1
	END  

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH