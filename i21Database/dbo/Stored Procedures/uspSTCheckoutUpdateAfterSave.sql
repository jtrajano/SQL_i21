CREATE PROCEDURE [dbo].[uspSTCheckoutUpdateAfterSave]
	@dblTotalSales DECIMAL(18, 6),
	@dblCustomerCharges DECIMAL(18, 6),
	@dblTotalToDeposit DECIMAL(18, 6),
	@dblTotalTax DECIMAL(18, 6),
	@dblCustomerPayments DECIMAL(18, 6),
	@dblTotalDeposits DECIMAL(18, 6),
	@dblTotalPaidOuts DECIMAL(18, 6),
	@dblEnteredPaidOuts DECIMAL(18, 6),
	@dblCashOverShort DECIMAL(18, 6),
	@dblDealerCommission DECIMAL(18, 6),
	@strStatus NVARCHAR(50),
	@intCheckoutId INT,
	@strRegisterClass NVARCHAR(30),
	@strRegisterUsername NVARCHAR(200),
	@strRegisterPassword NVARCHAR(200),

	@dblATMBegBalance DECIMAL(18, 6),
	@dblATMEndBalanceCalculated DECIMAL(18, 6),
	@dblATMVariance DECIMAL(18, 6),

	@dblChangeFundBegBalance DECIMAL(18, 6),
	@dblChangeFundEndBalance DECIMAL(18, 6),
	@dblChangeFundIncreaseDecrease DECIMAL(18, 6)
AS
BEGIN
	BEGIN TRY
		DECLARE @strStatusMsg AS NVARCHAR(1000) = ''
			  , @intRegisterId AS INT

----TEST
--INSERT INTO CopierDB.dbo.tblTestSP(strValueOne, strValueTwo)
--VALUES('@dblTotalSales', CAST(@dblTotalSales AS NVARCHAR(50))),
--      ('@dblCustomerCharges', CAST(@dblCustomerCharges AS NVARCHAR(50))),
--	  ('@dblTotalToDeposit', CAST(@dblTotalToDeposit AS NVARCHAR(50))),
--	  ('@dblTotalTax', CAST(@dblTotalTax AS NVARCHAR(50))),
--	  ('@dblCustomerPayments', CAST(@dblCustomerPayments AS NVARCHAR(50))),
--	  ('@dblTotalDeposits', CAST(@dblTotalDeposits AS NVARCHAR(50))),
--	  ('@dblTotalPaidOuts', CAST(@dblTotalPaidOuts AS NVARCHAR(50))),
--	  ('@dblEnteredPaidOuts', CAST(@dblEnteredPaidOuts AS NVARCHAR(50))),
--	  ('@dblCashOverShort', CAST(@dblCashOverShort AS NVARCHAR(50))),
--	  ('@strStatus', CAST(@strStatus AS NVARCHAR(50))),
--	  ('@intCheckoutId', CAST(@intCheckoutId AS NVARCHAR(50))),
--	  ('@strRegisterClass', CAST(@strRegisterClass AS NVARCHAR(50))),
--	  ('@strRegisterUsername', CAST(@strRegisterUsername AS NVARCHAR(50))),
--	  ('@strRegisterPassword', CAST(@strRegisterPassword AS NVARCHAR(50)))
	
		IF EXISTS(SELECT TOP 1 1 FROM tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId)
			BEGIN
				UPDATE tblSTCheckoutHeader
				SET dblTotalSales					= @dblTotalSales
				  , dblCustomerCharges				= @dblCustomerCharges
				  , dblTotalToDeposit				= @dblTotalToDeposit
				  , dblTotalTax						= @dblTotalTax
				  , dblCustomerPayments				= @dblCustomerPayments
				  , dblTotalDeposits				= @dblTotalDeposits
				  , dblTotalPaidOuts				= @dblTotalPaidOuts
				  , dblEnteredPaidOuts				= @dblEnteredPaidOuts
				  , dblCashOverShort				= @dblCashOverShort
				  , dblDealerCommission				= @dblDealerCommission
				  , strStatus						= @strStatus
				  , dblATMBegBalance				= ISNULL(@dblATMBegBalance, 0)
				  , dblATMEndBalanceCalculated		= ISNULL(@dblATMEndBalanceCalculated, 0)
				  , dblATMVariance					= ISNULL(@dblATMVariance, 0)
				  , dblChangeFundBegBalance			= ISNULL(@dblChangeFundBegBalance, 0)
				  , dblChangeFundEndBalance			= ISNULL(@dblChangeFundEndBalance, 0)
				  , dblChangeFundIncreaseDecrease	= ISNULL(dblChangeFundIncreaseDecrease, 0)
				WHERE intCheckoutId = @intCheckoutId


				-- has been removed - ST-2681
				--IF(@strRegisterClass = 'SAPPHIRE/COMMANDER' AND @strRegisterUsername != '' AND @strRegisterPassword != '')
				--	BEGIN
				--		UPDATE Register
				--			SET Register.strSAPPHIREUserName = @strRegisterUsername
				--			  , Register.strSAPPHIREPassword = @strRegisterPassword
				--		FROM tblSTRegister Register
				--		JOIN tblSTStore Store
				--			ON Register.intRegisterId = Store.intRegisterId
				--		JOIN tblSTCheckoutHeader CH
				--			ON Store.intStoreId = CH.intStoreId
				--		WHERE CH.intCheckoutId = @intCheckoutId
				--			AND Register.strRegisterClass = 'SAPPHIRE/COMMANDER'
				--	END
			END


	END TRY

	BEGIN CATCH
		SET @strStatusMsg = ERROR_MESSAGE()
	End CATCH
END