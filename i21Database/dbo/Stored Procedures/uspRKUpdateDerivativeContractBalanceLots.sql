CREATE PROCEDURE [dbo].[uspRKUpdateDerivativeContractBalanceLots]
	@intFutOptTransactionId INT 
	,@strType NVARCHAR(50)  --Sale or Purchase
	,@dblBalanceLots  NUMERIC(18,6) = 0

AS


SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @ysnLocked BIT

	SELECT  @ysnLocked = dbo.fnRKIsDerivativeLocked(@intFutOptTransactionId, 'Assign Derivatives')
		--ISNULL(ysnLocked,0) FROM vyuRKFutOptTranForNotMapping WHERE intFutOptTransactionId = @intFutOptTransactionId

	IF @ysnLocked = 0
	BEGIN

		IF @strType = 'Sale'
		BEGIN
			UPDATE tblRKFutOptTransaction SET dblSContractBalanceLots = ISNULL(dblSContractBalanceLots,0) + @dblBalanceLots WHERE intFutOptTransactionId = @intFutOptTransactionId
		END
	
		IF @strType = 'Purchase'
		BEGIN
			UPDATE tblRKFutOptTransaction SET dblPContractBalanceLots = ISNULL(dblPContractBalanceLots,0) + @dblBalanceLots WHERE intFutOptTransactionId = @intFutOptTransactionId
		END
	END
END
