GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportServiceCharge')
	DROP PROCEDURE uspARImportServiceCharge
GO
CREATE PROCEDURE [dbo].[uspARImportServiceCharge]
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
		PRINT '1 Time Service Charge Synchronization'

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
			,'Percent'
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
