IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportServiceCharge')
	DROP PROCEDURE uspARImportServiceCharge
GO


IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
BEGIN

	EXEC('CREATE PROCEDURE [dbo].[uspARImportServiceCharge]
	@ServiceChargeCode NVARCHAR(2) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS
BEGIN	
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

		--================================================
		--     Insert into tblARServiceCharge only those exist in agsrvmst
		--================================================
		INSERT [dbo].[tblARServiceCharge]
			([strServiceChargeCode],
			 [strDescription],
			 [strCalculationType],
			 [dblPercentage],
			 [dblServiceChargeAPR],
			 [dblMinimumCharge],
			 [intGracePeriod])
		 SELECT 
			 agsrv_srv_no
			,agsrv_desc
			,''Percent''
			,agsrv_pct
			,0
			,0
			,0
		FROM agsrvmst LEFT JOIN 
		tblARServiceCharge ON agsrvmst.agsrv_srv_no  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
						
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NULL) 
	BEGIN
		SELECT 
			 @Total = COUNT(agsrv_srv_no)
		FROM agsrvmst LEFT JOIN 
		tblARServiceCharge ON agsrvmst.agsrv_srv_no  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
	END
	
END
')
END

IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'PT' and strDBName = db_name()) = 1
BEGIN
	EXEC('CREATE PROCEDURE [dbo].[uspARImportServiceCharge]
	@ServiceChargeCode NVARCHAR(2) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS
BEGIN	
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
				ptsrv_desc = SUBSTRING(SrvCharge.strDescription,1,20),
				ptsrv_pct = CAST((SrvCharge.dblPercentage/100) as decimal(5,5))
				,ptsrv_pct_freq = (CASE	WHEN SrvCharge.strFrequency = ''Daily''
											THEN ''D''
										WHEN SrvCharge.strFrequency = ''Monthly''
											THEN ''M''
										ELSE ''''
									END)
				,ptsrv_amt = CAST(SrvCharge.dblServiceChargeAPR as decimal(9,2)) 
				,ptsrv_min_svchg = CAST(SrvCharge.dblMinimumCharge as decimal(9,2))
				,ptsrv_grace_per = SrvCharge.intGracePeriod 
				,ptsrv_applied = (CASE	WHEN SrvCharge.strAppliedPer = ''Invoice''
											THEN ''I''
										WHEN SrvCharge.strAppliedPer = ''Customer''
											THEN ''C''
										ELSE ''I''
									END)
				,ptsrv_allow_mthly_chg_freq = (CASE	WHEN SrvCharge.ysnAllowCatchUpCharges = 1
													THEN ''Y''
												ELSE ''N''
												END)
			FROM tblARServiceCharge SrvCharge
				WHERE strServiceChargeCode = @ServiceChargeCode AND ptsrv_code = @ServiceChargeCode
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO ptsrvmst(
				ptsrv_code,
				ptsrv_desc,
				ptsrv_pct
				,ptsrv_pct_freq
				,ptsrv_amt
				,ptsrv_min_svchg
				,ptsrv_grace_per
				,ptsrv_applied
				,ptsrv_allow_mthly_chg_freq
			)
			SELECT 
				strServiceChargeCode,
				SUBSTRING(strDescription,1,20),
				CAST((dblPercentage/100) as decimal(5,5))
				,(CASE	WHEN strFrequency = ''Daily''
						THEN ''D''
					WHEN strFrequency = ''Monthly''
						THEN ''M''
					ELSE NULL
				END)
				,CAST(dblServiceChargeAPR as decimal(9,2))
				,CAST(dblMinimumCharge as decimal(9,2))
				,intGracePeriod
				,(CASE	WHEN strAppliedPer = ''Invoice''
							THEN ''I''
						WHEN strAppliedPer = ''Customer''
							THEN ''C''
						ELSE ''''
					END)
				,(CASE	WHEN ysnAllowCatchUpCharges = 1
							THEN ''Y''
						ELSE ''N''
						END)
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

		--================================================
		--     Insert into tblARServiceCharge only those exist in ptsrvmst
		--================================================
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
		 SELECT 
			 ptsrv_code
			,ptsrv_desc
			,''Percent''
			,CAST((ptsrv_pct * 100) AS numeric(18,2))
			,(CASE	WHEN ptsrv_pct_freq = ''D''
						THEN ''Daily''
					WHEN ptsrv_pct_freq = ''M''
						THEN ''Monthly''
					ELSE ''Annual''
				END)
			,CAST(ptsrv_amt AS numeric(18,2))
			,CAST(ptsrv_min_svchg  AS numeric(18,2))
			,ptsrv_grace_per
			,(CASE	WHEN ptsrv_applied = ''I''
						THEN ''Invoice''
					WHEN ptsrv_applied = ''C''
						THEN ''Customer''
					ELSE ''''
				END)
			,(CASE	WHEN ptsrv_allow_mthly_chg_freq = ''Y''
							THEN 1
						ELSE 0
						END)
		FROM ptsrvmst LEFT JOIN 
		tblARServiceCharge ON ptsrvmst.ptsrv_code  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
						
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @ServiceChargeCode IS NULL) 
	BEGIN
		SELECT 
			 @Total = COUNT(ptsrv_code)
		FROM ptsrvmst LEFT JOIN 
		tblARServiceCharge ON ptsrvmst.ptsrv_code  = tblARServiceCharge.strServiceChargeCode COLLATE Latin1_General_CI_AS
		WHERE tblARServiceCharge.strServiceChargeCode IS NULL
	END
	
END
')
END