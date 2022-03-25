CREATE PROCEDURE uspRKAutoAssignDerivative
	@strContractNumber NVARCHAR(100) 
	, @strContractSequence NVARCHAR(100)
	, @intFutOptTransactionId INT
	, @strInternalTradeNo NVARCHAR(100)
	, @dblAssignedLots NUMERIC(18,6)
	, @strResultOutput NVARCHAR(MAX) OUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY


DECLARE @dblToBeAssignedLots NUMERIC(18,6)
	,@intContractDetailId INT = NULL
	, @intContractHeaderId INT = NULL
	,@dtmCurrentDate DATETIME  = GETDATE()

select
	@dblToBeAssignedLots = dblToBeAssignedLots
	,@intContractDetailId = intContractDetailId
	,@intContractHeaderId = intContractHeaderId
from vyuRKGetAssignPhysicalTransaction where strContractNumber = @strContractNumber and intContractSeq = @strContractSequence


IF @dblAssignedLots <= @dblToBeAssignedLots
BEGIN
	EXEC uspRKFutOptAssignedSave 
		@intContractDetailId 
		,@dtmCurrentDate
		,@intFutOptTransactionId 
		,@dblAssignedLots
		,@intContractHeaderId 
		,@strContractSequence
		,@strContractNumber 

	SET @strResultOutput = 'Derivative ' + @strInternalTradeNo +' was successfully assigned to Contract ' + @strContractNumber + '-'+ @strContractSequence + '.'

END


END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
