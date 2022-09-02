GO
PRINT 'BEGIN Pre-deployment TR Data Clean-up'
GO


PRINT('Update TR Cross Reference BOL TruckId')
GO

IF EXISTS(SELECT * FROM  INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblTRCrossReferenceBol') 
BEGIN
	UPDATE 
		tblTRCrossReferenceBol
	SET 
		intTruckId = NULL
	WHERE
		strType = 'Truck' AND
		intTruckId NOT IN
			(SELECT intEntityShipViaTruckId FROM tblSMShipViaTruck)
END
GO