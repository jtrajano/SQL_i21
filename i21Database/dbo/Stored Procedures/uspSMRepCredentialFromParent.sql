

CREATE  PROCEDURE [dbo].[uspSMRepCredentialFromParent]
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

		DECLARE @intMultiCompanyParentId int;
		DECLARE @strParentDB nvarchar(100);
		select @intMultiCompanyParentId = intMultiCompanyParentId from tblSMMultiCompany Where strDatabaseName = DB_NAME()
		SELECT @strParentDB = strDatabaseName  from tblSMMultiCompany Where intMultiCompanyId  =  @intMultiCompanyParentId;


			IF @strParentDB IS Not NULL
				BEGIN 
					CREATE  TABLE tblTemporary(
						intId int IDENTITY(1, 1) primary key,
						strQuery nvarchar(max)
					)
						
						DECLARE @sql nvarchar(max) = N'';		
						DECLARE @TableCount int ;
						DECLARE @tempQuery nvarchar(max) = N'';
						DEClARE @queryId int;


						SET  @sql = N'
									DECLARE @strPassword nvarchar(max) 
									DECLARE @strDecryptedPassword nvarchar(max)			
									SET  @strDecryptedPassword =  [@ParentDB].[dbo].fnAESDecryptASym(N''''@password'''')

									EXEC [dbo].[uspSMRepEncryptPassword] 
										@strPassword = @strDecryptedPassword,
										@strEnryptedPassword = @strPassword OUT;

									UPDATE tblEMEntityCredential SET strPassword = @strPassword  WHERE intEntityCredentialId=@id 
									--SELECT	@strPassword	
									';
							
						SET @sql = Replace('INSERT INTO tblTemporary
						SELECT Replace (Replace( N''@sqlReplace'', ''@password'', strPassword ),''@id'', intEntityCredentialId) from [@ParentDB].[dbo].tblEMEntityCredential','@sqlReplace', @sql )
						
						
						SET @sql = Replace( @sql, '@ParentDB', 'RC174001' )
						EXEC ( @sql )

						SELECT @TableCount = COUNT(1) from tblTemporary
						WHILE @TableCount > 0 
						BEGIN

							SELECT Top 1 @queryId = intId from tblTemporary 
							SELECT Top 1 @tempQuery = strQuery from tblTemporary
							
							EXEC (@tempQuery)
						

							DELETE 	tblTemporary WHERE intId = @queryId
							SELECT @TableCount = COUNT(1) from tblTemporary
							
						END

					DROP  TABLE tblTemporary

				END
END