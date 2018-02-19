IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportDiscountAndStorageChargeItem')
	DROP PROCEDURE uspGRImportDiscountAndStorageChargeItem
GO
CREATE PROCEDURE uspGRImportDiscountAndStorageChargeItem 
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
		SELECT @Total = COUNT(1)
		FROM 
		(
			SELECT 
			strItemNo = t.strItemNo
			FROM 
			(
				SELECT DISTINCT	
				LTRIM(RTRIM(gadsc_com_cd))+' '		
				+ CASE 
					WHEN a1.gacdc_desc IS NOT NULL THEN LTRIM(RTRIM(a1.gacdc_desc))
						ELSE 
							CASE 
								WHEN ISNULL(LTRIM(RTRIM(gadsc_desc)), '') <> '' THEN LTRIM(RTRIM(gadsc_disc_cd)) + ' / ' + ISNULL(LTRIM(RTRIM(gadsc_desc)), '')
								ELSE LTRIM(RTRIM(gadsc_disc_cd))
							 END
					END 
				 AS strItemNo
				FROM gadscmst a
			JOIN gacommst b ON LTRIM(RTRIM(b.gacom_com_cd)) = LTRIM(RTRIM(a.gadsc_com_cd))
			JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(a.gadsc_com_cd)) COLLATE Latin1_General_CS_AS
			LEFT JOIN gacdcmst a1 ON LTRIM(RTRIM(a.gadsc_disc_cd)) = LTRIM(RTRIM(a1.gacdc_cd)) AND LTRIM(RTRIM(a.gadsc_com_cd)) = LTRIM(RTRIM(a1.gacdc_com_cd))
			)t 
			LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(t.strItemNo)) COLLATE  Latin1_General_CS_AS WHERE Item.strItemNo IS NULL	
			
			UNION

			SELECT 
			 strItemNo = LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Storage'
			FROM gacommst t
			JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(t.gacom_com_cd)) COLLATE Latin1_General_CS_AS
			LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Storage' COLLATE  Latin1_General_CS_AS 
			WHERE Item.strItemNo IS NULL
			
			UNION

			SELECT 
			 strItemNo = LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Freight'
			FROM gacommst t
			JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(t.gacom_com_cd)) COLLATE Latin1_General_CS_AS
			LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Freight' COLLATE  Latin1_General_CS_AS 
			WHERE Item.strItemNo IS NULL
		)t

		RETURN @Total
	END

	BEGIN		
		INSERT [dbo].[tblICItem] 
		(
		 [strItemNo]
		,[strShortName]
		,[strType]
		,[strDescription]
		,[strStatus]
		,[strInventoryTracking]
		,[strLotTracking]		
		,[intLifeTime]
		,[ysnLandedCost]		
		,[ysnTaxable]
		,[ysnDropShip]
		,[ysnCommisionable]
		,[ysnSpecialCommission]
		,[intCommodityId]
		,[strCostMethod]
		,[strCostType]
		,[ysnAccrue]
		,[ysnPrice]	
		,[intConcurrencyId]
		)	
		--Discount Item
		SELECT 
		 strItemNo				= t.strItemNo
		,strShortName			= t.strShortName 
		,strType				= 'Other Charge'
		,strDescription			= t.strDescription
		,strStatus				= 'Active'	
		,strInventoryTracking	= 'Item Level'
		,strLotTracking			= 'No'  
		,[intLifeTime]			= 0 
		,[ysnLandedCost]		= 0  		
		,[ysnTaxable]			= 0 
		,[ysnDropShip]			= 0 
		,[ysnCommisionable]		= 0 
		,[ysnSpecialCommission] = 0 
		,[intCommodityId]	    = t.intCommodityId 
		,[strCostMethod]		= 'Amount'  
		,strCostType			= 'Discount'
		,[ysnAccrue]			= 0
		,[ysnPrice]				= 0 		
		,intConcurrencyId		= 1  
		FROM 
		(
			SELECT DISTINCT	
			 LTRIM(RTRIM(gadsc_disc_cd)) AS strShortName
			,LTRIM(RTRIM(gadsc_com_cd))+' '		
			+ CASE 
				WHEN a1.gacdc_desc IS NOT NULL THEN LTRIM(RTRIM(a1.gacdc_desc))
					ELSE 
						CASE 
							WHEN ISNULL(LTRIM(RTRIM(gadsc_desc)), '') <> '' THEN LTRIM(RTRIM(gadsc_disc_cd)) + ' / ' + ISNULL(LTRIM(RTRIM(gadsc_desc)), '')
							ELSE LTRIM(RTRIM(gadsc_disc_cd))
						 END
				END 
			 AS strItemNo
			,LTRIM(RTRIM(b.gacom_desc)) + ' ' +CASE 
				WHEN LTRIM(RTRIM(a1.gacdc_desc)) IS NOT NULL THEN LTRIM(RTRIM(a1.gacdc_desc))
					ELSE 
						CASE 
							WHEN ISNULL(LTRIM(RTRIM(gadsc_desc)), '') <> '' THEN LTRIM(RTRIM(gadsc_disc_cd)) + '' + ISNULL(LTRIM(RTRIM(gadsc_desc)), '')
							ELSE LTRIM(RTRIM(gadsc_disc_cd))
						 END
				END  AS strDescription
			,Com.intCommodityId
		FROM gadscmst a
		JOIN gacommst b ON LTRIM(RTRIM(b.gacom_com_cd)) = LTRIM(RTRIM(a.gadsc_com_cd))
		JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(a.gadsc_com_cd)) COLLATE Latin1_General_CS_AS
		LEFT JOIN gacdcmst a1 ON LTRIM(RTRIM(a.gadsc_disc_cd)) = LTRIM(RTRIM(a1.gacdc_cd)) AND LTRIM(RTRIM(a.gadsc_com_cd)) = LTRIM(RTRIM(a1.gacdc_com_cd))
		)t 
		LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(t.strItemNo)) COLLATE  Latin1_General_CS_AS WHERE Item.strItemNo IS NULL
		
		UNION	
		--- Storage Charge
		SELECT 
		 strItemNo				= LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Storage'
		,strShortName			= 'Storage'
		,strType				= 'Other Charge'
		,strDescription			= LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Storage Fees'
		,strStatus				= 'Active'	
		,strInventoryTracking	= 'Item Level'
		,strLotTracking			= 'No'  
		,[intLifeTime]			= 0 
		,[ysnLandedCost]		= 0  		
		,[ysnTaxable]			= 0 
		,[ysnDropShip]			= 0 
		,[ysnCommisionable]		= 0 
		,[ysnSpecialCommission] = 0 
		,[intCommodityId]	    = Com.intCommodityId 
		,[strCostMethod]		= 'Amount'  
		,strCostType			= 'Storage Charge'
		,[ysnAccrue]			= 0
		,[ysnPrice]				= 0 	
		,intConcurrencyId		= 1  
		FROM gacommst t
		JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(t.gacom_com_cd)) COLLATE Latin1_General_CS_AS
		LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Storage' COLLATE  Latin1_General_CS_AS 
		WHERE Item.strItemNo IS NULL
		UNION
		--- Freight Chargers
		SELECT 
		 strItemNo				= LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Freight'
		,strShortName			= 'Freight'
		,strType				= 'Other Charge'
		,strDescription			= LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Freight Charge'
		,strStatus				= 'Active'	
		,strInventoryTracking	= 'Item Level'
		,strLotTracking			= 'No'  
		,[intLifeTime]			= 0 
		,[ysnLandedCost]		= 0  		
		,[ysnTaxable]			= 0 
		,[ysnDropShip]			= 0 
		,[ysnCommisionable]		= 0 
		,[ysnSpecialCommission] = 0 
		,[intCommodityId]	    = Com.intCommodityId 
		,[strCostMethod]		= 'Amount'  
		,strCostType			= 'Freight Charge'
		,[ysnAccrue]			= 0
		,[ysnPrice]				= 0 	
		,intConcurrencyId		= 1  
		FROM gacommst t
		JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(t.gacom_com_cd)) COLLATE Latin1_General_CS_AS
		LEFT JOIN tblICItem Item ON Item.strItemNo=LTRIM(RTRIM(ISNULL(t.gacom_desc,gacom_com_cd)))+' Freight' COLLATE  Latin1_General_CS_AS 
		WHERE Item.strItemNo IS NULL		
		
    END

END
