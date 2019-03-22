CREATE PROCEDURE [dbo].[uspFRDCreateRowCalculation]

	@intRowDetailId INT,
	@intRowDetailRefNo INT,
	@intRowId INT,
	@intRefNoId INT,
	@intRefNoCalc INT,
	@strAction NVARCHAR(100),
	@intSort INT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

	INSERT INTO tblFRRowDesignCalculation (intRowDetailId,
											intRowDetailRefNo,
											intRowId,
											intRefNoId,
											intRefNoCalc,
											strAction,
											intSort)

								SELECT	   @intRowDetailId,
											@intRowDetailRefNo,
											@intRowId,
											@intRefNoId,
											@intRefNoCalc,
											@strAction,
											@intSort

END
