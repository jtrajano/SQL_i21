GO
PRINT N'BEGIN - STORE Item Movement Data Fix for Gross Sales = NULL'
IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSTCheckoutItemMovements' AND COLUMN_NAME = 'dblGrossSales') 
	BEGIN
		EXEC('
				IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutItemMovements WHERE dblGrossSales IS NULL)
					BEGIN
						PRINT ''Updating Item Movement Gross sales amount that is = NULL''

						UPDATE tblSTCheckoutItemMovements
						SET dblGrossSales = (dblCurrentPrice * intQtySold)
						WHERE dblGrossSales IS NULL
					END
			')
	END
PRINT N'END - STORE - Item Movement Data Fix for Gross Sales = NULL'

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTRegister.ysnTransctionLog to tblSTRegisterFileConfiguration.ysnActive
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(
			SELECT TOP 1 1
			FROM tblSTRegisterFileConfiguration fc
			INNER JOIN tblSTRegister r
				ON fc.intRegisterId = r.intRegisterId
			WHERE r.strRegisterClass = N'SAPPHIRE/COMMANDER'
				AND fc.strFileType = N'Inbound'
				AND fc.strFilePrefix = N'vtransset-tlog'
				AND ISNULL(r.ysnTransctionLog, 0) != ISNULL(fc.ysnActive, 0)
		 )
	BEGIN

		UPDATE r
			SET r.ysnTransctionLog = ISNULL(fc.ysnActive, 0)
		FROM tblSTRegisterFileConfiguration fc
		INNER JOIN tblSTRegister r
			ON fc.intRegisterId = r.intRegisterId
		WHERE r.strRegisterClass = N'SAPPHIRE/COMMANDER'
			AND fc.strFileType = N'Inbound'
			AND fc.strFilePrefix = N'vtransset-tlog'
			AND ISNULL(r.ysnTransctionLog, 0) != ISNULL(fc.ysnActive, 0)

	END
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTRegister.ysnTransctionLog to tblSTRegisterFileConfiguration.ysnActive
----------------------------------------------------------------------------------------------------------------------------------

IF EXISTS(
			SELECT TOP 1 1 FROM tblSTTranslogRebates
			WHERE intRegisterClassId IS NULL
		)
	BEGIN
		
		UPDATE tr
			SET tr.intRegisterClassId = setup.intRegisterSetupId
		FROM tblSTTranslogRebates tr
		INNER JOIN tblSTStore st
			ON tr.intStoreId = st.intStoreId
		INNER JOIN tblSTRegister reg
			ON st.intRegisterId = reg.intRegisterId
		INNER JOIN tblSTRegisterSetup setup
			ON reg.strRegisterClass = setup.strRegisterClass
		WHERE tr.intRegisterClassId IS NULL 
	END

	
----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTRegister.strRegisterClass from SAPPHIRE to SAPPHIRE/COMMANDER
----------------------------------------------------------------------------------------------------------------------------------
IF EXISTS(
			SELECT TOP 1 1
			FROM tblSTRegister 
			WHERE strRegisterClass = N'SAPPHIRE'
		 )
	BEGIN

		UPDATE tblSTRegister
			SET strRegisterClass = 'SAPPHIRE/COMMANDER'
		WHERE strRegisterClass = 'SAPPHIRE'

	END
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTRegister.strRegisterClass from SAPPHIRE to SAPPHIRE/COMMANDER
----------------------------------------------------------------------------------------------------------------------------------

	
----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTCheckoutHeader.dblTotalToDeposit additional of ATM Replenished to the computation of Total To Deposit
----------------------------------------------------------------------------------------------------------------------------------
      
IF EXISTS(SELECT intCheckoutId FROM tblSTCheckoutHeader 
			WHERE dblTotalToDeposit != (dblTotalSales + dblTotalTax + dblCustomerPayments) -  (dblTotalPaidOuts + dblCustomerCharges + dblATMReplenished))
			BEGIN
				UPDATE tblSTCheckoutHeader 
					SET dblTotalToDeposit = (dblTotalSales + dblTotalTax + dblCustomerPayments) -  (dblTotalPaidOuts + dblCustomerCharges + dblATMReplenished),
						dblCashOverShort = dblCashOverShort + dblATMReplenished
				WHERE dblTotalToDeposit != (dblTotalSales + dblTotalTax + dblCustomerPayments) -  (dblTotalPaidOuts + dblCustomerCharges + dblATMReplenished)
			END
			
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTCheckoutHeader.dblTotalToDeposit additional of ATM Replenished to the computation of Total To Deposit
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTLotteryGame - Add default intItemUOMId with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------
      
IF EXISTS(SELECT intItemUOMId FROM tblSTLotteryGame WHERE intItemUOMId IS NULL)
			BEGIN
				UPDATE tblSTLotteryGame 
					SET intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE tblSTLotteryGame.intItemId = tblICItemUOM.intItemId AND ysnStockUnit = 1)
			END
			
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTLotteryGame - Add default intItemUOMId with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTPumpItem - Add default strUnitMeasure with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------
      
IF EXISTS(SELECT strUnitMeasure FROM tblSTPumpItem WHERE strUnitMeasure IS NULL)
			BEGIN
				UPDATE tblSTPumpItem 
					SET strUnitMeasure = (SELECT TOP 1 strUnitMeasure FROM tblICUnitMeasure um 
																		JOIN tblICItemUOM uom
																			ON um.intUnitMeasureId = uom.intUnitMeasureId
																		WHERE intItemUOMId = tblSTPumpItem.intItemUOMId AND uom.ysnStockUnit = 1)
			END
			
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTPumpItem - Add default strUnitMeasure with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTLotteryBook - Add default intItemUOMId with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------
      
IF EXISTS(SELECT intItemUOMId FROM tblSTLotteryBook WHERE intItemUOMId IS NULL)
			BEGIN
				UPDATE tblSTLotteryBook 
					SET intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblSTLotteryGame WHERE intLotteryGameId = tblSTLotteryBook.intLotteryGameId)
			END
			
----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTLotteryBook - Add default intItemUOMId with stock unit of Item UOM
----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTRegister - Add default store app parameters if NULL  ST-890
----------------------------------------------------------------------------------------------------------------------------------

UPDATE tblSTRegister
SET ysnDeleteRegisterFileInbound = ISNULL(ysnDeleteRegisterFileInbound, 1),
	strRegisterFolderInbound = ISNULL(strRegisterFolderInbound, 'C:\irely\Import'),
	strRegisterFolderOutbound = ISNULL(strRegisterFolderOutbound, 'C:\irely\Export'),
	strHandheldImportFolderPath = ISNULL(strHandheldImportFolderPath, 'C:\irely\Import'),
	strHandheldExportFolderPath = ISNULL(strHandheldExportFolderPath, 'C:\irely\Import'),
	strDeleteLogsOlderDays = ISNULL(strDeleteLogsOlderDays, '7'),
	strUpdateStoreAppInterval = ISNULL(strUpdateStoreAppInterval, '60'),
	ysnAllowAutoUpdate = ISNULL(ysnAllowAutoUpdate, 1),
	strDaysToRetrieveTranslog = ISNULL(strDaysToRetrieveTranslog, '7')

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTRegister - Add default store app parameters if NULL  ST-890
----------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Update tblSTRegister for password
----------------------------------------------------------------------------------------------------------------------------------

-- Note: <= 100 in length are the not encrypted passwords
--       344 in length are the encrypted passwords
UPDATE tblSTRegister
SET strSAPPHIREPassword = dbo.fnAESEncryptASym(strSAPPHIREPassword)
WHERE LEN(strSAPPHIREPassword) <= 100 

UPDATE tblSTRegister
SET strSAPPHIREBasePassword = dbo.fnAESEncryptASym(strSAPPHIREBasePassword)
WHERE LEN(strSAPPHIREBasePassword) <= 100 

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Update tblSTRegister for password
----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Add default value on tblSTCompanyPreferencce
----------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT TOP 1 1 FROM tblSTCompanyPreference)
	BEGIN
		INSERT INTO tblSTCompanyPreference (dtmDateEntered, intConcurrencyId)
		VALUES (GETDATE(), 1)
	END

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Add default value on tblSTCompanyPreferencce
----------------------------------------------------------------------------------------------------------------------------------

PRINT N'BEGIN - Lottery Book fix ending number'

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Lottery Book fix ending number
----------------------------------------------------------------------------------------------------------------------------------

UPDATE tblSTLotteryBook
SET tblSTLotteryBook.intStartingNumber = tbl_Update.intStartingNumber,
tblSTLotteryBook.intEndingNumber = tbl_Update.intEndingNumber,
tblSTLotteryBook.intReceiptEndingNumber = tbl_Update.intReceiptEndingNumber,
tblSTLotteryBook.dblQuantityRemaining = CASE WHEN tbl_Update.strStatus = 'Sold'
											THEN 0
										ELSE ABS(tbl_Update.intEndingNumber - tbl_Update.intStartingNumber) + 1
										END
FROM 
(
	SELECT 
		LB.intLotteryBookId,
		LG.intLotteryGameId,
		COALESCE(LC.intEndingCount, LB.intStartingNumber, LG.intStartingNumber) AS intStartingNumber,
		ISNULL(LB.intEndingNumber, LG.intEndingNumber) AS intEndingNumber,
		LG.intEndingNumber AS intReceiptEndingNumber,
		LB.strStatus AS strStatus
	FROM tblSTLotteryBook LB
	LEFT JOIN tblSTLotteryGame LG
		ON LB.intLotteryGameId = LG.intLotteryGameId
	LEFT JOIN (
	SELECT * FROM (
		SELECT  tmp_LB.intLotteryBookId, 
				tmp_CH.intCheckoutId,
				tmp_CL.intEndingCount,
				ROW_NUMBER() OVER (PARTITION BY tmp_LB.intStoreId, tmp_LB.intLotteryBookId ORDER BY tmp_CH.dtmCheckoutDate DESC) AS intRowNum
		FROM tblSTLotteryBook tmp_LB
		INNER JOIN tblSTCheckoutLotteryCount AS tmp_CL
			ON tmp_LB.intLotteryBookId = tmp_CL.intLotteryBookId
		INNER JOIN tblSTCheckoutHeader AS tmp_CH
			ON tmp_CL.intCheckoutId = tmp_CH.intCheckoutId
		INNER JOIN tblSTLotteryGame tmp_LG
			ON tmp_LB.intLotteryGameId = tmp_LG.intLotteryGameId
		WHERE tmp_CH.strCheckoutStatus = 'Posted'
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1) LC
	ON LB.intLotteryBookId = LC.intLotteryBookId
) tbl_Update
WHERE tblSTLotteryBook.intLotteryBookId = tbl_Update.intLotteryBookId

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Lottery Book fix ending number
----------------------------------------------------------------------------------------------------------------------------------

PRINT N'BEGIN - Add defaulting of UPCA and SCC-14'

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Add defaulting of UPCA and SCC-14
----------------------------------------------------------------------------------------------------------------------------------


UPDATE tblICItemUOM
SET strUPCA = CASE WHEN LEN(dbo.fnICValidateUPCCode(strLongUPCCode)) IN (10, 11, 12)
					THEN RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 12)
					ELSE NULL
					END
WHERE strUPCA IS NULL AND strLongUPCCode IS NOT NULL AND ISNUMERIC(strLongUPCCode) = 1 AND strLongUPCCode NOT LIKE '%.%'
AND RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 12) NOT IN (
	SELECT strLongUPCCode FROM (
		SELECT
			RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 12) AS strLongUPCCode
		FROM
			tblICItemUOM
		GROUP BY
			RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 12)
		HAVING 
			COUNT(*) > 1
	) sc WHERE strLongUPCCode IS NOT NULL
)


UPDATE tblICItemUOM
SET strSCC14 = CASE WHEN LEN(dbo.fnICValidateUPCCode(strLongUPCCode)) IN (10, 11, 12, 13, 14)
					THEN RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 14)
					ELSE NULL
					END
WHERE strSCC14 IS NULL AND strLongUPCCode IS NOT NULL AND ISNUMERIC(strLongUPCCode) = 1 AND strLongUPCCode NOT LIKE '%.%'
AND RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 14) NOT IN (
	SELECT strLongUPCCode FROM (
		SELECT
			RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 14) AS strLongUPCCode
		FROM
			tblICItemUOM
		GROUP BY
			RIGHT('0000' + dbo.fnICValidateUPCCode(strLongUPCCode), 14)
		HAVING 
			COUNT(*) > 1
	) sc WHERE strLongUPCCode IS NOT NULL
)

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Add defaulting of UPCA and SCC-14
----------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------
-- [START]: Fix Promo Price in Promotion Sales Screen
----------------------------------------------------------------------------------------------------------------------------------
UPDATE
    SL
SET
    SL.dblPromoPrice = tmp.dblPrice
FROM
    tblSTPromotionSalesList AS SL
    INNER JOIN (
		SELECT psl.intPromoSalesListId, tmps.dblPrice
		FROM tblSTPromotionSalesList psl
		INNER JOIN (
			SELECT 
				sld.intPromoSalesListId, 
				CASE WHEN strPromoType = 'M' 
						THEN SUM(dblPrice) 
					 WHEN strPromoType = 'C' 
						THEN SUM(sld.intQuantity * dblPrice) 
					END 
				AS dblPrice 
			FROM tblSTPromotionSalesListDetail sld
			JOIN tblSTPromotionSalesList sl
			ON sld.intPromoSalesListId = sl.intPromoSalesListId
			GROUP BY sld.intPromoSalesListId, strPromoType
		) tmps
	ON psl.intPromoSalesListId = tmps.intPromoSalesListId
) AS tmp
        ON SL.intPromoSalesListId = tmp.intPromoSalesListId

----------------------------------------------------------------------------------------------------------------------------------
-- [END]: Fix Promo Price in Promotion Sales Screen
----------------------------------------------------------------------------------------------------------------------------------
GO