CREATE PROCEDURE [dbo].[uspARUpdateCompanyLocationFreightTerm]
	@intFreightTermId	INT = NULL
AS

IF ((ISNULL(@intFreightTermId, 0) = 0) OR NOT EXISTS (SELECT TOP 1 NULL FROM tblSMFreightTerms WHERE intFreightTermId = @intFreightTermId))
	BEGIN
		RAISERROR('Freight Term is not defined.', 16, 1)
		RETURN;
	END

UPDATE EL
SET EL.intFreightTermId = @intFreightTermId
FROM tblEMEntityLocation EL
INNER JOIN tblARCustomer C ON EL.intEntityId = C.intEntityId