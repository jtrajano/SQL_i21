CREATE PROCEDURE dbo.uspCTUndoShortCloseContractSequence
	@intContractDetailId INT,
	@intUserId INT
AS
BEGIN

DECLARE @AllowShortClosing BIT
DECLARE @OriginalStatusId INT
DECLARE @intContractHeaderId INT

SELECT TOP 1 @AllowShortClosing = ysnAllowAutoShortCloseFutureTypeContracts
FROM tblCTCompanyPreference

SELECT @OriginalStatusId = intContractStatusId, @intContractHeaderId = intContractHeaderId
FROM tblCTContractDetail
WHERE intContractDetailId = @intContractDetailId

IF (@OriginalStatusId = 6 AND @AllowShortClosing = 1)
BEGIN
	UPDATE tblCTContractDetail
	SET intContractStatusId = 1, ysnAutoShortClosed = 0
	WHERE intContractDetailId = @intContractDetailId

	DECLARE @strOldStatus NVARCHAR(50)
	DECLARE @strNewStatus NVARCHAR(50)

	SELECT @strOldStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = @OriginalStatusId;
	SELECT @strNewStatus = strContractStatus FROM tblCTContractStatus WHERE intContractStatusId = 1;

	DECLARE @Details NVARCHAR(2000)
	SET @Details = '{"change": "tblCTContractDetails","children": [{"action": "Updated","change": "Updated - Record: ' + CONVERT(NVARCHAR(20), @intContractDetailId)+ '","iconCls": "small-tree-modified","children": [{"change": "Contract Status","from": "' + @strOldStatus + '","to": "' + @strNewStatus + ' ","leaf": true,"iconCls": "small-gear"}]}],"iconCls":"small-tree-grid"}';
	
	EXEC	dbo.uspSMAuditLog
			@keyValue				= @intContractHeaderId,				
			@screenName				= 'ContractManagement.view.Contract', 
			@entityId				= @intUserId,	
			@actionType				= 'Updated',
			@actionIcon				= 'small-tree-modified',
			@changeDescription		= '',
			@fromValue				= '',
			@toValue				= '',
			@details				= @Details 		

	EXEC	uspCTCreateDetailHistory	@intContractHeaderId 	= NULL,--@intContractHeaderId,
										@intContractDetailId	= @intContractDetailId,
										@strSource 				= 'Contract',
										@strProcess 			= 'Update Sequence Status',
										@intUserId				= @intUserId

END

END