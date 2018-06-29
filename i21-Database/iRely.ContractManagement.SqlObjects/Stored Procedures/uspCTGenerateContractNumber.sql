CREATE PROCEDURE [dbo].[uspCTGenerateContractNumber]
	
	 @intPatternCode	INT
	,@intEntityId		INT = NULL
	,@strPatternString	NVARCHAR(50) OUTPUT

AS

BEGIN TRY
	
	DECLARE @ErrMsg				NVARCHAR(MAX),
			@intContractTypeId	INT,
			@ysnExist			BIT	=	1

	IF	@intPatternCode = 25 SET @intContractTypeId = 1 ELSE SET @intContractTypeId = 2

	WHILE	@ysnExist	=	1
	BEGIN
		EXEC	uspMFGeneratePatternId 
				 @intCategoryId			=	NULL
				,@intItemId				=	NULL
				,@intManufacturingId	=	NULL
				,@intSubLocationId		=	NULL
				,@intLocationId			=	NULL
				,@intOrderTypeId		=	NULL
				,@intBlendRequirementId	=	NULL
				,@intPatternCode		=	@intPatternCode
				,@ysnProposed			=	0
				,@strPatternString 		=	@strPatternString out
				,@intEntityId			=	@intEntityId

		IF NOT EXISTS(SELECT * FROM tblCTContractHeader WHERE strContractNumber = @strPatternString AND intContractTypeId = @intContractTypeId)
			SET	@ysnExist = 0
	END
		
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
