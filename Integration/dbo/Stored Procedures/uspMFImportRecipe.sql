IF EXISTS(select top 1 1 from sys.procedures where name = 'uspMFImportRecipe')
	DROP PROCEDURE uspMFImportRecipe
GO

	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================

	DECLARE @cnt INT = 1
	DECLARE @SQLCMD NVARCHAR(3000)
	DECLARE @EntityId int
	SET @EntityId = ISNULL((SELECT  intEntityUserSecurityId FROM tblSMUserSecurity WHERE intEntityUserSecurityId = @UserId),@UserId)

	DECLARE @ysnAG BIT = 0
    DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst
	
	IF NOT EXISTS (select intManufacturingProcessId from tblMFManufacturingProcess where strProcessName= 'Blending')
	BEGIN
		INSERT INTO [tblMFManufacturingProcess]
				   ([strProcessName]
				   ,[strDescription]
				   ,[intAttributeTypeId]
				   ,[intCreatedUserId]
				   ,[dtmCreated]
				   ,[intLastModifiedUserId]
				   ,[dtmLastModified]
				   ,[intConcurrencyId])
			 VALUES
				   ('Blending'
				   ,'Blending'
				   ,(select intAttributeTypeId from tblMFAttributeType where strAttributeTypeName = 'Blending')
				   ,@EntityId
				   ,GETDATE()
				   ,@EntityId
				   ,GETDATE()
				   ,1)
	END				
	

	IF(@Checking = 0)
	BEGIN
			--================================================
			--     Insert into tblMFRecipe--AG Recipes--
			--================================================			
		--IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		-- Begin
			--================================================
			--     Insert into tblMFRecipe--PT Recipes--
			--================================================	
					
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptfrmmst')
		 Begin
			INSERT INTO [dbo].[tblMFRecipe]
					   ([strName]
					   ,[intItemId]
					   ,[dblQuantity]
					   ,[intItemUOMId]
					   ,[intLocationId]
					   ,[intVersionNo]
					   ,[intRecipeTypeId]
					   ,[intManufacturingProcessId]
					   ,[ysnActive]
					   ,[ysnImportOverride]
					   ,[ysnAutoBlend]
					   ,[intCreatedUserId]
					   ,[dtmCreated]
					   ,[intLastModifiedUserId]
					   ,[dtmLastModified]
					   ,[intConcurrencyId])
			SELECT      ITM.strDescription
					   ,ITM.[intItemId]
					   ,UOM.dblUnitQty--[dblQuantity]
					   ,UOM.intItemUOMId--[intItemUOMId]
					   ,LOC.intCompanyLocationId--[intLocationId]
					   ,1--[intVersionNo]
					   ,(select intRecipeTypeId from tblMFRecipeType where strName = 'By Quantity')--[intRecipeTypeId]
					   ,(select intManufacturingProcessId from tblMFManufacturingProcess where strProcessName= 'Blending')--[intManufacturingProcessId]
					   ,1--[ysnActive]
					   ,0--[ysnImportOverride]
					   ,CASE WHEN (FRM.ptfrm_auto_blend_yn = 'Y') THEN 1 ELSE 0 END--[ysnAutoBlend]
					   ,@EntityId--[intCreatedUserId]
					   ,(CASE WHEN ISDATE(FRM.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRM.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--,[dtmCreated]
					   ,@EntityId--[intLastModifiedUserId]
					   ,(CASE WHEN ISDATE(FRM.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRM.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmLastModified]
					   ,1--[intConcurrencyId]
			FROM ptfrmmst  FRM
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )			
		 end
		
			--==========================================================
			--     Insert into tblARInvoiceDetail - AG INVOICE DETAILS
			--==========================================================
		--IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		-- Begin
		-- end 

			--==========================================================
			--     Insert into tblARInvoiceDetail - PT INVOICE DETAILS
			--==========================================================
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 Begin
		 -- Insert Output item
			INSERT INTO [tblMFRecipeItem]
			           ([intRecipeId]
			           ,[intItemId]
			           ,[strDescription]
			           ,[dblQuantity]
			           ,[dblCalculatedQuantity]
			           ,[intItemUOMId]
			           ,[intRecipeItemTypeId]
			           ,[strItemGroupName]
			           ,[dblUpperTolerance]
			           ,[dblLowerTolerance]
			           ,[dblCalculatedUpperTolerance]
			           ,[dblCalculatedLowerTolerance]
			           ,[dblShrinkage]
			           ,[ysnScaled]
			           ,[ysnYearValidationRequired]
			           ,[ysnMinorIngredient]
			           ,[ysnOutputItemMandatory]
			           ,[dblScrap]
			           ,[ysnConsumptionRequired]
			           ,[ysnCostAppliedAtInvoice]
			           ,[intSequenceNo]
			           ,[intCreatedUserId]
			           ,[dtmCreated]
			           ,[intLastModifiedUserId]
			           ,[dtmLastModified]
			           ,[intConcurrencyId])
			SELECT      RCP.intRecipeId
			           ,RCP.intItemId
			           ,NULL
			           ,RCP.dblQuantity
			           ,0
			           ,RCP.intItemUOMId
			           ,(SELECT intRecipeItemTypeId FROM tblMFRecipeItemType WHERE strName = 'OUTPUT')
			           ,''
			           ,0
			           ,0
			           ,RCP.dblQuantity
			           ,RCP.dblQuantity
			           ,0
			           ,0
			           ,0
			           ,0
			           ,1
			           ,0
			           ,1
			           ,0
			           ,NULL
			           ,@EntityId
			           ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
			           ,@EntityId
			           ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
			           ,1          
			FROM ptfrmmst FRMI
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId 
			WHERE NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId )			

			--Insert all ingredient items 
			WHILE @cnt < 11
			BEGIN
			   SET @SQLCMD = 'INSERT INTO [tblMFRecipeItem]
					   ([intRecipeId]
					   ,[intItemId]
					   ,[strDescription]
					   ,[dblQuantity]
					   ,[dblCalculatedQuantity]
					   ,[intItemUOMId]
					   ,[intRecipeItemTypeId]
					   ,[strItemGroupName]
					   ,[dblUpperTolerance]
					   ,[dblLowerTolerance]
					   ,[dblCalculatedUpperTolerance]
					   ,[dblCalculatedLowerTolerance]
					   ,[dblShrinkage]
					   ,[ysnScaled]
					   ,[ysnYearValidationRequired]
					   ,[ysnMinorIngredient]
					   ,[ysnOutputItemMandatory]
					   ,[dblScrap]
					   ,[ysnConsumptionRequired]
					   ,[ysnCostAppliedAtInvoice]
					   ,[intSequenceNo]
					   ,[intCreatedUserId]
					   ,[dtmCreated]
					   ,[intLastModifiedUserId]
					   ,[dtmLastModified]
					   ,[intConcurrencyId])
						SELECT      RCP.intRecipeId
					   ,ITM1.intItemId
					   ,NULL
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,0
					   ,UOM.intItemUOMId
					   ,(SELECT intRecipeItemTypeId FROM tblMFRecipeItemType WHERE strName = ''INPUT'')
					   ,''''
					   ,0
					   ,0
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,0  --[dblShrinkage]
					   ,1  --[ysnScaled]
					   ,0  --[ysnYearValidationRequired]
					   ,0  --[ysnMinorIngredient]
					   ,0  --[ysnOutputItemMandatory]
					   ,0  --[dblScrap]
					   ,0  --[ysnConsumptionRequired]
					   ,0  --[ysnCostAppliedAtInvoice]
					   ,1  --[intSequenceNo]
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,1          
			FROM ptfrmmst FRMI
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM1 ON ITM1.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM1.intItemId   
			WHERE FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' IS NOT NULL AND NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId  AND intItemId = ITM1.intItemId )' 

			   EXEC (@SQLCMD)

			   SET @cnt = @cnt + 1;
			END
		 END
	END

		 			
	--================================================
	--     GET TO BE IMPORTED RECORDS
	--	This is checking if there are still records need to be import	
	--================================================
	IF(@Checking = 1)
	BEGIN
		--IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agivcmst')
		-- BEGIN
		 --Check first on agflmmst

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
		 BEGIN
		--Check first on ptfrmmst
			SELECT @Total = COUNT(FRM.ptfrm_itm_no)	FROM ptfrmmst FRM
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )				
		 END		
		
	END
		
END	



