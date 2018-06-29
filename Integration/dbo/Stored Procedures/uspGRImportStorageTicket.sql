IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportStorageTicket')
	DROP PROCEDURE uspGRImportStorageTicket
GO
CREATE PROCEDURE uspGRImportStorageTicket 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
		--================================================
			--     IMPORT Storage Tickets
			--================================================
			IF (@Checking = 1)
			BEGIN
				
				IF EXISTS(SELECT 1 FROM tblGRCustomerStorage)
					SELECT @Total = 0
				ELSE
					SELECT @Total = COUNT(1)FROM gastrmst WHERE gastr_un_bal >0 
										
				RETURN @Total
						
			END

			DECLARE @intCustomerStorageId		   INT
			DECLARE @intConcurrencyId			   INT
			DECLARE @strSourceType				   NVARCHAR(30)
			DECLARE @strDiscountChargeType		   NVARCHAR(30)
												   
			DECLARE @dblGradeReading1			   DECIMAL(24,10)
			DECLARE @dblGradeReading2			   DECIMAL(24,10)
			DECLARE @dblGradeReading3			   DECIMAL(24,10)
			DECLARE @dblGradeReading4			   DECIMAL(24,10)
			DECLARE @dblGradeReading5			   DECIMAL(24,10)
			DECLARE @dblGradeReading6			   DECIMAL(24,10)
			DECLARE @dblGradeReading7			   DECIMAL(24,10)
			DECLARE @dblGradeReading8			   DECIMAL(24,10)
			DECLARE @dblGradeReading9			   DECIMAL(24,10)
			DECLARE @dblGradeReading10			   DECIMAL(24,10)
			DECLARE @dblGradeReading11			   DECIMAL(24,10)
			DECLARE @dblGradeReading12			   DECIMAL(24,10)
												   
			DECLARE @strCalcMethod1				   NVARCHAR(30)
			DECLARE @strCalcMethod2				   NVARCHAR(30)
			DECLARE @strCalcMethod3				   NVARCHAR(30)
			DECLARE @strCalcMethod4				   NVARCHAR(30)
			DECLARE @strCalcMethod5				   NVARCHAR(30)
			DECLARE @strCalcMethod6				   NVARCHAR(30)
			DECLARE @strCalcMethod7				   NVARCHAR(30)
			DECLARE @strCalcMethod8				   NVARCHAR(30)
			DECLARE @strCalcMethod9				   NVARCHAR(30)
			DECLARE @strCalcMethod10			   NVARCHAR(30)
			DECLARE @strCalcMethod11			   NVARCHAR(30)
			DECLARE @strCalcMethod12			   NVARCHAR(30)
												   
			DECLARE @strShrinkWhat1				   NVARCHAR(30)
			DECLARE @strShrinkWhat2				   NVARCHAR(30)
			DECLARE @strShrinkWhat3				   NVARCHAR(30)
			DECLARE @strShrinkWhat4				   NVARCHAR(30)
			DECLARE @strShrinkWhat5				   NVARCHAR(30)
			DECLARE @strShrinkWhat6				   NVARCHAR(30)
			DECLARE @strShrinkWhat7				   NVARCHAR(30)
			DECLARE @strShrinkWhat8				   NVARCHAR(30)
			DECLARE @strShrinkWhat9				   NVARCHAR(30)
			DECLARE @strShrinkWhat10			   NVARCHAR(30)
			DECLARE @strShrinkWhat11			   NVARCHAR(30)
			DECLARE @strShrinkWhat12			   NVARCHAR(30)
												   
			DECLARE @dblShrinkPercent1			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent2			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent3			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent4			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent5			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent6			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent7			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent8			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent9			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent10			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent11			   DECIMAL(24,10)
			DECLARE @dblShrinkPercent12			   DECIMAL(24,10)
												   
			DECLARE @dblDiscountAmount1			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount2			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount3			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount4			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount5			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount6			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount7			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount8			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount9			   DECIMAL(24,10)
			DECLARE @dblDiscountAmount10		   DECIMAL(24,10)
			DECLARE @dblDiscountAmount11		   DECIMAL(24,10)
			DECLARE @dblDiscountAmount12		   DECIMAL(24,10)
												   
			DECLARE @dblDiscountPaid1			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid2			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid3			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid4			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid5			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid6			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid7			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid8			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid9			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid10			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid11			   DECIMAL(24,10)
			DECLARE @dblDiscountPaid12			   DECIMAL(24,10)
			
			DECLARE @intDiscountScheduleCodeId1    INT
			DECLARE @intDiscountScheduleCodeId2    INT
			DECLARE @intDiscountScheduleCodeId3    INT
			DECLARE @intDiscountScheduleCodeId4    INT
			DECLARE @intDiscountScheduleCodeId5    INT
			DECLARE @intDiscountScheduleCodeId6    INT
			DECLARE @intDiscountScheduleCodeId7    INT
			DECLARE @intDiscountScheduleCodeId8    INT
			DECLARE @intDiscountScheduleCodeId9    INT
			DECLARE @intDiscountScheduleCodeId10   INT
			DECLARE @intDiscountScheduleCodeId11   INT
			DECLARE @intDiscountScheduleCodeId12   INT
			
			DECLARE @strDiscountCode1			   NVARCHAR(10)
			DECLARE @strDiscountCode2			   NVARCHAR(10)
			DECLARE @strDiscountCode3			   NVARCHAR(10)
			DECLARE @strDiscountCode4			   NVARCHAR(10)
			DECLARE @strDiscountCode5			   NVARCHAR(10)
			DECLARE @strDiscountCode6			   NVARCHAR(10)
			DECLARE @strDiscountCode7			   NVARCHAR(10)
			DECLARE @strDiscountCode8			   NVARCHAR(10)
			DECLARE @strDiscountCode9			   NVARCHAR(10)
			DECLARE @strDiscountCode10			   NVARCHAR(10)
			DECLARE @strDiscountCode11			   NVARCHAR(10)
			DECLARE @strDiscountCode12			   NVARCHAR(10)
			
			DECLARE @ysnGraderAutoEntry			   BIT
			DECLARE @dtmDiscountPaidDate		   DateTime
			DECLARE @strCurrency				   NVARCHAR(30)
			DECLARE @strCommodityCode			   NVARCHAR(30)
			DECLARE @intStorageTypeId			   INT
			DECLARE @strStorageTypeCode			   NVARCHAR(30)
			DECLARE @strDiscountDescription		   NVARCHAR(30)
			
			SET @intConcurrencyId = 1
			SET @strSourceType ='Storage'
			SET @strDiscountChargeType='Dollar'
			SET @ysnGraderAutoEntry=0
			SET @dtmDiscountPaidDate=NULL


			DECLARE @tblDiscountCode AS TABLE
			(
			   intDiscountScheduleCodeId	 INT
			  ,intShrinkCalculationOptionId  INT
			  ,strCurrency					 NVARCHAR(50) COLLATE Latin1_General_CS_AS 
			  ,strCommodityCode				 NVARCHAR(50) COLLATE Latin1_General_CS_AS
			  ,intStorageTypeId				 INT 
			  ,strStorageTypeCode			 NVARCHAR(50) COLLATE Latin1_General_CS_AS  
			  ,strShortName					 NVARCHAR(50) COLLATE Latin1_General_CS_AS
			  ,strDiscountDescription		 NVARCHAR(50) COLLATE Latin1_General_CS_AS
			)
			INSERT INTO @tblDiscountCode
			(
			   intDiscountScheduleCodeId
			  ,intShrinkCalculationOptionId
			  ,strCurrency
			  ,strCommodityCode
			  ,intStorageTypeId
			  ,strStorageTypeCode
			  ,strShortName
			  ,strDiscountDescription
			 )
			SELECT
			 intDiscountScheduleCodeId	  = DSO.intDiscountScheduleCodeId
			,intShrinkCalculationOptionId = DSO.intShrinkCalculationOptionId 
			,strCurrency				  = CUR.strCurrency
			,strCommodityCode			  = COM.strCommodityCode
			,intStorageTypeId			  = DSO.intStorageTypeId
			,strStorageTypeCode			  = ST.strStorageTypeCode
			,strShortName				  = Item.strShortName
			,strDiscountDescription		  = DS.strDiscountDescription
			FROM tblGRDiscountScheduleCode DSO
			JOIN tblICItem Item ON Item.intItemId=DSO.intItemId
			JOIN tblGRDiscountSchedule DS ON DS.intDiscountScheduleId=DSO.intDiscountScheduleId
			JOIN tblICCommodity COM ON COM.intCommodityId=DS.intCommodityId
			JOIN tblSMCurrency  CUR ON CUR.intCurrencyID=DS.intCurrencyId
			JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId=DSO.intStorageTypeId


			SET IDENTITY_INSERT [dbo].[tblGRCustomerStorage] ON

				INSERT INTO tblGRCustomerStorage
				(
				   intCustomerStorageId
				  ,intConcurrencyId
				  ,intEntityId
				  ,intCommodityId
				  ,intStorageTypeId
				  ,intStorageScheduleId
				  ,intCompanyLocationId
				  ,intTicketId
				  ,intDiscountScheduleId
				  ,dblOriginalBalance
				  ,dblOpenBalance
				  ,dtmDeliveryDate
				  ,strDPARecieptNumber
				  --,dtmLastStorageAccrueDate
				  ,dblStorageDue
				  ,dblStoragePaid
				  ,dblInsuranceRate
				  ,strOriginState
				  ,strInsuranceState
				  ,dblFeesDue
				  ,dblFeesPaid
				  ,dblFreightDueRate
				  ,ysnPrinted
				  ,dblCurrencyRate
				  ,strDiscountComment
				  ,dblDiscountsDue
				  ,dblDiscountsPaid
				  ,strCustomerReference
				  --,strStorageType
				  ,intCurrencyId
				  ,strStorageTicketNumber
				  ,intItemId
				  ,intCompanyLocationSubLocationId
				  ,intStorageLocationId
				  ,intUnitMeasureId
				)
				SELECT
				  intCustomerStorageId			  = a.A4GLIdentity
				 ,intConcurrencyId				  = 1
				 ,intEntityId					  = t.intEntityId
				 ,intCommodityId				  = Com.intCommodityId
				 ,intStorageTypeId				  = St.intStorageScheduleTypeId
				 ,intStorageScheduleId			  = Sr.intStorageScheduleRuleId
				 ,intCompanyLocationId			  = L.intCompanyLocationId 
				 ,intTicketId					  = a.A4GLIdentity
				 ,intDiscountScheduleId			  = a.gastr_disc_schd_no
				 ,dblOriginalBalance			  = a.gastr_orig_un
				 ,dblOpenBalance				  = a.gastr_un_bal   
				 ,dtmDeliveryDate				  = Convert(Date,CAST(a.gastr_dlvry_rev_dt AS Nvarchar))  
				 ,strDPARecieptNumber			  = a.gastr_dpa_or_rcpt_no  
				 ,dblStorageDue					  = a.gastr_un_stor_due
				 ,dblStoragePaid				  = a.gastr_un_stor_pd
				 ,dblInsuranceRate				  = a.gastr_un_ins_rt
				 ,strOriginState				  = LTRIM(RTRIM(a.gastr_origin_state))
				 ,strInsuranceState				  = LTRIM(RTRIM(a.gastr_ins_state))
				 ,dblFeesDue					  = a.gastr_fees_due  
				 ,dblFeesPaid					  = a.gastr_fees_pd  
				 ,dblFreightDueRate				  = a.gastr_un_frt_rt 
				 ,ysnPrinted					  = 0 
				 ,dblCurrencyRate				  = a.gastr_currency_rt
				 ,strDiscountComment			  = LTRIM(RTRIM(a.gastr_tic_comment))
				 ,dblDiscountsDue				  = a.gastr_un_disc_due
				 ,dblDiscountsPaid				  = a.gastr_un_disc_pd
				 ,strCustomerReference			  = LTRIM(RTRIM(a.gastr_cus_ref_no ))
				 ,intCurrencyId					  = Cur.intCurrencyID
				 ,strStorageTicketNumber		  = LTRIM(RTRIM(a.gastr_tic_no))
				 ,intItemId						  = (SELECT TOP 1 intItemId FROM tblICItem WHERE strType='Inventory' AND strItemNo Like 
																																 CASE 
																																      WHEN a.gastr_com_cd='B' THEN 'B%'
																																	  WHEN a.gastr_com_cd='C' THEN 'C%'
																																	  WHEN a.gastr_com_cd='H' THEN 'H%'
																																	  WHEN a.gastr_com_cd='M' THEN 'M%'
																																	  WHEN a.gastr_com_cd='S' THEN 'S%'
																																	  WHEN a.gastr_com_cd='W' THEN 'W%'
																																 END			
																																 ) 
				,intCompanyLocationSubLocationId = NULL 
				,intStorageLocationId			 = bin.intStorageLocationId
				,intUnitMeasureId				 = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol=UOM.gacom_un_desc COLLATE  Latin1_General_CS_AS)
				FROM gastrmst a
				JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType IN('Vendor','Customer') AND ISNULL(EY.strEntityNo,'')<>'' --AND EY.ysnActive =1
					) t  WHERE intRowNum = 1

				)   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(a.gastr_cus_no))
				AND t.strType = 'Vendor'
				JOIN tblICCommodity Com ON Com.strCommodityCode=LTRIM(RTRIM(a.gastr_com_cd)) COLLATE  Latin1_General_CS_AS
				JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=a.gastr_stor_type
				JOIN tblGRStorageScheduleRule Sr ON Sr.intStorageType=St.intStorageScheduleTypeId AND Sr.intCommodity=Com.intCommodityId
				JOIN tblSMCompanyLocation L ON L.strLocationNumber=LTRIM(RTRIM(a.gastr_loc_no)) COLLATE  Latin1_General_CS_AS
				JOIN	tblGRDiscountSchedule	DSch ON DSch.strDiscountDescription collate Latin1_General_CI_AS =  CASE WHEN LTRIM(RTRIM(a.gastr_disc_schd_no))='0' THEN Com.strDescription +' Discount' ELSE LTRIM(RTRIM(a.gastr_disc_schd_no)) END AND DSch.intCommodityId = Com.intCommodityId
				JOIN tblSMCurrency Cur ON Cur.strCurrency=a.gastr_currency COLLATE  Latin1_General_CS_AS
				JOIN gacommst UOM ON UOM.gacom_com_cd=a.gastr_com_cd
				LEFT JOIN tblICStorageLocation bin ON bin.strName=a.gastr_bin_no COLLATE  Latin1_General_CS_AS
				WHERE a.gastr_un_bal >0  AND a.gastr_pur_sls_ind='P'
				
				UNION 
				SELECT
				  intCustomerStorageId	 =  a.A4GLIdentity
				 ,intConcurrencyId	     = 1 
				 ,intEntityId		     = t.intEntityId
				 ,intCommodityId		 = Com.intCommodityId
				 ,intStorageTypeId		 = (SELECT intStorageScheduleTypeId FROM tblGRStorageType WHERE ysnCustomerStorage=1 AND strStorageTypeCode=LTRIM(a.gastr_stor_type)+' O')
				 ,intStorageScheduleId	 = Sr.intStorageScheduleRuleId
				 ,intCompanyLocationId	 = L.intCompanyLocationId 
				 ,intTicketId			 = a.A4GLIdentity 
				 ,intDiscountScheduleId  = a.gastr_disc_schd_no
				 ,dblOriginalBalance	 = a.gastr_orig_un
				 ,dblOpenBalance		 = a.gastr_un_bal  
				 ,dtmDeliveryDate		 = Convert(Date,CAST(a.gastr_dlvry_rev_dt AS Nvarchar)) 
				 ,strDPARecieptNumber	 = a.gastr_dpa_or_rcpt_no 
				 ,dblStorageDue			 = a.gastr_un_stor_due 
				 ,dblStoragePaid		 = a.gastr_un_stor_pd
				 ,dblInsuranceRate		 = a.gastr_un_ins_rt
				 ,strOriginState		 = LTRIM(RTRIM(a.gastr_origin_state))
				 ,strInsuranceState		 = LTRIM(RTRIM(a.gastr_ins_state))
				 ,dblFeesDue			 = a.gastr_fees_due
				 ,dblFeesPaid			 = a.gastr_fees_pd
				 ,dblFreightDueRate		 = a.gastr_un_frt_rt	
				 ,ysnPrinted			 = 0 
				 ,dblCurrencyRate		 = a.gastr_currency_rt
				 ,strDiscountComment	 = LTRIM(RTRIM(a.gastr_tic_comment))
				 ,dblDiscountsDue		 = a.gastr_un_disc_due
				 ,dblDiscountsPaid		 = a.gastr_un_disc_pd
				 ,strCustomerReference	 = LTRIM(RTRIM(a.gastr_cus_ref_no ))
				 ,intCurrencyId			 = Cur.intCurrencyID
				 ,strStorageTicketNumber = LTRIM(RTRIM(a.gastr_tic_no))
				,intItemId				 = (SELECT TOP 1 intItemId FROM tblICItem WHERE strType='Inventory' AND strItemNo Like 
																															 CASE 
																															      WHEN a.gastr_com_cd='B' THEN 'B%'
																															 	  WHEN a.gastr_com_cd='C' THEN 'Corn%'
																															 	  WHEN a.gastr_com_cd='H' THEN 'H%'
																															 	  WHEN a.gastr_com_cd='M' THEN 'M%'
																															 	  WHEN a.gastr_com_cd='S' THEN 'S%'
																															 	  WHEN a.gastr_com_cd='W' THEN 'W%'
																															 END			
																															 ) 
				,intCompanyLocationSubLocationId = NULL
				,intStorageLocationId			 = bin.intStorageLocationId
				,(SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol=UOM.gacom_un_desc COLLATE  Latin1_General_CS_AS) AS intUnitMeasureId
				FROM gastrmst a
				JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType IN('Vendor','Customer') AND ISNULL(EY.strEntityNo,'')<>'' --AND EY.ysnActive =1
					) t  WHERE intRowNum = 1

				)   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(a.gastr_cus_no))
				AND t.strType = 'Customer'
				JOIN tblICCommodity Com ON Com.strCommodityCode=a.gastr_com_cd COLLATE  Latin1_General_CS_AS
				JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=a.gastr_stor_type
				JOIN tblGRStorageScheduleRule Sr ON Sr.intStorageType=St.intStorageScheduleTypeId AND Sr.intCommodity=Com.intCommodityId
				JOIN tblSMCompanyLocation L ON L.strLocationNumber=LTRIM(RTRIM(a.gastr_loc_no)) COLLATE  Latin1_General_CS_AS				
				JOIN	tblGRDiscountSchedule	DSch ON DSch.strDiscountDescription collate Latin1_General_CI_AS =  CASE WHEN LTRIM(RTRIM(a.gastr_disc_schd_no))='0' THEN Com.strDescription +' Discount' ELSE LTRIM(RTRIM(a.gastr_disc_schd_no)) END AND DSch.intCommodityId = Com.intCommodityId
				JOIN tblSMCurrency Cur ON Cur.strCurrency=a.gastr_currency COLLATE  Latin1_General_CS_AS 
				JOIN gacommst UOM ON UOM.gacom_com_cd=a.gastr_com_cd
				LEFT JOIN tblICStorageLocation bin ON bin.strName=a.gastr_bin_no COLLATE  Latin1_General_CS_AS
				WHERE a.gastr_un_bal >0  AND a.gastr_pur_sls_ind='S' 
				
				UNION 
				SELECT
				  intCustomerStorageId	 =  a.A4GLIdentity
				 ,intConcurrencyId	     = 1 
				 ,intEntityId		     = t.intEntityId
				 ,intCommodityId		 = Com.intCommodityId
				 ,intStorageTypeId		 = (SELECT intStorageScheduleTypeId FROM tblGRStorageType WHERE ysnCustomerStorage=1 AND strStorageTypeCode=LTRIM(a.gastr_stor_type)+' O')
				 ,intStorageScheduleId	 = Sr.intStorageScheduleRuleId
				 ,intCompanyLocationId	 = L.intCompanyLocationId 
				 ,intTicketId			 = a.A4GLIdentity 
				 ,intDiscountScheduleId  = a.gastr_disc_schd_no
				 ,dblOriginalBalance	 = a.gastr_orig_un
				 ,dblOpenBalance		 = a.gastr_un_bal  
				 ,dtmDeliveryDate		 = Convert(Date,CAST(a.gastr_dlvry_rev_dt AS Nvarchar)) 
				 ,strDPARecieptNumber	 = a.gastr_dpa_or_rcpt_no 
				 ,dblStorageDue			 = a.gastr_un_stor_due 
				 ,dblStoragePaid		 = a.gastr_un_stor_pd
				 ,dblInsuranceRate		 = a.gastr_un_ins_rt
				 ,strOriginState		 = LTRIM(RTRIM(a.gastr_origin_state))
				 ,strInsuranceState		 = LTRIM(RTRIM(a.gastr_ins_state))
				 ,dblFeesDue			 = a.gastr_fees_due
				 ,dblFeesPaid			 = a.gastr_fees_pd
				 ,dblFreightDueRate		 = a.gastr_un_frt_rt	
				 ,ysnPrinted			 = 0 
				 ,dblCurrencyRate		 = a.gastr_currency_rt
				 ,strDiscountComment	 = LTRIM(RTRIM(a.gastr_tic_comment))
				 ,dblDiscountsDue		 = a.gastr_un_disc_due
				 ,dblDiscountsPaid		 = a.gastr_un_disc_pd
				 ,strCustomerReference	 = LTRIM(RTRIM(a.gastr_cus_ref_no ))
				 ,intCurrencyId			 = Cur.intCurrencyID
				 ,strStorageTicketNumber = LTRIM(RTRIM(a.gastr_tic_no))
				,intItemId				 = (SELECT TOP 1 intItemId FROM tblICItem WHERE strType='Inventory' AND strItemNo Like 
																															 CASE 
																															      WHEN a.gastr_com_cd='B' THEN 'B%'
																															 	  WHEN a.gastr_com_cd='C' THEN 'Corn%'
																															 	  WHEN a.gastr_com_cd='H' THEN 'H%'
																															 	  WHEN a.gastr_com_cd='M' THEN 'M%'
																															 	  WHEN a.gastr_com_cd='S' THEN 'S%'
																															 	  WHEN a.gastr_com_cd='W' THEN 'W%'
																															 END			
																															 ) 
				,intCompanyLocationSubLocationId = NULL
				,intStorageLocationId			 = bin.intStorageLocationId
				,(SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol=UOM.gacom_un_desc COLLATE  Latin1_General_CS_AS) AS intUnitMeasureId
				FROM gastrmst a
				JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType IN('Vendor','Customer') AND ISNULL(EY.strEntityNo,'')<>'' --AND EY.ysnActive =1
					) t  WHERE intRowNum = 1

				)   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(a.gastr_cus_no))
				AND t.strType = CASE  WHEN a.gastr_pur_sls_ind='P' THEN 'Vendor' ELSE 'Customer' END
				JOIN tblICCommodity Com ON Com.strCommodityCode=a.gastr_com_cd COLLATE  Latin1_General_CS_AS
				JOIN tblGRStorageType St ON St.intStorageScheduleTypeId=a.gastr_stor_type
				JOIN tblGRStorageScheduleRule Sr ON Sr.intStorageType=St.intStorageScheduleTypeId AND Sr.intCommodity=Com.intCommodityId
				JOIN tblSMCompanyLocation L ON L.strLocationNumber=LTRIM(RTRIM(a.gastr_loc_no)) COLLATE  Latin1_General_CS_AS				
				JOIN	tblGRDiscountSchedule	DSch ON DSch.strDiscountDescription collate Latin1_General_CI_AS =  CASE WHEN LTRIM(RTRIM(a.gastr_disc_schd_no))='0' THEN Com.strDescription +' Discount' ELSE LTRIM(RTRIM(a.gastr_disc_schd_no)) END AND DSch.intCommodityId = Com.intCommodityId
				JOIN tblSMCurrency Cur ON Cur.strCurrency=a.gastr_currency COLLATE  Latin1_General_CS_AS 
				JOIN gacommst UOM ON UOM.gacom_com_cd = a.gastr_com_cd
				JOIN  gastlmst GT ON GT.gastl_cus_no = a.gastr_cus_no		AND 
									 GT.gastl_com_cd = a.gastr_com_cd		AND
									 GT.gastl_tic_no = a.gastr_tic_no		AND
									 GT.gastl_rec_type = a.gastr_stor_type
				LEFT JOIN tblICStorageLocation bin ON bin.strName=a.gastr_bin_no COLLATE  Latin1_General_CS_AS
				WHERE a.gastr_un_bal = 0  AND GT.gastl_pd_yn <> 'Y' 

			SET IDENTITY_INSERT [dbo].[tblGRCustomerStorage] OFF


		--Quality Discount Data
		SELECT @intCustomerStorageId = MIN(intCustomerStorageId) FROM tblGRCustomerStorage
		
		WHILE @intCustomerStorageId >0
		BEGIN
		
		SET  @dblGradeReading1 = NULL
		SET  @dblGradeReading2 = NULL
		SET  @dblGradeReading3 = NULL
		SET  @dblGradeReading4 = NULL
		SET  @dblGradeReading5 = NULL
		SET  @dblGradeReading6 = NULL
		SET  @dblGradeReading7 = NULL
		SET  @dblGradeReading8 = NULL
		SET  @dblGradeReading9 = NULL
		SET  @dblGradeReading10 = NULL
		SET  @dblGradeReading11 = NULL
		SET  @dblGradeReading12 = NULL
		
		SET  @strCalcMethod1  = NULL
		SET  @strCalcMethod2  = NULL
		SET  @strCalcMethod3  = NULL
		SET  @strCalcMethod4  = NULL
		SET  @strCalcMethod5  = NULL
		SET  @strCalcMethod6  = NULL
		SET  @strCalcMethod7  = NULL
		SET  @strCalcMethod8  = NULL
		SET  @strCalcMethod9  = NULL
		SET  @strCalcMethod10  = NULL
		SET  @strCalcMethod11  = NULL
		SET  @strCalcMethod12  = NULL
		
		SET  @strShrinkWhat1    = NULL
		SET  @strShrinkWhat2    = NULL
		SET  @strShrinkWhat3    = NULL
		SET  @strShrinkWhat4    = NULL
		SET  @strShrinkWhat5    = NULL
		SET  @strShrinkWhat6    = NULL
		SET  @strShrinkWhat7    = NULL
		SET  @strShrinkWhat8    = NULL
		SET  @strShrinkWhat9    = NULL
		SET  @strShrinkWhat10    = NULL
		SET  @strShrinkWhat11    = NULL
		SET  @strShrinkWhat12    = NULL
		
		SET  @dblShrinkPercent1 = NULL
		SET  @dblShrinkPercent2 = NULL
		SET  @dblShrinkPercent3 = NULL
		SET  @dblShrinkPercent4 = NULL
		SET  @dblShrinkPercent5 = NULL
		SET  @dblShrinkPercent6 = NULL
		SET  @dblShrinkPercent7 = NULL
		SET  @dblShrinkPercent8 = NULL
		SET  @dblShrinkPercent9 = NULL
		SET  @dblShrinkPercent10 = NULL
		SET  @dblShrinkPercent11 = NULL
		SET  @dblShrinkPercent12 = NULL
		
		SET  @dblDiscountAmount1 = NULL
		SET  @dblDiscountAmount2 = NULL
		SET  @dblDiscountAmount3 = NULL
		SET  @dblDiscountAmount4 = NULL
		SET  @dblDiscountAmount5 = NULL
		SET  @dblDiscountAmount6 = NULL
		SET  @dblDiscountAmount7 = NULL
		SET  @dblDiscountAmount8 = NULL
		SET  @dblDiscountAmount9 = NULL
		SET  @dblDiscountAmount10 = NULL
		SET  @dblDiscountAmount11 = NULL
		SET  @dblDiscountAmount12 = NULL
		
		SET  @dblDiscountPaid1 = NULL
		SET  @dblDiscountPaid2 = NULL
		SET  @dblDiscountPaid3 = NULL
		SET  @dblDiscountPaid4 = NULL
		SET  @dblDiscountPaid5 = NULL
		SET  @dblDiscountPaid6 = NULL
		SET  @dblDiscountPaid7 = NULL
		SET  @dblDiscountPaid8 = NULL
		SET  @dblDiscountPaid9 = NULL
		SET  @dblDiscountPaid10 = NULL
		SET  @dblDiscountPaid11 = NULL
		SET  @dblDiscountPaid12 = NULL
		
		SET  @intDiscountScheduleCodeId1 = NULL
		SET  @intDiscountScheduleCodeId2 = NULL
		SET  @intDiscountScheduleCodeId3 = NULL
		SET  @intDiscountScheduleCodeId4 = NULL
		SET  @intDiscountScheduleCodeId5 = NULL
		SET  @intDiscountScheduleCodeId6 = NULL
		SET  @intDiscountScheduleCodeId7 = NULL
		SET  @intDiscountScheduleCodeId8 = NULL
		SET  @intDiscountScheduleCodeId9 = NULL
		SET  @intDiscountScheduleCodeId10 = NULL
		SET  @intDiscountScheduleCodeId11 = NULL
		SET  @intDiscountScheduleCodeId12 = NULL
		
		SET  @strCurrency = NULL
		SET  @strCommodityCode = NULL
		SET  @intStorageTypeId = NULL
		SET  @strStorageTypeCode = NULL
		SET  @strDiscountDescription = NULL
		
		---1.
		
		SELECT 
		 @dblGradeReading1=gastr_reading_1
		,@dblGradeReading2=gastr_reading_2
		,@dblGradeReading3=gastr_reading_3
		,@dblGradeReading4=gastr_reading_4
		,@dblGradeReading5=gastr_reading_5
		,@dblGradeReading6=gastr_reading_6
		,@dblGradeReading7=gastr_reading_7
		,@dblGradeReading8=gastr_reading_8
		,@dblGradeReading9=gastr_reading_9
		,@dblGradeReading10=gastr_reading_10
		,@dblGradeReading11=gastr_reading_11
		,@dblGradeReading12=gastr_reading_12
		
		,@strCalcMethod1  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='P'THEN 3
						   END
		,@strCalcMethod2  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='P'THEN 3
						   END
		,@strCalcMethod3  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='P'THEN 3
						   END
		,@strCalcMethod4  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='P'THEN 3
						   END
		,@strCalcMethod5  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='P'THEN 3
						   END
		,@strCalcMethod6  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='P'THEN 3
						   END
		,@strCalcMethod7  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='P'THEN 3
						   END
		,@strCalcMethod8  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='P'THEN 3
						   END
		,@strCalcMethod9  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='P'THEN 3
						   END
		,@strCalcMethod10  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='P'THEN 3
						   END
		,@strCalcMethod11  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='P'THEN 3
						   END
		,@strCalcMethod12  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='N'THEN 1
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='W'THEN 2
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='P'THEN 3
						    END
		
		, @strShrinkWhat1  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_1,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat2  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_2,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat3  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_3,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat4  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_4,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat5  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_5,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat6  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_6,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat7  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_7,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat8  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_8,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat9  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_9,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat10  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_10,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat11  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_11,'N')))='P'THEN 'Gross Weight'
						   END
		,@strShrinkWhat12  = CASE 
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='N'THEN 'Net Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='W'THEN 'Wet Weight'
								WHEN LTRIM(RTRIM(ISNULL(gastr_shrk_what_12,'N')))='P'THEN 'Gross Weight'
						   END
		
		,@dblShrinkPercent1=gastr_shrk_pct_1
		,@dblShrinkPercent2=gastr_shrk_pct_2
		,@dblShrinkPercent3=gastr_shrk_pct_3
		,@dblShrinkPercent4=gastr_shrk_pct_4
		,@dblShrinkPercent5=gastr_shrk_pct_5
		,@dblShrinkPercent6=gastr_shrk_pct_6
		,@dblShrinkPercent7=gastr_shrk_pct_7
		,@dblShrinkPercent8=gastr_shrk_pct_8
		,@dblShrinkPercent9=gastr_shrk_pct_9
		,@dblShrinkPercent10=gastr_shrk_pct_10
		,@dblShrinkPercent11=gastr_shrk_pct_11
		,@dblShrinkPercent12=gastr_shrk_pct_12
		
		,@dblDiscountAmount1=gastr_un_disc_amt_1
		,@dblDiscountAmount2=gastr_un_disc_amt_2
		,@dblDiscountAmount3=gastr_un_disc_amt_3
		,@dblDiscountAmount4=gastr_un_disc_amt_4
		,@dblDiscountAmount5=gastr_un_disc_amt_5
		,@dblDiscountAmount6=gastr_un_disc_amt_6
		,@dblDiscountAmount7=gastr_un_disc_amt_7
		,@dblDiscountAmount8=gastr_un_disc_amt_8
		,@dblDiscountAmount9=gastr_un_disc_amt_9
		,@dblDiscountAmount10=gastr_un_disc_amt_10
		,@dblDiscountAmount11=gastr_un_disc_amt_11
		,@dblDiscountAmount12=gastr_un_disc_amt_12
		
		,@dblDiscountPaid1=gastr_un_disc_bill_1
		,@dblDiscountPaid2=gastr_un_disc_bill_2
		,@dblDiscountPaid3=gastr_un_disc_bill_3
		,@dblDiscountPaid4=gastr_un_disc_bill_4
		,@dblDiscountPaid5=gastr_un_disc_bill_5
		,@dblDiscountPaid6=gastr_un_disc_bill_6
		,@dblDiscountPaid7=gastr_un_disc_bill_7
		,@dblDiscountPaid8=gastr_un_disc_bill_8
		,@dblDiscountPaid9=gastr_un_disc_bill_9
		,@dblDiscountPaid10=gastr_un_disc_bill_10
		,@dblDiscountPaid11=gastr_un_disc_bill_11
		,@dblDiscountPaid12=gastr_un_disc_bill_12
		
		,@strDiscountCode1=ISNULL(gastr_disc_cd_1,'')
		,@strDiscountCode2=ISNULL(gastr_disc_cd_2,'')
		,@strDiscountCode3=ISNULL(gastr_disc_cd_3,'')
		,@strDiscountCode4=ISNULL(gastr_disc_cd_4,'')
		,@strDiscountCode5=ISNULL(gastr_disc_cd_5,'')
		,@strDiscountCode6=ISNULL(gastr_disc_cd_6,'')
		,@strDiscountCode7=ISNULL(gastr_disc_cd_7,'')
		,@strDiscountCode8=ISNULL(gastr_disc_cd_8,'')
		,@strDiscountCode9=ISNULL(gastr_disc_cd_9,'')
		,@strDiscountCode10=ISNULL(gastr_disc_cd_10,'')
		,@strDiscountCode11=ISNULL(gastr_disc_cd_11,'')
		,@strDiscountCode12=ISNULL(gastr_disc_cd_12,'')
		,@strCurrency = LTRIM(RTRIM(gastr_currency))
		,@strCommodityCode = LTRIM(RTRIM(gastr_com_cd))
		,@intStorageTypeId=gastr_stor_type
		,@strDiscountDescription = LTRIM(RTRIM(gastr_disc_schd_no))
		FROM gastrmst WHERE A4GLIdentity = @intCustomerStorageId
		
		SELECT @strStorageTypeCode =strStorageTypeCode FROM tblGRStorageType WHERE intStorageScheduleTypeId=@intStorageTypeId
		
		IF @strDiscountCode1 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId1=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod1
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode1 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId1 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId1=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode1 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading1
			,@strCalcMethod1
			,@strShrinkWhat1
			,@dblShrinkPercent1
			,@dblDiscountAmount1
			,@dblDiscountAmount1
			,@dblDiscountPaid1
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId1
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,1
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode2 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId2=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod2
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode2 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId2 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId2=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode2 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading2
			,@strCalcMethod2
			,@strShrinkWhat2
			,@dblShrinkPercent2
			,@dblDiscountAmount2
			,@dblDiscountAmount2
			,@dblDiscountPaid2
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId2
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,2
			,@strDiscountChargeType
		
		END
		
		IF @strDiscountCode3 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId3=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod3
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode3 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId3 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId3=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode3 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading3
			,@strCalcMethod3
			,@strShrinkWhat3
			,@dblShrinkPercent3
			,@dblDiscountAmount3
			,@dblDiscountAmount3
			,@dblDiscountPaid3
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId3
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,3
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode4 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId4=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod4
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode4 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId4 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId4=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode4 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading4
			,@strCalcMethod4
			,@strShrinkWhat4
			,@dblShrinkPercent4
			,@dblDiscountAmount4
			,@dblDiscountAmount4
			,@dblDiscountPaid4
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId4
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,4
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode5 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId5=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod5
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode5 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId5 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId5=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode5 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading5
			,@strCalcMethod5
			,@strShrinkWhat5
			,@dblShrinkPercent5
			,@dblDiscountAmount5
			,@dblDiscountAmount5
			,@dblDiscountPaid5
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId5
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,5
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode6 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId6=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod6
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode6 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId6 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId6=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode6 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading6
			,@strCalcMethod6
			,@strShrinkWhat6
			,@dblShrinkPercent6
			,@dblDiscountAmount6
			,@dblDiscountAmount6
			,@dblDiscountPaid6
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId6
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,6
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode7 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId7=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod7
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode7 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId7 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId7=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode7 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading7
			,@strCalcMethod7
			,@strShrinkWhat7
			,@dblShrinkPercent7
			,@dblDiscountAmount7
			,@dblDiscountAmount7
			,@dblDiscountPaid7
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId7
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,7
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode8 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId8=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod8
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode8 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId8 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId8=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode8 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading8
			,@strCalcMethod8
			,@strShrinkWhat8
			,@dblShrinkPercent8
			,@dblDiscountAmount8
			,@dblDiscountAmount8
			,@dblDiscountPaid8
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId8
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,8
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode9 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId9=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod9
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode9 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId9 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId9=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode9 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading9
			,@strCalcMethod9
			,@strShrinkWhat9
			,@dblShrinkPercent9
			,@dblDiscountAmount9
			,@dblDiscountAmount9
			,@dblDiscountPaid9
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId9
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,9
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode10 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId10=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod10
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode10 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId10 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId10=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode10 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading10
			,@strCalcMethod10
			,@strShrinkWhat10
			,@dblShrinkPercent10
			,@dblDiscountAmount10
			,@dblDiscountAmount10
			,@dblDiscountPaid10
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId10
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,10
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode11 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId11=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod11
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode11 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId11 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId11=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode11 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading11
			,@strCalcMethod11
			,@strShrinkWhat11
			,@dblShrinkPercent11
			,@dblDiscountAmount11
			,@dblDiscountAmount11
			,@dblDiscountPaid11
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId11
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,11
			,@strDiscountChargeType
		END
		
		IF @strDiscountCode12 <> ''
		BEGIN
			SELECT TOP 1 @intDiscountScheduleCodeId12=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE intShrinkCalculationOptionId=@strCalcMethod12
			AND strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND intStorageTypeId=@intStorageTypeId AND strShortName=@strDiscountCode12 
			AND strDiscountDescription=@strDiscountDescription
		
			IF @intDiscountScheduleCodeId12 IS NULL
			SELECT TOP 1 @intDiscountScheduleCodeId12=intDiscountScheduleCodeId FROM @tblDiscountCode 
			WHERE strCurrency=@strCurrency AND strCommodityCode=@strCommodityCode 
			AND strStorageTypeCode='C' AND strShortName=@strDiscountCode12 
			AND strDiscountDescription=@strDiscountDescription
		
			INSERT INTO tblQMTicketDiscount
			(
			 intConcurrencyId
			,dblGradeReading
			,strCalcMethod
			,strShrinkWhat
			,dblShrinkPercent
			,dblDiscountAmount
			,dblDiscountDue
			,dblDiscountPaid
			,ysnGraderAutoEntry
			,intDiscountScheduleCodeId
			,dtmDiscountPaidDate
			,intTicketId
			,intTicketFileId
			,strSourceType
			,intSort
			,strDiscountChargeType
			)
			SELECT 
			 @intConcurrencyId
			,@dblGradeReading12
			,@strCalcMethod12
			,@strShrinkWhat12
			,@dblShrinkPercent12
			,@dblDiscountAmount12
			,@dblDiscountAmount12
			,@dblDiscountPaid12
			,@ysnGraderAutoEntry
			,@intDiscountScheduleCodeId12
			,@dtmDiscountPaidDate
			,NULL
			,@intCustomerStorageId
			,@strSourceType
			,12
			,@strDiscountChargeType
		END

		SELECT @intCustomerStorageId = MIN(intCustomerStorageId) FROM tblGRCustomerStorage WHERE intCustomerStorageId > @intCustomerStorageId

		END

END

GO