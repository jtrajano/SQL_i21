
CREATE PROCEDURE [dbo].[uspSMReplicateCredential] 
AS

DECLARE @SQLString NVARCHAR(MAX) = '';
DECLARE @ParentDB sysname;
DECLARE @SubsidiaryDB sysname;
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

		--Update [dbo].[tblSMMultiCompany] SET strType = DB_NAME() Where strDatabaseName = DB_NAME();
	
		select @ParentDB = strDatabaseName from tblSMMultiCompany where intMultiCompanyId in ( select intMultiCompanyParentId from  tblSMMultiCompany where strDatabaseName = DB_NAME())
		SET @SubsidiaryDB = DB_NAME();

		SET @SQLString = N'
		USE [@Subsidiary]
	

		CREATE TABLE #tblEMTempCredential
		(
		intEntityCredentialId int, 
		strPassword nvarchar(MAX)
		)

		

		Insert Into #tblEMTempCredential (intEntityCredentialId, strPassword)
				Select intEntityCredentialId, [@Parent].dbo.fnAESDecryptASym(strPassword) from [@Parent].dbo.tblEMEntityCredential

				
		--======================Open symmetric code snnipet=====================
		OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
		DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
		WITH PASSWORD = ''neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY=''


		

			UPDATE
				tblEMEntityCredential
			SET
				strPassword = convert(nvarchar(max),dbo.fnAESEncryptASym(#tblEMTempCredential.strPassword))
			FROM
				#tblEMTempCredential
			INNER JOIN
				tblEMEntityCredential tblCred
			ON 
				-- intEntityId  = tblCred.intEntityCredentialId 
				#tblEMTempCredential.intEntityCredentialId = tblCred.intEntityCredentialId 


		CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

		
		DROP TABLE #tblEMTempCredential
		
		
		';

	SET @SQLString = N'' + Replace(@SQLString, '@Parent', @ParentDB);
	SET @SQLString = N'' + Replace(@SQLString, '@Subsidiary', @SubsidiaryDB);
	

	--SELECT @SQLString;
	EXECUTE sp_executesql @SQLString;


END 

