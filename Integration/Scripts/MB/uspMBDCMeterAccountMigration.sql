IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspMBDCMeterAccountMigration]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspMBDCMeterAccountMigration]; 
GO 

CREATE PROCEDURE [dbo].[uspMBDCMeterAccountMigration]

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpOriginAllKeyLock')) 
DROP TABLE #tmpOriginAllKeyLock
	
SELECT
	klcus_key_no
	,klcus_cus_no
	,klcus_last_rdg
	,klcus_pet_itm_no
	,klcus_disc_p_or_a
	,klcus_disc_rt
	,klcus_fet_yn
	,klcus_set_yn
	,klcus_sst_yn
	,klcus_lc1_yn
	,klcus_lc2_yn
	,klcus_lc3_yn
	,klcus_lc4_yn
	,klcus_lc5_yn
	,klcus_lc6_yn
	,klcus_lc7_yn
	,klcus_lc8_yn
	,klcus_lc9_yn
	,klcus_lc10_yn
	,klcus_lc11_yn
	,klcus_lc12_yn
	,klcus_rdg_seq
	,klcus_terms
	,klcus_grs_net_prc
	,klcus_last_dollars
	,klcus_meter_co_id
	,klcus_meter_no
	,klcus_loc_no
	,klcus_meter_prod_no
	,klcus_consignment_group
	,A4GLIdentity
	--,klcus_conv_factor
	--,klcus_qty_var_warn
	--,klcus_tank_serial_no
	--,klcus_tie_breaker
	,intItemId = ITEM.intItemId 
	INTO #tmpOriginAllKeyLock
FROM dbo.klcusmst  A
INNER JOIN tblICItem ITEM ON LTRIM(RTRIM(A.klcus_pet_itm_no)) COLLATE Latin1_General_CI_AS = LTRIM(RTRIM(ITEM.strItemNo)) COLLATE Latin1_General_CI_AS
WHERE klcus_key_no COLLATE Latin1_General_CI_AS  NOT IN (SELECT strMeterKey COLLATE Latin1_General_CI_AS  FROM tblMBMeterAccountDetail)  

/******************************************************************************************************************************/
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpkeyLock')) 
DROP TABLE #tmpkeyLock
	
SELECT  klcus_cus_no 
		, klcus_loc_no 
		, B.intEntityId
		, BLoc.intEntityLocationId
		, C.intCompanyLocationId
		, D.intTermID  
		, klcus_grs_net_prc
INTO #tmpkeyLock
FROM #tmpOriginAllKeyLock  A
INNER JOIN tblARCustomer B 
	ON A.klcus_cus_no COLLATE Latin1_General_CI_AS  = B.strCustomerNumber COLLATE Latin1_General_CI_AS  
INNER JOIN tblEMEntityLocation BLoc 
	ON B.intEntityId = BLoc.intEntityId AND BLoc.ysnDefaultLocation = 1
LEFT JOIN tblSMCompanyLocation C
	ON  RTRIM(LTRIM(A.klcus_loc_no  COLLATE Latin1_General_CI_AS))  COLLATE Latin1_General_CI_AS   = RTRIM(LTRIM(C.[strLocationNumber] COLLATE Latin1_General_CI_AS)) 
LEFT JOIN tblSMTerm D 
ON CAST(A.klcus_terms AS NVARCHAR (10)) COLLATE Latin1_General_CI_AS  = D.strTerm COLLATE Latin1_General_CI_AS  
			
GROUP BY  klcus_cus_no 
, klcus_loc_no 
, B.intEntityId
, BLoc.intEntityLocationId
, C.intCompanyLocationId
, D.intTermID  
, klcus_grs_net_prc
/******************************************************************************************************************************/			
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpkeyLockBadData')) 
DROP TABLE #tmpkeyLockBadData
select klcus_cus_no 
		, klcus_loc_no 
		, klcus_grs_net_prc
		,klcus_terms
		,klcus_consignment_group
INTO #tmpkeyLockBadData
FROM klcusmst WHERE klcus_cus_no IN (SELECT klcus_cus_no  FROM #tmpkeyLock GROUP BY klcus_cus_no HAVING COUNT(*) > 1)
GROUP BY  klcus_cus_no 
, klcus_loc_no 
, klcus_grs_net_prc
,klcus_terms
,klcus_consignment_group


DECLARE @strMeterAccountCusNo AS NVARCHAR(100)
DECLARE @strMeterAccountLocNo AS NVARCHAR(25)
DECLARE @intEntityCustomerId AS INT
DECLARE @intEntityLocationId AS INT
DECLARE @intCompanyLocationId AS INT
DECLARE @intTermId AS INT
DECLARE @strtPriceType AS NVARCHAR(10)
DECLARE @strTermId AS NVARCHAR(100)
DECLARE @strConsignmentGroup AS NVARCHAR(100)
DECLARE @NewMeterAccountId AS INT

DECLARE @intItemId AS INT 

/****************************************************************************************************************************************************************/
DECLARE @CustomerMeterAccount AS CURSOR;
SET @CustomerMeterAccount = CURSOR FOR

SELECT * FROM #tmpkeyLock WHERE klcus_cus_no NOT IN (SELECT klcus_cus_no FROM #tmpkeyLockBadData)
ORDER BY klcus_cus_no
OPEN @CustomerMeterAccount;
	FETCH NEXT FROM @CustomerMeterAccount INTO @strMeterAccountCusNo, @strMeterAccountLocNo, @intEntityCustomerId,@intEntityLocationId, @intCompanyLocationId,@intTermId, @strtPriceType ; 
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
	SET @NewMeterAccountId = (SELECT TOP 1 intMeterAccountId FROM tblMBMeterAccount WHERE intEntityCustomerId = @intEntityCustomerId AND intEntityLocationId = @intEntityLocationId)
		
    IF ISNULL(@NewMeterAccountId,0) = 0 
	BEGIN
	 INSERT INTO tblMBMeterAccount( intEntityCustomerId
								,intEntityLocationId
								,intTermId
								,intPriceType
								,intConsignmentGroupId
								,intCompanyLocationId
								,intSort
								,intConcurrencyId)
						 VALUES(@intEntityCustomerId
								,@intEntityLocationId
								,NULL
								,(CASE WHEN LTRIM(RTRIM(@strtPriceType )) = 'G' THEN 1 ELSE 2 END)
								,NULL
								,@intCompanyLocationId
								,NULL
								,0)	 
	  SET @NewMeterAccountId = SCOPE_IDENTITY()
	END
	 
	 INSERT INTO tblMBMeterAccountDetail (intMeterAccountId
								,strMeterKey
								,intItemId
								,strWorksheetSequence
								,strMeterCustomerId
								,strMeterFuelingPoint
								,strMeterProductNumber
								,dblLastMeterReading
								,dblLastTotalSalesDollar
								,intSort
								,intConcurrencyId)
						SELECT @NewMeterAccountId
							,klcus_key_no
							,intItemId 
							,klcus_rdg_seq
							,klcus_meter_co_id
							,klcus_meter_no
							,klcus_meter_prod_no
							,klcus_last_rdg
							,klcus_last_dollars
							,0
							,0
							 FROM #tmpOriginAllKeyLock
							 WHERE klcus_cus_no =  @strMeterAccountCusNo

	 FETCH NEXT FROM @CustomerMeterAccount INTO @strMeterAccountCusNo, @strMeterAccountLocNo, @intEntityCustomerId,@intEntityLocationId, @intCompanyLocationId,@intTermId, @strtPriceType ; 
	END
CLOSE @CustomerMeterAccount;
DEALLOCATE @CustomerMeterAccount;
/****************************************************************************************************************************************************************/


/**ERROR MESSAGING**/
/****************************************************************************************************************************************************************/
DECLARE @ErrorMessage NVARCHAR(4000);  
DECLARE @MultipleHeaderInfo AS CURSOR;
SET @MultipleHeaderInfo = CURSOR FOR

SELECT klcus_cus_no 
		,klcus_loc_no 
		,klcus_terms
		,klcus_grs_net_prc
		,klcus_consignment_group
FROM #tmpkeyLockBadData

OPEN @MultipleHeaderInfo;
	/****************************************************************************************************************************************************************/
	FETCH NEXT FROM @MultipleHeaderInfo INTO @strMeterAccountCusNo, @strMeterAccountLocNo, @strTermId , @strtPriceType, @strConsignmentGroup ; 
	IF @@FETCH_STATUS = 0
	BEGIN
		SET @ErrorMessage = '--------------------------------------------------'
		SET @ErrorMessage = @ErrorMessage  + char(13) +  'Multiple Customer Meter Account Header Info:'
		SET @ErrorMessage = @ErrorMessage  + char(13) +  'CUSTOMER | COMPANY LOCATION | TERM | PRICE TYPE | CONSIGNMENT GROUP'
	END
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @ErrorMessage = @ErrorMessage + char(13) + @strMeterAccountCusNo + char(9) +  ISNULL(@strMeterAccountLocNo, 'NULL') + char(9) + @strTermId + char(9) + @strtPriceType + char(9)  +ISNULL(@strConsignmentGroup,'NULL'); 
		--SET @ErrorMessage = FORMATMESSAGE(@ErrorMessage  + char(13) + '%-20s' + '%-20s' + '%-20s' + '%-20s',   @strMeterAccountCusNo , ISNULL(@strMeterAccountLocNo, 'NULL'),  ISNULL(@strTermId, 'NULL') , @strtPriceType  ) 
	FETCH NEXT FROM @MultipleHeaderInfo INTO @strMeterAccountCusNo, @strMeterAccountLocNo, @strTermId , @strtPriceType, @strConsignmentGroup ; 
	END
	/****************************************************************************************************************************************************************/
CLOSE @MultipleHeaderInfo;
DEALLOCATE @MultipleHeaderInfo;

IF(@ErrorMessage <> '')
RAISERROR (@ErrorMessage, 18, 1)
/****************************************************************************************************************************************************************/