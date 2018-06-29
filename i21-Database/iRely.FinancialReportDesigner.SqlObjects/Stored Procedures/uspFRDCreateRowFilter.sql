CREATE PROCEDURE [dbo].[uspFRDCreateRowFilter]

	@intRowDetailId INT,
	@intRowId INT,
	@intRefNoId INT,
	@strName NVARCHAR(100),
	@strCondition NVARCHAR(300),
	@strCriteria NVARCHAR(300),
	@strCriteriaBetween NVARCHAR(300),
	@strJoin NVARCHAR(30)
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

	INSERT INTO tblFRRowDesignFilterAccount(intRowDetailId,
											intRowId,
											intRefNoId,
											strName,
											strCondition,
											strCriteria,
											strCriteriaBetween,
											strJoin)

								SELECT	   @intRowDetailId,
											@intRowId,
											@intRefNoId,
											@strName,
											@strCondition,
											@strCriteria,
											@strCriteriaBetween,
											@strJoin

END
