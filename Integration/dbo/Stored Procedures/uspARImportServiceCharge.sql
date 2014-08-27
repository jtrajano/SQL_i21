GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportServiceCharge')
	DROP PROCEDURE uspARImportServiceCharge
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN
EXEC('CREATE PROCEDURE uspARImportServiceCharge
	@ServiceChargeCode NVARCHAR(2) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of agsrvmst. This will use to track all service charge already imported
	IF(OBJECT_ID(''dbo.tblARTempServiceCharge'') IS NULL)
		SELECT * INTO tblARTempServiceCharge FROM agsrvmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM agsrvmst WHERE agsrv_srv_no = @ServiceChargeCode))
		BEGIN
			UPDATE agsrvmst
				SET 
				agsrv_srv_no = SrvCharge.strServiceChargeCode,
				agsrv_desc = SUBSTRING(SrvCharge.strDescription,1,20),
				agsrv_pct = SrvCharge.dblPercentage
			FROM tblARServiceCharge SrvCharge
				WHERE strServiceChargeCode = @ServiceChargeCode AND agsrv_srv_no = @ServiceChargeCode
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO agsrvmst(
				agsrv_srv_no,
				agsrv_desc,
				agsrv_pct
			)
			SELECT 
				strServiceChargeCode,
				SUBSTRING(strDescription,1,20),
				dblPercentage
			FROM tblARServiceCharge
			WHERE strServiceChargeCode = @ServiceChargeCode
		
	RETURN;
	END


	--================================================
	--     ONE TIME SERVICE CHARGE SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @ServiceChargeCode IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Service Charge Synchronization''

		DECLARE @originServiceChargeCode	NVARCHAR(2)
		DECLARE @strServiceChargeCode		NVARCHAR(2)
		DECLARE	@strDescription				NVARCHAR(MAX)
		DECLARE @dblPercentage				NUMERIC(18,6)
	
		DECLARE @Counter INT = 0
	
    
		--Import only those are not yet imported
		SELECT agsrv_srv_no INTO #tmpagsrvmst 
			FROM agsrvmst
		LEFT JOIN tblARServiceCharge
			ON agsrvmst.agsrv_srv_no  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
		ORDER BY agsrvmst.agsrv_srv_no DESC

		WHILE (EXISTS(SELECT 1 FROM #tmpagsrvmst))
		BEGIN
		
			SELECT @originServiceChargeCode = agsrv_srv_no FROM #tmpagsrvmst

			SELECT TOP 1
				@strServiceChargeCode = agsrv_srv_no,
				@strDescription = agsrv_desc,
				@dblPercentage = agsrv_pct
			FROM agsrvmst
			WHERE agsrv_srv_no = @originServiceChargeCode
		
			--Insert into tblARServiceCharge
			INSERT [dbo].[tblARServiceCharge]
			([strServiceChargeCode],
			 [strDescription],
			 [strCalculationType],
			 [dblPercentage],
			 [dblServiceChargeAPR],
			 [dblMinimumCharge],
			 [intGracePeriod])
			VALUES
			(@strServiceChargeCode,
			 @strDescription,
			 ''Percent'',
			 @dblPercentage,
			 0,
			 0,
			 0)				
	
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpagsrvmst WHERE agsrv_srv_no = @originServiceChargeCode
		
		
			SET @Counter += 1
		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempServiceCharge
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NULL) 
	BEGIN
		SELECT @Total = COUNT(agsrv_srv_no) from tblARTempServiceCharge
	END'
	)
END


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
EXEC('CREATE PROCEDURE uspARImportServiceCharge
	@ServiceChargeCode NVARCHAR(2) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of agsrvmst. This will use to track all service charge already imported
	IF(OBJECT_ID(''dbo.tblARTempServiceCharge'') IS NULL)
		SELECT * INTO tblARTempServiceCharge FROM ptsrvmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM ptsrvmst WHERE ptsrv_code = @ServiceChargeCode))
		BEGIN
			UPDATE ptsrvmst
				SET 
				ptsrv_code = SrvCharge.strServiceChargeCode,
				ptsrv_desc = SUBSTRING(SrvCharge.strDescription,1,30),
				ptsrv_pct = SrvCharge.dblPercentage,
				ptsrv_pct_freq = (CASE WHEN strFrequency = ''Daily'' THEN ''D'' WHEN strFrequency = ''Monthly'' THEN ''M'' WHEN strFrequency = ''Anual'' THEN ''A'' ELSE '''' END),
				ptsrv_min_svchg = dblMinimumCharge,
				ptsrv_grace_per = intGracePeriod,
				ptsrv_applied = (CASE WHEN strAppliedPer = ''Customer'' THEN ''C'' WHEN strAppliedPer = ''Invoice'' THEN ''I'' ELSE '''' END),
				ptsrv_allow_mthly_chg_freq = (CASE WHEN ysnAllowCatchUpCharges = 1 THEN ''Y'' ELSE ''N'' END)
			FROM tblARServiceCharge SrvCharge
				WHERE strServiceChargeCode = @ServiceChargeCode AND ptsrv_code = @ServiceChargeCode
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO ptsrvmst(
				ptsrv_code,
				ptsrv_desc,
				ptsrv_pct,
				ptsrv_pct_freq,
				ptsrv_min_svchg,
				ptsrv_grace_per,
				ptsrv_applied,
				ptsrv_allow_mthly_chg_freq					
			)
			SELECT 
				strServiceChargeCode,
				SUBSTRING(strDescription,1,30),
				dblPercentage,
				(CASE WHEN strFrequency = ''Daily'' THEN ''D'' WHEN strFrequency = ''Monthly'' THEN ''M'' WHEN strFrequency = ''Anual'' THEN ''A'' ELSE '''' END),
				dblMinimumCharge,
				intGracePeriod,
				(CASE WHEN strAppliedPer = ''Customer'' THEN ''C'' WHEN strAppliedPer = ''Invoice'' THEN ''I'' ELSE '''' END),
				(CASE WHEN ysnAllowCatchUpCharges = 1 THEN ''Y'' ELSE ''N'' END)
			FROM tblARServiceCharge
			WHERE strServiceChargeCode = @ServiceChargeCode
		
	RETURN;
	END


	--================================================
	--     ONE TIME SERVICE CHARGE SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @ServiceChargeCode IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Service Charge Synchronization''

		DECLARE @originServiceChargeCode	NVARCHAR(2)
		DECLARE @strServiceChargeCode		NVARCHAR(2)
		DECLARE	@strDescription				NVARCHAR(MAX)
		DECLARE @dblPercentage				NUMERIC(18,6)
		DECLARE @strFrequency				NVARCHAR(50)
		DECLARE @dblMinimumCharge			NUMERIC(18,6)
		DECLARE @intGracePeriod				INT
		DECLARE @strAppliedPer				NVARCHAR(20)
		DECLARE @ysnAllowCatchUpCharges		BIT
	
		DECLARE @Counter INT = 0
	
    
		--Import only those are not yet imported
		SELECT ptsrv_code INTO #tmpptsrvmst 
			FROM ptsrvmst
		LEFT JOIN tblARServiceCharge
			ON ptsrvmst.ptsrv_code  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
		ORDER BY ptsrvmst.ptsrv_code DESC

		WHILE (EXISTS(SELECT 1 FROM #tmpptsrvmst))
		BEGIN
		
			SELECT @originServiceChargeCode = ptsrv_code FROM #tmpptsrvmst

			SELECT TOP 1
				@strServiceChargeCode = ptsrv_code,
				@strDescription = ptsrv_desc,
				@dblPercentage = ptsrv_pct,
				@strFrequency = (CASE WHEN ptsrv_pct_freq = ''D'' THEN ''Daily'' WHEN ptsrv_pct_freq = ''M'' THEN ''Monthly'' WHEN ptsrv_pct_freq = ''A'' THEN ''Anual'' ELSE '''' END ),			
				@dblMinimumCharge = ptsrv_min_svchg,		
				@intGracePeriod = ptsrv_grace_per,			
				@strAppliedPer = (CASE WHEN ptsrv_applied = ''C'' THEN ''Customer'' WHEN ptsrv_applied = ''I'' THEN ''Invoice'' ELSE '''' END),			
				@ysnAllowCatchUpCharges = (CASE WHEN ptsrv_allow_mthly_chg_freq = ''Y'' THEN 1 ELSE 0 END)
			FROM ptsrvmst
			WHERE ptsrv_code = @originServiceChargeCode
		
			--Insert into tblARServiceCharge
			INSERT [dbo].[tblARServiceCharge]
			([strServiceChargeCode],
			 [strDescription],
			 [strCalculationType],
			 [dblPercentage],
			 [strFrequency],
			 [dblServiceChargeAPR],
			 [dblMinimumCharge],
			 [intGracePeriod],
			 [strAppliedPer],
			 [ysnAllowCatchUpCharges])
			VALUES
			(@strServiceChargeCode,
			 @strDescription,
			 ''Percent'',
			 @dblPercentage,
			 @strFrequency,
			 0,
			 @dblMinimumCharge,
			 @intGracePeriod,
			 @strAppliedPer,
			 @ysnAllowCatchUpCharges)				
	
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpptsrvmst WHERE ptsrv_code = @originServiceChargeCode
		
		
			SET @Counter += 1
		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempServiceCharge
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NULL) 
	BEGIN
		SELECT @Total = COUNT(ptsrv_code) from tblARTempServiceCharge
	END'
	)
	
END