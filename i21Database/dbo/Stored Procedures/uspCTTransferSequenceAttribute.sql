CREATE PROCEDURE [dbo].[uspCTTransferSequenceAttribute]
	
	@intFromContractDetailId	INT,
	@intToContractDetailId		INT,
	@intUserId					INT

AS

BEGIN TRY
	
	DECLARE @SQL NVARCHAR(MAX) = '',
			@ErrMsg  NVARCHAR(MAX)

	EXEC uspQMTransferContractSample @intFromContractDetailId, @intToContractDetailId, @intUserId
	EXEC uspLGTransferContractLoads @intFromContractDetailId, @intToContractDetailId, @intUserId

END TRY
BEGIN CATCH       
	SET @ErrMsg = ERROR_MESSAGE()      
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')      
END CATCH