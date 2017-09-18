
IF EXISTS (select top 1 1 from sys.procedures where name = 'uspTRImportTruck')
	DROP PROCEDURE uspTRImportTruck
GO

CREATE PROCEDURE uspTRImportTruck
	@Checking BIT = 0,
	@Total INT = 0 OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--==========================================================
	--     Insert into [tblSCTruckDriverReference] - TR Truck 
	--==========================================================
	IF(@Checking = 0)
	BEGIN
		INSERT INTO [dbo].[tblSCTruckDriverReference]
				   ([strData]
				   ,[intEntityId]
				   ,[strRecordType]
				   ,[intConcurrencyId])
		SELECT distinct trhst_tractor_trailor,
				(select top 1 shp.intEntityId from tblSMShipVia shp where 
				 strShipViaOriginKey COLLATE SQL_Latin1_General_CP1_CS_AS 
				 =HST.trhst_pur_carrier COLLATE SQL_Latin1_General_CP1_CS_AS)
			   ,'T'
			   ,1 
		FROM trhstmst HST
		LEFT JOIN [tblSCTruckDriverReference] SCT 
		ON SCT.strData COLLATE SQL_Latin1_General_CP1_CS_AS = HST.trhst_tractor_trailor COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE trhst_tractor_trailor IS NOT NULL AND SCT.strData IS NULL
	END

	IF(@Checking = 1)
	BEGIN
		SELECT @Total = COUNT(DISTINCT trhst_tractor_trailor)			  
		FROM trhstmst HST
		LEFT JOIN [tblSCTruckDriverReference] SCT 
		ON SCT.strData COLLATE SQL_Latin1_General_CP1_CS_AS = HST.trhst_tractor_trailor COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE trhst_tractor_trailor IS NOT NULL AND SCT.strData IS NULL
	END
	
END
GO
