CREATE PROCEDURE [dbo].[uspCTMigrateCompanyPreference]
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference)
BEGIN
    INSERT INTO tblCTCompanyPreference([ysnAssignSaleContract], [ysnAssignPurchaseContract],[ysnRequireDPContract],[ysnApplyScaleToBasis],[intPriceCalculationTypeId])
    SELECT
    CASE	WHEN ISNULL(AssignSaleContract,'') = '' THEN 0 
			WHEN UPPER(LTRIM(RTRIM(AssignSaleContract)))='TRUE' THEN 1
			ELSE 0 
	END ysnAssignSaleContract, 
    CASE	WHEN ISNULL(AssignPurchaseContract,'') = '' THEN 0 
			WHEN UPPER(LTRIM(RTRIM(AssignPurchaseContract)))='TRUE' THEN 1
			ELSE 0 
	END ysnAssignPurchaseContract, 
    CASE	WHEN ISNULL(DPContract,'') = '' THEN 0 
			WHEN UPPER(LTRIM(RTRIM(DPContract)))='TRUE' THEN 1
			ELSE 0 
	END ysnRequireDPContract, 
	CASE	WHEN ISNULL(ApplyScaleToBasis,'') = '' THEN 0 
			WHEN UPPER(LTRIM(RTRIM(ApplyScaleToBasis)))='TRUE' THEN 1
			ELSE 0 
	END ysnApplyScaleToBasis ,
	CAST(CashFuturePrice AS INT) intPriceCalculationTypeId

    FROM
    (
      SELECT strValue, strPreference
      FROM tblSMPreferences
      WHERE intUserID = 0
    ) d
    pivot
    (
      MAX(strValue)
      FOR strPreference IN (AssignSaleContract, AssignPurchaseContract,DPContract,CashFuturePrice,ApplyScaleToBasis)
    ) piv
    
    DELETE FROM tblSMPreferences
    WHERE strPreference
    IN ('AssignSaleContract', 'AssignPurchaseContract','DPContract','CashFuturePrice','ApplyScaleToBasis')
    AND intUserID = 0
END