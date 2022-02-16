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

GO