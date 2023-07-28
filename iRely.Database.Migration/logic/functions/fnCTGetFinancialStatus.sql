--liquibase formatted sql

-- changeset Von:fnCTGetFinancialStatus.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetFinancialStatus]
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



