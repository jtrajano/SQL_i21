CREATE PROCEDURE uspQMImportContractAllocation
    @intImportLogId INT
AS

BEGIN TRY
	BEGIN TRANSACTION

    -- Validate Foreign Key Fields
    UPDATE IMP
    SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage),charindex(',',reverse(MSG.strLogMessage))+1,len(MSG.strLogMessage)))
        ,ysnSuccess = 0
        ,ysnProcessed = 1
    FROM tblQMImportCatalogue IMP
    -- Contract Number
    LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = IMP.strContractNumber
    -- Contract Sequence
    LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND CD.intContractSeq = IMP.intContractItem
    -- Sample Status
    LEFT JOIN tblQMSampleStatus SAMPLE_STATUS ON SAMPLE_STATUS.strStatus = IMP.strSampleStatus
    -- Group Number
    LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strGroupNumber
    -- Format log message
    OUTER APPLY (
        SELECT strLogMessage = 
            CASE WHEN (CH.intContractHeaderId IS NULL) THEN 'CONTRACT NUMBER, ' ELSE '' END
            + CASE WHEN (CD.intContractDetailId IS NULL) THEN 'CONTRACT ITEM, ' ELSE '' END
            + CASE WHEN (SAMPLE_STATUS.intSampleStatusId IS NULL AND ISNULL(IMP.strSampleStatus, '') <> '') THEN 'SAMPLE STATUS, ' ELSE '' END
            + CASE WHEN (BOOK.intBookId IS NULL AND ISNULL(IMP.strGroupNumber, '') <> '') THEN 'GROUP NUMBER, ' ELSE '' END
    ) MSG
    WHERE IMP.intImportLogId = @intImportLogId
    AND IMP.ysnSuccess = 1
    AND (
        (CH.intContractHeaderId IS NULL)
        OR (CD.intContractDetailId IS NULL)
        OR (SAMPLE_STATUS.intSampleStatusId IS NULL AND ISNULL(IMP.strSampleStatus, '') <> '')
        OR (BOOK.intBookId IS NULL AND ISNULL(IMP.strGroupNumber, '') <> '')
    )
    -- End Validation   

    DECLARE
        @intImportCatalogueId INT
        ,@intSampleId INT
        ,@intContractHeaderId INT
        ,@intContractDetailId INT
        ,@intSampleStatusId INT
        ,@intBookId INT
        ,@dblCashPrice NUMERIC(18, 6)

    DECLARE @MFBatchTableType MFBatchTableType

    -- Loop through each valid import detail
    DECLARE @C AS CURSOR;
	SET @C = CURSOR FAST_FORWARD FOR
        SELECT
            intImportCatalogueId = IMP.intImportCatalogueId
            ,intSampleId = S.intSampleId
            ,intContractHeaderId = CH.intContractHeaderId
            ,intContractDetailId = CD.intContractDetailId
            ,intSampleStatusId = SAMPLE_STATUS.intSampleStatusId
            ,intBookId = BOOK.intBookId
            ,dblCashPrice = IMP.dblBoughtPrice
        FROM tblQMSample S
        INNER JOIN tblQMAuction A ON A.intSampleId = S.intSampleId
        INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
        INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = A.intCatalogueTypeId
        INNER JOIN (tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId)
            ON V.intEntityId = S.intEntityId
        INNER JOIN (
            tblQMImportCatalogue IMP
            -- Sale Year
            INNER JOIN tblQMSaleYear SY ON SY.strSaleYear = IMP.strSaleYear
            -- Contract Number
            LEFT JOIN tblCTContractHeader CH ON CH.strContractNumber = IMP.strContractNumber
            -- Contract Sequence
            LEFT JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId AND CD.intContractSeq = IMP.intContractItem
            -- Sample Status
            LEFT JOIN tblQMSampleStatus SAMPLE_STATUS ON SAMPLE_STATUS.strStatus = IMP.strSampleStatus
            -- Group Number
            LEFT JOIN tblCTBook BOOK ON BOOK.strBook = IMP.strGroupNumber
        ) ON S.strSaleYear = IMP.strSaleYear
            AND CL.strLocationName = IMP.strBuyingCenter
            AND S.intSaleNumber = IMP.intSaleNumber
            AND CT.strCatalogueType = IMP.strCatalogueType
            AND E.strName = IMP.strSupplier
            AND S.strRepresentLotNumber = IMP.strLotNumber
        WHERE IMP.intImportLogId = @intImportLogId
            AND IMP.ysnSuccess = 1

    OPEN @C
	FETCH NEXT FROM @C INTO
		@intImportCatalogueId
        ,@intSampleId
        ,@intContractHeaderId
        ,@intContractDetailId
        ,@intSampleStatusId
        ,@intBookId
        ,@dblCashPrice
	WHILE @@FETCH_STATUS = 0
	BEGIN
        -- Update Sample
        UPDATE S
        SET
            intConcurrencyId = S.intConcurrencyId + 1
            ,intContractHeaderId = @intContractHeaderId
            ,intContractDetailId = @intContractDetailId
            ,intSampleStatusId = @intSampleStatusId
            ,intBookId = @intBookId
        FROM tblQMSample S
        WHERE S.intSampleId = @intSampleId

        -- Update Contract Cash Price
        UPDATE CD
        SET
            intConcurrencyId = CD.intConcurrencyId + 1
            ,dblCashPrice = @dblCashPrice
        FROM tblCTContractDetail CD
        WHERE CD.intContractHeaderId = @intContractHeaderId
        AND CD.intContractDetailId = @intContractDetailId

        UPDATE tblQMImportCatalogue
        SET intSampleId = @intSampleId
        WHERE intImportCatalogueId = @intImportCatalogueId

        FETCH NEXT FROM @C INTO
            @intImportCatalogueId
            ,@intSampleId
            ,@intContractHeaderId
            ,@intContractDetailId
            ,@intSampleStatusId
            ,@intBookId
            ,@dblCashPrice
    END
    CLOSE @C
	DEALLOCATE @C

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
    ROLLBACK TRANSACTION

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH