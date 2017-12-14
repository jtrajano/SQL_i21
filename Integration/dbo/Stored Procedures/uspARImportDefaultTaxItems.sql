IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportDefaultTaxItems')
	DROP PROCEDURE uspARImportDefaultTaxItems
GO

CREATE PROCEDURE [dbo].[uspARImportDefaultTaxItems]
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN

	DECLARE @ptlcl_state CHAR(2), @SQLCMD VARCHAR(3000), @cnt INT = 1
	DECLARE @Tempcnt TABLE
	(
		strItemNo nvarchar(100)
	) 
	
	IF (@Checking = 1)
	BEGIN
		SELECT DISTINCT ptlcl_state INTO #tmptx FROM ptlclmst

					WHILE (EXISTS(SELECT 1 FROM #tmptx))
					BEGIN 
							 SELECT @ptlcl_state =  ptlcl_state FROM #tmptx
							SET @cnt = 1

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC1-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local1_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC1-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local1_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC2-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local2_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC2-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local2_desc
								
							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC3-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local3_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC3-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local3_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC4-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local4_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC4-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local4_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC5-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local5_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC5-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local5_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC6-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local6_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC6-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local6_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC7-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local7_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC7-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local7_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC8-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local8_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC8-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local8_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC9-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local9_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC9-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local9_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC10-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local10_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC10-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local10_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC11-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local11_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC11-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local11_desc

							    INSERT INTO @Tempcnt   SELECT TOP 1 strItemNo	= 'LC12-'+ptlcl_state COLLATE Latin1_General_CI_AS
								FROM ptlclmst AS LCL
								WHERE ptlcl_state = @ptlcl_state AND ptlcl_local12_desc IS NOT NULL
								AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
														'LC12-'+ptlcl_state COLLATE Latin1_General_CI_AS)
								GROUP BY ptlcl_state, ptlcl_local12_desc
			

						DELETE FROM #tmptx WHERE ptlcl_state = @ptlcl_state
					END
					
					SELECT @Total = COUNT(*) from @Tempcnt
					
				RETURN (@Total)					
	END


 IF NOT EXISTS (select * from tblICCategory where strCategoryCode = 'Origin Taxes')
 BEGIN
	INSERT INTO tblICCategory (strCategoryCode, strDescription, strInventoryType)
	VALUES ('Origin Taxes', 'Origin Taxes', 'Other Charge')
 END

--------------------------------------------------------------------------------------------------------
IF NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo = 'SST')
BEGIN
	INSERT INTO tblICItem 
				(strItemNo				
				,strType				
				,strDescription		
				,strStatus				
				,strInventoryTracking	
				,strLotTracking		
				,intCategoryId			
				,intLifeTime			
				,ysnLandedCost			
				,ysnDropShip			
				,ysnSpecialCommission	
				,intConcurrencyId)		

	VALUES ( 'SST' COLLATE Latin1_General_CI_AS
			,'Other Charge' COLLATE Latin1_General_CI_AS
			,'STATE SALES TAX' COLLATE Latin1_General_CI_AS
			,'Discontinued' COLLATE Latin1_General_CI_AS
			,'Item Level' COLLATE Latin1_General_CI_AS
			,'No' COLLATE Latin1_General_CI_AS
			,(SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = 'Origin Taxes' COLLATE SQL_Latin1_General_CP1_CS_AS)
			,1
			,0
			,0
			,0
			,1)
END

IF NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo = 'SET')
BEGIN
	INSERT INTO tblICItem 
				(strItemNo				
				,strType				
				,strDescription		
				,strStatus				
				,strInventoryTracking	
				,strLotTracking		
				,intCategoryId			
				,intLifeTime			
				,ysnLandedCost			
				,ysnDropShip			
				,ysnSpecialCommission	
				,intConcurrencyId)		

	VALUES ( 'SET' COLLATE Latin1_General_CI_AS
			,'Other Charge' COLLATE Latin1_General_CI_AS
			,'STATE EXCISE TAX' COLLATE Latin1_General_CI_AS
			,'Discontinued' COLLATE Latin1_General_CI_AS
			,'Item Level' COLLATE Latin1_General_CI_AS
			,'No' COLLATE Latin1_General_CI_AS
			,(SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = 'Origin Taxes' COLLATE SQL_Latin1_General_CP1_CS_AS)
			,1
			,0
			,0
			,0
			,1)
END

IF NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo = 'PST')
BEGIN
	INSERT INTO tblICItem 
				(strItemNo				
				,strType				
				,strDescription		
				,strStatus				
				,strInventoryTracking	
				,strLotTracking		
				,intCategoryId			
				,intLifeTime			
				,ysnLandedCost			
				,ysnDropShip			
				,ysnSpecialCommission	
				,intConcurrencyId)		

	VALUES ( 'PST' COLLATE Latin1_General_CI_AS
			,'Other Charge' COLLATE Latin1_General_CI_AS
			,'PREPAID SALES TAX' COLLATE Latin1_General_CI_AS
			,'Discontinued' COLLATE Latin1_General_CI_AS
			,'Item Level' COLLATE Latin1_General_CI_AS
			,'No' COLLATE Latin1_General_CI_AS
			,(SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = 'Origin Taxes' COLLATE SQL_Latin1_General_CP1_CS_AS)
			,1
			,0
			,0
			,0
			,1)
END

IF NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo = 'FET')
BEGIN
	INSERT INTO tblICItem 
				(strItemNo				
				,strType				
				,strDescription		
				,strStatus				
				,strInventoryTracking	
				,strLotTracking		
				,intCategoryId			
				,intLifeTime			
				,ysnLandedCost			
				,ysnDropShip			
				,ysnSpecialCommission	
				,intConcurrencyId)		

	VALUES ( 'FET' COLLATE Latin1_General_CI_AS
			,'Other Charge' COLLATE Latin1_General_CI_AS
			,'FEDERAL EXCISE TAX' COLLATE Latin1_General_CI_AS
			,'Discontinued' COLLATE Latin1_General_CI_AS
			,'Item Level' COLLATE Latin1_General_CI_AS
			,'No' COLLATE Latin1_General_CI_AS
			,(SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = 'Origin Taxes' COLLATE SQL_Latin1_General_CP1_CS_AS)
			,1
			,0
			,0
			,0
			,1)
END

----------------------------------------------------------------------------------------------------
SELECT DISTINCT ptlcl_state INTO #tmpST FROM ptlclmst

			WHILE (EXISTS(SELECT 1 FROM #tmpST))
			BEGIN 
					SELECT @ptlcl_state = ptlcl_state FROM #tmpST
					SET @cnt = 1
				WHILE @cnt < 13
					BEGIN
					   SET @SQLCMD = ' 	INSERT INTO tblICItem 
				(strItemNo				
				,strType				
				,strDescription		
				,strStatus				
				,strInventoryTracking	
				,strLotTracking		
				,intCategoryId			
				,intLifeTime			
				,ysnLandedCost			
				,ysnDropShip			
				,ysnSpecialCommission	
				,intConcurrencyId)
				SELECT TOP 1
							 strItemNo					= ''LC'+CAST(@cnt AS NVARCHAR)+'-''+ptlcl_state COLLATE Latin1_General_CI_AS
							, strType					= ''Other Charge'' COLLATE Latin1_General_CI_AS
							, strDescription			= ptlcl_local'+CAST(@cnt AS NVARCHAR)+'_desc COLLATE Latin1_General_CI_AS
							, strStatus					= ''Discontinued'' COLLATE Latin1_General_CI_AS
							, strInventoryTracking		= ''Item Level'' COLLATE Latin1_General_CI_AS
							, strLotTracking			= ''No'' COLLATE Latin1_General_CI_AS
							, intCategoryId				= (SELECT TOP 1 min(intCategoryId) FROM tblICCategory AS cls WHERE (cls.strCategoryCode) COLLATE SQL_Latin1_General_CP1_CS_AS = ''Origin Taxes'' COLLATE SQL_Latin1_General_CP1_CS_AS)
							, intLifeTime				= 1
							, ysnLandedCost				= CAST(0 AS BIT)
							, ysnDropShip				= CAST(0 AS BIT)
							, ysnSpecialCommission		= CAST(0 AS BIT)
							, intConcurrencyId			= 1
						FROM ptlclmst AS LCL
						WHERE ptlcl_state = '''+@ptlcl_state+'''
						AND  NOT EXISTS ( SELECT * FROM tblICItem WHERE strItemNo COLLATE Latin1_General_CI_AS = 
						''LC'+CAST(@cnt AS NVARCHAR)+'-''+ptlcl_state COLLATE Latin1_General_CI_AS)
						GROUP BY ptlcl_state, ptlcl_local'+CAST(@cnt AS NVARCHAR)+'_desc'			

					   EXEC (@SQLCMD)

					   SET @cnt = @cnt + 1;
					END				

				DELETE FROM #tmpST WHERE ptlcl_state = @ptlcl_state
			END 


--------------------------------------------------------------------------------------------
INSERT INTO tblICItemUOM (
			  intItemId			
			 ,intUnitMeasureId
			 ,dblUnitQty		
			 ,ysnStockUnit		
			 ,ysnAllowPurchase
			 ,ysnAllowSale		
			 ,intConcurrencyId)
	   SELECT intItemId			= I.intItemId
			, intUnitMeasureId	= U.intUnitMeasureId
			, dblUnitQty		= 1
			, ysnStockUnit		= CAST(1 AS BIT)
			, ysnAllowPurchase	= CAST(1 AS BIT)
			, ysnAllowSale		= CAST(1 AS BIT)
			, intConcurrencyId	= 1 
		FROM tblICItem I
		INNER JOIN tblICCategory C ON C.intCategoryId = I.intCategoryId
		INNER JOIN tblICUnitMeasure U ON U.strUnitMeasure = 'GALLON'
		WHERE C.strCategoryCode ='Origin Taxes' 
		AND NOT EXISTS (SELECT * FROM tblICItem WHERE intItemId = I.intItemId 
		AND intUnitMeasureId	= U.intUnitMeasureId)


END


	
GO


