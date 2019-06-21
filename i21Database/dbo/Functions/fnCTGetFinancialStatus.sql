CREATE FUNCTION [dbo].[fnCTGetFinancialStatus]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	strFinancialStatus	NVARCHAR(100)  COLLATE Latin1_General_CI_AS
)
AS
BEGIN
	INSERT INTO @returntable
	SELECT TOP 1 strStatus
	FROM vyuARContractFinancialStatus
	WHERE intContractDetailId = @intContractDetailId
	ORDER BY intInvoiceId DESC
		
	RETURN;
END