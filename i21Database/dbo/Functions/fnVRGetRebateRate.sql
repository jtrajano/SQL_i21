CREATE FUNCTION [dbo].[fnVRGetRebateRate]
(
	@intVendorID				INT
	,@intCustomerId				INT
	,@intItemId					INT	
	,@dtmDate					DATETIME
)
RETURNS @returntable TABLE
(
	 dblRate				NUMERIC(18,6)
	,intProgramId			INT
	,strRebateBy			NVARCHAR(15)
)
AS
BEGIN
	DECLARE @intCategoryId INT
	DECLARE @intVendorSetupId INT
	DECLARE @intProgramId INT
	DECLARE @dblRebateRate NUMERIC(18,6)
	DECLARE @strRebateBy NVARCHAR(15)


	SELECT TOP 1
		@intVendorSetupId = intVendorSetupId
	FROM tblVRVendorSetup
	WHERE intEntityId = @intVendorID

	--Check for Vendor
	IF(@intVendorSetupId IS NOT NULL)
	BEGIN

		--CEHCK for Customer
		IF EXISTS(SELECT TOP 1 1 FROM tblVRCustomerXref WHERE intEntityId = @intCustomerId AND intVendorSetupId = @intVendorSetupId)
		BEGIN
			SELECT TOP 1
				@intProgramId = intProgramId
			FROM tblVRProgram
			WHERE intVendorSetupId = @intVendorSetupId

			--Check for Program
			IF(@intProgramId IS NOT NULL)
			BEGIN 
				-- SEarch for the item Id program
				SELECT TOP 1 
					@dblRebateRate = dblRebateRate
				FROM tblVRProgramItem 
				WHERE intProgramId = @intProgramId 
					AND intItemId = @intItemId
					AND dtmBeginDate <= @dtmDate
					AND dtmEndDate >= @dtmDate

				IF @dblRebateRate IS NOT NULL
				BEGIN
					INSERT INTO @returntable
					(
						 dblRate		
						,intProgramId	
						,strRebateBy	
					)
					SELECT  dblRate		= @dblRebateRate
						,intProgramId	= @intProgramId	
						,strRebateBy	= @strRebateBy
						
				END
				ELSE
				BEGIN
					
					--Search for the Category of the Item
					SELECT TOP 1 
						@intCategoryId = intCategoryId
					FROM tblICItem
					WHERE intItemId = @intItemId

					--SEarch for the CAtegory in the program
					SELECT TOP 1 
						@dblRebateRate = dblRebateRate
					FROM tblVRProgramItem 
					WHERE intProgramId = @intProgramId 
						AND intCategoryId = @intCategoryId
						AND dtmBeginDate <= @dtmDate
						AND dtmEndDate >= @dtmDate

					IF @dblRebateRate IS NOT NULL
					BEGIN
						INSERT INTO @returntable
						(
							 dblRate		
							,intProgramId	
							,strRebateBy	
						)
						SELECT  dblRate		= @dblRebateRate
							,intProgramId	= @intProgramId	
							,strRebateBy	= @strRebateBy
					END
				END
			END
		END
	END

	RETURN
END