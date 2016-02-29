CREATE PROCEDURE [dbo].[uspSTCheckoutItemMovementReport]
	@BeginDate Datetime,
	@EndDate Datetime
AS
BEGIN

	SELECT CIM.intItemUPCId, UOM.strUpcCode, UOM.strLongUPCCode
	, SUM(CIM.intQtySold) [intQtySold]
	, SUM(CIM.dblCurrentPrice) [dblCurrentPrice]
	, (SUM(CIM.dblCurrentPrice) * SUM(CIM.intQtySold)) [dblTotalSales]
	FROM dbo.tblSTCheckoutItemMovements CIM
	JOIN dbo.tblSTCheckoutHeader CH ON CH.intCheckoutId = CIM.intCheckoutId
	JOIN dbo.tblICItemUOM UOM ON UOM.intItemUOMId = CIM.intItemUPCId
	Where CH.dtmCheckoutDate BETWEEN @BeginDate AND @EndDate
	GROUP BY CIM.intItemUPCId, UOM.strUpcCode, UOM.strLongUPCCode

END
