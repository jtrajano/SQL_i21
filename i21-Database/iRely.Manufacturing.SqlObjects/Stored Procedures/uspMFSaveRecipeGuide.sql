CREATE PROCEDURE [dbo].[uspMFSaveRecipeGuide]
	@strXml nvarchar(max),
	@intRecipeGuideId int out
AS

BEGIN TRY

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(Max)
	Declare @strName nvarchar(50)

	Set @intRecipeGuideId=0

	EXEC sp_xml_preparedocument @idoc OUTPUT
		,@strXml

	DECLARE @tblRecipeGuide TABLE (
		intRecipeGuideId int
		,strName nvarchar(250) COLLATE Latin1_General_CI_AS
		,intSalesOrderId int
		,intCustomerId int
		,intFarmId int
		,intFieldId int
		,intCommodityId int
		,intUOMId int
		,dtmExpiryDate DateTime
		,dtmApplicableDate DateTime
		,intCostTypeId int
		,dblNoOfAcre numeric(18,6)
		,strGuaranteedAnalysis nvarchar(max) COLLATE Latin1_General_CI_AS
		,strComment nvarchar(max) COLLATE Latin1_General_CI_AS
		,intUserId int
		,intMethodOfAppId int
		,intManufacturingCellId int
		,dblBatchSize numeric(18,6)
		,intNoOfBatches int
		,ysnAllowOverMixerSize bit
		)
	DECLARE @tblItemNutrient TABLE (
		intRecipeGuideNutrientId INT
		,intRecipeGuideId INT
		,intPropertyId INT
		,dblProposed NUMERIC(38,20)
		,dblActual NUMERIC(38,20)
		,dblPercentage NUMERIC(38,20)
		)

	INSERT INTO @tblRecipeGuide (
		intRecipeGuideId
		,strName
		,intSalesOrderId
		,intCustomerId
		,intFarmId
		,intFieldId
		,intCommodityId
		,intUOMId
		,dtmExpiryDate
		,dtmApplicableDate
		,intCostTypeId
		,dblNoOfAcre
		,strGuaranteedAnalysis
		,strComment
		,intUserId
		,intMethodOfAppId
		,intManufacturingCellId
		,dblBatchSize
		,intNoOfBatches
		,ysnAllowOverMixerSize
		)
	SELECT intRecipeGuideId
		,strName
		,intSalesOrderId
		,intCustomerId
		,intFarmId
		,intFieldId
		,intCommodityId
		,intUOMId
		,dtmExpiryDate
		,dtmApplicableDate
		,intCostTypeId
		,dblNoOfAcre
		,strGuaranteedAnalysis
		,strComment
		,intUserId
		,intMethodOfAppId
		,intManufacturingCellId
		,dblBatchSize
		,intNoOfBatches
		,ysnAllowOverMixerSize
	FROM OPENXML(@idoc, 'root', 2) WITH (
		intRecipeGuideId int
		,strName nvarchar(250)
		,intSalesOrderId int
		,intCustomerId int
		,intFarmId int
		,intFieldId int
		,intCommodityId int
		,intUOMId int
		,dtmExpiryDate DateTime
		,dtmApplicableDate DateTime
		,intCostTypeId int
		,dblNoOfAcre numeric(18,6)
		,strGuaranteedAnalysis nvarchar(max)
		,strComment nvarchar(max)
		,intUserId int
		,intMethodOfAppId int
		,intManufacturingCellId int
		,dblBatchSize numeric(18,6)
		,intNoOfBatches int
		,ysnAllowOverMixerSize bit
			)

	INSERT INTO @tblItemNutrient (
		intRecipeGuideNutrientId
		,intRecipeGuideId
		,intPropertyId
		,dblProposed
		,dblActual
		,dblPercentage
		)
	SELECT intRecipeGuideNutrientId
		,intRecipeGuideId
		,intPropertyId
		,dblProposed
		,dblActual
		,dblPercentage
	FROM OPENXML(@idoc, 'root/nutrient', 2) WITH (
		intRecipeGuideNutrientId INT
		,intRecipeGuideId INT
		,intPropertyId INT
		,dblProposed NUMERIC(38,20)
		,dblActual NUMERIC(38,20)
		,dblPercentage NUMERIC(38,20)
			)

	Select @strName=strName From @tblRecipeGuide

	Begin Tran

	If Not Exists (Select 1 From tblMFRecipeGuide Where strName=@strName)
	Begin
		Insert Into tblMFRecipeGuide(strName,intSalesOrderId,intCustomerId,intFarmId,intFieldId,intCommodityId,
					intUOMId,dtmExpiryDate,dtmApplicableDate,intCostTypeId,dblNoOfAcre,strGuaranteedAnalysis,strComment,
					intCreatedUserId,dtmCreated,intLastModifiedUserId,dtmLastModified,intMethodOfAppId,intManufacturingCellId,dblBatchSize,intNoOfBatches,ysnAllowOverMixerSize)
		Select strName,intSalesOrderId,intCustomerId,intFarmId,intFieldId,intCommodityId,
					intUOMId,dtmExpiryDate,dtmApplicableDate,intCostTypeId,dblNoOfAcre,strGuaranteedAnalysis,strComment,
					intUserId,GETDATE(),intUserId,GETDATE(),intMethodOfAppId,intManufacturingCellId,dblBatchSize,intNoOfBatches,ysnAllowOverMixerSize
		From @tblRecipeGuide

		Select @intRecipeGuideId=SCOPE_IDENTITY()

		Insert Into tblMFRecipeGuideNutrient(intRecipeGuideId,intPropertyId,dblProposed,dblActual,dblPercentage)
		Select @intRecipeGuideId,intPropertyId,dblProposed,dblActual,dblPercentage
		From @tblItemNutrient
	End
	Else
	Begin
		Select @intRecipeGuideId=intRecipeGuideId From tblMFRecipeGuide Where strName=@strName

		Update rg Set rg.intSalesOrderId=trg.intSalesOrderId,rg.intCustomerId=trg.intCustomerId,rg.intFarmId=trg.intFarmId,rg.intFieldId=trg.intFieldId,rg.intCommodityId=trg.intCommodityId,
					rg.intUOMId=trg.intUOMId,rg.dtmExpiryDate=trg.dtmExpiryDate,rg.dtmApplicableDate=trg.dtmApplicableDate,rg.intCostTypeId=trg.intCostTypeId,
					rg.dblNoOfAcre=trg.dblNoOfAcre,rg.strGuaranteedAnalysis=trg.strGuaranteedAnalysis,rg.strComment=trg.strComment,rg.intMethodOfAppId=trg.intMethodOfAppId,
					rg.intManufacturingCellId=trg.intManufacturingCellId,rg.dblBatchSize=trg.dblBatchSize,rg.intNoOfBatches=trg.intNoOfBatches,rg.ysnAllowOverMixerSize=trg.ysnAllowOverMixerSize
		From tblMFRecipeGuide rg Join @tblRecipeGuide trg on rg.strName=trg.strName

		Update n Set n.dblProposed=tn.dblProposed,n.dblActual=tn.dblActual,n.dblPercentage=tn.dblPercentage
		From tblMFRecipeGuideNutrient n Join @tblItemNutrient tn on n.intPropertyId=tn.intPropertyId
		Where n.intRecipeGuideId=@intRecipeGuideId
	End

COMMIT TRAN

END TRY
BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH