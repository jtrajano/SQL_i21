CREATE PROCEDURE [dbo].[uspARImportTaxGroupCustomerLocation]
@Checking BIT = 0,
@Total INT  = 0 Output
AS
BEGIN
	DECLARE @ysnPtcusmst INT = 0;
	SELECT TOP 1 @ysnPtcusmst = 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptcusmst';
	
	IF(@ysnPtcusmst = 1)
	BEGIN

		SELECT @Total = Count(1)
		FROM ptcusmst PT
		INNER JOIN tblEMEntity EN
			ON PT.ptcus_cus_no COLLATE Latin1_General_CI_AS  = EN.strEntityNo COLLATE Latin1_General_CI_AS
		INNER JOIN tblEMEntityLocation LOC
			ON EN.intEntityId = LOC.intEntityId
		LEFT JOIN tblSMTaxGroup TG
			ON (ISNULL(PT.ptcus_state,'') + ' ' + isnull(PT.ptcus_local1,'') + ' ' + ISNULL(PT.ptcus_local2,'')) COLLATE Latin1_General_CI_AS = TG.strTaxGroup
		WHERE LOC.intTaxGroupId IS NULL AND TG.intTaxGroupId IS NULL

		IF(@Checking = 1)
		BEGIN
			UPDATE LOC
				SET LOC.intTaxGroupId = TG.intTaxGroupId 
			FROM ptcusmst PT
			INNER JOIN tblEMEntity EN
				ON PT.ptcus_cus_no COLLATE Latin1_General_CI_AS  = EN.strEntityNo COLLATE Latin1_General_CI_AS
			INNER JOIN tblEMEntityLocation LOC
				ON EN.intEntityId = LOC.intEntityId
			INNER JOIN tblSMTaxGroup TG
				ON (ISNULL(PT.ptcus_state,'') + ' ' + isnull(PT.ptcus_local1,'') + ' ' + ISNULL(PT.ptcus_local2,'')) COLLATE Latin1_General_CI_AS = TG.strTaxGroup
		END
	END				
				
END