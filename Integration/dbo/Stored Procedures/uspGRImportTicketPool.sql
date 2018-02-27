IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportTicketPool')
	DROP PROCEDURE uspGRImportTicketPool
GO

CREATE PROCEDURE uspGRImportTicketPool 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	
	--================================================
	--     IMPORT Scale Station SetUps
	--================================================
	IF (@Checking = 1)
	BEGIN

		IF EXISTS(SELECT 1 FROM tblSCTicketPool)
			SELECT @Total = 0
		ELSE
			SELECT @Total = COUNT(1) FROM gascimst
		
		RETURN @Total
	END

	 INSERT INTO tblSCTicketPool 
	 (
	 	 strTicketPool
	 	,intNextTicketNumber
	 	,intConcurrencyId
	 )
	 SELECT 
	  strTicketPool		  = t1.strTicketPool		
	 ,intNextTicketNumber = t1.intNextTicketNumber
	 ,intConcurrencyId    = t1.intConcurrencyId
	 FROM
	 (
		SELECT 
			 strTicketPool		 = gatkt_pool
			,intNextTicketNumber = gatkt_next_single_tic_no
			,intConcurrencyId    = 1
		FROM gatktmst
		
		UNION ALL
		
		SELECT 
			 strTicketPool		 = LTRIM(RTRIM(gasci_loc_no)) + LTRIM(RTRIM(gasci_scale_station))
			,intNextTicketNumber = 0
			,intConcurrencyId    = 1
		FROM gascimst
		WHERE LTRIM(RTRIM(ISNULL(gasci_scale_pool, ''))) = ''
	  ) t1
	  LEFT JOIN tblSCTicketPool t2 ON t2.strTicketPool = t1.strTicketPool collate Latin1_General_CI_AS
	  WHERE t2.strTicketPool IS NULL

	 INSERT INTO tblSCTicketType 
	 (
		 intTicketPoolId
		,intListTicketTypeId
		,intNextTicketNumber
		,intDiscountSchedule
		,intDistributionMethod
		,ysnSelectByPO
		,intSplitInvoiceOption
		,intContractRequired
		,intOverrideTicketCopies
		,ysnPrintAtKiosk
		,ynsVerifySplitMethods
		,ysnOverrideSingleTicketSeries
		,intConcurrencyId
		,ysnTicketAllowed
	 )
	 SELECT DISTINCT
	 intTicketPoolId			   = TP.intTicketPoolId
	,intListTicketTypeId		   = LT.intTicketTypeId
	,intNextTicketNumber		   = CASE	
											WHEN LT.intTicketTypeId = 1 THEN gatkt_next_in_tic_no
									 		WHEN LT.intTicketTypeId = 2 THEN gatkt_next_out_tic_no
									 		WHEN LT.intTicketTypeId = 3 THEN gatkt_next_xfer_tic_no
									 		WHEN LT.intTicketTypeId = 4 THEN gatkt_next_xfer_tic_no
									 		WHEN LT.intTicketTypeId = 5 THEN gatkt_next_memo_tic_no
									 		WHEN LT.intTicketTypeId = 7 THEN gatkt_next_ag_tic_no
									 		ELSE 1
									 END
	
	,intDiscountSchedule		   = NULL
	,intDistributionMethod		   = CASE	
											WHEN LT.intTicketTypeId = 1 AND SS.gasci_in_auto_dist_yn = 'Y' THEN 1 
									 		WHEN LT.intTicketTypeId = 1 AND SS.gasci_in_auto_dist_yn = 'N' THEN 2	
									 		WHEN LT.intTicketTypeId = 2 AND SS.gasci_out_auto_dist_yn = 'Y' THEN 1
									 		WHEN LT.intTicketTypeId = 2 AND SS.gasci_out_auto_dist_yn = 'N' THEN 2
									 		ELSE 1
									 END
	,ysnSelectByPO				   = 0
	
	,intSplitInvoiceOption		   = CASE	
											WHEN SS.gasci_split_cus_by_inv = 'N' THEN 1
									 		WHEN SS.gasci_split_cus_by_inv = 'A' THEN 2
									 		WHEN SS.gasci_split_cus_by_inv = 'L' THEN 3
									 END
	
	,intContractRequired		   = CASE	
											WHEN LT.intTicketTypeId = 1 AND SS.gasci_err_on_cnt_exists_in_asw = 'A' THEN 1 
									 		WHEN LT.intTicketTypeId = 1 AND SS.gasci_err_on_cnt_exists_in_asw = 'S' THEN 2		
									 		WHEN LT.intTicketTypeId = 1 AND SS.gasci_err_on_cnt_exists_in_asw = 'W' THEN 3
									 		WHEN LT.intTicketTypeId = 2 AND SS.gasci_err_on_cnt_exists_ot_asw = 'A' THEN 1
									 		WHEN LT.intTicketTypeId = 2 AND SS.gasci_err_on_cnt_exists_ot_asw = 'S' THEN 2
									 		WHEN LT.intTicketTypeId = 2 AND SS.gasci_err_on_cnt_exists_ot_asw = 'W' THEN 3
									 		ELSE 3
									 END

	,intOverrideTicketCopies	   = 0
	,ysnPrintAtKiosk			   = 0
	,ynsVerifySplitMethods		   = 1
	,ysnOverrideSingleTicketSeries = CAST(CASE	WHEN
									 		CASE	WHEN LT.intTicketTypeId = 1 THEN gatkt_in_single_series_yn
									 				WHEN LT.intTicketTypeId = 2 THEN gatkt_out_single_series_yn
									 				WHEN LT.intTicketTypeId = 3 THEN gatkt_xfer_single_series_yn
									 				WHEN LT.intTicketTypeId = 4 THEN gatkt_xfer_single_series_yn
									 				WHEN LT.intTicketTypeId = 5 THEN gatkt_memo_single_series_yn
									 				WHEN LT.intTicketTypeId = 7 THEN gatkt_ag_single_series_yn
									 		END = 'Y'
									 	THEN 1
									 	ELSE 0
									 END AS BIT)
	,intConcurrencyId			   = 1
	,ysnTicketAllowed 			   = 1
	FROM	gatktmst TK 
	JOIN	tblSCTicketPool TP ON LTRIM(RTRIM(TP.strTicketPool)) = LTRIM(RTRIM(TK.gatkt_pool)) collate Latin1_General_CI_AS
	CROSS	
	JOIN	tblSCListTicketTypes	LT
	JOIN	gascimst				SS	ON	SS.gasci_scale_pool collate Latin1_General_CI_AS = TP.strTicketPool OR (LTRIM(RTRIM(ISNULL(SS.gasci_scale_pool,'')))  = '' AND LTRIM(RTRIM(gasci_loc_no)) + LTRIM(RTRIM(gasci_scale_station)) collate Latin1_General_CI_AS = TP.strTicketPool)
	JOIN	galocmst				LO	ON	LO.galoc_loc_no = SS.gasci_loc_no

	 INSERT INTO tblSCDistributionOption 
	 (
	 	 strDistributionOption
	 	,intTicketPoolId
	 	,intTicketTypeId
	 	,ysnDistributionAllowed
	 	,ysnDefaultDistribution
	 	,intConcurrencyId
	 )
	 SELECT DISTINCT
	 	  strDistributionOption	 = ST.strStorageTypeCode
	 	 ,intTicketPoolId		 = TT.intTicketPoolId
	 	 ,intTicketTypeId		 = TT.intTicketTypeId
	 	 ,ysnDistributionAllowed = 1
	 	 ,ysnDefaultDistribution = 0
	 	 ,intConcurrencyId		 = 1
	 FROM tblGRStorageType ST
	 CROSS JOIN tblSCTicketType TT
	
	INSERT INTO tblSCTicketFormat 
	(
		 strTicketFormat
		,intTicketFormatSelection
		,ysnSuppressCompanyName
		,ysnFormFeedEachCopy
		,strTicketHeader
		,strTicketFooter
		,intConcurrencyId
	)
	SELECT  
	   strTicketFormat		            =  t1.strTicketFormat		    
	  ,intTicketFormatSelection   		=  t1.intTicketFormatSelection 
	  ,ysnSuppressCompanyName	    	=  t1.ysnSuppressCompanyName	
	  ,ysnFormFeedEachCopy				=  t1.ysnFormFeedEachCopy		
	  ,strTicketHeader					=  t1.strTicketHeader			
	  ,strTicketFooter					=  t1.strTicketFooter			
	  ,intConcurrencyId 				=  t1.intConcurrencyId 		
	  FROM
	 (    
		 SELECT 
		 strTicketFormat		       = 'Main-Full'
		,intTicketFormatSelection      =  1
		,ysnSuppressCompanyName	       =  0
		,ysnFormFeedEachCopy		   =  0
		,strTicketHeader			   =  NULL
		,strTicketFooter			   =  NULL
		,intConcurrencyId			   =  1
	
		UNION ALL
		
		SELECT 
			 strTicketFormat		       ='Main-Half'
			,intTicketFormatSelection      =  2
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Copy-Full'
			,intTicketFormatSelection      =  1
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Copy-Half'
			,intTicketFormatSelection      =  2
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Grade'
			,intTicketFormatSelection      =  13
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Plant'
			,intTicketFormatSelection      =  12
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Kiosk-120'
			,intTicketFormatSelection      =  14
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
		
		UNION ALL
		
		SELECT 
			 strTicketFormat		       = 'Kiosk-80'
			,intTicketFormatSelection      =  16
			,ysnSuppressCompanyName	       =  0
			,ysnFormFeedEachCopy		   =  0
			,strTicketHeader			   =  NULL
			,strTicketFooter			   =  NULL
			,intConcurrencyId			   =  1
     )t1
	LEFT JOIN tblSCTicketFormat t2 ON t2.strTicketFormat = t1.strTicketFormat collate Latin1_General_CI_AS
	WHERE t2.strTicketFormat IS NULL
    
END
GO