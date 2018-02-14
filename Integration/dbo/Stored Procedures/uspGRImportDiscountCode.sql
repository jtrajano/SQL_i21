IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportDiscountCode')
	DROP PROCEDURE uspGRImportDiscountCode
GO

CREATE PROCEDURE uspGRImportDiscountCode 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	--================================================
	--     IMPORT GRAIN Discount Schedule
	--================================================
	IF (@Checking = 1)
	BEGIN

		IF EXISTS(SELECT 1 FROM tblGRDiscountScheduleCode)
			SELECT @Total = 0
		ELSE  
			SELECT @Total = COUNT(1) FROM gadscmst WHERE gadsc_seq_no=1

		RETURN @Total
	END

	BEGIN	
			----Create Discount and Storage Charge Items	
			EXEC uspGRImportDiscountAndStorageChargeItem

			DECLARE @intDiscountScheduleId INT
			DECLARE @strCurrency NVARCHAR(50)
			DECLARE @strCommodityCode NVARCHAR(50)
			DECLARE @strDiscountDescription NVARCHAR(50)
			DECLARE @intDiscountScheduleCodeId INT
			DECLARE @strShortName NVARCHAR(50)
			DECLARE @strStorageTypeCode NVARCHAR(50)
			DECLARE @strLocationName NVARCHAR(50)
			
			DECLARE @tblDiscountSchedule AS TABLE 
			(
				 IdentityKey INT
				,strCurrency NVARCHAR(40) COLLATE Latin1_General_CS_AS
				,strDiscountDescription NVARCHAR(30) COLLATE Latin1_General_CS_AS
				,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CS_AS
				,strLocationName NVARCHAR(50) COLLATE Latin1_General_CS_AS
				,strStorageType NVARCHAR(50) COLLATE Latin1_General_CS_AS
				,strDiscountCode NVARCHAR(50) COLLATE Latin1_General_CS_AS
				,intSequenceNo INT
				,strDescription NVARCHAR(100) COLLATE Latin1_General_CS_AS
				,strItemNo NVARCHAR(50) COLLATE Latin1_General_CS_AS
				,intShrinkCalculationOptionId INT
				,intDiscountCalculationOptionId INT
				,dblDefaultReading DECIMAL(7, 3)
				,dblMinReading DECIMAL(7, 3)
				,dblMaxReading DECIMAL(7, 3)
				,dblRangeStartingValue DECIMAL(7, 3)
				,dblRangeEndingValue DECIMAL(7, 3)
				,dblIncrementValue DECIMAL(7, 3)
				,dblDiscountValue DECIMAL(7, 3)
				,dblShrinkValue DECIMAL(7, 3)
			)

			INSERT INTO @tblDiscountSchedule 
			(
				 IdentityKey
				,strCurrency
				,strDiscountDescription
				,strCommodityCode
				,strLocationName
				,strStorageType
				,strDiscountCode
				,intSequenceNo
				,strDescription
				,strItemNo
				,intShrinkCalculationOptionId
				,intDiscountCalculationOptionId
				,dblDefaultReading
				,dblMinReading
				,dblMaxReading
				,dblRangeStartingValue
				,dblRangeEndingValue
				,dblIncrementValue
				,dblDiscountValue
				,dblShrinkValue
			)
			SELECT 
				 IdentityKey					 = a.A4GLIdentity
				,strCurrency					 = LTRIM(RTRIM(gadsc_currency))
				,strDiscountDescription			 = LTRIM(RTRIM(gadsc_disc_schd_no))
				,strCommodityCode				 = LTRIM(RTRIM(gadsc_com_cd))
				,strLocationName				 = LTRIM(RTRIM(gadsc_loc_no))
				,strStorageType					 = LTRIM(RTRIM(gadsc_stor_type))
				,strDiscountCode				 = LTRIM(RTRIM(gadsc_disc_cd))
				,intSequenceNo					 = gadsc_seq_no
				,strDescription					 = LTRIM(RTRIM(gadsc_desc))
				,strItemNo						 = LTRIM(RTRIM(gadsc_com_cd)) + ' '
															--CASE 
															--	WHEN LTRIM(RTRIM(gadsc_com_cd)) = 'B' THEN 'Barley '
															--	WHEN LTRIM(RTRIM(gadsc_com_cd)) = 'C' THEN 'Corn '
															--	WHEN LTRIM(RTRIM(gadsc_com_cd)) = 'M' THEN 'Milo '
															--	WHEN LTRIM(RTRIM(gadsc_com_cd)) = 'S' THEN 'Soyabean '
															--	WHEN LTRIM(RTRIM(gadsc_com_cd)) = 'W' THEN 'Wheat '
															-- END
															+ CASE 
																  WHEN LTRIM(RTRIM(a1.gacdc_desc)) IS NOT NULL THEN LTRIM(RTRIM(a1.gacdc_desc))
																  ELSE 
																  		CASE 
																  			 WHEN ISNULL(LTRIM(RTRIM(gadsc_desc)), '') <> '' THEN LTRIM(RTRIM(gadsc_disc_cd)) + ' / ' + ISNULL(LTRIM(RTRIM(gadsc_desc)), '')
																  			 ELSE LTRIM(RTRIM(gadsc_disc_cd))
																  		 END
															  END 
				
				,intShrinkCalculationOptionId	= CASE WHEN gadsc_seq_no=1 THEN 
													CASE 
														  WHEN LTRIM(RTRIM(gadsc_shrk_what)) = 'N' THEN  1
														  WHEN LTRIM(RTRIM(gadsc_shrk_what)) = 'W' THEN  2
														  WHEN LTRIM(RTRIM(gadsc_shrk_what)) = 'P' THEN  3
													END  
													ELSE NULL END

				,intDiscountCalculationOptionId  = CASE WHEN gadsc_seq_no=1 THEN 
												   CASE 
												   	   WHEN LTRIM(RTRIM(gadsc_disc_calc)) = 'N' THEN  1
												   	   WHEN LTRIM(RTRIM(gadsc_disc_calc)) = 'W' THEN  2
												   	   WHEN LTRIM(RTRIM(gadsc_disc_calc)) = 'G' THEN  3
												   END 
												   ELSE NULL END 

				,dblDefaultReading               = CASE WHEN gadsc_seq_no=1 THEN gadsc_def_reading ELSE NULL END
				,dblMinReading                   = CASE WHEN gadsc_seq_no=1 THEN gadsc_min_reading ELSE NULL END
				,dblMaxReading                   = CASE WHEN gadsc_seq_no=1 THEN gadsc_max_reading ELSE NULL END
				,dblRangeStartingValue           = gadsc_from_reading
				,dblRangeEndingValue             = gadsc_thru_reading
				,dblIncrementValue               = gadsc_increment
				,dblDiscountValue                = gadsc_increment_disc 
				,dblShrinkValue                  = gadsc_increment_pct
			FROM gadscmst a
			LEFT JOIN gacdcmst a1 ON LTRIM(RTRIM(a.gadsc_disc_cd)) = LTRIM(RTRIM(a1.gacdc_cd))
								 AND LTRIM(RTRIM(a.gadsc_com_cd))  = LTRIM(RTRIM(a1.gacdc_com_cd))

			SELECT @intDiscountScheduleId = MIN(intDiscountScheduleId)
			FROM tblGRDiscountSchedule

			WHILE @intDiscountScheduleId > 0
			BEGIN
				SET @strCurrency			= NULL
				SET @strCommodityCode		= NULL
				SET @strDiscountDescription = NULL

				SELECT 
					 @strCurrency			 = LTRIM(RTRIM(CUR.strCurrency))
					,@strCommodityCode		 = LTRIM(RTRIM(COM.strCommodityCode))
					,@strDiscountDescription = LTRIM(RTRIM(DS.strDiscountDescription))
				FROM tblGRDiscountSchedule DS
				JOIN tblICCommodity COM ON COM.intCommodityId = DS.intCommodityId
				JOIN tblSMCurrency CUR ON CUR.intCurrencyID = DS.intCurrencyId
				WHERE DS.intDiscountScheduleId = @intDiscountScheduleId

				INSERT INTO tblGRDiscountScheduleCode 
				(
					 intDiscountScheduleId
					,intDiscountCalculationOptionId
					,intShrinkCalculationOptionId
					,ysnZeroIsValid
					,dblMinimumValue
					,dblMaximumValue
					,dblDefaultValue
					,ysnQualityDiscount
					,ysnDryingDiscount
					,dtmEffectiveDate
					,dtmTerminationDate
					,intConcurrencyId
					,intSort
					,strDiscountChargeType
					,intItemId
					,intStorageTypeId
					,intCompanyLocationId
					)
				SELECT 
					 intDiscountScheduleId
					,intDiscountCalculationOptionId
					,intShrinkCalculationOptionId
					,ysnZeroIsValid
					,dblMinimumValue
					,dblMaximumValue
					,dblDefaultValue
					,ysnQualityDiscount
					,ysnDryingDiscount
					,dtmEffectiveDate
					,dtmTerminationDate
					,intConcurrencyId
					,intSort
					,strDiscountChargeType
					,intItemId
					,intStorageTypeId
					,intCompanyLocationId
				FROM (
					SELECT 
						 IdentityKey					 = t.IdentityKey
						,intDiscountScheduleId		     = Sch.intDiscountScheduleId
						,intDiscountCalculationOptionId	 = intDiscountCalculationOptionId
						,intShrinkCalculationOptionId	 = intShrinkCalculationOptionId
						,ysnZeroIsValid					 = 0 
						,dblMinimumValue				 = t.dblMinReading
						,dblMaximumValue				 = t.dblMaxReading
						,dblDefaultValue				 = t.dblDefaultReading 
						,ysnQualityDiscount				 = 0 
						,ysnDryingDiscount				 = 0 
						,dtmEffectiveDate				 = NULL 
						,dtmTerminationDate				 = NULL 
						,intConcurrencyId				 = 1 
						,intSort						 = NULL 
						,strDiscountChargeType			 =  CASE 
																 WHEN t.intShrinkCalculationOptionId = 3 THEN 'Percent'
																 ELSE 'Dollar'
															END 
						,intItemId						 = Item.intItemId 
						,intStorageTypeId				 = - 1  --St.intStorageScheduleTypeId AS intStorageTypeId
						,intCompanyLocationId			 = L.[intCompanyLocationId] 
					FROM @tblDiscountSchedule t
					JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(t.strCommodityCode)) COLLATE Latin1_General_CS_AS
					JOIN tblSMCurrency Cur ON Cur.strCurrency = LTRIM(RTRIM(t.strCurrency)) COLLATE Latin1_General_CS_AS
					JOIN tblGRDiscountSchedule Sch ON Sch.intCurrencyId = Cur.intCurrencyID
					JOIN tblICItem Item ON Item.strItemNo = LTRIM(RTRIM(t.strItemNo)) COLLATE Latin1_General_CS_AS
					--JOIN tblGRStorageType St ON St.strStorageTypeCode= LTRIM(RTRIM(t.strStorageType)) COLLATE  Latin1_General_CS_AS
					--JOIN tblSMCompanyLocation L ON L.strLocationName=LTRIM(RTRIM(t.strLocationName ))  COLLATE  Latin1_General_CS_AS
					JOIN tblSMCompanyLocation L ON L.strLocationNumber = LTRIM(RTRIM(t.strLocationName)) COLLATE Latin1_General_CS_AS
						AND Sch.strDiscountDescription = LTRIM(RTRIM(t.strDiscountDescription)) COLLATE Latin1_General_CS_AS
						AND Sch.intCommodityId = Com.intCommodityId
					WHERE t.intSequenceNo = '1'
						AND t.strCurrency = @strCurrency
						AND t.strCommodityCode = @strCommodityCode
						AND t.strDiscountDescription = @strDiscountDescription
					) t

				SELECT @intDiscountScheduleId = MIN(intDiscountScheduleId)
				FROM tblGRDiscountSchedule
				WHERE intDiscountScheduleId > @intDiscountScheduleId
			END

			-----Incremental Grid Information
			SELECT @intDiscountScheduleCodeId = MIN(intDiscountScheduleCodeId)
			FROM tblGRDiscountScheduleCode

			WHILE @intDiscountScheduleCodeId > 0
			BEGIN
				SET @strCurrency = NULL
				SET @strCommodityCode = NULL
				SET @strStorageTypeCode = NULL
				SET @strLocationName = NULL
				SET @strShortName = NULL
				SET @strDiscountDescription = NULL

				SELECT 
					 @strCurrency				= CUR.strCurrency
					,@strCommodityCode			= COM.strCommodityCode
					,@strStorageTypeCode		= ST.strStorageTypeCode
					--,@strLocationName=L.strLocationName
					,@strLocationName			= L.strLocationNumber
					,@strShortName				= Item.strShortName
					,@strDiscountDescription	= DS.strDiscountDescription
				FROM tblGRDiscountScheduleCode DSO
				JOIN tblICItem Item ON Item.intItemId = DSO.intItemId
				JOIN tblGRDiscountSchedule DS ON DS.intDiscountScheduleId = DSO.intDiscountScheduleId
				JOIN tblICCommodity COM ON COM.intCommodityId = DS.intCommodityId
				JOIN tblSMCurrency CUR ON CUR.intCurrencyID = DS.intCurrencyId
				JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = DSO.intStorageTypeId
				JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = DSO.intCompanyLocationId
				WHERE DSO.intDiscountScheduleCodeId = @intDiscountScheduleCodeId

				INSERT INTO tblGRDiscountScheduleLine 
				(
					 intDiscountScheduleCodeId
					,dblRangeStartingValue
					,dblRangeEndingValue
					,dblIncrementValue
					,dblDiscountValue
					,dblShrinkValue
					,intConcurrencyId
				)
				SELECT 
					 @intDiscountScheduleCodeId
					,dblRangeStartingValue
					,dblRangeEndingValue
					,dblIncrementValue
					,dblDiscountValue
					,dblShrinkValue
					,intConcurrencyId
				FROM (
						SELECT TOP 100 PERCENT 
						 dblRangeStartingValue
						,dblRangeEndingValue
						,dblIncrementValue
						,dblDiscountValue
						,dblShrinkValue
						,1 AS intConcurrencyId
						,intSequenceNo
					FROM @tblDiscountSchedule
					WHERE strCurrency = @strCurrency
						AND strDiscountDescription = @strDiscountDescription
						AND strCommodityCode = @strCommodityCode
						AND strLocationName = @strLocationName
						--AND strStorageType=@strStorageTypeCode
						AND strDiscountCode = @strShortName
					ORDER BY intSequenceNo
					) t

				SELECT @intDiscountScheduleCodeId = MIN(intDiscountScheduleCodeId)
				FROM tblGRDiscountScheduleCode
				WHERE intDiscountScheduleCodeId > @intDiscountScheduleCodeId
			END
			
    END

END
