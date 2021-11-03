CREATE PROCEDURE dbo.uspPRImportOriginEmployeeEarning(
    @ysnDoImport BIT = 0,
	@intRecordCount INT = 0 OUTPUT
)

AS

BEGIN

SELECT * FROM tblPREmployeeEarning

END

GO