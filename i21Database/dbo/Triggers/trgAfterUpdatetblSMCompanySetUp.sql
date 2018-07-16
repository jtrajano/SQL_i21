CREATE TRIGGER [dbo].[trgAfterUpdatetblSMCompanySetUp]
ON  [dbo].[tblSMCompanySetUp]
AFTER UPDATE
AS 
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
	DECLARE @strCompanyName nvarchar(max);
	SELECT @strCompanyName = strCompanyName from tblSMCompanySetup


	IF @strCompanyName IS NOT NULL
	BEGIN
		UPDATE tblSMMultiCompany SET  strCompanyName = @strCompanyName	WHERE strDatabaseName = DB_NAME();
	END
END