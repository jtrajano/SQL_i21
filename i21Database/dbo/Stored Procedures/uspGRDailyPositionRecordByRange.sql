CREATE PROCEDURE [dbo].[uspGRDailyPositionRecordByRange]
				 	
	-- Add the parameters for the stored procedure here
		@xmlParam NVARCHAR(MAX)
AS
BEGIN
    select @xmlParam xmlParam
END
GO