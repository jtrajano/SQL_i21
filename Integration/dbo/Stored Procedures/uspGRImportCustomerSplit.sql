IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportCustomerSplit')
	DROP PROCEDURE uspGRImportCustomerSplit
GO

CREATE PROCEDURE uspGRImportCustomerSplit 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	--================================================
	--     IMPORT GRAIN Customer Split
	--================================================
	IF (@Checking = 1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM tblEMEntitySplit)
			SELECT @Total = 0
		ELSE  
			SELECT @Total = COUNT(1)FROM sssplmst

		RETURN @Total
	END

		SET IDENTITY_INSERT tblEMEntitySplit ON

		INSERT INTO tblEMEntitySplit
		(
		   intSplitId  
		  ,intEntityId
		  ,strSplitNumber
		  ,strDescription
		  ,dblAcres
		  ,intCategoryId
		  ,strSplitType
		  ,intConcurrencyId
		)
		SELECT 
		   intSplitId		= OSplit.A4GLIdentity  
		  ,intEntityId		= EY.intEntityId
		  ,strSplitNumber	= LTRIM(RTRIM(OSplit.ssspl_split_no))
		  ,strDescription	= LTRIM(RTRIM(OSplit.ssspl_desc))
		  ,dblAcres			= OSplit.ssspl_acres
		  ,intCategoryId	= NULL
		  ,strSplitType		= 'Both'
		  ,intConcurrencyId = 1
		  FROM sssplmst OSplit
		  JOIN	tblEMEntity EY	ON	LTRIM(RTRIM(EY.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(OSplit.ssspl_bill_to_cus))

	    SET IDENTITY_INSERT tblEMEntitySplit OFF

		INSERT INTO tblEMEntitySplitDetail
		 (
			 intSplitId
			,intEntityId
			,dblSplitPercent
			,strOption
			,intStorageScheduleTypeId
			,intConcurrencyId
		 )
		  SELECT 
		  intSplitId				   = t.A4GLIdentity
		 ,intEntityId			       = EY.intEntityId
		 ,dblSplitPercent			   = t.Percentage
		 ,strOption				       = t.strStorageCode
		 ,intStorageScheduleTypeId     = St.intStorageScheduleTypeId
		 ,intConcurrencyId             = 1
		 FROM
		 ( 
					   SELECT A4GLIdentity,Entity = ssspl_cus_no_1 , Percentage = ssspl_pct_1,strStorageCode=ssspl_option_1 FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_2,ssspl_pct_2,ssspl_option_2    FROM sssplmst  
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_3,ssspl_pct_3,ssspl_option_3    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_4,ssspl_pct_4,ssspl_option_4    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_5,ssspl_pct_5,ssspl_option_5    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_6,ssspl_pct_6,ssspl_option_6    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_7,ssspl_pct_7,ssspl_option_7    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_8,ssspl_pct_8,ssspl_option_8    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_9,ssspl_pct_9,ssspl_option_9    FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_10,ssspl_pct_10,ssspl_option_10 FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_11,ssspl_pct_11,ssspl_option_11 FROM sssplmst 
			  UNION ALL SELECT A4GLIdentity,ssspl_cus_no_12,ssspl_pct_12,ssspl_option_12 FROM sssplmst
		 )t 
		 JOIN	tblEMEntity EY	ON	LTRIM(RTRIM(EY.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(t.Entity))
		 LEFT  JOIN tblGRStorageType St ON St.strStorageTypeCode collate Latin1_General_CI_AS = t.strStorageCode
		 WHERE t.Entity IS NOT NULL AND t.Percentage >0

END