GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportServiceCharge')
	DROP PROCEDURE uspARImportServiceCharge
GO
EXEC('CREATE PROCEDURE [dbo].[uspARImportServiceCharge]
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
