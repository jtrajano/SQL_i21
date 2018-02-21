IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGRImportShipTo')
	DROP PROCEDURE uspGRImportShipTo
GO
CREATE PROCEDURE uspGRImportShipTo
	@Checking BIT = 0,
	@UserId INT = 0,
	@Total INT = 0 OUTPUT
	AS
BEGIN
	--================================================
	--     IMPORT GRAIN Ship To Locations
	--================================================

	IF (@Checking = 1)
	BEGIN
			 SELECT @Total = COUNT(*)  FROM galshmst  
						 INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = galsh_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
						 INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
						 WHERE ETYP.strType = 'Customer'
						 AND NOT EXISTS ( SELECT * FROM tblEMEntityLocation WHERE intEntityId = ENT.intEntityId 
						 AND strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = (RTRIM (galsh_ship_to))+'_'+(RTRIM (galsh_name)) COLLATE SQL_Latin1_General_CP1_CS_AS) 
						 
			 RETURN @Total
	END

			INSERT [dbo].[tblEMEntityLocation]    
					([intEntityId], 
					 [strLocationName], 
					 [strAddress], 
					 [strCity], 
					 [strCountry], 
					 [strState], 
					 [strZipCode], 
					 [strNotes],  
					 [intShipViaId], 
					 --[intTermsId], 
					 [intWarehouseId], 
					 [ysnDefaultLocation])
			SELECT 			
					ENT.intEntityId, 
					(RTRIM (galsh_ship_to))+'_'+(RTRIM (galsh_name)),
					ISNULL(galsh_addr,'''') + CHAR(10) + ISNULL(galsh_addr2,''''),
					LTRIM(RTRIM(galsh_city)),
					ENT.intDefaultCountryId,
					LTRIM(RTRIM(galsh_state)),
					LTRIM(RTRIM(galsh_zip)),
					NULL,
					NULL,
					--(SELECT intTermID FROM tblSMTerm WHERE strTermCode = CAST(galsh_terms_cd AS CHAR(10))),
					NULL,
					0
			FROM galshmst  
			INNER JOIN tblEMEntity ENT ON ENT.strEntityNo COLLATE SQL_Latin1_General_CP1_CS_AS = galsh_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
			INNER JOIN tblEMEntityType ETYP ON ETYP.intEntityId = ENT.intEntityId
			WHERE ETYP.strType = 'Customer'
			AND NOT EXISTS ( SELECT * FROM tblEMEntityLocation WHERE intEntityId = ENT.intEntityId 
			AND strLocationName COLLATE SQL_Latin1_General_CP1_CS_AS = (RTRIM (galsh_ship_to))+'_'+(RTRIM (galsh_name)) COLLATE SQL_Latin1_General_CP1_CS_AS) 
			
		
END	

GO



