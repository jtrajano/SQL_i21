

CREATE  PROCEDURE [dbo].[uspSMRepCredentialFromParent]
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @intMultiCompanyParentId int;
				DECLARE @strSubsidiaryDB nvarchar(100);
				select @intMultiCompanyParentId = intMultiCompanyParentId from tblSMMultiCompany Where strDatabaseName = DB_NAME()
				SELECT TOP 1 @strSubsidiaryDB = strDatabaseName  from tblSMMultiCompany  order by intMultiCompanyId desc;


					IF @strSubsidiaryDB IS Not NULL
						BEGIN 
							DECLARE @tblTemporaryExist int;
							SELECT @tblTemporaryExist = Object_Id('tblTemporary')
								IF(@tblTemporaryExist IS NULL)
								BEGIN
									CREATE  TABLE tblTemporary(
										intId int IDENTITY(1, 1) primary key,
										strQuery nvarchar(max)
									)
								END
								
								DECLARE @sql nvarchar(max) = N'';		
								DECLARE @TableCount int ;
								DECLARE @tempQuery nvarchar(max) = N'';
								DEClARE @queryId int;


								SET  @sql = N'
											DECLARE @strPassword nvarchar(max) 
											DECLARE @strDecryptedPassword nvarchar(max)			
											SET  @strDecryptedPassword =  [dbo].fnAESDecryptASym(N''''@password'''')
										--	SELECT @strDecryptedPassword
											EXEC [@subsidiary].[dbo].[uspSMRepEncryptPassword] 
												@strPassword = @strDecryptedPassword,
												@strEnryptedPassword = @strPassword OUT;
											IF @strPassword is not Null
											BEGIN
												UPDATE [@subsidiary].dbo.tblEMEntityCredential SET strPassword = @strPassword  WHERE intEntityCredentialId=@id 
											END
											--SELECT	@strPassword	
											';
									
								SET @sql = Replace('INSERT INTO tblTemporary
								SELECT Replace (Replace( N''@sqlReplace'', ''@password'', strPassword ),''@id'', intEntityCredentialId) from [dbo].tblEMEntityCredential
						','@sqlReplace', @sql )
								

								
								SET @sql = Replace( @sql, '@subsidiary', @strSubsidiaryDB )
								
								
							--	SELECT (@sql)
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

								IF(@tblTemporaryExist IS NOT NULL)
								BEGIN
									DROP  TABLE tblTemporary

								END
							

							DECLARE @updateStatusQuery nvarchar(max) = N'UPDATE @Parent.dbo.tblSMRepInitStatus SET intStatus = 2';
						
							
							
						END
END
