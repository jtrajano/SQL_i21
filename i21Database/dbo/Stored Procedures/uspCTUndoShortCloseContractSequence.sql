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

IF (@OriginalStatusId IN (6, 4) AND @AllowShortClosing = 1)
BEGIN
	UPDATE tblCTContractDetail
	SET intContractStatusId = 4, ysnAutoShortClosed = 0
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

	BEGIN TRY
		DECLARE @SingleAuditLogParam SingleAuditLogParam
		INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
				SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@intContractHeaderId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
				UNION ALL
				SELECT 2, '', '', 'tblCTContractDetails', NULL, NULL, NULL, NULL, NULL, 1
				UNION ALL
				SELECT 3, '', 'Updated', 'Updated - Record: ' + CONVERT(NVARCHAR(20), @intContractDetailId), NULL, NULL, NULL, NULL, NULL, 2
				UNION ALL
				SELECT 4, '', '', 'Contract Status', @strOldStatus, @strNewStatus, NULL, NULL, NULL, 3

		EXEC uspSMSingleAuditLog 
			@screenName     = 'ContractManagement.view.Contract',
			@recordId       = @intContractHeaderId,
			@entityId       = @intUserId,
			@AuditLogParam  = @SingleAuditLogParam
	END TRY
	BEGIN CATCH
	END CATCH

	EXEC	uspCTCreateDetailHistory	@intContractHeaderId 	= NULL,--@intContractHeaderId,
										@intContractDetailId	= @intContractDetailId,
										@strSource 				= 'Contract',
										@strProcess 			= 'Update Sequence Status',
										@intUserId				= @intUserId

	DECLARE @XML NVARCHAR(4000)
	SET @XML = '<tblCTContractDetails><tblCTContractDetail><intContractDetailId>' 
		+ CAST(@intContractDetailId AS NVARCHAR(1000)) 
		+ '</intContractDetailId><strRowState>Modified</strRowState></tblCTContractDetail></tblCTContractDetails>'
	EXEC uspCTBeforeSaveContract @intContractHeaderId, @intUserId, @XML

	DECLARE @XML2 NVARCHAR(4000)
	SET @XML2 = '<tblCTContractHeaders><tblCTContractHeader><intContractHeaderId>' + CAST(@intContractHeaderId AS NVARCHAR(1000)) 
		+ '</intContractHeaderId></tblCTContractHeader></tblCTContractHeaders>'
	EXEC uspCTValidateContractHeader @XML2, 'Modified'

	EXEC uspCTSaveContract @intContractHeaderId, @intUserId, ''

	EXEC uspCTValidateContractAfterSave @intContractHeaderId

	UPDATE tblCTContractDetail
	SET intContractStatusId = 1, ysnAutoShortClosed = 0
	WHERE intContractDetailId = @intContractDetailId
END

END