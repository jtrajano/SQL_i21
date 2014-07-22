GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportAccount')
	DROP PROCEDURE uspARImportAccount
GO


--IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
--BEGIN
	EXEC(
	'CREATE PROCEDURE uspARImportAccount
	@AccountCode NVARCHAR(1) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of ssascmst. This will use to track all accounts already imported
	IF(OBJECT_ID(''dbo.tblARTempAccount'') IS NULL)
		SELECT * INTO tblARTempAccount FROM ssascmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @AccountCode IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM ssascmst WHERE ssasc_code = @AccountCode))
		BEGIN
			UPDATE ssascmst
				SET 
				ssasc_code = Accnt.strAccountStatusCode,
				ssasc_desc = Accnt.strDescription
			FROM tblARAccountStatus Accnt
				WHERE strAccountStatusCode = @AccountCode AND ssasc_code = @AccountCode
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO ssascmst(
				ssasc_code,
				ssasc_desc
			)
			SELECT 
				strAccountStatusCode,
				strDescription
			FROM tblARAccountStatus
			WHERE strAccountStatusCode = @AccountCode
		
	RETURN;
	END


	--================================================
	--     ONE TIME ACCOUNT SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @AccountCode IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Accounts Synchronization''

		DECLARE @originAccountCode		NVARCHAR(1)
		DECLARE @strAccountStatusCode	NVARCHAR (1)
		DECLARE	@strDescription			NVARCHAR (MAX)
	
		DECLARE @Counter INT = 0
	
    
		--Import only those are not yet imported
		SELECT ssasc_code INTO #tmpssascmst 
			FROM ssascmst
		LEFT JOIN tblARAccountStatus
			ON ssascmst.ssasc_code COLLATE Latin1_General_CI_AS = tblARAccountStatus.strAccountStatusCode COLLATE Latin1_General_CI_AS
		WHERE tblARAccountStatus.strAccountStatusCode IS NULL
		ORDER BY ssascmst.ssasc_code

		WHILE (EXISTS(SELECT 1 FROM #tmpssascmst))
		BEGIN
		
			SELECT @originAccountCode = ssasc_code FROM #tmpssascmst

			SELECT TOP 1
				@strAccountStatusCode = ssasc_code,
				@strDescription = ssasc_desc
			FROM ssascmst
			WHERE ssasc_code = @originAccountCode
		
			--Insert into tblARAccountStatus
			INSERT [dbo].[tblARAccountStatus]
			([strAccountStatusCode],[strDescription])
			VALUES
			(@strAccountStatusCode,@strDescription)						
	
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpssascmst WHERE ssasc_code = @originAccountCode
		
		
			SET @Counter += 1
		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempAccount
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @AccountCode IS NULL) 
	BEGIN
		SELECT @Total = COUNT(ssasc_code) from tblARTempAccount
	END'
	)

--END