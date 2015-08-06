CREATE PROCEDURE [dbo].[uspMFAutoBlendSheet]
    @intLocationId INT,                            
    @intBlendRequirementId INT,    
    @dblQtyToProduce NUMERIC(18,6),                                  
    @strXml NVARCHAR(MAX)=NULL  
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

IF(SELECT ISNULL(COUNT(1),0) FROM tblMFBlendRequirementRule WHERE intBlendRequirementId=@intBlendRequirementId) = 0  
	RAISERROR('Unable to create auto blend sheet as business rules are not added to the blend requirement.',16,1)

IF EXISTS(SELECT * FROM tblMFBlendRequirementRule a JOIN tblMFBlendSheetRule b ON a.intBlendSheetRuleId=b.intBlendSheetRuleId
WHERE b.strName='Is Quality Data Applicable?' AND a.strValue='No' and a.intBlendRequirementId=@intBlendRequirementId)
BEGIN
	EXEC [uspMFAutoBlendSheetFIFO] 
			@intLocationId=@intLocationId,
			@intBlendRequirementId=@intBlendRequirementId,
			@dblQtyToProduce=@dblQtyToProduce,
			@strXml=@strXml
END
