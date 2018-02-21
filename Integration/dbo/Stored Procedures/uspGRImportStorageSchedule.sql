IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportStorageSchedule')
	DROP PROCEDURE uspGRImportStorageSchedule
GO

CREATE PROCEDURE uspGRImportStorageSchedule 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	--================================================
	--     IMPORT GRAIN STORAGE TYPES
	--================================================
	IF (@Checking = 1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM tblGRStorageScheduleRule)
			SELECT @Total = 0
		ELSE  
			SELECT @Total = COUNT(1) FROM gachrmst

		RETURN @Total
	END

	DECLARE @tblStorageSchedule AS TABLE 
	(
		 IdentityKey INT
		,intCurrencyId INT
		,strCurrency NVARCHAR(40) COLLATE Latin1_General_CS_AS
		,strLocation NVARCHAR(30) COLLATE Latin1_General_CS_AS
		,intCommodityId INT
		,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CS_AS
		,intStorageType INT
		,strStorageScheduleNo NVARCHAR(50) COLLATE Latin1_General_CS_AS
		,strDescription NVARCHAR(100) COLLATE Latin1_General_CS_AS
		,intAllowanceDays INT
		,dblFeeRate DECIMAL(18, 6)
		,strFeeType NVARCHAR(100) COLLATE Latin1_General_CS_AS
	)
	
	DECLARE @tblStoragePeriod AS TABLE 
	(
		 IdentityKey INT
		,strPeriodType NVARCHAR(50) COLLATE Latin1_General_CS_AS
		,dtmEffectiveDate DATETIME
		,dtmEndingDate DATETIME
		,intNumberOfDays INT
		,dblStorageRate NUMERIC(18, 6)
		,dblFeeRate DECIMAL(18, 6)
		,strFeeType NVARCHAR(100) COLLATE Latin1_General_CS_AS
		,intSort INT
	)

	INSERT INTO @tblStorageSchedule 
	(
		 IdentityKey
		,intCurrencyId
		,strCurrency
		,strLocation
		,intCommodityId
		,strCommodityCode
		,intStorageType
		,strStorageScheduleNo
		,strDescription
		,intAllowanceDays
		,dblFeeRate
		,strFeeType
	)
	SELECT 
		 IdentityKey          = A4GLIdentity
		,intCurrencyId        = Cur.intCurrencyID
		,strCurrency          = LTRIM(RTRIM(gachr_currency))
		,strLocation		  = LTRIM(RTRIM(gachr_loc_no))
		,intCommodityId		  = Com.intCommodityId
		,strCommodityCode	  = LTRIM(RTRIM(gachr_com_cd))
		,intStorageType		  = StorageType.intStorageScheduleTypeId
		,strStorageScheduleNo = LTRIM(RTRIM(gachr_stor_schd_no))
		,strDescription		  = LTRIM(RTRIM(ISNULL(gachr_desc, gachr_stor_schd_no)))
		,intAllowanceDays     = gachr_allow_days
		,dblFeeRate			  = gachr_in_un_chrg
		,strFeeType			  = CASE 
							  		WHEN gachr_type_chrg = 'P' THEN 'Price'
							  		WHEN gachr_type_chrg = 'W' THEN 'Weight'
							    END
	FROM gachrmst a
	JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(a.gachr_com_cd)) COLLATE Latin1_General_CS_AS
	JOIN tblSMCurrency Cur ON Cur.strCurrency = LTRIM(RTRIM(a.gachr_currency)) COLLATE Latin1_General_CS_AS
	JOIN tblGRStorageType StorageType ON StorageType.strStorageTypeCode =LTRIM(RTRIM(a.gachr_stor_type)) COLLATE Latin1_General_CS_AS

	INSERT INTO @tblStoragePeriod 
	(
		 IdentityKey
		,strPeriodType
		,dtmEffectiveDate
		,dtmEndingDate
		,intNumberOfDays
		,dblStorageRate
		,dblFeeRate
		,strFeeType
		,intSort
	)
	SELECT 
		 IdentityKey     = b.IdentityKey
		,strPeriodType	 = CASE 
								WHEN a.gachr_init_beg_rev_dt > 0 THEN 'Date Range'
								ELSE 'Number of Days'
						   END

		,dtmEffectiveDate = CASE 
								 WHEN a.gachr_init_beg_rev_dt > 0 THEN Convert(DATE, CAST(gachr_init_beg_rev_dt AS NVARCHAR))
								 ELSE NULL
							END

		,dtmEndingDate   = CASE 
						  		WHEN a.gachr_init_end_rev_dt > 0 THEN Convert(DATE, CAST(gachr_init_end_rev_dt AS NVARCHAR))
						  		ELSE NULL
						    END
					     
		,intNumberOfDays = gachr_init_days
		,dblStorageRate  = gachr_init_un_chrg
		,dblFeeRate      = gachr_in_un_chrg
		
		,strFeeType      = CASE 
					     		WHEN gachr_type_chrg = 'P' THEN 'Price'
					     		WHEN gachr_type_chrg = 'W' THEN 'Weight'
					       END
		,intSort		 = 1
	FROM gachrmst a
	JOIN @tblStorageSchedule b ON b.IdentityKey = a.A4GLIdentity
	
	UNION
	
	SELECT 
		 IdentityKey		= b.IdentityKey
		,strPeriodType		= 'Number of Days'
		,dtmEffectiveDate	= NULL
		,dtmEndingDate		= NULL
		,intNumberOfDays	= gachr_next_days
		,dblStorageRate		= gachr_next_un_chrg
		,dblFeeRate			= gachr_in_un_chrg
		,strFeeType			= CASE 
							       WHEN gachr_type_chrg = 'P' THEN 'Price'
							       WHEN gachr_type_chrg = 'W' THEN 'Weight'
							  END
		,intSort			= 2
	FROM gachrmst a
	JOIN @tblStorageSchedule b ON b.IdentityKey = a.A4GLIdentity
	
	UNION
	
	SELECT IdentityKey		= b.IdentityKey
		,strPeriodType		= 'Thereafter'
		,dtmEffectiveDate	= NULL
		,dtmEndingDate		= NULL
		,intNumberOfDays	= NULL
		,dblStorageRate		= gachr_after_un_chrg
		,dblFeeRate			= gachr_in_un_chrg
		,strFeeType			= CASE 
									WHEN gachr_type_chrg = 'P' THEN 'Price'
									WHEN gachr_type_chrg = 'W' THEN 'Weight'
							  END
		,intSort		    = 3
	FROM gachrmst a
	JOIN @tblStorageSchedule b ON b.IdentityKey = a.A4GLIdentity

	SET IDENTITY_INSERT [dbo].[tblGRStorageScheduleRule] ON

	INSERT INTO tblGRStorageScheduleRule 
	(
		 intStorageScheduleRuleId
		,intConcurrencyId
		,strScheduleDescription
		,intStorageType
		,intCommodity
		,intAllowanceDays
		,dtmEffectiveDate
		,dtmTerminationDate
		,intCurrencyID
		,strScheduleId
		,strStorageRate
		,strFirstMonth
		,strLastMonth
		,strAllowancePeriod
		,dtmAllowancePeriodFrom
		,dtmAllowancePeriodTo
	)
	SELECT 
		 intStorageScheduleRuleId   = IdentityKey
		,intConcurrencyId		    = 1
		,strScheduleDescription     = strDescription
		,intStorageType			    = intStorageType
		,intCommodity			    = intCommodityId
		,intAllowanceDays		    = intAllowanceDays
		,dtmEffectiveDate		    = NULL
		,dtmTerminationDate		    = NULL
		,intCurrencyID			    = intCurrencyId
		,strScheduleId			    = strStorageScheduleNo + '/' + LTRIM(IdentityKey)
		,strStorageRate			    = 'Daily'
		,strFirstMonth			    = 'Number of Days'
		,strLastMonth			    = 'Number of Days'
		,strAllowancePeriod		    = 'Day(s)'
		,dtmAllowancePeriodFrom     = NULL
		,dtmAllowancePeriodTo       = NULL
	FROM @tblStorageSchedule

	SET IDENTITY_INSERT [dbo].[tblGRStorageScheduleRule] OFF

	INSERT INTO tblGRStorageScheduleLocationUse 
	(
		[intStorageScheduleId]
		,[intCompanyLocationId]
		,[ysnStorageScheduleLocationActive]
		,[intConcurrencyId]
	)
	SELECT 
		 intStorageScheduleId				= A4GLIdentity
		,[intCompanyLocationId]				= b.intCompanyLocationId
		,[ysnStorageScheduleLocationActive] = 1
		,[intConcurrencyId]					= 1
	FROM dbo.gachrmst a
	JOIN tblSMCompanyLocation b ON b.strLocationNumber = a.gachr_loc_no COLLATE Latin1_General_CS_AS

	INSERT INTO tblGRStorageSchedulePeriod 
	(
		 intConcurrencyId
		,intStorageScheduleRule
		,strPeriodType
		,dtmEffectiveDate
		,dtmEndingDate
		,intNumberOfDays
		,dblStorageRate
		,strFeeDescription
		,dblFeeRate
		,strFeeType
		,intSort
	)
	SELECT 
	     intConcurrencyId       = 1
		,intStorageScheduleRule = IdentityKey
		,strPeriodType			= strPeriodType
		,dtmEffectiveDate		= dtmEffectiveDate
		,dtmEndingDate			= dtmEndingDate
		,intNumberOfDays		= intNumberOfDays
		,dblStorageRate			= dblStorageRate
		,strFeeDescription		= 'Fee'
		,dblFeeRate				= dblFeeRate
		,strFeeType				= strFeeType
		,intSort				= intSort
	FROM @tblStoragePeriod
END

GO