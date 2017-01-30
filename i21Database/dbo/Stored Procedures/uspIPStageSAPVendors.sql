CREATE PROCEDURE [dbo].[uspIPStageSAPVendors]
	@strXml nvarchar(max)
AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
		
	DECLARE @idoc INT
	DECLARE @ErrMsg nvarchar(max)
	DECLARE @strEntityName NVARCHAR(100)
	DECLARE @intStageEntityId int

	Set @strXml= REPLACE(@strXml,'utf-8' COLLATE Latin1_General_CI_AS,'utf-16' COLLATE Latin1_General_CI_AS)  

	EXEC sp_xml_preparedocument @idoc OUTPUT
	,@strXml

	DECLARE @tblVendor TABLE (
		strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strAddress NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strCountry NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strZipCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		strPhone NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strTaxNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		strFLOId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		dtmCreated DATETIME NULL DEFAULT((getdate())),
		strCreatedUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

	DECLARE @tblVendorContact TABLE (
		[strFirstName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strLastName] NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		[strPhone] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	 )

	INSERT INTO @tblVendor (
		strName
		,strAddress
		,strAddress1
		,strCity
		,strCountry
		,strZipCode
		,strPhone
		,strAccountNo
		,strTaxNo
		,strFLOId
		,dtmCreated
		,strCreatedUserName
		)
	SELECT NAME1
		,STRAS
		,PFACH
		,ORT01
		,LAND1
		,PSTL2
		,TELF1
		,LIFNR
		,STCEG
		,KTOKK
		,ERDAT
		,ERNAM
	FROM OPENXML(@idoc, 'CREMAS06/IDOC/E1LFA1M', 2) WITH (
			 NAME1 NVARCHAR(100)
			,STRAS NVARCHAR(MAX)
			,PFACH NVARCHAR(MAX)
			,ORT01 NVARCHAR(MAX)
			,LAND1 NVARCHAR(MAX)
			,PSTL2 NVARCHAR(MAX)
			,TELF1 NVARCHAR(50)
			,LIFNR NVARCHAR(50)
			,STCEG NVARCHAR(50)
			,KTOKK NVARCHAR(100)
			,ERDAT DATETIME
			,ERNAM NVARCHAR(100)
			)

	If NOT Exists (Select 1 From @tblVendor)
		RaisError('Unable to process. Xml tag (CREMAS06/IDOC/E1LFA1M) not found.',16,1)

	Update @tblVendor Set strTerm=x.ZTERM,strCurrency=x.WAERS
		FROM OPENXML(@idoc, 'CREMAS06/IDOC/E1LFA1M/E1LFM1M', 2) WITH (
			 ZTERM NVARCHAR(100)
			,WAERS NVARCHAR(50)) x

	Insert Into @tblVendorContact(strFirstName,strLastName,strPhone)
		SELECT NAMEV
		,NAME1
		,TELF1
	FROM OPENXML(@idoc, 'CREMAS06/IDOC/E1LFA1M/E1KNVKM', 2) WITH (
			 NAMEV NVARCHAR(100)
			,NAME1 NVARCHAR(100)
			,TELF1 NVARCHAR(50)
	)

	Select @strEntityName=strName From @tblVendor

	Begin Tran

	--Add to Staging tables
	Insert into tblIPEntityStage(strName,strAddress,strAddress1,strCity,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,dtmCreated,strCreatedUserName,strEntityType,strCurrency,strTerm)
	Select strName,strAddress,strAddress1,strCity,strCountry,strZipCode,strPhone,strAccountNo,strTaxNo,strFLOId,dtmCreated,strCreatedUserName,'Vendor',strCurrency,strTerm
	From @tblVendor

	Select @intStageEntityId=SCOPE_IDENTITY()

	Insert Into tblIPEntityContactStage(intStageEntityId,strEntityName,strFirstName,strLastName,strPhone)
	Select @intStageEntityId,@strEntityName,strFirstName,strLastName,strPhone
	From @tblVendorContact

	Commit Tran

END TRY

BEGIN CATCH
	IF XACT_STATE() != 0
		AND @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	SET @ErrMsg = ERROR_MESSAGE()

	IF @idoc <> 0
		EXEC sp_xml_removedocument @idoc

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH