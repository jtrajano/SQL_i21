CREATE PROCEDURE [dbo].[uspTMGetOverageQty]
  @dblQuantity NUMERIC(18,6),
	@intContractDetailId INT = NULL,
	@dblOverage NUMERIC(18,6) = 0 OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN


	DECLARE @dblAvailable DECIMAL(18,6) = NULL

	SELECT @dblAvailable = ISNULL(B.dblBalance,0.0) - ISNULL(B.dblScheduleQty,0.0)
	FROM tblCTContractHeader A
	INNER JOIN vyuCTContractDetail B
		ON A.intContractHeaderId = B.intContractHeaderId
	WHERE B.intContractDetailId = @intContractDetailId
				
	IF(@dblAvailable > 0)
		BEGIN
			SET @dblOverage = @dblQuantity - @dblAvailable
		END
	ELSE
		BEGIN
			SET @dblOverage = @dblQuantity
		END

END