/* Calculate Expiry Date by
 *   > Manufatured date or
 *   > Receipt Date if no Manufactured date is missing   
 */
CREATE FUNCTION fnICCalculateExpiryDate(@intItemId INT, @dtmManufacturedDate DATETIME, @dtmTransactionDate DATETIME)
RETURNS DATETIME
AS
BEGIN

	DECLARE @strLifeTimeType NVARCHAR(20)
	DECLARE @intLifeTime INT
	DECLARE @strItemType NVARCHAR(20)
	DECLARE @dtmExpiryDate DATETIME

	SELECT 
		@strItemType = i.strType
		,@intLifeTime = i.intLifeTime
		,@strLifeTimeType = i.strLifeTimeType
	FROM tblICItem i
	WHERE i.intItemId = @intItemId

	IF @strLifeTimeType = 'Minutes'
		SET @dtmExpiryDate = DATEADD(MINUTE, @intLifeTime, ISNULL(@dtmManufacturedDate, @dtmTransactionDate))
	ELSE IF @strLifeTimeType = 'Hours'
		SET @dtmExpiryDate = DATEADD(HOUR, @intLifeTime, ISNULL(@dtmManufacturedDate, @dtmTransactionDate))
	ELSE IF @strLifeTimeType = 'Days'
		SET @dtmExpiryDate = DATEADD(DAY, @intLifeTime, ISNULL(@dtmManufacturedDate, @dtmTransactionDate))
	ELSE IF @strLifeTimeType = 'Months'
		SET @dtmExpiryDate = DATEADD(MONTH, @intLifeTime, ISNULL(@dtmManufacturedDate, @dtmTransactionDate))
	ELSE IF @strLifeTimeType = 'Years'
		SET @dtmExpiryDate = DATEADD(YEAR, @intLifeTime, ISNULL(@dtmManufacturedDate, @dtmTransactionDate))

	RETURN @dtmExpiryDate

END