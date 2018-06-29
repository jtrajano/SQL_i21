CREATE PROCEDURE [dbo].[uspGLConsolidate]
@dtmDate DATETIME
AS
DECLARE @sql NVARCHAR(MAX)

IF object_id('tempdb..##ConsolidateResult') IS NOT NULL
	BEGIN
		DROP TABLE ##ConsolidateResult
	END
	CREATE TABLE ##ConsolidateResult(
			[strCompanyName] [nvarchar](50) NULL,
			[ysnFiscalOpen] [bit] NULL,
			[ysnUnpostedTrans] [bit] NULL,
			[strResult] [nvarchar](1000) NULL
		)

BEGIN TRY
BEGIN TRAN
	
	DECLARE @dbTable TABLE
	(
	DbName NVARCHAR(50),
	Id INT,
	CompanyName NVARCHAR(50)
	)

	DECLARE @intParentId int,@strParentDbName NVARCHAR(50),  @strCompanyName NVARCHAR(50)
	SELECT top 1 @intParentId= intMultiCompanyId , @strParentDbName = strDatabaseName FROM tblSMMultiCompany WHERE intMultiCompanyParentId IS NULL
	
	INSERT INTO @dbTable
	--select * from [dbo].[fnSplitString](@arrDbName, @char)
		SELECT strDatabaseName, intMultiCompanyId, strCompanyName FROM tblSMMultiCompany WHERE intMultiCompanyParentId = @intParentId

	DECLARE @DbName NVARCHAR(50), @CompanyId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM @dbTable)
	BEGIN
		SELECT TOP 1 @DbName= DbName,@CompanyId = Id,@strCompanyName = CompanyName FROM @dbTable
		EXEC dbo.uspGLConsolidateSubsidiary @DbName ,@CompanyId, @dtmDate,@strCompanyName, @strParentDbName
		DELETE FROM @dbTable WHERE Id = @CompanyId
		--EXEC sp_executesql @strCommand
		
	END
	IF @@TRANCOUNT > 0 
		COMMIT TRAN

	SELECT * FROM ##ConsolidateResult
	--SET  IDENTITY_INSERT tblGLAccountCategory OFF
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	Declare @ErrorNumber int
	Declare @ErrorMessage varchar(2000)
	Declare @ErrorSeverity int
	Declare @ErrorState int
	Select @ErrorNumber = Error_Number()
           ,@ErrorMessage = 'Error updating consolidation table :' + Error_message()
           ,@ErrorSeverity= Error_Severity()
           ,@ErrorState = Error_State()
    RaisError (@ErrorMessage, @ErrorSeverity, @ErrorState)
	
END CATCH
