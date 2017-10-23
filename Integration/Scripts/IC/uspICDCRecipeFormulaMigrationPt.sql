IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspICDCRecipeFormulaMigrationPt]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [uspICDCRecipeFormulaMigrationPt]; 
GO

CREATE PROCEDURE [dbo].[uspICDCRecipeFormulaMigrationPt]
	@UserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


----======================================----------
---- Referenced from uspMFImportRecipe
----======================================----------

	DECLARE @EntityId INT;
	DECLARE @cnt INT = 1;
	DECLARE @SQLCMD NVARCHAR(4000);
	DECLARE @TransactionName AS VARCHAR(500) = 'IMPORT RECIPE/FORMULA' + CAST(NEWID() AS NVARCHAR(100));
	DECLARE @errorMsg NVARCHAR(200);

	SET @EntityId = ISNULL((SELECT  intEntityId FROM tblSMUserSecurity WHERE intEntityId = @UserId), @UserId)
	
	BEGIN TRAN @TransactionName;
	SAVE TRAN @TransactionName;

	IF NOT EXISTS (SELECT intManufacturingProcessId FROM tblMFManufacturingProcess WHERE strProcessName= 'Blending')
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
				   ,(SELECT intAttributeTypeId FROM tblMFAttributeType WHERE strAttributeTypeName = 'Blending')
				   ,@EntityId
				   ,GETDATE()
				   ,@EntityId
				   ,GETDATE()
				   ,1)
	END

	--================================================
	--     Insert into tblMFRecipe--PT Recipes--
	--================================================
	IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptfrmmst')
	BEGIN
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
	END
	ELSE
	BEGIN
		SET @errorMsg = 'Petro Recipe Table does not exists!';
		RAISERROR(@errorMsg, 16, 1);
	END

	--==========================================================
	--     Insert into tblARInvoiceDetail - PT INVOICE DETAILS
	--==========================================================
	IF EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptivcmst')
	BEGIN
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
					   ,(SELECT intConsumptionMethodId FROM tblMFConsumptionMethod WHERE strName = ''None'')
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
			INNER JOIN ptitmmst OITM ON OITM.ptitm_itm_no = FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+'
			INNER JOIN tblICItem ITM ON ITM.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_itm_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItem ITM1 ON ITM1.strItemNo COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblSMCompanyLocation LOC ON LOC.strLocationNumber COLLATE SQL_Latin1_General_CP1_CS_AS = FRMI.ptfrm_loc_no  COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblMFRecipe RCP ON RCP.intItemId = ITM.intItemId AND RCP.intLocationId = LOC.intCompanyLocationId
			INNER JOIN tblICUnitMeasure UM ON Upper(UM.strSymbol) COLLATE SQL_Latin1_General_CP1_CS_AS = Upper(OITM.ptitm_unit) COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblICItemUOM UOM ON UOM.intItemId = ITM.intItemId AND UOM.intUnitMeasureId = UM.intUnitMeasureId  
			WHERE FRMI.ptfrm_ingr_itm_no_'+CAST(@cnt AS NVARCHAR)+' IS NOT NULL AND NOT EXISTS (SELECT * FROM tblMFRecipeItem WHERE intRecipeId = RCP.intRecipeId  AND intItemId = ITM1.intItemId )' 
			
			EXEC (@SQLCMD);

			SET @cnt = @cnt + 1;
		END
	END
	ELSE
	BEGIN
		SET @errorMsg = 'Petro Recipe Detail Table does not exists!';
		RAISERROR(@errorMsg, 16, 1);
		GOTO Post_Rollback;
	END
	

Post_Commit:
	COMMIT TRAN @TransactionName;
	GOTO Post_Exit;

Post_Rollback:
	IF(@@TRANCOUNT > 0)
		ROLLBACK TRAN @TransactionName;	

	GOTO Post_Exit;

Post_Exit:

GO

