CREATE PROCEDURE [dbo].[uspCRMUpdateOpportunityQuote]
	@SalesOrderId AS INT,
	@OpportunityId AS INT,
	@ForDelete AS BIT
AS
BEGIN

DECLARE @intSalesOrderId INT
	  , @intOpportunityId INT
	  , @ysnForDelete    BIT  

SET @intSalesOrderId = @SalesOrderId
SET @intOpportunityId = @OpportunityId
SET @ysnForDelete = @ForDelete

	IF(@intOpportunityId IS NOT NULL)
	BEGIN
		IF(@ysnForDelete = 1)
		BEGIN
			DELETE FROM tblCRMOpportunityQuote
			WHERE intOpportunityId = @intOpportunityId AND intSalesOrderId = @intSalesOrderId
		END
		ELSE
		BEGIN
			IF(@intSalesOrderId IS NOT NULL)
			BEGIN
				INSERT INTO tblCRMOpportunityQuote(intOpportunityId, intSalesOrderId, intConcurrencyId)
				VALUES(@intOpportunityId, @intSalesOrderId, 1)
			END
		END
	END
END
GO