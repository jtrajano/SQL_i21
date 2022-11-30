CREATE PROCEDURE uspIPStageContractHeader_EK @strInfo1 NVARCHAR(MAX) = '' OUTPUT
	,@strInfo2 NVARCHAR(MAX) = '' OUTPUT
	,@intNoOfRowsAffected INT = 0 OUTPUT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX) = ''
		,@intRowNo INT
		,@strXml NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
	DECLARE @tblIPIDOCXMLStage TABLE (intIDOCXMLStageId INT)
	DECLARE @tblIPContractHeader TABLE (strContractNo NVARCHAR(50))

	INSERT INTO @tblIPIDOCXMLStage (intIDOCXMLStageId)
	SELECT intIDOCXMLStageId
	FROM tblIPIDOCXMLStage
	WHERE strType = 'Contract Header'
		AND intStatusId IS NULL

	SELECT @intRowNo = MIN(intIDOCXMLStageId)
	FROM @tblIPIDOCXMLStage

	IF @intRowNo IS NULL
	BEGIN
		RETURN
	END

	UPDATE S
	SET S.intStatusId = - 1
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId

	WHILE (ISNULL(@intRowNo, 0) > 0)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

			SELECT @strXml = NULL
				,@idoc = NULL
				,@intNoOfRowsAffected = 1

			SELECT @strXml = strXml
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			SET @strXml = REPLACE(@strXml, 'utf-8' COLLATE Latin1_General_CI_AS, 'utf-16' COLLATE Latin1_General_CI_AS)

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strXml

			DELETE
			FROM @tblIPContractHeader

			INSERT INTO tblIPContractHeaderStage (
				intDocNo
				,strSender
				,strContractNo
				,dtmContractDate
				,strVendorAccountNo
				,strLocation
				,strCommodity
				,strTermsCode
				,strIncoTerm
				,strIncoTermLocation
				,strSalesPerson
				,dblContractValue
				,strCurrency
				,dtmPeriodFrom
				,dtmPeriodTo
				,strStatus
				,strBuyingOrderNo
				)
			OUTPUT INSERTED.strContractNo
			INTO @tblIPContractHeader
			SELECT DocNo
				,Sender
				,ContractNo
				,ContractDate
				,VendorAccountNo
				,[Location]
				,Commodity
				,TermsCode
				,IncoTerm
				,IncoTermLocation
				,SalesPerson
				,ContractValue
				,Currency
				,PeriodFrom
				,PeriodTo
				,[Status]
				,BuyingOrderNo
			FROM OPENXML(@idoc, 'root/Header', 2) WITH (
					DocNo BIGINT '../DocNo'
					,Sender NVARCHAR(50) '../Sender'
					,ContractNo NVARCHAR(50)
					,ContractDate DATETIME
					,VendorAccountNo NVARCHAR(100)
					,[Location] NVARCHAR(50)
					,Commodity NVARCHAR(50)
					,TermsCode NVARCHAR(50)
					,IncoTerm NVARCHAR(100)
					,IncoTermLocation NVARCHAR(100)
					,SalesPerson NVARCHAR(100)
					,ContractValue NUMERIC(18, 6)
					,Currency NVARCHAR(40)
					,PeriodFrom DATETIME
					,PeriodTo DATETIME
					,[Status] NVARCHAR(50)
					,BuyingOrderNo NVARCHAR(50)
					)

			SELECT @strInfo1 = @strInfo1 + ISNULL(strContractNo, '') + ','
			FROM @tblIPContractHeader

			--Move to Archive
			INSERT INTO tblIPIDOCXMLArchive (
				strXml
				,strType
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPIDOCXMLError (
				strXml
				,strType
				,strMsg
				,dtmCreatedDate
				)
			SELECT strXml
				,strType
				,@ErrMsg
				,dtmCreatedDate
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo

			DELETE
			FROM tblIPIDOCXMLStage
			WHERE intIDOCXMLStageId = @intRowNo
		END CATCH

		SELECT @intRowNo = MIN(intIDOCXMLStageId)
		FROM @tblIPIDOCXMLStage
		WHERE intIDOCXMLStageId > @intRowNo
	END

	UPDATE S
	SET S.intStatusId = NULL
	FROM tblIPIDOCXMLStage S
	JOIN @tblIPIDOCXMLStage TS ON TS.intIDOCXMLStageId = S.intIDOCXMLStageId
	WHERE S.intStatusId = - 1

	IF (ISNULL(@strInfo1, '')) <> ''
		SELECT @strInfo1 = LEFT(@strInfo1, LEN(@strInfo1) - 1)

	IF @strFinalErrMsg <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
END TRY

BEGIN CATCH
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
