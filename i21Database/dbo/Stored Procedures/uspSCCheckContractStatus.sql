CREATE PROCEDURE [dbo].[uspSCCheckContractStatus]
	@intContractDetailId int 
AS

	declare @intContractStatusId int
	declare @intContractHeaderId INT
	DECLARE @intContractSeq INT
	DECLARE @strContractStatus NVARCHAR(40)
	DECLARE @strContractNumber NVARCHAR(50)
	DECLARE @ErrorMessage nvarchar(500)
	
	select @intContractStatusId = intContractStatusId 
			, @intContractHeaderId = intContractHeaderId
			, @intContractSeq = intContractSeq
		from tblCTContractDetail 
			where intContractDetailId = @intContractDetailId


	

	SELECT @intContractStatusId = intContractStatusId
			, @strContractStatus = strContractStatus 
			, @intContractSeq = intContractSeq
			, @strContractNumber = strContractNumber 
			from vyuCTContractDetailView WHERE intContractDetailId = @intContractDetailId
	IF ISNULL(@intContractStatusId, 0) = 6--!= 1 AND ISNULL(@intContractStatusId, 0) != 4
	BEGIN
		SET @ErrorMessage = 'Contract ' + @strContractNumber +'-Seq.' + CAST(@intContractSeq AS nvarchar) + ' is ' + @strContractStatus +'. Please Open contract sequence in order to use it.';
		RAISERROR(@ErrorMessage, 11, 1);
		RETURN;
	END

	-- IF( isnull(@intContractStatusId, 0)) = 6 --SHORT-CLOSED
	-- BEGIN

	-- 	DECLARE @strContractNumber NVARCHAR(50)
	-- 	DECLARE @ErrorMessage nvarchar(500)

	-- 	set @ErrorMessage = 'Contract '+ @strContractNumber +'-sequence '+ CAST(@intContractSeq AS NVARCHAR(50)) +' has been short-closed.  Please reopen contract sequence in order to use it.'
	-- 	SELECT @strContractNumber = strContractNumber
	-- 			FROM tblCTContractHeader
	-- 			WHERE intContractHeaderId = @intContractHeaderId		

	-- 	RAISERROR(@ErrorMessage,16,1,1)
	-- 	RETURN 0;
	-- END

RETURN 1
