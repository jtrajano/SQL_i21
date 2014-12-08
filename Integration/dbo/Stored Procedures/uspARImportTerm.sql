GO
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
		
		DECLARE @intTermId			INT
		DECLARE @strTerm			NVARCHAR(200)
		DECLARE @strTermCode		NVARCHAR(10)
		DECLARE @strType			NVARCHAR(50)
		DECLARE @dblDiscountEP		NUMERIC(18,6)
		DECLARE @intDiscountDay		INT
		DECLARE @dtmDiscountDate	DATETIME
		DECLARE @intBalanceDue		INT
		DECLARE @dtmDueDate			DATETIME
		DECLARE @ysnAllowEFT		BIT
		DECLARE @isTermExists		BIT
		
		SELECT 
		 LTRIM(RTRIM(agtrm_desc)) as strTerm
		,agtrm_key_n as strTermCode
		,(CASE 
			WHEN agtrm_net_rev_dt <> 0  OR agtrm_net_rev_dt <> 0
				THEN 'Specific Date'
			ELSE
				'Standard'
			END) as strType
		,agtrm_disc_pct as dblDiscountEP
		,agtrm_disc_days as intDiscountDay
		,(CASE WHEN ISDATE(agtrm_disc_rev_dt) = 1 THEN CONVERT(DATE, CAST(agtrm_disc_rev_dt AS CHAR(12)), 112) ELSE NULL END) as dtmDiscountDate
		,agtrm_net_days as intBalanceDue
		,(CASE WHEN ISDATE(agtrm_net_rev_dt) = 1 THEN CONVERT(DATE, CAST(agtrm_net_rev_dt AS CHAR(12)), 112) ELSE NULL END) as dtmDueDate
		,(CASE WHEN RTRIM(LTRIM(ISNULL(agtrm_eft_yn,'N'))) = 'N' THEN 0 ELSE 1 END) as ysnAllowEFT
		INTO #tmpTerm
		FROM agtrmmst 
		LEFT JOIN tblSMTerm
					ON CAST(agtrmmst.agtrm_key_n as CHAR(10)) COLLATE Latin1_General_CI_AS = tblSMTerm.strTermCode COLLATE Latin1_General_CI_AS
		 WHERE tblSMTerm.strTermCode is  null
		 
		WHILE (EXISTS(SELECT 1 FROM #tmpTerm))
		BEGIN
			SET @isTermExists = 0;
			
			SELECT TOP 1 
			 @strTerm			= strTerm			
			,@strTermCode		= strTermCode		 
			,@strType			= strType			 
			,@dblDiscountEP		= dblDiscountEP		 
			,@intDiscountDay	= intDiscountDay		 
			,@dtmDiscountDate	= dtmDiscountDate	 
			,@intBalanceDue		= intBalanceDue		 
			,@dtmDueDate		= dtmDueDate			 
			,@ysnAllowEFT		= ysnAllowEFT		
			FROM #tmpTerm
			
			IF(EXISTS(SELECT 1 FROM tblSMTerm WHERE LTRIM(RTRIM(strTerm)) = @strTerm))
			BEGIN
				SET @strTerm = @strTerm + '*'
				SET @isTermExists = 1
			END
			
			INSERT INTO [dbo].[tblSMTerm]
			   ([strTerm]
			   ,[strTermCode]
			   ,[strType]
			   ,[dblDiscountEP]
			   ,[intDiscountDay]
			   ,[dtmDiscountDate]
			   ,[intBalanceDue]
			   ,[dtmDueDate]
			   ,[ysnAllowEFT]
			   ,[dblAPR]
			   ,[intDayofMonthDue]
			   ,[intDueNextMonth])
			VALUES
				(@strTerm			
				,@strTermCode		
				,@strType			
				,@dblDiscountEP		
				,@intDiscountDay	
				,@dtmDiscountDate	
				,@intBalanceDue		
				,@dtmDueDate		
				,@ysnAllowEFT
				,0 -- dblAPR	
				,0 -- intDayofMonthDue
				,0) -- intDueNextMonth
			SET @intTermId = SCOPE_IDENTITY()
			
			IF(@isTermExists = 1)
			BEGIN
				UPDATE tblSMTerm SET strTerm = SUBSTRING(@strTerm,0,CHARINDEX('*',@strTerm)) + ' - ' +  CAST(@intTermId AS NVARCHAR(100)) WHERE strTermCode = @strTermCode
			END
			
			DELETE FROM #tmpTerm WHERE strTermCode = @strTermCode
			
		END
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1) 
	BEGIN
		SELECT 
		@Total = COUNT(agtrm_key_n)		
		FROM agtrmmst 
		LEFT JOIN tblSMTerm
					ON CAST(agtrmmst.agtrm_key_n as CHAR(10)) COLLATE Latin1_General_CI_AS = tblSMTerm.strTermCode COLLATE Latin1_General_CI_AS
		 WHERE tblSMTerm.strTermCode is  null
		
	END
		
END