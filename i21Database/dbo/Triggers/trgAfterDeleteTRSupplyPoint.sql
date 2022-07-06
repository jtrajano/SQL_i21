CREATE TRIGGER [dbo].[trgAfterDeleteTRSupplyPoint] 
	ON [dbo].[tblTRSupplyPoint]
	FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS (SELECT TOP 1 1 FROM tblTRSupplyPoint WHERE intRackPriceSupplyPointId IN (SELECT intSupplyPointId FROM deleted))
	BEGIN
		UPDATE tblTRSupplyPoint SET intRackPriceSupplyPointId = NULL WHERE intRackPriceSupplyPointId IN (SELECT intSupplyPointId FROM deleted) 
	END
END