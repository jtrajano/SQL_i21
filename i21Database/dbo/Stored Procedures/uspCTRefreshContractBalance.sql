CREATE PROCEDURE [dbo].[uspCTRefreshContractBalance]
	@dtmEndDate DATETIME
AS
BEGIN
	DELETE FROM tblCTContractBalance
	WHERE dtmEndDate = @dtmEndDate
END