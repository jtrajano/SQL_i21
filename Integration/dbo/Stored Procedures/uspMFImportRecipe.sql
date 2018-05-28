IF EXISTS(select top 1 1 from sys.procedures where name = 'uspMFImportRecipe')
	DROP PROCEDURE uspMFImportRecipe
GO
CREATE PROCEDURE uspMFImportRecipe
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN
	--================================================
	--     ONE TIME INVOICE SYNCHRONIZATION	
	--================================================

	DECLARE @cnt INT = 1
	DECLARE @SQLCMD NVARCHAR(4000)
	DECLARE @EntityId int
	SET @EntityId = ISNULL((SELECT  intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId),@UserId)

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
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agfmlmst')
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
			SELECT      LTRIM(RTRIM(ITM.strDescription))+'_'+LTRIM(agfml_seq_no)
					   ,ITM.[intItemId]
					   ,UOM.dblUnitQty--[dblQuantity]
					   ,UOM.intItemUOMId--[intItemUOMId]
					   ,LOC.intCompanyLocationId--[intLocationId]
					   ,1--[intVersionNo]
					   ,(select intRecipeTypeId from tblMFRecipeType where strName = 'By Quantity')--[intRecipeTypeId]
					   ,(select intManufacturingProcessId from tblMFManufacturingProcess where strProcessName= 'Blending')--[intManufacturingProcessId]
					   ,1--[ysnActive]
					   ,0--[ysnImportOverride]
					   ,0--[ysnAutoBlend]
					   ,@EntityId--[intCreatedUserId]
					   ,(CASE WHEN ISDATE(FRM.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRM.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--,[dtmCreated]
					   ,@EntityId--[intLastModifiedUserId]
					   ,(CASE WHEN ISDATE(FRM.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRM.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmLastModified]
					   ,1--[intConcurrencyId]
			FROM agfmlmst  FRM
			INNER JOIN agitmmst OITM ON OITM.agitm_no = FRM.agfml_itm_no AND OITM.agitm_loc_no = FRM.agfml_loc_no				
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.agfml_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.agfml_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )			
		 END

		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agrcpmst')
		 Begin
			INSERT INTO [dbo].[tblMFRecipe]
					   ([strName]
					   ,[intCustomerId]
					   ,[intItemId]
					   ,[dblQuantity]
					   ,[intItemUOMId]
					   ,[intMarginUOMId]
					   ,[intLocationId]
					   ,[intVersionNo]
					   ,[intRecipeTypeId]
					   ,[intManufacturingProcessId]
					   ,[ysnActive]
					   ,[ysnImportOverride]
					   ,[ysnAutoBlend]
					   ,[dblMargin]
					   ,[intCreatedUserId]
					   ,[dtmCreated]
					   ,[intLastModifiedUserId]
					   ,[dtmLastModified]
					   ,[intConcurrencyId])
			SELECT      LTRIM(RTRIM(RCP.agrcp_rcp_no))
					   ,CUS.intEntityId --[intCustomerId]
					   ,NULL
					   ,1--[dblQuantity]
					   ,NULL--[intItemUOMId]
					   ,(SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE Upper(strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = 'LB')
					   ,LOC.intCompanyLocationId--[intLocationId]
					   ,1--[intVersionNo]
					   ,(select intRecipeTypeId from tblMFRecipeType where strName = 'By Quantity')--[intRecipeTypeId]
					   ,(select intManufacturingProcessId from tblMFManufacturingProcess where strProcessName= 'Blending')--[intManufacturingProcessId]
					   ,1--[ysnActive]
					   ,0--[ysnImportOverride]
					   ,0--[ysnAutoBlend]
					   ,RCP.agrcp_mrgn--[dblMargin]					   
					   ,1--@EntityId--[intCreatedUserId]
					   ,(CASE WHEN ISDATE(RCP.agrcp_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(RCP.agrcp_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--,[dtmCreated]
					   ,1--@EntityId--[intLastModifiedUserId]
					   ,(CASE WHEN ISDATE(RCP.agrcp_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(RCP.agrcp_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)--[dtmLastModified]
					   ,1--[intConcurrencyId]			
		    FROM agrcpmst RCP
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE strName COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_rcp_no COLLATE SQL_Latin1_General_CP1_CS_AS)
		END
		
			--==========================================================
			--     Insert into tblMFRecipeItem - AG Recipe Items
			--==========================================================
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agfmlmst')
		 BEGIN
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
			           ,1
			           ,(CASE WHEN ISDATE(FRMI.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
			           ,1
			           ,(CASE WHEN ISDATE(FRMI.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
			           ,1    
			FROM agfmlmst FRMI
			INNER JOIN agitmmst OITM ON OITM.agitm_no = FRMI.agfml_itm_no AND OITM.agitm_loc_no = FRMI.agfml_loc_no					
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.agfml_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.agfml_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
									AND RCP.[strName] = LTRIM(RTRIM(ITM.strDescription))+'_'+LTRIM(agfml_seq_no)
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId )			

			--Insert all ingredient items 
			WHILE @cnt < 61
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
					   ,[intConsumptionMethodId]
					   ,[ysnYearValidationRequired]
					   ,[ysnMinorIngredient]
					   ,[ysnOutputItemMandatory]
					   ,[dblScrap]
					   ,dtmValidFrom
					   ,dtmValidTo
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
					   ,FRMI.agfml_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,FRMI.agfml_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,UOM.intItemUOMId
					   ,(SELECT intRecipeItemTypeId FROM tblMFRecipeItemType WHERE strName = ''INPUT'')
					   ,''''
					   ,0
					   ,0
					   ,FRMI.agfml_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,FRMI.agfml_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,0  --[dblShrinkage]
					   ,1  --[ysnScaled]
					   ,CASE WHEN ITM.strType = ''Other Charge'' THEN 
							(SELECT intConsumptionMethodId FROM tblMFConsumptionMethod WHERE strName = ''None'')
							ELSE 1 END
					   ,0  --[ysnYearValidationRequired]
					   ,0  --[ysnMinorIngredient]
					   ,0  --[ysnOutputItemMandatory]
					   ,0  --[dblScrap]
					   ,''1900-01-01 00:00:00.000'' --dtmValidFrom
					   ,''9999-12-31 00:00:00.000'' --dtmValidTo,					   
					   ,0  --[ysnConsumptionRequired]
					   ,0  --[ysnCostAppliedAtInvoice]
					   ,1  --[intSequenceNo]
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.agfml_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.agfml_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,1          
			FROM agfmlmst FRMI
			INNER JOIN agitmmst OITM ON OITM.agitm_no = FRMI.agfml_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' AND OITM.agitm_loc_no = FRMI.agfml_loc_no
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.agfml_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM1 ON ITM1.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.agfml_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.agfml_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
										AND RCP.[strName] = LTRIM(RTRIM(ITM.strDescription))+''_''+LTRIM(agfml_seq_no)
			LEFT  JOIN tblICUnitMeasure UM ON Upper(UM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = ''LB''
			LEFT JOIN tblICItemUOM UOM ON UOM.intItemId = ITM1.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId  
			WHERE FRMI.agfml_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' IS NOT NULL AND NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId  AND intItemId = ITM1.intItemId ) 			
			' 
			
			   EXEC (@SQLCMD)

			   SET @cnt = @cnt + 1;
			END
		 END

			--==========================================================
			--     Insert into tblMFRecipeItem - AG Recipe Items - agrcpmst
			--==========================================================
IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agrcpmst')
		 BEGIN
			SET @cnt = 1
			SET @SQLCMD = ' '
			--Insert all ingredient items 
			WHILE @cnt < 61
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
					   ,[intConsumptionMethodId]
					   ,[ysnYearValidationRequired]
					   ,[ysnMinorIngredient]
					   ,[ysnOutputItemMandatory]
					   ,[dblScrap]
					   ,dtmValidFrom
					   ,dtmValidTo
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
					   ,RCPI.agrcp_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,0
					   ,UOM.intItemUOMId
					   ,(SELECT intRecipeItemTypeId FROM tblMFRecipeItemType WHERE strName = ''INPUT'')
					   ,''''
					   ,0
					   ,0
					   ,RCPI.agrcp_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,RCPI.agrcp_ingr_lbs_'+CAST(@cnt AS NVARCHAR)+'
					   ,0  --[dblShrinkage]
					   ,1  --[ysnScaled]
					   ,CASE WHEN ITM1.strType = ''Other Charge'' THEN 
							(SELECT intConsumptionMethodId FROM tblMFConsumptionMethod WHERE strName = ''None'')
							ELSE 1 END
					   ,0  --[ysnYearValidationRequired]
					   ,0  --[ysnMinorIngredient]
					   ,0  --[ysnOutputItemMandatory]
					   ,0  --[dblScrap]
					   ,''1900-01-01 00:00:00.000'' --dtmValidFrom
					   ,''9999-12-31 00:00:00.000'' --dtmValidTo,					   
					   ,0  --[ysnConsumptionRequired]
					   ,0  --[ysnCostAppliedAtInvoice]
					   ,1  --[intSequenceNo]
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(RCPI.agrcp_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(RCPI.agrcp_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(RCPI.agrcp_user_rev_dt) = 1 THEN CONVERT(DATE, CAST(RCPI.agrcp_user_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,1          
			FROM agrcpmst RCPI
			INNER JOIN agitmmst OITM ON OITM.agitm_no = RCPI.agrcp_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' AND OITM.agitm_loc_no = RCPI.agrcp_loc_no
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCPI.agrcp_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			--INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = RCPI.agrcp_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM1 ON ITM1.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = RCPI.agrcp_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCPI.agrcp_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intCustomerId = CUS.intEntityId AND RCP.intLocationId = LOC.intCompanyLocationId
										AND RCP.[strName] COLLATE SQL_Latin1_General_CP1_CS_AS = LTRIM(RTRIM(RCPI.agrcp_rcp_no)) COLLATE SQL_Latin1_General_CP1_CS_AS
			LEFT  JOIN tblICUnitMeasure UM ON Upper(UM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = ''LB''
			LEFT JOIN tblICItemUOM UOM ON UOM.intItemId = ITM1.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId  
			WHERE RCPI.agrcp_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' IS NOT NULL AND NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId  AND intItemId = ITM1.intItemId )
			' 
			
			   EXEC (@SQLCMD)

			   SET @cnt = @cnt + 1;
			END
		 END
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
			INNER JOIN ptitmmst OITM ON OITM.ptitm_itm_no = FRM.ptfrm_itm_no AND OITM.ptitm_loc_no = FRM.ptfrm_loc_no				
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )			
		 end
		
			--==========================================================
			--     Insert into tblMFRecipeItem - PT FORMULA DETAILS
			--==========================================================
		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptfrmmst')
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
			INNER JOIN ptitmmst OITM ON OITM.ptitm_itm_no = FRMI.ptfrm_itm_no AND OITM.ptitm_loc_no = FRMI.ptfrm_loc_no					
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
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
					   ,[intConsumptionMethodId]
					   ,[ysnYearValidationRequired]
					   ,[ysnMinorIngredient]
					   ,[ysnOutputItemMandatory]
					   ,[dblScrap]
					   ,dtmValidFrom
					   ,dtmValidTo
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
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,UOM.intItemUOMId
					   ,(SELECT intRecipeItemTypeId FROM tblMFRecipeItemType WHERE strName = ''INPUT'')
					   ,''''
					   ,0
					   ,0
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,FRMI.ptfrm_ingr_qty_'+CAST(@cnt AS NVARCHAR)+'
					   ,0  --[dblShrinkage]
					   ,1  --[ysnScaled]
					   ,CASE WHEN ITM.strType = ''Other Charge'' THEN 
							(SELECT intConsumptionMethodId FROM tblMFConsumptionMethod WHERE strName = ''None'')
							ELSE 1 END
					   ,0  --[ysnYearValidationRequired]
					   ,0  --[ysnMinorIngredient]
					   ,0  --[ysnOutputItemMandatory]
					   ,0  --[dblScrap]
					   ,''1900-01-01 00:00:00.000'' --dtmValidFrom
					   ,''9999-12-31 00:00:00.000'' --dtmValidTo,					   
					   ,0  --[ysnConsumptionRequired]
					   ,0  --[ysnCostAppliedAtInvoice]
					   ,1  --[intSequenceNo]
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,'+CAST(@EntityId AS NVARCHAR)+'
					   ,(CASE WHEN ISDATE(FRMI.ptfrm_last_chg_rev_dt) = 1 THEN CONVERT(DATE, CAST(FRMI.ptfrm_last_chg_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END)
					   ,1          
			FROM ptfrmmst FRMI
			INNER JOIN ptitmmst OITM ON OITM.ptitm_itm_no = FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' AND OITM.ptitm_loc_no = FRMI.ptfrm_loc_no
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM1 ON ITM1.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM1.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId  
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
		IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agfmlmst')
		 BEGIN
		 --Check first on agfmlmst
			SELECT  @Total = COUNT(FRM.agfml_itm_no) FROM agfmlmst FRM
			INNER JOIN agitmmst OITM ON OITM.agitm_no = FRM.agfml_itm_no AND OITM.agitm_loc_no = FRM.agfml_loc_no
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.agfml_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.agfml_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strUnitMeasure) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.agitm_un_desc) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )

			SELECT  @Total = @Total + COUNT(*) FROM agrcpmst RCP
			INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE strName COLLATE SQL_Latin1_General_CP1_CS_AS = RCP.agrcp_rcp_no COLLATE SQL_Latin1_General_CP1_CS_AS)
		END

		IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptfrmmst')
		 BEGIN
		--Check first on ptfrmmst
			SELECT @Total = COUNT(FRM.ptfrm_itm_no)	FROM ptfrmmst FRM
			INNER JOIN ptitmmst OITM ON OITM.ptitm_itm_no = FRM.ptfrm_itm_no AND OITM.ptitm_loc_no = FRM.ptfrm_loc_no				
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRM.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId
			WHERE NOT EXISTS (select * from tblMFRecipe WHERE intItemId = ITM.intItemId AND intLocationId = LOC.intCompanyLocationId )				
		 END		
		
	END
		
END	
GO
