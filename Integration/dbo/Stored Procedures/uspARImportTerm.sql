IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportTerm')
	DROP PROCEDURE uspARImportTerm
GO

CREATE PROCEDURE uspARImportTerm
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

	AS
BEGIN
	--================================================
	--     ONE TIME TERM SYNCHRONIZATION	
	--================================================
	IF(@Checking = 0) 
	BEGIN
		
		--1 Time synchronization here
		PRINT '1 Time Term Synchronization'
		
		
			--================================================
			--     Insert into tblSMTerm only those exist in agivcmst
			--================================================
			INSERT INTO [dbo].[tblSMTerm]
			   ([strTerm]
			   ,[strTermCode]
			   ,[strType]
			   ,[dblDiscountEP]
			   ,[intDiscountDay]
			   ,[dtmDiscountDate]
			   ,[intBalanceDue]
			   ,[dtmDueDate]
			   ,[ysnAllowEFT])
			SELECT 
				agtrm_desc
				,agtrm_key_n
				,(CASE 
					WHEN agtrm_net_rev_dt <> 0  OR agtrm_net_rev_dt <> 0
						THEN 'Specific Date'
					ELSE
						'Standard'
					END)
				,agtrm_disc_pct
				,agtrm_disc_days
				,(CASE WHEN ISDATE(agtrm_disc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agtrm_disc_rev_dt AS CHAR(12)), 112) ELSE NULL END)
				,agtrm_net_days
				,(CASE WHEN ISDATE(agtrm_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agtrm_net_rev_dt AS CHAR(12)), 112) ELSE NULL END)
				,agtrm_eft_yn
			FROM agtrmmst 
			LEFT JOIN tblSMTerm Term ON CONVERT(NVARCHAR(20),agtrmmst.agtrm_key_n) COLLATE Latin1_General_CI_AS = Term.strTermCode COLLATE Latin1_General_CI_AS
			WHERE agtrm_key_n in (SELECT DISTINCT agivc_terms_code FROM agivcmst) 
			AND Term.strTermCode IS NULL AND agtrmmst.agtrm_key_n = UPPER(agtrmmst.agtrm_key_n) COLLATE Latin1_General_CS_AS
			 

	END

	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1) 
	BEGIN
		DECLARE @fromTerm INT
        DECLARE @fromOriginTerm INT
        
        select @fromTerm = COUNT(strTermCode) from tblSMTerm where strTermCode  IN (SELECT CONVERT(nvarchar(10),agtrm_key_n) FROM agtrmmst WHERE agtrm_key_n in (SELECT DISTINCT agivc_terms_code FROM agivcmst))
		
		SELECT @fromOriginTerm = COUNT(DISTINCT agivc_terms_code) FROM agivcmst
        
        IF(@fromTerm = @fromOriginTerm)
        BEGIN
            SET @Total = 0
        END
        ELSE
            Set @Total = @fromOriginTerm - @fromTerm
		
	END
		
END	