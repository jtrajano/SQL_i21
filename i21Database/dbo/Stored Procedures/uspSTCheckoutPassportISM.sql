﻿CREATE PROCEDURE [dbo].[uspSTCheckoutPassportISM]
@intCheckoutId INT,
@strStatusMsg NVARCHAR(250) OUTPUT,
@intCountRows INT OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @intStoreId INT, @strAllowRegisterMarkUpDown NVARCHAR(50), @intShiftNo INT, @intMarkUpDownId INT
		SELECT @intStoreId = intStoreId, @intShiftNo = intShiftNo FROM dbo.tblSTCheckoutHeader WHERE intCheckoutId = @intCheckoutId

		--------------------------------------------------------------------------------------------  
		-- Create Save Point.  
		--------------------------------------------------------------------------------------------    
		-- Create a unique transaction name. 
		DECLARE @TransactionName AS VARCHAR(500) = 'CheckoutPassportISM' + CAST(NEWID() AS NVARCHAR(100)); 
		BEGIN TRAN @TransactionName
		SAVE TRAN @TransactionName --> Save point
		--------------------------------------------------------------------------------------------  
		-- END Create Save Point.  
		-------------------------------------------------------------------------------------------- 




		-- ================================================================================================================== 
		-- Get Error logs. Check Register XML that is not configured in i21
		-- Compare <POSCode> tag of (RegisterXML) and (Inventory->Item->strUpcCode, strLongUPCCode)
		-- ------------------------------------------------------------------------------------------------------------------ 
		INSERT INTO tblSTCheckoutErrorLogs 
		(
			strErrorMessage 
			, strRegisterTag
			, strRegisterTagValue
			, intCheckoutId
			, intConcurrencyId
		)
		SELECT DISTINCT
			'Missing Pos Code' as strErrorMessage
			, 'POSCode' as strRegisterTag
			, ISNULL(Chk.POSCode, '') AS strRegisterTagValue
			, @intCheckoutId
			, 1
		FROM #tempCheckoutInsert Chk
		WHERE ISNULL(Chk.POSCode, '') NOT IN
		(
			SELECT DISTINCT 
				tbl.strXmlRegisterPOSCode
			FROM
			(
				SELECT DISTINCT
					Chk.POSCode AS strXmlRegisterPOSCode
				FROM #tempCheckoutInsert Chk
				JOIN dbo.tblICItemUOM UOM 
					ON Chk.POSCode COLLATE Latin1_General_CI_AS IN (ISNULL(UOM.strUpcCode, ''), ISNULL(UOM.strLongUPCCode, ''))
				JOIN dbo.tblICItem I 
					ON I.intItemId = UOM.intItemId
				JOIN dbo.tblICItemLocation IL 
					ON IL.intItemId = I.intItemId
				JOIN dbo.tblICItemPricing P 
					ON IL.intItemLocationId = P.intItemLocationId 
					AND I.intItemId = P.intItemId
				JOIN dbo.tblSMCompanyLocation CL 
					ON CL.intCompanyLocationId = IL.intLocationId
				JOIN dbo.tblSTStore S 
					ON S.intCompanyLocationId = CL.intCompanyLocationId
				WHERE S.intStoreId = @intStoreId
				AND ISNULL(Chk.POSCode, '') != ''
			) AS tbl
		)
		-- ------------------------------------------------------------------------------------------------------------------  
		-- END Get Error logs. Check Register XML that is not configured in i21.  
		-- ==================================================================================================================





		

		DECLARE @intLocationId AS INT = (SELECT intCompanyLocationId FROM tblSTStore WHERE intStoreId = @intStoreId)

		--Removed DISTINCT
		BEGIN
			INSERT INTO dbo.tblSTCheckoutItemMovements
			(
				intCheckoutId
				, intItemUPCId
				, strDescription
				, intVendorId
				, intQtySold
				, dblCurrentPrice
				, dblDiscountAmount
				, dblTotalSales
				, dblItemStandardCost
				, intConcurrencyId
			)
			SELECT 
				intCheckoutId		= @intCheckoutId
			  , intItemUPCId		= UOM.intItemUOMId
			  , strDescription		= I.strDescription
			  , intVendorId			= IL.intVendorId
			  , intQtySold			= ISNULL(CAST(Chk.SalesQuantity as int),0)
			  , dblCurrentPrice		= ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
			  , dblDiscountAmount	= ISNULL(CAST(Chk.DiscountAmount as decimal(18,6)),0)
			  , dblTotalSales		= ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)
			  , dblItemStandardCost = ISNULL(CAST(P.dblStandardCost as decimal(18,6)),0)
			  , intConcurrencyId	= 1
			FROM #tempCheckoutInsert Chk
			JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
							   OR Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strLongUPCCode
			JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
			JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
			JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
			JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
			JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
			WHERE S.intStoreId = @intStoreId
		END

		-- Add Mark Up or Down only if ISM Price is not equal to Inventory Retail Price
		INSERT INTO dbo.tblSTCheckoutMarkUpDowns
		SELECT @intCheckoutId
			 , IC.intCategoryId
			 , UOM.intItemUOMId
			 , ISNULL(CAST(Chk.SalesQuantity as int),0)
			--, ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
			 --, ISNULL(CAST(Chk.SalesAmount as decimal(18,6)),0)

			 -- Sales Price
			 , (CASE 
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice 
						THEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) - P.dblSalePrice
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice 
						THEN P.dblSalePrice - ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)
				END) AS dblRetailUnit

			 -- Total Amount
			 , (CASE 
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice 
						THEN (ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) - P.dblSalePrice) * ISNULL(CAST(Chk.SalesQuantity as int),0)
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice 
						THEN (P.dblSalePrice - ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)) * ISNULL(CAST(Chk.SalesQuantity as int),0)
				END) AS dblAmount

			 , (CASE 
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice 
						THEN CAST((ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) - P.dblSalePrice) AS DECIMAL(18,6))
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice 
						THEN CAST((P.dblSalePrice - ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0)) AS DECIMAL(18,6))
				END) AS dblShrink
			 , (CASE 
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) > P.dblSalePrice THEN 'Mark Up'
					WHEN ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) < P.dblSalePrice THEN 'Mark Down' 
				END) AS strUpDownNotes
			 , 1
		FROM #tempCheckoutInsert Chk
		JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
						   OR Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strLongUPCCode
		JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
		JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
		JOIN dbo.tblICItemPricing P ON IL.intItemLocationId = P.intItemLocationId AND I.intItemId = P.intItemId
		JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
		JOIN dbo.tblICCategory IC ON IC.intCategoryId = I.intCategoryId
		JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
		WHERE S.intStoreId = @intStoreId
		AND I.strLotTracking = 'No'
		AND ISNULL(CAST(Chk.ActualSalesPrice as decimal(18,6)),0) <> P.dblSalePrice


		-- Get MUD- next Batch number
		DECLARE @strMUDbatchId AS NVARCHAR(1000)
		EXEC uspSTGetMarkUpDownBatchId @strMUDbatchId OUT, @intLocationId

		-- Update batch no.
		UPDATE tblSTCheckoutHeader
		SET strMarkUpDownBatchNo = @strMUDbatchId
		WHERE intCheckoutId = @intCheckoutId

		SET @intCountRows = 1
		SET @strStatusMsg = 'Success'

		-- IF SUCCESS Commit Transaction
		COMMIT TRAN @TransactionName

	END TRY

	BEGIN CATCH
		-- IF HAS Error Rollback Transaction
		ROLLBACK TRAN @TransactionName	

		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()

		COMMIT TRAN @TransactionName
	END CATCH
END