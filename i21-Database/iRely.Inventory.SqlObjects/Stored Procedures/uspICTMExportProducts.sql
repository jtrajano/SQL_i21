CREATE PROCEDURE [dbo].[uspICTMExportProducts]
	@intEntityUserSecurityId INT
AS
DECLARE @intDefaultLocationId INT
DECLARE @ID INT 

SELECT @intDefaultLocationId = intCompanyLocationId
FROM tblSMUserSecurity
WHERE [intEntityId] = @intEntityUserSecurityId


--PRICES---------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tblPRICES (
		RowID INT
		,intItemId INT    
		,name NVARCHAR(100) 
		,pricingMethod NVARCHAR(10)
		,reference INT
		,perUnit NUMERIC (16,4)
		,intLocationId INT
		)

INSERT INTO #tblPRICES(intItemId,name,pricingMethod,reference,perUnit, intLocationId)
	SELECT DISTINCT
		intItemId
		,name
		,pricingMethod
		,reference
		,perUnit
		,intLocationId
		FROM (	
			
				---------------------------------------------------------->>>>> Item Price- Direct from ItemPricing table <<<<<<------------------------------------------------------------------------
				SELECT item.intItemId, name = item.strShortName, 'Item' pricingMethod, reference = item.intItemId , perUnit = CAST(ROUND(price.dblPrice,4) AS NUMERIC (16,4)), price.intLocationId
				FROM tblICItem item
					INNER JOIN (
								SELECT Item.intItemId intItemId
										, Item.intLocationId
										, dblPrice = ISNULL(Item.dblSalePrice , 0) 
								FROM vyuICGetItemPricing Item
								WHERE intItemUnitMeasureId = (SELECT TOP 1 intIssueUOMId FROM tblICItemLocation WHERE intItemId = Item.intItemId AND intLocationId = Item.intLocationId)
								AND Item.dblSalePrice > 0) price 
								ON price.intItemId = item.intItemId
				WHERE (item.ysnAvailableTM = 1	OR item.strType = 'Service') and price.intLocationId = @intDefaultLocationId

				UNION ALL

				SELECT item.intItemId, name = item.strShortName, 'Item' pricingMethod, reference = item.intItemId , perUnit = price.dblUnitPrice, itemLocation.intLocationId
				FROM tblICItem item
					INNER JOIN tblICItemPricingLevel price ON price.intItemId = item.intItemId
					INNER JOIN tblICItemLocation itemLocation ON itemLocation.intItemLocationId = price.intItemLocationId
				WHERE (item.ysnAvailableTM = 1 OR item.strType = 'Service') and itemLocation.intLocationId = @intDefaultLocationId
				--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
				UNION ALL
			
				-------------------------------------------------------------------->>>>> Dispatch <<<<<<--------------------------------------------------------------------------------
				SELECT DISTINCT
					A.intProductID itemId
					,name = (CASE WHEN C.intItemId IS NULL THEN ISNULL(B.strShortName,'') ELSE ISNULL(C.strShortName,'') END)
					,'Dispatch' pricingMethod
					,reference = A.intDispatchID
					,perUnit = CAST(ROUND(dblPrice,4) AS NUMERIC (16,4))
					,NULL
				FROM tblTMDispatch A
				INNER JOIN tblICItem B
					ON A.intProductID = B.intItemId
				LEFT JOIN tblICItem C
					ON A.intSubstituteProductID = C.intItemId
					--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		) Z
		
		
		UPDATE #tblPRICES
		SET #tblPRICES.RowID = X.RowID
		FROM  #tblPRICES 
				INNER JOIN 
					(SELECT ROW_NUMBER() OVER(ORDER BY intItemId ASC) RowID , perUnit , intItemId
					FROM #tblPRICES 
					GROUP BY intItemId ,perUnit ) X
					ON #tblPRICES.intItemId = X.intItemId AND #tblPRICES.perUnit = X.perUnit
		
		SELECT DISTINCT ID = RowID ,name = name,perUnit  --,intItemId--,pricingMethod, reference, intItemId
		FROM #tblPRICES 
		--ORDER BY pricingMethod, intItemId, perUnit  

--PRODUCTS---------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT
			CAST(item.strItemNo AS NVARCHAR(16)) code
			, CAST(item.strShortName AS NVARCHAR(35)) name
			,p.RowID priceID 
			, CAST('' AS NVARCHAR(8)) taxCode
			, 0 aux1
			, 0 aux2
			, CAST(0 AS NVARCHAR(8)) fuelTypeCode
			, 0 preOp
			, 0 postOp
		FROM tblICItem item
		OUTER APPLY (SELECT TOP 1 perUnit,RowID,intLocationId FROM #tblPRICES prices WHERE item.intItemId = prices.reference AND prices.pricingMethod = 'Item') p--p ON item.intItemId = p.reference AND p.pricingMethod = 'Item'
		WHERE item.ysnAvailableTM = 1
			OR item.strType = 'Service'
		GROUP BY item.intItemId,item.strItemNo, item.strShortName,RowID, p.intLocationId
		ORDER BY p.intLocationId DESC


--ASSET ACCT---------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT
			 account = C.strEntityNo
			 ,number = REPLACE(STR(intSiteNumber, 4), SPACE(1), '0') + '-' + ISNULL(G.strSerialNumber,'')
			 ,reference = RTRIM(SUBSTRING(A.strDescription,0,11))
			 ,priceID = X.RowID
			 ,priceDiscount = 0.0000
			 ,cashCode = (SELECT TOP 1 strTermCode FROM tblSMTerm WHERE intTermID =  A.intDeliveryTermID )
			 ,miscTranCode = ''
			 ,misPriceID = ''
			 ,lastDate =  CONVERT(VARCHAR(10), dtmLastDeliveryDate, 112)
			 ,lastAmount = CAST(ROUND(dblLastDeliveredGal,2) AS NUMERIC(18,2))
			 --,X.name --shortName
			  --,priceID = CAST(F.dblSalePrice AS NUMERIC(8,6))
			  --CAST(ROW_NUMBER() OVER(ORDER BY intSiteNumber ASC) AS NVARCHAR(100)) AS RowID
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B
			ON A.intCustomerID =B.intCustomerID
		INNER JOIN (SELECT 
						Ent.strEntityNo
						,Ent.intEntityId
						,Cus.ysnActive
					FROM tblEMEntity Ent
					INNER JOIN tblARCustomer Cus 
						ON Ent.intEntityId = Cus.intEntityId
					) C
					ON B.intCustomerNumber = C.intEntityId
		--LEFT JOIN (
		--			SELECT 
		--				A.intItemId
		--				,A.strItemNo 
		--				,A.intLocationId
		--				,A.dblSalePrice
		--				,A.intUnitMeasureId
		--				,shortName = A.strItemNo --shortName
		--				,X.RowID
		--			FROM vyuICGetItemPricing A
		--			WHERE intUnitMeasureId = (SELECT TOP 1 intIssueUOMId FROM tblICItemLocation WHERE intItemId = A.intItemId AND intLocationId = A.intLocationId)
		--			) F
		--			ON 	F.intItemId = A.intProduct
		--				AND A.intLocationId = F.intLocationId
		LEFT JOIN #tblPRICES X ON A.intProduct = X.reference AND A.intLocationId = X.intLocationId AND X.pricingMethod = 'Item'
		LEFT JOIN (
					SELECT 
						AA.intSiteID
						,BB.strSerialNumber
						,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
					FROM tblTMSiteDevice AA
					INNER JOIN tblTMDevice BB
						ON AA.intDeviceId = BB.intDeviceId
					INNER JOIN tblTMDeviceType CC
						ON BB.intDeviceTypeId = CC.intDeviceTypeId
					WHERE ISNULL(BB.ysnAppliance,0) = 0
						AND CC.strDeviceType = 'Tank'
					) G
					ON A.intSiteID = G.intSiteID AND G.intCntId = 1
		WHERE C.ysnActive = 1 AND A.ysnActive = 1 
 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--TM DISPATCH ---------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT 
			 routeNum = J.strRouteId
			 ,seqNum = ''
			 ,account = CAST(C.strEntityNo AS NVARCHAR(16))
			 ,asset = REPLACE(STR(A.intSiteNumber, 4), SPACE(1), '0') + '-' + ISNULL(K.strSerialNumber,'')
			 ,orderQty = CAST(ROUND((CASE WHEN ISNULL(D.dblMinimumQuantity,0) = 0 THEN ISNULL(D.dblQuantity,0.0) ELSE D.dblMinimumQuantity END),0) AS INT)
			 ,priceID = X.RowID --,priceID = D.dblPrice
			 ,invoice = ''
			 ,"message" = CAST(D.strComments AS NVARCHAR(64))
			 ,reference = D.intDispatchID
			 ,taxCode = A.intTaxStateID
		FROM tblTMSite A
		INNER JOIN tblTMCustomer B
			ON A.intCustomerID =B.intCustomerID
		INNER JOIN (SELECT 
						Ent.strEntityNo
						,Ent.intEntityId
						,Cus.ysnActive
					FROM tblEMEntity Ent
					INNER JOIN tblARCustomer Cus 
						ON Ent.intEntityId = Cus.intEntityId) C
			ON B.intCustomerNumber =C.intEntityId
		INNER JOIN tblTMDispatch D
			ON A.intSiteID = D.intSiteID
        INNER JOIN #tblPRICES X
			ON D.intDispatchID = X.reference AND X.pricingMethod = 'Dispatch'
		LEFT JOIN tblTMRoute J
			ON A.intRouteId = J.intRouteId
		LEFT JOIN tblSMTaxGroup H
			ON A.intTaxStateID = H.intTaxGroupId
		LEFT JOIN (
				SELECT 
					AA.intSiteID
					,BB.strSerialNumber
					,intCntId = ROW_NUMBER() OVER (PARTITION BY AA.intSiteID ORDER BY AA.intSiteDeviceID ASC)
				FROM tblTMSiteDevice AA
				INNER JOIN tblTMDevice BB
					ON AA.intDeviceId = BB.intDeviceId
				INNER JOIN tblTMDeviceType CC
					ON BB.intDeviceTypeId = CC.intDeviceTypeId
				WHERE ISNULL(BB.ysnAppliance,0) = 0
					AND CC.strDeviceType = 'Tank'
			) K
				ON A.intSiteID = K.intSiteID AND K.intCntId = 1
		WHERE C.ysnActive = 1 AND A.ysnActive = 1
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
GO
