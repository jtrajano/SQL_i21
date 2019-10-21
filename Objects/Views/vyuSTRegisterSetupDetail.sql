CREATE VIEW [dbo].[vyuSTRegisterSetupDetail]
	AS
SELECT 
	rsd.intRegisterSetupDetailId, 
    rsd.intRegisterSetupId, 
	rsd.intImportFileHeaderId,
    rsd.strImportFileHeaderName,
    rsd.strFileType,
    rsd.strFilePrefix, 
	rsd.strFileNamePattern, 
    rsd.strURICommand, 
	rsd.strStoredProcedure,
	rsd.intConcurrencyId,
	rs.strRegisterClass,
	rs.strXmlVersion
FROM tblSTRegisterSetupDetail rsd
INNER JOIN tblSTRegisterSetup rs
	ON rsd.intRegisterSetupId = rs.intRegisterSetupId
