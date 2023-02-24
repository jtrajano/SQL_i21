CREATE PROCEDURE uspQMImportGardenMark
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#GARDENMARKS') IS NOT NULL DROP TABLE #GARDENMARKS	

	SELECT intImportLogId
		 , intImportGardenMarkId
		 , strGardenMark			= NULLIF(strGardenMark, '')
		 , strOrigin				= NULLIF(strOrigin, '')
		 , intOriginId				= CAST(NULL AS INT)
		 , strCountry				= NULLIF(strCountry, '')
		 , intCountryId				= CAST(NULL AS INT)
		 , strProducer				= NULLIF(strProducer, '')
		 , intProducerId			= CAST(NULL AS INT)
		 , strProductLine			= NULLIF(strProductLine, '')
		 , intProductLineId			= CAST(NULL AS INT)
		 , dtmCertifiedDate
		 , dtmExpiryDate
		 , ysnSuccess				= ISNULL(ysnSuccess, 0)
		 , strErrorMsg				= CAST(NULL AS NVARCHAR(200))
	INTO #GARDENMARKS
	FROM tblQMImportGardenMark
	WHERE intImportLogId = @intImportLogId
	  AND ysnSuccess = 1

	--VALIDATE EXISTING GARDEN MARK
	UPDATE GM
	SET strErrorMsg		= ISNULL(GM.strErrorMsg, '') + ' Garden Mark: ' + GM.strGardenMark + ' already exists.'
	FROM #GARDENMARKS GM
	INNER JOIN tblQMGardenMark GMM ON GM.strGardenMark = GMM.strGardenMark

	UPDATE GM
	SET strErrorMsg		= ISNULL(GM.strErrorMsg, '') + ' Garden Mark: ' + GM.strGardenMark + ' duplicate value.'
	FROM #GARDENMARKS GM
	INNER JOIN (
		SELECT strGardenMark
		FROM #GARDENMARKS 
		GROUP BY strGardenMark
		HAVING COUNT(1) > 1
	) DUP ON GM.strGardenMark = DUP.strGardenMark

	--VALIDATE ORIGIN
	UPDATE GM
	SET strErrorMsg		= ISNULL(GM.strErrorMsg, '') + CASE WHEN O.intCommodityAttributeId IS NULL THEN ' Origin: ' + GM.strOrigin + ' doesn''t exists.' ELSE '' END
	  , intOriginId		= O.intCommodityAttributeId
	FROM #GARDENMARKS GM
	LEFT JOIN tblICCommodityAttribute O ON GM.strOrigin = O.strDescription AND O.strType = 'Origin'
	WHERE GM.strOrigin IS NOT NULL

	--VALIDATE COUNTRY
	UPDATE GM
	SET strErrorMsg		= ISNULL(GM.strErrorMsg, '') + CASE WHEN C.intCountryID IS NULL THEN ' Country: ' + GM.strCountry + ' doesn''t exists.' ELSE '' END
	  , intCountryId	= C.intCountryID
	FROM #GARDENMARKS GM
	LEFT JOIN tblSMCountry C ON GM.strCountry = C.strCountry
	WHERE GM.strCountry IS NOT NULL

	--VALIDATE PRODUCER
	UPDATE GM
	SET strErrorMsg		= ISNULL(GM.strErrorMsg, '') + CASE WHEN E.intEntityId IS NULL THEN ' Producer: ' + GM.strProducer + ' doesn''t exists.' ELSE '' END
	  , intProducerId	= E.intEntityId
	FROM #GARDENMARKS GM
	OUTER APPLY (
		SELECT TOP 1 E.intEntityId 
		FROM tblEMEntity E 
		INNER JOIN tblEMEntityType ET ON E.intEntityId = ET.intEntityId AND ET.strType = 'Producer'
		WHERe GM.strProducer = E.strName
	) E 
	WHERE GM.strProducer IS NOT NULL

	--VALIDATE PRODUCER LINE
	UPDATE GM
	SET strErrorMsg			= ISNULL(GM.strErrorMsg, '') + CASE WHEN PL.intCommodityProductLineId IS NULL THEN ' Product Line: ' + GM.strProductLine + ' doesn''t exists.' ELSE '' END
	  , intProductLineId	= PL.intCommodityProductLineId
	FROM #GARDENMARKS GM
	LEFT JOIN tblICCommodityProductLine PL ON GM.strProductLine = PL.strDescription
	WHERE GM.strProductLine IS NOT NULL

	--VALIDATE EXPIRY DATE
	UPDATE GM
	SET strErrorMsg			= ISNULL(GM.strErrorMsg, '') + ' Expiry Date should be less than Certified Date.'
	FROM #GARDENMARKS GM
	WHERE GM.dtmCertifiedDate IS NOT NULL
	  AND GM.dtmExpiryDate IS NOT NULL
	  AND GM.dtmCertifiedDate > GM.dtmExpiryDate

	UPDATE #GARDENMARKS
	SET ysnSuccess = CASE WHEN LTRIM(RTRIM(strErrorMsg)) = '' THEN 1 ELSE 0 END

	UPDATE IGM
	SET ysnSuccess		= GM.ysnSuccess
	  , strLogResult	= CASE WHEN GM.ysnSuccess = 1 THEN 'Successfully Imported.' ELSE GM.strErrorMsg END
	FROM tblQMImportGardenMark IGM
	INNER JOIN #GARDENMARKS GM ON IGM.intImportGardenMarkId = GM.intImportGardenMarkId

	--INSERT TO MAIN TABLE
	INSERT INTO tblQMGardenMark (
		  strGardenMark
		, intOriginId
		, intCountryId
		, intProducerId
		, intProductLineId
		, dtmCertifiedDate
		, dtmExpiryDate
		, intConcurrencyId
	)
	SELECT strGardenMark		= GM.strGardenMark
		, intOriginId			= GM.intOriginId
		, intCountryId			= GM.intCountryId
		, intProducerId			= GM.intProducerId
		, intProductLineId		= GM.intProductLineId
		, dtmCertifiedDate		= GM.dtmCertifiedDate
		, dtmExpiryDate			= GM.dtmExpiryDate
		, intConcurrencyId
	FROM tblQMImportGardenMark IGM
	INNER JOIN #GARDENMARKS GM ON IGM.intImportGardenMarkId = GM.intImportGardenMarkId
	WHERE IGM.intImportLogId = @intImportLogId
	  AND GM.ysnSuccess = 1
      AND IGM.ysnSuccess = 1

	UPDATE IGM
	SET intGardenMarkId	= GM.intGardenMarkId
	FROM tblQMImportGardenMark IGM
	INNER JOIN tblQMGardenMark GM ON IGM.strGardenMark = GM.strGardenMark

	UPDATE tblQMImportGardenMark
	SET ysnSuccess = ISNULL(ysnSuccess, 0)
	WHERE intImportLogId = @intImportLogId

	--UPDATE LOG
	UPDATE IL
	SET intSuccessCount		= ISNULL(GM.intSuccessCount, 0)
	  , intFailedCount		= ISNULL(GM.intFailedCount, 0)
	FROM tblQMImportLog IL
	INNER JOIN (
		SELECT intImportLogId
			 , intSuccessCount	= SUM(CASE WHEN ysnSuccess = 1 THEN 1 ELSE 0 END)
			 , intFailedCount	= SUM(CASE WHEN ysnSuccess = 0 THEN 1 ELSE 0 END)
		FROM tblQMImportGardenMark
		GROUP BY intImportLogId
	) GM ON IL.intImportLogId = GM.intImportLogId
	WHERE IL.intImportLogId = @intImportLogId

	--AUDIT LOG
	DECLARE @auditLog AS BatchAuditLogParam

	INSERT INTO @auditLog (
		  [Id]
		, [Namespace]
		, [Action]
		, [Description]
		, [From]
		, [To]
		, [EntityId]
	)
	SELECT [Id]				= GM.intGardenMarkId
		, [Namespace]		= 'Quality.view.GardenMark'
		, [Action]			= 'Created'
		, [Description]		= 'Imported from CSV'
		, [From]			= NULL
		, [To]				= GM.strGardenMark
		, [EntityId]		= IL.intEntityId
	FROM tblQMImportGardenMark IGM
	INNER JOIN tblQMGardenMark GM ON IGM.intGardenMarkId = GM.intGardenMarkId
	INNER JOIN tblQMImportLog IL ON IGM.intImportLogId = IL.intImportLogId
	WHERE IGM.intImportLogId = @intImportLogId

	IF EXISTS (SELECT TOP 1 NULL FROM @auditLog)
		BEGIN 
			DECLARE @intUserId INT = NULL

			SELECT @intUserId = intEntityId
			FROM tblQMImportLog
			WHERE intImportLogId = @intImportLogId

			EXEC dbo.uspSMBatchAuditLog @AuditLogParam 	= @auditLog
									  , @EntityId		= @intUserId
		END

	IF OBJECT_ID('tempdb..#GARDENMARKS') IS NOT NULL DROP TABLE #GARDENMARKS

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH