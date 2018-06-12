GO

IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARImportCustomerComments')
	DROP PROCEDURE uspARImportCustomerComments
GO


CREATE PROCEDURE [dbo].[uspARImportCustomerComments]
			@Checking BIT = 0,
			@Total INT = 0 OUTPUT

AS
BEGIN
	SET NOCOUNT ON;
	SET ANSI_WARNINGS ON;

	DECLARE @ysnAG BIT = 0
	DECLARE @ysnPT BIT = 0

	SELECT TOP 1 @ysnAG = CASE WHEN ISNULL(coctl_ag, '') = 'Y' THEN 1 ELSE 0 END
			   , @ysnPT = CASE WHEN ISNULL(coctl_pt, '') = 'Y' THEN 1 ELSE 0 END 
	FROM coctlmst	
	
	declare @maxId INT = 1

	select @maxId = MAX(intMessageId) from tblEMEntityMessage

	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agcmtmst')
	AND (@Checking = 0) 
	BEGIN
		INSERT INTO [dbo].[tblEMEntityMessage]
				   ([intEntityId]
				   ,[strMessageType]
				   ,[strAction]
				   ,[strMessage])
		SELECT CUS.intEntityId--intEntityId
			   ,CASE WHEN CMT.agcmt_com_typ = 'REG' THEN 'Regular (customer inquiry)' 
					 WHEN CMT.agcmt_com_typ = 'IVC' THEN 'Invoice'
					 WHEN CMT.agcmt_com_typ = 'PIC' THEN 'Pick Ticket'
					 WHEN CMT.agcmt_com_typ = 'TIC' THEN 'Ticket Entry'
					 WHEN CMT.agcmt_com_typ = 'STM' THEN 'Statement'
					 WHEN CMT.agcmt_com_typ = 'ETC' THEN 'Energy Trac'
					 WHEN CMT.agcmt_com_typ = 'EML' THEN 'Email'
					 WHEN CMT.agcmt_com_typ = 'GSC' THEN 'Settlements'
					 WHEN CMT.agcmt_com_typ = 'LDS' THEN 'Load Scheduling'
					 WHEN CMT.agcmt_com_typ = 'LDD' THEN 'Load Directions'
					 WHEN CMT.agcmt_com_typ = 'GST' THEN 'Scale Ticket'
					 WHEN CMT.agcmt_com_typ = 'PMT' THEN 'Payments'
					 WHEN CMT.agcmt_com_typ = 'CRD' THEN 'Credit'
					 WHEN CMT.agcmt_com_typ = 'Fax' THEN 'Faxing'
					 ELSE agcmt_com_typ END --strMessageType
			   ,CASE WHEN CMT.agcmt_com_typ = 'REG' THEN 'Message here will pop up on the customer inquiry screen'
					 WHEN CMT.agcmt_com_typ = 'IVC' THEN 'Message listed here will print on the invoice'
					 WHEN CMT.agcmt_com_typ = 'PIC' THEN 'Message listed here will print on the pick ticket'
					 WHEN CMT.agcmt_com_typ = 'TIC' THEN ' '
					 WHEN CMT.agcmt_com_typ = 'STM' THEN 'Message listed here will print on the statement.'
					 WHEN CMT.agcmt_com_typ = 'ETC' THEN 'Message entered here may be accessed in the Notes section of the Customer Search program in the Energy Trac system.'
					 WHEN CMT.agcmt_com_typ = 'EML' THEN 'Message entered here will be incorporated into the email. This feature will only be available if VSIFAX has been interfaced.'
					 WHEN CMT.agcmt_com_typ = 'GSC' THEN 'Message entered here will be displayed in the Adjust Settlements program and in the Write Settlements program.'
					 WHEN CMT.agcmt_com_typ = 'LDS' THEN 'Message entered here will be displayed in the Load schedule Maintenance program accessed from the Load Scheduling Menu.'
					 WHEN CMT.agcmt_com_typ = 'LDD' THEN 'Message entered here will be displayed on the Carrier Shipment Order report accessed from the Grain Load Scheduling Menu.'
					 WHEN CMT.agcmt_com_typ = 'GST' THEN 'Message entered here will be displayed when entering incoming, outbound or direct shipped tickets in the Enter Incoming Commodity program as well as the Scale Ticket Entry/Print program'
					 WHEN CMT.agcmt_com_typ = 'PMT' THEN 'Message entered here will be displayed in the Enter Payments program.'
					 WHEN CMT.agcmt_com_typ = 'CRD' THEN 'Message entered here may be accessed from the Customer Inquiry screen.'
					 WHEN CMT.agcmt_com_typ = 'FAX' THEN 'Message entered here will be incorporated into the fax. This feature will only be available if VSIFAX has been interfaced.'
					 ELSE '' END --strAction
			   ,ISNULL((SELECT ' '+ LTRIM(RTRIM(x.agcmt_data))
						FROM agcmtmst x
					   WHERE CMT.agcmt_cus_no = x.agcmt_cus_no AND CMT.agcmt_com_typ = x.agcmt_com_typ
					GROUP BY x.agcmt_data,x.agcmt_com_cd,x.agcmt_com_seq ORDER BY x.agcmt_com_cd,x.agcmt_com_seq
					 FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), '') 
		 FROM agcmtmst CMT
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CMT.agcmt_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblEMEntityMessage EM ON EM.intEntityId = CUS.intEntityId AND EM.strMessageType COLLATE SQL_Latin1_General_CP1_CS_AS = 
						(CASE WHEN CMT.agcmt_com_typ = 'REG' THEN 'Regular (customer inquiry)'  WHEN CMT.agcmt_com_typ = 'IVC' THEN 'Invoice'
						 WHEN CMT.agcmt_com_typ = 'PIC' THEN 'Pick Ticket' WHEN CMT.agcmt_com_typ = 'TIC' THEN 'Ticket Entry'
						 WHEN CMT.agcmt_com_typ = 'STM' THEN 'Statement' WHEN CMT.agcmt_com_typ = 'ETC' THEN 'Energy Trac'
						 WHEN CMT.agcmt_com_typ = 'EML' THEN 'Email' WHEN CMT.agcmt_com_typ = 'GSC' THEN 'Settlements'
						 WHEN CMT.agcmt_com_typ = 'LDS' THEN 'Load Scheduling' WHEN CMT.agcmt_com_typ = 'LDD' THEN 'Load Directions'
						 WHEN CMT.agcmt_com_typ = 'GST' THEN 'Scale Ticket' WHEN CMT.agcmt_com_typ = 'PMT' THEN 'Payments'
						 WHEN CMT.agcmt_com_typ = 'CRD' THEN 'Credit' WHEN CMT.agcmt_com_typ = 'Fax' THEN 'Faxing'
						 ELSE agcmt_com_typ END) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EM.intMessageId IS NULL
		GROUP BY CMT.agcmt_cus_no, CMT.agcmt_com_typ, CUS.intEntityId

	END

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptcmtmst')
	AND (@Checking = 0) 
	
	BEGIN
		INSERT INTO [dbo].[tblEMEntityMessage]
				   ([intEntityId]
				   ,[strMessageType]
				   ,[strAction]
				   ,[strMessage])
		SELECT CUS.intEntityId--intEntityId
			   ,CASE WHEN CMT.ptcmt_type = 'REG' THEN 'Regular (customer inquiry)' 
					 WHEN CMT.ptcmt_type = 'IVC' THEN 'Invoice'
					 WHEN CMT.ptcmt_type = 'PIC' THEN 'Pick Ticket'
					 WHEN CMT.ptcmt_type = 'TIC' THEN 'Ticket Entry'
					 WHEN CMT.ptcmt_type = 'STM' THEN 'Statement'
					 WHEN CMT.ptcmt_type = 'ETC' THEN 'Energy Trac'
					 ELSE ptcmt_type END --strMessageType
			   ,CASE WHEN CMT.ptcmt_type = 'REG' THEN 'Message here will pop up on the customer inquiry screen'
					 WHEN CMT.ptcmt_type = 'IVC' THEN 'Message listed here will print on the invoice'
					 WHEN CMT.ptcmt_type = 'PIC' THEN 'Message listed here will print on the pick ticket'
					 WHEN CMT.ptcmt_type = 'TIC' THEN ' '
					 WHEN CMT.ptcmt_type = 'STM' THEN 'Message listed here will print on the statement.'
					 WHEN CMT.ptcmt_type = 'ETC' THEN 'Message entered here may be accessed in the Notes section of the Customer Search program in the Energy Trac system.'
					 ELSE '' END --strAction
			   ,ISNULL((SELECT ' '+ LTRIM(RTRIM(x.ptcmt_comment))
						FROM ptcmtmst x
					   WHERE CMT.ptcmt_cus_no = x.ptcmt_cus_no AND CMT.ptcmt_type = x.ptcmt_type
					GROUP BY x.ptcmt_comment,x.ptcmt_seq_no ORDER BY x.ptcmt_seq_no
					 FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), '') 
		 FROM ptcmtmst CMT
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CMT.ptcmt_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblEMEntityMessage EM ON EM.intEntityId = CUS.intEntityId AND EM.strMessageType COLLATE SQL_Latin1_General_CP1_CS_AS = 
						(CASE WHEN CMT.ptcmt_type = 'REG' THEN 'Regular (customer inquiry)'  WHEN CMT.ptcmt_type = 'IVC' THEN 'Invoice'
						 WHEN CMT.ptcmt_type = 'PIC' THEN 'Pick Ticket' WHEN CMT.ptcmt_type = 'TIC' THEN 'Ticket Entry'
						 WHEN CMT.ptcmt_type = 'STM' THEN 'Statement' WHEN CMT.ptcmt_type = 'ETC' THEN 'Energy Trac'
						 ELSE ptcmt_type END) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EM.intMessageId IS NULL
		GROUP BY CMT.ptcmt_cus_no, CMT.ptcmt_type, CUS.intEntityId
	END
	
	IF @ysnAG = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'agcmtmst')
	AND (@Checking = 1) 
	BEGIN
		SELECT  @Total = COUNT(*) FROM agcmtmst CMT
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CMT.agcmt_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblEMEntityMessage EM ON EM.intEntityId = CUS.intEntityId AND EM.strMessageType COLLATE SQL_Latin1_General_CP1_CS_AS = 
						(CASE WHEN CMT.agcmt_com_typ = 'REG' THEN 'Regular (customer inquiry)'  WHEN CMT.agcmt_com_typ = 'IVC' THEN 'Invoice'
						 WHEN CMT.agcmt_com_typ = 'PIC' THEN 'Pick Ticket' WHEN CMT.agcmt_com_typ = 'TIC' THEN 'Ticket Entry'
						 WHEN CMT.agcmt_com_typ = 'STM' THEN 'Statement' WHEN CMT.agcmt_com_typ = 'ETC' THEN 'Energy Trac'
						 ELSE agcmt_com_typ END) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EM.intMessageId IS NULL
		--GROUP BY CMT.agcmt_cus_no, CMT.agcmt_com_typ, CUS.intEntityId
	END
	

	IF @ysnPT = 1 AND EXISTS(SELECT TOP 1 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'ptcmtmst')
	AND (@Checking = 1) 
	BEGIN			
		SELECT @Total = COUNT(*) FROM ptcmtmst CMT
		INNER JOIN tblARCustomer CUS ON CUS.strCustomerNumber COLLATE SQL_Latin1_General_CP1_CS_AS = CMT.ptcmt_cus_no COLLATE SQL_Latin1_General_CP1_CS_AS
		LEFT JOIN tblEMEntityMessage EM ON EM.intEntityId = CUS.intEntityId AND EM.strMessageType COLLATE SQL_Latin1_General_CP1_CS_AS = 
						(CASE WHEN CMT.ptcmt_type = 'REG' THEN 'Regular (customer inquiry)'  WHEN CMT.ptcmt_type = 'IVC' THEN 'Invoice'
						 WHEN CMT.ptcmt_type = 'PIC' THEN 'Pick Ticket' WHEN CMT.ptcmt_type = 'TIC' THEN 'Ticket Entry'
						 WHEN CMT.ptcmt_type = 'STM' THEN 'Statement' WHEN CMT.ptcmt_type = 'ETC' THEN 'Energy Trac'
						 ELSE ptcmt_type END) COLLATE SQL_Latin1_General_CP1_CS_AS
		WHERE EM.intMessageId IS NULL
		--GROUP BY CMT.ptcmt_cus_no, CMT.ptcmt_type, CUS.intEntityId
	END


	if @Checking = 0
	begin
		update tblEMEntityMessage 
			set strMessage = dbo.fnEMBreakLine(strMessage, 80) 
				where strMessageType = 'Energy Trac' and intMessageId > @maxId
	end
END

